import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  Future<Directory> _resolveBaseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    // print('Documents dir: ${dir.path}');
    final baseDir = Directory('${dir.path}/atimelog2');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    return baseDir;
  }

  Future<File> _resolveFile(String relativePath) async {
    final baseDir = await _resolveBaseDir();
    return File('${baseDir.path}/$relativePath');
  }

  Future<Map<String, dynamic>?> readJson(String relativePath) async {
    final file = await _resolveFile(relativePath);
    if (!await file.exists()) {
      return null;
    }
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> writeJson(String relativePath, Map<String, dynamic> data) async {
    final file = await _resolveFile(relativePath);
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(data)}\n');
  }

  Future<void> deleteFile(String relativePath) async {
    final file = await _resolveFile(relativePath);
    if (!await file.exists()) {
      return;
    }
    await file.delete();
  }
}
