import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  static const double _tileExtent = 92;
  static const double _rowSpacing = 12;
  static const double _gridHeight = _tileExtent * 2 + _rowSpacing;

  final List<Category> categories;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _gridHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: _tileExtent,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryGridTile(
            category: category,
            onSelected: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class CategoryGridTile extends StatelessWidget {
  const CategoryGridTile({
    super.key,
    required this.category,
    required this.onSelected,
  });

  final Category category;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcon.iconByCode(category.iconCode);
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onSelected,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CategoryIconTile(color: category.color, icon: icon),
          const SizedBox(height: 6),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryIconTile extends StatelessWidget {
  const _CategoryIconTile({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        height: 52,
        width: 52,
        child: Icon(icon, color: color),
      ),
    );
  }
}
