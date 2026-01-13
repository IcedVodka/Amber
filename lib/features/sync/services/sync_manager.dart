import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../../core/services/sync_meta_service.dart';
import '../models/sync_config.dart';

class SyncManager {
  SyncManager({SyncMetaService? metaService})
      : _metaService = metaService ?? SyncMetaService();

  final SyncMetaService _metaService;
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<String> get statusStream => _statusController.stream;

  void dispose() {
    _statusController.close();
  }

  Future<void> testConnection(SyncConfig config) async {
    final client = _createClient(config);
    await client.ping();
  }

  Future<void> hotSync(SyncConfig config) async {
    final client = _createClient(config);
    _emit('正在连接云端...');
    await client.ping();
    await _ensureBaseFolders(client, config);

    final now = DateTime.now();
    final currentMonth = _formatMonth(now);
    final previousMonth = _formatMonth(DateTime(now.year, now.month - 1, 1));
    final months = <String>{currentMonth, previousMonth};

    await _processFolder(
      client: client,
      config: config,
      folderKey: 'current',
      folderPath: 'current',
    );
    for (final month in months) {
      await _processFolder(
        client: client,
        config: config,
        folderKey: month,
        folderPath: 'data/$month',
      );
    }
    _emit('同步完成');
  }

  Future<void> coldSync(SyncConfig config) async {
    final client = _createClient(config);
    _emit('正在连接云端...');
    await client.ping();
    await _ensureBaseFolders(client, config);

    await _processFolder(
      client: client,
      config: config,
      folderKey: 'current',
      folderPath: 'current',
    );

    final months = await _collectAllMonths(client, config);
    for (final month in months) {
      await _processFolder(
        client: client,
        config: config,
        folderKey: month,
        folderPath: 'data/$month',
      );
    }
    _emit('同步完成');
  }

  Future<List<String>> _collectAllMonths(
    webdav.Client client,
    SyncConfig config,
  ) async {
    final months = <String>{};
    months.addAll(await _listLocalMonths());
    months.addAll(await _listRemoteMonths(client, config));
    final list = months.toList()..sort();
    return list;
  }

  Future<void> _processFolder({
    required webdav.Client client,
    required SyncConfig config,
    required String folderKey,
    required String folderPath,
  }) async {
    _emit('正在检查 $folderKey...');
    final remoteFolderPath = _remotePath(config, folderPath);
    await client.mkdirAll(remoteFolderPath);

    final isFreshMeta = !await _metaService.hasMeta(folderKey);
    final meta = await _metaService.readMeta(folderKey);
    final remoteMap = await _listRemoteFiles(client, remoteFolderPath);
    final localMap = await _listLocalFiles(folderKey, isFreshMeta: isFreshMeta);

    final allNames = <String>{
      ...remoteMap.keys,
      ...localMap.keys,
    };

    final updatedRemote = <String>{};
    var needsRefresh = false;

    for (final name in allNames) {
      final remote = remoteMap[name];
      final local = localMap[name];
      final cachedEtag = meta[name];

      if (remote == null && local != null) {
        _emit('正在上传: $name');
        await _uploadLocalFile(client, config, folderPath, local);
        updatedRemote.add(name);
        needsRefresh = true;
        continue;
      }

      if (remote != null && local == null) {
        _emit('正在下载: $name');
        await _downloadRemoteFile(client, remote, folderPath);
        meta[name] = remote.eTag;
        continue;
      }

      if (remote == null || local == null) {
        continue;
      }

      if (cachedEtag != null && remote.eTag != null) {
        if (cachedEtag == remote.eTag) {
          continue;
        }
      }

      _emit('正在对比 $name...');
      final tempFile = await _downloadTempFile(client, remote);
      final localModified = local.lastModified;
      final remoteModified = remote.lastModified ?? DateTime(1970, 1, 1);

      if (remoteModified.isAfter(localModified)) {
        _emit('下载更新: $name');
        await _overwriteLocal(tempFile, local.file);
        meta[name] = remote.eTag;
      } else {
        _emit('上传修改: $name');
        await _uploadLocalFile(client, config, folderPath, local);
        updatedRemote.add(name);
        needsRefresh = true;
      }
    }

    if (needsRefresh) {
      final refreshed = await _listRemoteFiles(client, remoteFolderPath);
      for (final name in updatedRemote) {
        meta[name] = refreshed[name]?.eTag;
      }
    }

    await _metaService.writeMeta(folderKey, meta);
  }

  Future<Map<String, _RemoteFileInfo>> _listRemoteFiles(
    webdav.Client client,
    String remoteFolderPath,
  ) async {
    final items = await client.readDir(remoteFolderPath);
    final map = <String, _RemoteFileInfo>{};
    for (final item in items) {
      if (item.isDir == true) {
        continue;
      }
      final name = item.name ?? '';
      if (name.isEmpty) {
        continue;
      }
      final eTag = item.eTag == null || item.eTag!.isEmpty ? null : item.eTag;
      map[name] = _RemoteFileInfo(
        name: name,
        path: item.path ?? '$remoteFolderPath/$name',
        eTag: eTag,
        lastModified: item.mTime,
      );
    }
    return map;
  }

  Future<Map<String, _LocalFileInfo>> _listLocalFiles(
    String folderKey, {
    required bool isFreshMeta,
  }) async {
    final baseDir = await _resolveBaseDir();
    final folderPath = folderKey == 'current' ? 'current' : 'data/$folderKey';
    final dir = Directory('${baseDir.path}/$folderPath');
    if (!await dir.exists()) {
      return {};
    }
    final entities = await dir.list().toList();
    final map = <String, _LocalFileInfo>{};
    for (final entity in entities) {
      if (entity is! File) {
        continue;
      }
      final name = _basename(entity.path);
      if (name.isEmpty) {
        continue;
      }
      final fallback = await entity.lastModified();
      final lastModified = isFreshMeta && folderKey == 'current'
          ? DateTime(2020, 1, 1)
          : await _resolveLocalModified(entity, fallback);
      map[name] = _LocalFileInfo(
        name: name,
        relativePath: '$folderPath/$name',
        file: entity,
        lastModified: lastModified,
      );
    }
    return map;
  }

  Future<DateTime> _resolveLocalModified(File file, DateTime fallback) async {
    final content = await file.readAsString();
    final data = jsonDecode(content);
    if (data is Map<String, dynamic>) {
      final raw = data['lastModified'];
      if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      if (raw is String) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  Future<List<String>> _listLocalMonths() async {
    final baseDir = await _resolveBaseDir();
    final dataDir = Directory('${baseDir.path}/data');
    if (!await dataDir.exists()) {
      return [];
    }
    final entities = await dataDir.list().toList();
    final months = <String>[];
    for (final entity in entities) {
      if (entity is Directory) {
        final name = _basename(entity.path);
        if (name.isNotEmpty) {
          months.add(name);
        }
      }
    }
    return months;
  }

  Future<List<String>> _listRemoteMonths(
    webdav.Client client,
    SyncConfig config,
  ) async {
    final dataPath = _remotePath(config, 'data');
    await client.mkdirAll(dataPath);
    final items = await client.readDir(dataPath);
    final months = <String>[];
    for (final item in items) {
      if (item.isDir != true) {
        continue;
      }
      final name = item.name ?? '';
      if (name.isNotEmpty && name != '/') {
        months.add(name);
      }
    }
    return months;
  }

  Future<void> _downloadRemoteFile(
    webdav.Client client,
    _RemoteFileInfo remote,
    String folderPath,
  ) async {
    final baseDir = await _resolveBaseDir();
    final localFile = File('${baseDir.path}/$folderPath/${remote.name}');
    await localFile.parent.create(recursive: true);
    await client.read2File(remote.path, localFile.path);
  }

  Future<File> _downloadTempFile(
    webdav.Client client,
    _RemoteFileInfo remote,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('atimelog2_sync');
    final tempFile = File('${tempDir.path}/${remote.name}');
    await client.read2File(remote.path, tempFile.path);
    return tempFile;
  }

  Future<void> _overwriteLocal(File source, File target) async {
    await target.parent.create(recursive: true);
    await source.copy(target.path);
  }

  Future<void> _uploadLocalFile(
    webdav.Client client,
    SyncConfig config,
    String folderPath,
    _LocalFileInfo local,
  ) async {
    final remotePath = _remotePath(config, '$folderPath/${local.name}');
    await client.writeFromFile(local.file.path, remotePath);
  }

  Future<void> _ensureBaseFolders(
    webdav.Client client,
    SyncConfig config,
  ) async {
    final root = _targetRoot(config);
    await client.mkdirAll(root);
    await client.mkdirAll('$root/current');
    await client.mkdirAll('$root/data');
  }

  String _targetRoot(SyncConfig config) {
    final trimmed = config.targetFolder.trim();
    return trimmed.isEmpty ? 'AtimeLog2' : trimmed;
  }

  String _remotePath(SyncConfig config, String relative) {
    final root = _targetRoot(config);
    if (relative.isEmpty) {
      return root;
    }
    return '$root/$relative';
  }

  webdav.Client _createClient(SyncConfig config) {
    final client = webdav.newClient(
      config.webDavUrl,
      user: config.username,
      password: config.password,
    );
    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(8000);
    client.setReceiveTimeout(8000);
    client.setSendTimeout(8000);
    return client;
  }

  Future<Directory> _resolveBaseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final baseDir = Directory('${dir.path}/atimelog2');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    return baseDir;
  }

  String _formatMonth(DateTime date) {
    return '${date.year}-${_two(date.month)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    if (index == -1) {
      return normalized;
    }
    return normalized.substring(index + 1);
  }

  void _emit(String status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}

class _RemoteFileInfo {
  const _RemoteFileInfo({
    required this.name,
    required this.path,
    required this.eTag,
    required this.lastModified,
  });

  final String name;
  final String path;
  final String? eTag;
  final DateTime? lastModified;
}

class _LocalFileInfo {
  const _LocalFileInfo({
    required this.name,
    required this.relativePath,
    required this.file,
    required this.lastModified,
  });

  final String name;
  final String relativePath;
  final File file;
  final DateTime lastModified;
}
