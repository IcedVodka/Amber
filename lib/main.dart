import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/repositories/settings_repository.dart';
import 'features/settings/view_models/settings_view_model.dart';
import 'features/sync/repositories/sync_config_repository.dart';
import 'features/sync/view_models/sync_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(preferences: preferences),
        ),
        syncConfigRepositoryProvider.overrideWithValue(
          SyncConfigRepository(preferences: preferences),
        ),
      ],
      child: const AtimeLogApp(),
    ),
  );
}
