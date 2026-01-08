import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/config/app_config.dart';
import 'src/shared/routes/app_router.dart';
import 'src/shared/theme/app_theme.dart';
import 'src/shared/theme/theme_controller.dart';

class AtimeLogApp extends ConsumerWidget {
  const AtimeLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final themeData = ref.watch(themeDataProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      darkTheme: themeData,
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
