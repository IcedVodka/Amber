import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../categories/models/category.dart';
import '../../models/stats_models.dart';
import '../../utils/stats_formatters.dart';
import 'stats_report_timeline.dart';

class StatsReportSection extends StatelessWidget {
  const StatsReportSection({
    super.key,
    required this.section,
    required this.categoryMap,
    required this.showHeader,
  });

  final ReportSection section;
  final Map<String, Category> categoryMap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          _DayHeader(
            date: section.date,
            netSec: section.netSec,
          ),
        if (showHeader) const SizedBox(height: 8),
        StatsReportTimeline(
          items: section.items,
          categoryMap: categoryMap,
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.netSec,
  });

  final DateTime date;
  final int netSec;

  @override
  Widget build(BuildContext context) {
    final subtitle = '${formatFullDate(date)} · ${formatWeekday(date)}';
    return Card(
      child: ListTile(
        title: _ScaleDownText(
          text: subtitle,
          alignment: Alignment.centerLeft,
        ),
        trailing: _ScaleDownText(
          text: formatDuration(netSec),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }
}

class _ScaleDownText extends StatelessWidget {
  const _ScaleDownText({
    required this.text,
    this.style,
    this.alignment = Alignment.center,
  });

  final String text;
  final TextStyle? style;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, style: style, maxLines: 1),
    );
  }
}
