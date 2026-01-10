import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'features/settings/view_models/settings_view_model.dart';
import 'shared/routes/app_router.dart';
import 'shared/theme/app_theme.dart';

class AtimeLogApp extends ConsumerWidget {
  const AtimeLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final themeOption = settings.themeOption;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: themeOption.themeData,
      darkTheme: themeOption.themeData,
      themeMode: themeOption.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
