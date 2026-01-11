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
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == items.length) {
                  return CategoryAddTile(onTap: onAdd);
                }
                final item = items[index];
                return CategoryGridTile(
                  item: item,
                  onTap: () => onEdit(item),
                );
              },
              childCount: items.length + 1,
            ),
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
        child: GridTile(
          child: _AddTileBody(
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
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

class CategoryGridTile extends StatelessWidget {
  const CategoryGridTile({
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
        child: GridTile(
          child: _CategoryTileBody(
            icon: icon,
            name: item.name,
            enabled: item.enabled,
            iconColor: item.color,
            textColor: textColor,
          ),
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
