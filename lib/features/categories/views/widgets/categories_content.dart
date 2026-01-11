import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'category_options.dart';

class CategoriesContent extends StatelessWidget {
  const CategoriesContent({
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final subTitleStyle = textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          '分类管理',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text('点击分类可编辑配置', style: subTitleStyle),
        const SizedBox(height: 16),
        CategoryAddCard(onTap: onAdd),
        const SizedBox(height: 16),
        if (items.isEmpty) const CategoryEmptyState(),
        if (items.isNotEmpty) ..._buildItems(),
      ],
    );
  }

  List<Widget> _buildItems() {
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CategoryCard(
              item: item,
              onTap: () => onEdit(item),
            ),
          ),
        )
        .toList(growable: false);
  }
}

class CategoryAddCard extends StatelessWidget {
  const CategoryAddCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.add),
        ),
        title: const Text('新增分类'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Category item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = resolveCategoryIcon(item.iconCode);
    final subtitle = item.enabled ? null : const Text('已停用');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.color,
          child: Icon(icon, color: colorScheme.onPrimary),
        ),
        title: Text(item.name),
        subtitle: subtitle,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class CategoryEmptyState extends StatelessWidget {
  const CategoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.inbox_outlined),
        title: Text(
          '还没有分类，先添加一个吧。',
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }
}
