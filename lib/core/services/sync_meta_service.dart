import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SyncMetaService {
  Future<Directory> _resolveMetaDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final baseDir = Directory('${dir.path}/Amber');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    final metaDir = Directory('${baseDir.path}/meta');
    if (!await metaDir.exists()) {
      await metaDir.create(recursive: true);
    }
    return metaDir;
  }

  Future<File> _resolveMetaFile(String folderKey) async {
    final metaDir = await _resolveMetaDir();
    return File('${metaDir.path}/sync_$folderKey.json');
  }

  Future<bool> hasMeta(String folderKey) async {
    final file = await _resolveMetaFile(folderKey);
    return file.exists();
  }

  Future<Map<String, String?>> readMeta(String folderKey) async {
    final file = await _resolveMetaFile(folderKey);
    if (!await file.exists()) {
      return {};
    }
    final content = await file.readAsString();
    final raw = jsonDecode(content) as Map<String, dynamic>;
    return raw.map((key, value) => MapEntry(key, value as String?));
  }

  Future<void> writeMeta(String folderKey, Map<String, String?> data) async {
    final file = await _resolveMetaFile(folderKey);
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(data)}\n');
  }

  Future<void> markDirty(String relativePath) async {
    final entry = _parseMetaEntry(relativePath);
    if (entry == null) {
      return;
    }
    final meta = await readMeta(entry.folderKey);
    meta[entry.fileName] = null;
    await writeMeta(entry.folderKey, meta);
  }

  _MetaEntry? _parseMetaEntry(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    final segments = normalized.split('/');
    if (segments.length < 2) {
      return null;
    }
    if (segments.first == 'current') {
      return _MetaEntry('current', segments.last);
    }
    if (segments.first == 'data' && segments.length >= 3) {
      return _MetaEntry(segments[1], segments.last);
    }
    return null;
  }
}

class _MetaEntry {
  const _MetaEntry(this.folderKey, this.fileName);

  final String folderKey;
  final String fileName;
}
