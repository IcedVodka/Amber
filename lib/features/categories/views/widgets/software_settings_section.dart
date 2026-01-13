import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class SoftwareSettingsSection extends StatelessWidget {
  const SoftwareSettingsSection({
    super.key,
    required this.selectedTheme,
    required this.onThemeChange,
  });

  final AppThemeOption selectedTheme;
  final ValueChanged<AppThemeOption> onThemeChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SoftwareSettingsHeader(),
            const SizedBox(height: 12),
            ThemeSelector(
              selectedTheme: selectedTheme,
              onChanged: onThemeChange,
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftwareSettingsHeader extends StatelessWidget {
  const _SoftwareSettingsHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.tune_outlined)),
      title: Text(
        '软件设置',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onChanged,
  });

  final AppThemeOption selectedTheme;
  final ValueChanged<AppThemeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputBorder = _buildInputBorder(colorScheme);

    return DropdownButtonFormField<AppThemeOption>(
      initialValue: selectedTheme,
      isExpanded: true,
      icon: const Icon(Icons.expand_more),
      decoration: _buildDecoration(colorScheme, inputBorder),
      dropdownColor: colorScheme.surface,
      items: _buildItems(),
      onChanged: (option) => onChanged(option!),
    );
  }

  List<DropdownMenuItem<AppThemeOption>> _buildItems() {
    return AppThemeOption.values
        .map(
          (option) => DropdownMenuItem<AppThemeOption>(
            value: option,
            child: _ThemeOptionLabel(option: option),
          ),
        )
        .toList(growable: false);
  }

  InputDecoration _buildDecoration(
    ColorScheme colorScheme,
    OutlineInputBorder inputBorder,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  OutlineInputBorder _buildInputBorder(ColorScheme colorScheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
  }
}

class _ThemeOptionLabel extends StatelessWidget {
  const _ThemeOptionLabel({required this.option});

  final AppThemeOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final subtitleStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        _ThemeColorDot(color: option.previewColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: option.label,
              children: [
                TextSpan(
                  text: ' (${option.subtitle})',
                  style: subtitleStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeColorDot extends StatelessWidget {
  const _ThemeColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 5,
      backgroundColor: color,
    );
  }
}
