import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';
import '../../models/timeline_item.dart';

class TimelineList extends StatelessWidget {
  const TimelineList({
    super.key,
    required this.items,
    required this.categoryMap,
    required this.controller,
  });

  final List<TimelineItem> items;
  final Map<String, Category> categoryMap;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('今天还没有记录哦～'),
      );
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Note) {
          return TimelineRow(
            timeLabel: _formatTime(item.createdAt),
            child: NoteTile(note: item),
          );
        }
        if (item is TimeRecord) {
          return TimelineRow(
            timeLabel: _formatTime(item.startAt),
            child: RecordTile(
              record: item,
              category: categoryMap[item.categoryId],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({
    super.key,
    required this.timeLabel,
    required this.child,
  });

  final String timeLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final timeStyle = Theme.of(context).textTheme.labelMedium;
    final dividerColor = Theme.of(context).dividerColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 52, child: Text(timeLabel, style: timeStyle)),
          _TimelineMarker(color: dividerColor),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: Column(
        children: [
          const SizedBox(height: 2),
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: 2,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontFamily: 'Noto Serif CJK SC',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.4,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
      child: Text(note.content, style: textStyle),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({
    super.key,
    required this.record,
    required this.category,
  });

  final TimeRecord record;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final icon = category == null
        ? Icons.label_rounded
        : CategoryIcon.iconByCode(category!.iconCode);
    final color = category?.color ?? Theme.of(context).colorScheme.primary;
    final headerStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final metaStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final durationStyle = metaStyle?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecordHeader(
              icon: icon,
              color: color,
              label: category?.name ?? record.categoryId,
              weight: record.weight,
              style: headerStyle,
            ),
            const SizedBox(height: 6),
            Text(record.content, style: titleStyle),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(_formatDuration(record.durationSec), style: durationStyle),
                Text(' · ${_formatTime(record.endAt)}', style: metaStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordHeader extends StatelessWidget {
  const _RecordHeader({
    required this.icon,
    required this.color,
    required this.label,
    required this.weight,
    required this.style,
  });

  final IconData icon;
  final Color color;
  final String label;
  final double weight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final chipColor = Theme.of(context).colorScheme.surfaceVariant;
    final chipTextStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color.withOpacity(0.18),
          foregroundColor: color,
          child: Icon(icon, size: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label.toUpperCase(), style: style),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(' ${weight.toStringAsFixed(1)}', style: chipTextStyle),
        ),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}

String _formatTime(DateTime time) {
  return '${_two(time.hour)}:${_two(time.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
