import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/file_service.dart';
import '../models/timer_session.dart';

class SessionRepository {
  SessionRepository({
    SharedPreferences? preferences,
    FileService? fileService,
  })  : _preferences = preferences,
        _fileService = fileService;

  static const String _sessionKey = 'activity.session';
  static const String _legacyPath = 'current/session.json';

  final SharedPreferences? _preferences;
  final FileService? _fileService;

  Future<TimerSession?> load() async {
    final preferences = _preferences;
    final raw = preferences?.getString(_sessionKey);
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return TimerSession.fromJson(data);
    }
    final fileService = _fileService;
    if (fileService == null) {
      return null;
    }
    final legacy = await fileService.readJson(_legacyPath);
    if (legacy == null) {
      return null;
    }
    final session = TimerSession.fromJson(legacy);
    if (preferences != null) {
      await save(session);
      await fileService.deleteFile(_legacyPath);
    }
    return session;
  }

  Future<void> save(TimerSession session) async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    final payload = jsonEncode(session.toJson());
    await preferences.setString(_sessionKey, payload);
  }

  Future<void> clear() async {
    final preferences = _preferences;
    if (preferences != null) {
      await preferences.remove(_sessionKey);
    }
    final fileService = _fileService;
    if (fileService != null) {
      await fileService.deleteFile(_legacyPath);
    }
  }
}
