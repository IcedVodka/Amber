import 'package:flutter/material.dart';

import '../../models/recent_item.dart';

class RecentActivityHeader extends StatelessWidget {
  const RecentActivityHeader({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '最近记录',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('查看全部'),
        ),
      ],
    );
  }
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key, required this.items});

  final List<RecentItem> items;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _RecentCard(
          item: item,
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, required this.backgroundColor});

  final RecentItem item;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.28 : 0.05);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final durationStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Card(
      margin: EdgeInsets.zero,
      color: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: shadowColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        horizontalTitleGap: 14,
        minLeadingWidth: 10,
        leading: _StatusDot(color: item.color),
        title: Text(item.title, style: titleStyle),
        subtitle: Text(item.subtitle, style: subtitleStyle),
        trailing: _DurationTrailing(
          duration: item.duration,
          color: colorScheme.onSurfaceVariant,
          textStyle: durationStyle,
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DurationTrailing extends StatelessWidget {
  const _DurationTrailing({
    required this.duration,
    required this.color,
    required this.textStyle,
  });

  final String duration;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(duration, style: textStyle),
        const SizedBox(width: 8),
        Icon(Icons.play_arrow, color: color),
      ],
    );
  }
}
