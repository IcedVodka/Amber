import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

final appThemeProvider = StateProvider<AppThemeOption>((ref) {
  return AppThemeOption.minimalist;
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(appThemeProvider);
  return theme.themeData;
});
