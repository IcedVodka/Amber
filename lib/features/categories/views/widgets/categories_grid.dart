import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'category_item_tile.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onEdit,
  });

  final List<Category> items;
  final VoidCallback onAdd;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < items.length) {
            final item = items[index];
            return CategoryItemTile(
              item: item,
              onTap: () => onEdit(item),
            );
          }
          return CategoryAddTile(onTap: onAdd);
        },
        childCount: items.length + 1,
      ),
    );
  }
}

class CategoryAddTile extends StatelessWidget {
  const CategoryAddTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: _AddTileBody(
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ),
    );
  }
}

class _AddTileBody extends StatelessWidget {
  const _AddTileBody({
    required this.textTheme,
    required this.colorScheme,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.surfaceVariant,
          child: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          '新增活动',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
