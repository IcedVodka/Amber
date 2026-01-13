import 'package:shared_preferences/shared_preferences.dart';

import '../models/sync_config.dart';

class SyncConfigRepository {
  SyncConfigRepository({required SharedPreferences preferences})
      : _preferences = preferences;

  static const _webDavUrlKey = 'sync.webdav_url';
  static const _usernameKey = 'sync.username';
  static const _targetFolderKey = 'sync.target_folder';
  static const _autoHotSyncKey = 'sync.auto_hot_sync';
  static const _autoSyncIntervalKey = 'sync.auto_sync_interval';
  static const _lastHotSyncAtKey = 'sync.last_hot_sync_at';
  static const _passwordKey = 'sync.password';

  final SharedPreferences _preferences;

  Future<SyncConfig> load() async {
    final password = _preferences.getString(_passwordKey) ?? '';
    final map = <String, Object?>{
      'webDavUrl': _preferences.getString(_webDavUrlKey) ?? '',
      'username': _preferences.getString(_usernameKey) ?? '',
      'targetFolder': _preferences.getString(_targetFolderKey) ?? 'AtimeLog2',
      'autoHotSync': _preferences.getBool(_autoHotSyncKey) ?? false,
      'autoSyncInterval': _preferences.getInt(_autoSyncIntervalKey) ?? 10,
      'lastHotSyncAt': _preferences.getInt(_lastHotSyncAtKey),
    };
    return SyncConfig.fromStorageMap(map, password: password);
  }

  Future<void> save(SyncConfig config) async {
    await _preferences.setString(_webDavUrlKey, config.webDavUrl);
    await _preferences.setString(_usernameKey, config.username);
    await _preferences.setString(_targetFolderKey, config.targetFolder);
    await _preferences.setBool(_autoHotSyncKey, config.autoHotSync);
    await _preferences.setInt(_autoSyncIntervalKey, config.autoSyncInterval);
    if (config.lastHotSyncAt == null) {
      await _preferences.remove(_lastHotSyncAtKey);
    } else {
      await _preferences.setInt(
        _lastHotSyncAtKey,
        config.lastHotSyncAt!.millisecondsSinceEpoch,
      );
    }
    if (config.password.isEmpty) {
      await _preferences.remove(_passwordKey);
    } else {
      await _preferences.setString(_passwordKey, config.password);
    }
  }
}
