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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.surface,
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '已停用',
              style: textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
            ),
          ),
      ],
    );
  }
}
