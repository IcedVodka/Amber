import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({AppSettings? initial}) {
    _settings = initial ?? AppSettings.defaults;
  }

  late AppSettings _settings;

  AppSettings load() => _settings;

  void save(AppSettings settings) {
    _settings = settings;
  }
}
