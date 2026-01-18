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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final spacing = isCompact ? 4.0 : 6.0;
        final labelStyle = _labelStyle(context, isCompact);
        final chips = <Widget>[];
        for (var i = 0; i < groups.length; i++) {
          if (i > 0) {
            chips.add(SizedBox(width: spacing));
          }
          final group = groups[i];
          chips.add(
            Expanded(
              child: ChoiceChip(
                label: Text(group.label, textAlign: TextAlign.center),
                labelStyle: labelStyle,
                selected: group == selected,
                showCheckmark: false,
                padding: EdgeInsets.zero,
                labelPadding:
                    EdgeInsets.symmetric(horizontal: isCompact ? 4 : 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity:
                    isCompact ? VisualDensity.compact : VisualDensity.standard,
                onSelected: (_) => onChanged(group),
              ),
            ),
          );
        }
        return Row(children: chips);
      },
    );
  }

  TextStyle? _labelStyle(BuildContext context, bool isCompact) {
    final textTheme = Theme.of(context).textTheme;
    return isCompact ? textTheme.labelSmall : textTheme.labelMedium;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final spacing = isCompact ? 8.0 : 12.0;
        final minTileWidth = isCompact ? 56.0 : 64.0;
        var count = ((constraints.maxWidth + spacing) /
                (minTileWidth + spacing))
            .floor();
        if (count < 5) {
          count = 5;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
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
