import 'package:flutter/material.dart';

import '../../../activity/models/timeline_item.dart';
import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class StatsReportTimeline extends StatelessWidget {
  const StatsReportTimeline({
    super.key,
    required this.items,
    required this.categoryMap,
  });

  final List<TimelineItem> items;
  final Map<String, Category> categoryMap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.edit_note_outlined),
          title: Text('这一天还没有记录。'),
        ),
      );
    }

    return Column(
      children: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i += 1) {
      final item = items[i];
      final isLast = i == items.length - 1;
      if (item is Note) {
        widgets.add(
          _ReportTimelineRow(
            timeLabel: _formatTime(item.createdAt),
            showLine: !isLast,
            child: _ReportNoteTile(note: item),
          ),
        );
      } else if (item is TimeRecord) {
        widgets.add(
          _ReportTimelineRow(
            timeLabel: _formatTime(item.startAt),
            showLine: !isLast,
            child: _ReportRecordCard(
              record: item,
              category: categoryMap[item.categoryId],
            ),
          ),
        );
      }
      if (!isLast) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }
}

class _ReportTimelineRow extends StatelessWidget {
  const _ReportTimelineRow({
    required this.timeLabel,
    required this.child,
    required this.showLine,
  });

  final String timeLabel;
  final Widget child;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final timeStyle = Theme.of(context).textTheme.labelMedium;
    final dividerColor = Theme.of(context).dividerColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 52, child: Text(timeLabel, style: timeStyle)),
          _ReportTimelineMarker(color: dividerColor, showLine: showLine),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ReportTimelineMarker extends StatelessWidget {
  const _ReportTimelineMarker({
    required this.color,
    required this.showLine,
  });

  final Color color;
  final bool showLine;

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
          if (showLine)
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

class _ReportNoteTile extends StatelessWidget {
  const _ReportNoteTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.4,
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
      child: Text(note.content, style: style),
    );
  }
}

class _ReportRecordCard extends StatelessWidget {
  const _ReportRecordCard({
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecordHeader(
              icon: icon,
              color: color,
              label: category?.name ?? record.categoryId,
              weight: record.weight,
            ),
            const SizedBox(height: 6),
            Text(
              record.content,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            _RecordMeta(
              duration: _formatDuration(record.durationSec),
              endTime: _formatTime(record.endAt),
              color: color,
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
  });

  final IconData icon;
  final Color color;
  final String label;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Chip(
          label: Text(weight.toStringAsFixed(1)),
          labelStyle: chipStyle,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _RecordMeta extends StatelessWidget {
  const _RecordMeta({
    required this.duration,
    required this.endTime,
    required this.color,
  });

  final String duration;
  final String endTime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final metaStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Row(
      children: [
        Text(
          duration,
          style: metaStyle?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(' · $endTime', style: metaStyle),
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
