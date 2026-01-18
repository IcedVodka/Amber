import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final spacing = isCompact ? 8.0 : 12.0;
        final dotSize = isCompact ? 32.0 : 40.0;
        return _buildPalette(spacing, dotSize);
      },
    );
  }

  Widget _buildPalette(double spacing, double dotSize) {
    final rowCount = rows;
    if (rowCount == null || rowCount <= 1) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final item in items)
            ColorDot(
              color: item.color,
              label: item.label,
              selected: item.selected,
              onTap: item.onTap,
              size: dotSize,
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
      rowWidgets.add(_ColorPaletteRow(
        items: items.sublist(start, end),
        spacing: spacing,
        dotSize: dotSize,
      ));
      if (rowIndex < rowCount - 1 && end < items.length) {
        rowWidgets.add(SizedBox(height: spacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowWidgets,
    );
  }
}

class _ColorPaletteRow extends StatelessWidget {
  const _ColorPaletteRow({
    required this.items,
    required this.spacing,
    required this.dotSize,
  });

  final List<ColorPaletteItem> items;
  final double spacing;
  final double dotSize;

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
        children.add(SizedBox(width: spacing));
      }
      final item = items[i];
      children.add(
        ColorDot(
          color: item.color,
          label: item.label,
          selected: item.selected,
          onTap: item.onTap,
          size: dotSize,
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
    required this.size,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double size;

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
          size: size,
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
    required this.size,
  });

  final Color color;
  final Color borderColor;
  final Color iconColor;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: size * 0.5, color: iconColor)
          : null,
    );
  }
}
