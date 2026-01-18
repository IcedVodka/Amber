import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_session.dart';

class SessionRepository {
  SessionRepository({
    SharedPreferences? preferences,
  }) : _preferences = preferences;

  static const String _sessionKey = 'activity.session';

  final SharedPreferences? _preferences;

  Future<TimerSession?> load() async {
    final preferences = _preferences;
    final raw = preferences?.getString(_sessionKey);
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return TimerSession.fromJson(data);
    }
    return null;
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
  }
}
