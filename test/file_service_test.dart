import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:atimelog2/core/services/file_service.dart';

void main() {
  late Directory tempDir;
  late PathProviderPlatform originalPlatform;

  setUp(() async {
    originalPlatform = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('file_service_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('writeJson and readJson round trip with nested file', () async {
    final service = FileService();
    const relativePath = 'nested/example.json';
    final payload = {'hello': 'atimelog', 'count': 1};

    await service.writeJson(relativePath, payload);

    final jsonFile = File('${tempDir.path}/atimelog2/$relativePath');
    expect(await jsonFile.exists(), isTrue);
    expect(
      jsonDecode(await jsonFile.readAsString()),
      equals(payload),
    );

    final loaded = await service.readJson(relativePath);
    expect(loaded, equals(payload));

    final missing = await service.readJson('does/not/exist.json');
    expect(missing, isNull);
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.directory);

  final Directory directory;

  @override
  Future<Directory?> getApplicationDocumentsDirectory() async => directory;

  @override
  Future<String?> getApplicationDocumentsPath() async => directory.path;
}
