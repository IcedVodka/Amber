import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../models/category.dart';
import 'categories_page_item_tile.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onReorder,
  });

  final List<Category> items;
  final ValueChanged<Category> onEdit;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            _resolveCrossAxisCount(constraints.crossAxisExtent);
        return ReorderableSliverGridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          onReorder: onReorder,
          children: [
            for (final item in items)
              CategoryItemTile(
                key: ValueKey(item.id),
                item: item,
                onTap: () => onEdit(item),
              ),
          ],
        );
      },
    );
  }

  int _resolveCrossAxisCount(double extent) {
    final count = (extent / 140).floor();
    return count < 2 ? 2 : count;
  }
}
