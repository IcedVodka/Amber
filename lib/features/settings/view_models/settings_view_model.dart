import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, AppSettings>(SettingsViewModel.new);

class SettingsViewModel extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  void updateTheme(AppThemeOption option) {
    final next = state.copyWith(themeOption: option);
    state = next;
    ref.read(settingsRepositoryProvider).save(next);
  }
}
