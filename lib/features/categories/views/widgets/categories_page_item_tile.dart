import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/category_icons.dart';

class CategoryItemTile extends StatelessWidget {
  const CategoryItemTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Category item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = CategoryIcon.iconByCode(item.iconCode);
    final textColor =
        item.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant;
    final background = item.enabled
        ? item.color.withOpacity(0.16)
        : colorScheme.surfaceVariant;

    return Card(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: _CategoryTileBody(
          icon: icon,
          name: item.name,
          enabled: item.enabled,
          iconColor: item.color,
          textColor: textColor,
        ),
      ),
    );
  }
}

class _CategoryTileBody extends StatelessWidget {
  const _CategoryTileBody({
    required this.icon,
    required this.name,
    required this.enabled,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String name;
  final bool enabled;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final colorScheme = theme.colorScheme;
        final minSide = constraints.biggest.shortestSide;
        final scale = (minSide / 140).clamp(0.55, 1.0);
        final bodySize = (textTheme.bodyMedium?.fontSize ?? 14) * scale;
        final smallSize = (textTheme.bodySmall?.fontSize ?? 12) * scale;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CategoryIconBubble(
              icon: icon,
              colorScheme: colorScheme,
              iconColor: iconColor,
              scale: scale,
            ),
            SizedBox(height: 8 * scale),
            _CategoryName(
              name: name,
              textColor: textColor,
              fontSize: bodySize,
            ),
            if (!enabled)
              Padding(
                padding: EdgeInsets.only(top: 4 * scale),
                child: _CategoryStatus(
                  textColor: textColor,
                  fontSize: smallSize,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryIconBubble extends StatelessWidget {
  const _CategoryIconBubble({
    required this.icon,
    required this.colorScheme,
    required this.iconColor,
    required this.scale,
  });

  final IconData icon;
  final ColorScheme colorScheme;
  final Color iconColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20 * scale,
      backgroundColor: colorScheme.surface,
      child: Icon(
        icon,
        color: iconColor,
        size: 24 * scale,
      ),
    );
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({
    required this.name,
    required this.textColor,
    required this.fontSize,
  });

  final String name;
  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: fontSize,
          ),
    );
  }
}

class _CategoryStatus extends StatelessWidget {
  const _CategoryStatus({
    required this.textColor,
    required this.fontSize,
  });

  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '已停用',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: fontSize,
          ),
    );
  }
}
