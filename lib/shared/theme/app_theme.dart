import 'package:flutter/material.dart';

enum AppThemeOption {
  minimalist,
  darkFocus,
  softNature,
}

extension AppThemeOptionX on AppThemeOption {
  String get label {
    switch (this) {
      case AppThemeOption.minimalist:
        return '极简主义';
      case AppThemeOption.darkFocus:
        return '暗夜专注';
      case AppThemeOption.softNature:
        return '柔和自然';
    }
  }

  String get subtitle {
    switch (this) {
      case AppThemeOption.minimalist:
        return 'Minimalist';
      case AppThemeOption.darkFocus:
        return 'Dark Focus';
      case AppThemeOption.softNature:
        return 'Soft Nature';
    }
  }

  Color get previewColor {
    switch (this) {
      case AppThemeOption.minimalist:
        return const Color(0xFF5A6CFF);
      case AppThemeOption.darkFocus:
        return const Color(0xFF1AC98B);
      case AppThemeOption.softNature:
        return const Color(0xFF7B9A3C);
    }
  }

  bool get isDark => this == AppThemeOption.darkFocus;

  ThemeData get themeData {
    switch (this) {
      case AppThemeOption.minimalist:
        return _buildTheme(
          seedColor: const Color(0xFF5A6CFF),
          background: const Color(0xFFF6F7F9),
          surface: const Color(0xFFFFFFFF),
          brightness: Brightness.light,
        );
      case AppThemeOption.darkFocus:
        return _buildTheme(
          seedColor: const Color(0xFF1AC98B),
          background: const Color(0xFF0D0F12),
          surface: const Color(0xFF1A1D21),
          brightness: Brightness.dark,
        );
      case AppThemeOption.softNature:
        return _buildTheme(
          seedColor: const Color(0xFF7B9A3C),
          background: const Color(0xFFF6F1E6),
          surface: const Color(0xFFF1EBDD),
          brightness: Brightness.light,
        );
    }
  }
}

ThemeData _buildTheme({
  required Color seedColor,
  required Color background,
  required Color surface,
  required Brightness brightness,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  ).copyWith(
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    fontFamilyFallback: const [
      // Windows: 微软雅黑
      'Microsoft YaHei',
      // Linux: 文泉驿 
      'WenQuanYi Micro Hei',
      'Droid Sans Fallback',
      'Noto Sans CJK SC', 
      'sans-serif',
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: colorScheme.primary.withOpacity(0.12),
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerColor: colorScheme.outlineVariant,
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
  );
}
