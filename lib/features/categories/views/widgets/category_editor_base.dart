import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/category_colors.dart';
import '../../models/category_icons.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(child: Text(title, style: style)),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class EditorBody extends StatelessWidget {
  const EditorBody({
    super.key,
    required this.bottomInset,
    required this.children,
  });

  final double bottomInset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class EditorNameRow extends StatelessWidget {
  const EditorNameRow({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  final String name;
  final CategoryIcon icon;
  final CategoryColorOption color;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.color,
          radius: 26,
          child: Icon(icon.icon, color: colorScheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: name,
            decoration: const InputDecoration(
              labelText: '活动名称',
              border: UnderlineInputBorder(),
            ),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class EditorNameHeader extends StatelessWidget {
  const EditorNameHeader({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onNameChanged,
    required this.onEnabledChanged,
    required this.defaultWeight,
    required this.onDefaultWeightChanged,
  });

  final String name;
  final CategoryIcon icon;
  final CategoryColorOption color;
  final bool enabled;
  final double defaultWeight;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onDefaultWeightChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: EditorNameRow(
            name: name,
            icon: icon,
            color: color,
            onChanged: onNameChanged,
          ),
        ),
        const SizedBox(width: 12),
        WeightInputField(
          value: defaultWeight,
          onChanged: onDefaultWeightChanged,
        ),
        const SizedBox(width: 12),
        EnabledSwitch(
          value: enabled,
          onChanged: onEnabledChanged,
        ),
      ],
    );
  }
}

class EnabledSwitch extends StatelessWidget {
  const EnabledSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('启用分类', style: labelStyle),
        const SizedBox(height: 4),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class WeightInputField extends StatelessWidget {
  const WeightInputField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 96,
      child: TextFormField(
        initialValue: _formatWeight(value),
        decoration: const InputDecoration(
          labelText: '权重',
          hintText: '0-1.0',
          border: UnderlineInputBorder(),
        ),
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_weightInputFormatter],
        textAlign: TextAlign.center,
        onChanged: onChanged,
      ),
    );
  }
}

final TextInputFormatter _weightInputFormatter =
    TextInputFormatter.withFunction((oldValue, newValue) {
  final text = newValue.text;
  if (text.isEmpty) {
    return newValue;
  }
  final parsed = double.tryParse(text);
  if (parsed == null) {
    return oldValue;
  }
  if (parsed < 0 || parsed > 1.0) {
    return oldValue;
  }
  return newValue;
});

String _formatWeight(double value) {
  return value.toString();
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class EditorActions extends StatelessWidget {
  const EditorActions({
    super.key,
    required this.confirmLabel,
    required this.onSubmit,
    this.onDelete,
  });

  final String confirmLabel;
  final Future<void> Function() onSubmit;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      Expanded(
        child: FilledButton(
          onPressed: () => onSubmit(),
          child: Text(confirmLabel),
        ),
      ),
    ];

    if (onDelete != null) {
      actions.insert(
        0,
        Expanded(
          child: OutlinedButton(
            onPressed: () => onDelete?.call(),
            child: const Text('删除'),
          ),
        ),
      );
    }

    return Row(
      children: [
        actions.first,
        if (actions.length > 1) const SizedBox(width: 12),
        if (actions.length > 1) actions.last,
      ],
    );
  }
}
