import 'package:flutter/material.dart';

import '../../models/stats_models.dart';
import '../../utils/stats_formatters.dart';

class StatsReportFooter extends StatelessWidget {
  const StatsReportFooter({
    super.key,
    required this.report,
    required this.dimension,
  });

  final StatsReport report;
  final StatsDimension dimension;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _footerTitle(dimension),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            _SummaryLine(
              label: '有效产出',
              value: formatDuration(report.netSec),
            ),
            const SizedBox(height: 6),
            _SummaryLine(
              label: '物理时长',
              value: formatDuration(report.grossSec),
            ),
            const SizedBox(height: 6),
            _SummaryLine(
              label: '效率系数',
              value: report.efficiency.toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

String _footerTitle(StatsDimension dimension) {
  switch (dimension) {
    case StatsDimension.day:
      return '今日结算';
    case StatsDimension.week:
      return '本周结算';
    case StatsDimension.custom:
      return '本次结算';
  }
}
