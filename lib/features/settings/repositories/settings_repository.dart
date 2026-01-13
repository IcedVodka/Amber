import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({
    SharedPreferences? preferences,
    AppSettings? initial,
  }) : _preferences = preferences {
    _settings = initial ?? _loadFromPreferences() ?? AppSettings.defaults;
  }

  static const _themeOptionKey = 'settings.theme_option';

  final SharedPreferences? _preferences;
  late AppSettings _settings;

  AppSettings load() => _settings;

  void save(AppSettings settings) {
    _settings = settings;
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    unawaited(
      preferences.setString(_themeOptionKey, settings.themeOption.name),
    );
  }

  AppSettings? _loadFromPreferences() {
    final preferences = _preferences;
    if (preferences == null) {
      return null;
    }
    final storedValue = preferences.getString(_themeOptionKey);
    if (storedValue == null) {
      return null;
    }
    final option = AppThemeOption.values.firstWhere(
      (value) => value.name == storedValue,
      orElse: () => AppThemeOption.minimalist,
    );
    return AppSettings(themeOption: option);
  }
}
