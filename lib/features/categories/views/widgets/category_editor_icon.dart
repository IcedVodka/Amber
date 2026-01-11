import 'package:flutter/material.dart';

import '../../models/category_icons.dart';

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
