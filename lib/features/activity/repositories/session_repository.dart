import '../../../core/services/file_service.dart';
import '../models/timer_session.dart';

class SessionRepository {
  SessionRepository(this._fileService);

  final FileService _fileService;

  static const String _filePath = 'current/session.json';

  Future<TimerSession?> load() async {
    final data = await _fileService.readJson(_filePath);
    if (data == null) {
      return null;
    }
    return TimerSession.fromJson(data);
  }

  Future<void> save(TimerSession session) async {
    await _fileService.writeJson(_filePath, session.toJson());
  }

  Future<void> clear() async {
    await _fileService.deleteFile(_filePath);
  }
}
