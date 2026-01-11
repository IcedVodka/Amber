import 'dart:io';

Future<void> main(List<String> args) async {
  final defaultDir = Directory('lib/features/categories');
  final sourceDir = args.isNotEmpty ? Directory(args.first) : defaultDir;

  if (!sourceDir.existsSync()) {
    stderr.writeln('源目录不存在：${sourceDir.path}');
    exit(1);
  }
  if (!sourceDir.existsSync()) {
    stderr.writeln('源目录不存在：${sourceDir.path}');
    exit(1);
  }

  final tmpDir = Directory('tmp');
  if (!tmpDir.existsSync()) {
    tmpDir.createSync(recursive: true);
  }

  for (final entity in tmpDir.listSync()) {
    entity.deleteSync(recursive: true);
  }

  final dartFiles = <File>[];
  for (final entity in sourceDir.listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }

  for (final file in dartFiles) {
    final fileName = file.uri.pathSegments.last;
    final target = File('${tmpDir.path}/$fileName');
    await file.copy(target.path);
  }

  stdout.writeln('已将 ${dartFiles.length} 个 Dart 文件复制到 tmp/');
}
