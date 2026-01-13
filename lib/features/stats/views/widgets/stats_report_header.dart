import 'package:flutter/material.dart';

import '../../models/stats_models.dart';
import '../../utils/stats_formatters.dart';

class StatsReportHeaderCard extends StatelessWidget {
  const StatsReportHeaderCard({
    super.key,
    required this.report,
  });

  final StatsReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(title: report.title),
            const SizedBox(height: 12),
            _SummaryRow(report: report),
            const SizedBox(height: 12),
            _KeywordSection(keywords: report.keywords),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const Icon(Icons.share_outlined),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.report});

  final StatsReport report;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final valueStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Row(
      children: [
        Expanded(
          child: _MetaBlock(
            label: 'DATE',
            value: report.periodLabel,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetaBlock(
            label: 'NET TIME',
            value: formatDuration(report.netSec),
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
        ),
      ],
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScaleDownText(
          text: label,
          style: labelStyle,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 4),
        _ScaleDownText(
          text: value,
          style: valueStyle,
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}

class _KeywordSection extends StatelessWidget {
  const _KeywordSection({required this.keywords});

  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return Text(
        '关键词：暂无',
        style: Theme.of(context).textTheme.labelSmall,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关键词',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        _KeywordLine(keywords: keywords),
      ],
    );
  }
}

class _KeywordLine extends StatelessWidget {
  const _KeywordLine({required this.keywords});

  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    final chips = keywords
        .map((item) => Chip(label: Text(item)))
        .toList(growable: false);
    final children = <Widget>[];
    for (var i = 0; i < chips.length; i += 1) {
      children.add(chips[i]);
      if (i != chips.length - 1) {
        children.add(const SizedBox(width: 6));
      }
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
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
