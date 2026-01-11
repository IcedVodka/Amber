import 'package:flutter/material.dart';

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
  });

  final String name;
  final CategoryIcon icon;
  final CategoryColorOption color;
  final bool enabled;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<bool> onEnabledChanged;

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

class ColorPaletteItem {
  const ColorPaletteItem({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    required this.items,
    this.rows,
  });

  final List<ColorPaletteItem> items;
  final int? rows;

  @override
  Widget build(BuildContext context) {
    final rowCount = rows;
    if (rowCount == null || rowCount <= 1) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final item in items)
            ColorDot(
              color: item.color,
              label: item.label,
              selected: item.selected,
              onTap: item.onTap,
            ),
        ],
      );
    }

    final itemsPerRow = (items.length / rowCount).ceil();
    final rowWidgets = <Widget>[];
    for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final start = rowIndex * itemsPerRow;
      if (start >= items.length) {
        break;
      }
      var end = start + itemsPerRow;
      if (end > items.length) {
        end = items.length;
      }
      rowWidgets.add(
        _ColorPaletteRow(items: items.sublist(start, end)),
      );
      if (rowIndex < rowCount - 1 && end < items.length) {
        rowWidgets.add(const SizedBox(height: 12));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowWidgets,
    );
  }
}

class _ColorPaletteRow extends StatelessWidget {
  const _ColorPaletteRow({required this.items});

  final List<ColorPaletteItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(width: 12));
      }
      final item = items[i];
      children.add(
        ColorDot(
          color: item.color,
          label: item.label,
          selected: item.selected,
          onTap: item.onTap,
        ),
      );
    }
    return children;
  }
}

class ColorDot extends StatelessWidget {
  const ColorDot({
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected ? colorScheme.primary : colorScheme.outline;
    final iconColor = colorScheme.onPrimary;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ColorDotBody(
          color: color,
          borderColor: borderColor,
          iconColor: iconColor,
          selected: selected,
        ),
      ),
    );
  }
}

class ColorDotBody extends StatelessWidget {
  const ColorDotBody({
    super.key,
    required this.color,
    required this.borderColor,
    required this.iconColor,
    required this.selected,
  });

  final Color color;
  final Color borderColor;
  final Color iconColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 20, color: iconColor)
          : null,
    );
  }
}

class IconGroupSelector extends StatelessWidget {
  const IconGroupSelector({
    super.key,
    required this.groups,
    required this.selected,
    required this.onChanged,
  });

  final List<CategoryIconGroup> groups;
  final CategoryIconGroup selected;
  final ValueChanged<CategoryIconGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final group in groups)
          ChoiceChip(
            label: Text(group.label),
            selected: group == selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(group),
          ),
      ],
    );
  }
}

class IconGrid extends StatelessWidget {
  const IconGrid({
    super.key,
    required this.options,
    required this.selectedCode,
    required this.onChanged,
  });

  final List<CategoryIcon> options;
  final String selectedCode;
  final ValueChanged<CategoryIcon> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 64,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        return IconGridTile(
          option: option,
          selected: option.code == selectedCode,
          onTap: () => onChanged(option),
        );
      },
    );
  }
}

class IconGridTile extends StatelessWidget {
  const IconGridTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryIcon option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        selected ? colorScheme.primaryContainer : colorScheme.surfaceVariant;
    final border = selected ? colorScheme.primary : colorScheme.outlineVariant;
    final iconColor =
        selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Card(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: IconTileContent(
          label: option.label,
          icon: option.icon,
          color: iconColor,
        ),
      ),
    );
  }
}

class IconTileContent extends StatelessWidget {
  const IconTileContent({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color),
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
