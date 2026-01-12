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
      return const Center(child: Text('今天还没有记录'));
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Note) {
          return NoteTile(note: item);
        }
        if (item is TimeRecord) {
          return RecordTile(
            record: item,
            category: categoryMap[item.categoryId],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final timeStyle = Theme.of(context).textTheme.labelMedium;
    final dividerColor = Theme.of(context).dividerColor;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(_formatTime(note.createdAt), style: timeStyle),
            ),
            Container(width: 1, height: 24, color: dividerColor),
            const SizedBox(width: 12),
            Expanded(child: Text(note.content, style: textStyle)),
          ],
        ),
      ),
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

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            foregroundColor: color,
            child: Icon(icon),
          ),
          title: Text(category?.name ?? record.categoryId),
          subtitle: Text(record.content),
          trailing: _RecordTrailing(
            durationSec: record.durationSec,
            weight: record.weight,
          ),
        ),
      ),
    );
  }
}

class _RecordTrailing extends StatelessWidget {
  const _RecordTrailing({
    required this.durationSec,
    required this.weight,
  });

  final int durationSec;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final durationStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final weightStyle = Theme.of(context).textTheme.labelSmall;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(_formatDuration(durationSec), style: durationStyle),
        Text('Eff ${weight.toStringAsFixed(1)}', style: weightStyle),
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
