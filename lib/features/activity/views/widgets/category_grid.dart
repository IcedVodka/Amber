import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  final List<Category> categories;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 100,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryGridTile(
          category: category,
          onSelected: () => onSelected(category),
        );
      },
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
    final labelStyle = Theme.of(context).textTheme.labelMedium;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onSelected,
      child: GridTile(
        footer: Text(
          category.name,
          textAlign: TextAlign.center,
          style: labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        child: Center(
          child: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.2),
            foregroundColor: category.color,
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}
