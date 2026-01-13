import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../categories/models/category.dart';
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
    final timeStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final lineColor = Theme.of(context).dividerColor.withOpacity(0.6);
    final noteIndicatorColor = Theme.of(context).dividerColor;

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;
        if (item is Note) {
          return _TimelineEntryTile(
            timeLabel: _formatTime(item.createdAt),
            timeStyle: timeStyle,
            lineColor: lineColor,
            indicatorColor: noteIndicatorColor,
            isFirst: isFirst,
            isLast: isLast,
            child: NoteTile(note: item),
          );
        }
        if (item is TimeRecord) {
          final category = categoryMap[item.categoryId];
          final indicatorColor =
              category?.color ?? Theme.of(context).colorScheme.primary;
          return _TimelineEntryTile(
            timeLabel: _formatTime(item.startAt),
            timeStyle: timeStyle,
            lineColor: lineColor,
            indicatorColor: indicatorColor,
            isFirst: isFirst,
            isLast: isLast,
            child: RecordTile(
              record: item,
              category: category,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({
    required this.timeLabel,
    required this.child,
    required this.timeStyle,
    required this.lineColor,
    required this.indicatorColor,
    required this.isFirst,
    required this.isLast,
  });

  final String timeLabel;
  final Widget child;
  final TextStyle? timeStyle;
  final Color lineColor;
  final Color indicatorColor;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _TimelineDashedLineLayer(
            color: lineColor,
            isFirst: isFirst,
            isLast: isLast,
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: _timelineLineX,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: _timelineIndicatorSize,
            height: _timelineIndicatorSize,
            color: indicatorColor,
            indicatorXY: _timelineIndicatorXY,
          ),
          beforeLineStyle: _hiddenLineStyle,
          afterLineStyle: _hiddenLineStyle,
          startChild: _TimelineTimeLabel(
            label: timeLabel,
            style: timeStyle,
          ),
          endChild: _TimelineContent(
            bottomSpacing: isLast ? 0 : _timelineItemSpacing,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _TimelineDashedLineLayer extends StatelessWidget {
  const _TimelineDashedLineLayer({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TimelineDashedLinePainter(
          color: color,
          isFirst: isFirst,
          isLast: isLast,
        ),
      ),
    );
  }
}

class _TimelineDashedLinePainter extends CustomPainter {
  _TimelineDashedLinePainter({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || _timelineLineThickness <= 0) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = _timelineLineThickness
      ..strokeCap = StrokeCap.round;

    final lineX = size.width * _timelineLineX;
    final indicatorCenterY = size.height * _timelineIndicatorXY;
    final gapStart = (indicatorCenterY -
            (_timelineIndicatorSize / 2) -
            _timelineIndicatorGap)
        .clamp(0.0, size.height) as double;
    final gapEnd = (indicatorCenterY +
            (_timelineIndicatorSize / 2) +
            _timelineIndicatorGap)
        .clamp(0.0, size.height) as double;

    if (!isFirst) {
      _drawDashedLine(canvas, paint, lineX, 0, gapStart);
    }
    if (!isLast) {
      _drawDashedLine(canvas, paint, lineX, gapEnd, size.height);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    double x,
    double startY,
    double endY,
  ) {
    if (endY <= startY) {
      return;
    }
    var y = startY;
    while (y < endY) {
      final nextY = (y + _timelineDashLength).clamp(startY, endY) as double;
      canvas.drawLine(Offset(x, y), Offset(x, nextY), paint);
      y = nextY + _timelineDashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineDashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast;
  }
}

class _TimelineTimeLabel extends StatelessWidget {
  const _TimelineTimeLabel({
    required this.label,
    required this.style,
  });

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 2),
      child: Align(
        alignment: Alignment.topRight,
        child: Text(label, style: style),
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({
    required this.child,
    required this.bottomSpacing,
  });

  final Widget child;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: bottomSpacing),
      child: child,
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
    final lineColor = Theme.of(context).dividerColor.withOpacity(0.8);
    final content = '📝 "${note.content}"';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(content, style: textStyle),
          ),
        ],
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
    final title = category?.name ?? record.categoryId;
    final duration = _formatDuration(record.durationSec);
    final endTime = _formatTime(record.endAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecordTitleRow(
              title: title,
              duration: duration,
            ),
            const SizedBox(height: 4),
            _RecordSubtitle(text: record.content),
            const SizedBox(height: 8),
            _RecordMetaRow(
              weight: record.weight,
              endTime: endTime,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTitleRow extends StatelessWidget {
  const _RecordTitleRow({
    required this.title,
    required this.duration,
  });

  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final durationStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Row(
      children: [
        Expanded(
          child: Text(title, style: titleStyle),
        ),
        Text(duration, style: durationStyle),
      ],
    );
  }
}

class _RecordSubtitle extends StatelessWidget {
  const _RecordSubtitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Text(text, style: style);
  }
}

class _RecordMetaRow extends StatelessWidget {
  const _RecordMetaRow({
    required this.weight,
    required this.endTime,
  });

  final double weight;
  final String endTime;

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 9,
          letterSpacing: 0.2,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withOpacity(0.7),
        );
    final endStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _MetaChip(
          label: 'W: ${weight.toStringAsFixed(1)}',
          textStyle: chipStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(endTime, style: endStyle),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.textStyle,
  });

  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context)
        .colorScheme
        .surfaceVariant
        .withOpacity(0.45);
    final borderColor = Theme.of(context)
        .colorScheme
        .outlineVariant
        .withOpacity(0.35);
    return Chip(
      label: Text(label, style: textStyle),
      backgroundColor: background,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

const LineStyle _hiddenLineStyle =
    LineStyle(color: Colors.transparent, thickness: 0);
const double _timelineLineX = 0.2;
const double _timelineIndicatorXY = 0.12;
const double _timelineIndicatorSize = 12;
const double _timelineIndicatorGap = 4;
const double _timelineLineThickness = 1;
const double _timelineDashLength = 4;
const double _timelineDashGap = 4;
const double _timelineItemSpacing = 12;
