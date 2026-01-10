import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/settings_view_model.dart';
import 'widgets/theme_selector.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            '选择 UI 风格',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ThemeSelector(
            selectedTheme: settings.themeOption,
            onChanged: (option) {
              if (option == null) {
                return;
              }
              ref.read(settingsViewModelProvider.notifier).updateTheme(option);
            },
          ),
        ],
      ),
    );
  }
}
