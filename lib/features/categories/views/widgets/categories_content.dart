import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'categories_grid.dart';

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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            '分类管理',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SliverToBoxAdapter(child: _HeaderIntro()),
        if (items.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            sliver: SliverToBoxAdapter(child: CategoryEmptyState()),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: CategoriesGrid(
            items: items,
            onAdd: onAdd,
            onEdit: onEdit,
          ),
        ),
      ],
    );
  }
}

class _HeaderIntro extends StatelessWidget {
  const _HeaderIntro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final subTitleStyle = textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('自定义你的时间记录活动类型', style: subTitleStyle),
          const SizedBox(height: 4),
          Text('点击活动可编辑配置', style: subTitleStyle),
        ],
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
      elevation: 0,
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
