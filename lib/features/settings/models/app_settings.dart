import '../../../shared/theme/app_theme.dart';

class AppSettings {
  const AppSettings({required this.themeOption});

  final AppThemeOption themeOption;

  AppSettings copyWith({AppThemeOption? themeOption}) {
    return AppSettings(
      themeOption: themeOption ?? this.themeOption,
    );
  }

  static const AppSettings defaults = AppSettings(
    themeOption: AppThemeOption.minimalist,
  );
}
