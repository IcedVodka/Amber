import 'package:flutter/material.dart';

import '../../models/stats_models.dart';
import '../../utils/stats_formatters.dart';

class StatsMetricCards extends StatelessWidget {
  const StatsMetricCards({
    super.key,
    required this.summary,
  });

  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 360;
    final spacing = isCompact ? 8.0 : 12.0;
    return Row(
      children: [
        Expanded(child: _NetTimeCard(summary: summary, isCompact: isCompact)),
        SizedBox(width: spacing),
        Expanded(
          child: _EfficiencyCard(summary: summary, isCompact: isCompact),
        ),
        SizedBox(width: spacing),
        Expanded(child: _GrossTimeCard(summary: summary, isCompact: isCompact)),
      ],
    );
  }
}

class _NetTimeCard extends StatelessWidget {
  const _NetTimeCard({
    required this.summary,
    required this.isCompact,
  });

  final StatsSummary summary;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent = theme.colorScheme.primary;
    return _MetricCard(
      backgroundColor: accent.withOpacity(0.08),
      isCompact: isCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricHeader(
            title: '有效时长',
            icon: Icons.timer_rounded,
            color: accent,
          ),
          const SizedBox(height: 8),
          _ScaleDownText(
            text: formatDurationCompact(summary.netSec),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _DeltaLabel(delta: summary.delta),
        ],
      ),
    );
  }
}

class _EfficiencyCard extends StatelessWidget {
  const _EfficiencyCard({
    required this.summary,
    required this.isCompact,
  });

  final StatsSummary summary;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent = _scoreColor(context, summary.efficiency);
    return _MetricCard(
      backgroundColor: accent.withOpacity(0.08),
      isCompact: isCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricHeader(
            title: '效率系数',
            icon: Icons.bolt_rounded,
            color: accent,
          ),
          const SizedBox(height: 8),
          _ScaleDownText(
            text: formatScore(summary.efficiency),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          _ScaleDownText(
            text: _scoreLabel(summary.efficiency),
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrossTimeCard extends StatelessWidget {
  const _GrossTimeCard({
    required this.summary,
    required this.isCompact,
  });

  final StatsSummary summary;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent = theme.colorScheme.secondary;
    return _MetricCard(
      isCompact: isCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricHeader(
            title: '物理时长',
            icon: Icons.schedule_rounded,
            color: accent,
          ),
          const SizedBox(height: 8),
          _ScaleDownText(
            text: formatDurationCompact(summary.grossSec),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _ScaleDownText(
            text: 'Gross Time',
            style: textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.child,
    required this.isCompact,
    this.backgroundColor,
  });

  final Widget child;
  final bool isCompact;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final padding = isCompact ? 10.0 : 12.0;
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

class _MetricHeader extends StatelessWidget {
  const _MetricHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color.withOpacity(0.16),
          foregroundColor: color,
          child: Icon(icon, size: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ScaleDownText(
            text: title,
            style: style,
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.delta});

  final StatsDelta delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!delta.isAvailable) {
      return Text(
        '—',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final isPositive = delta.ratio >= 0;
    final color = isPositive ? Colors.green : Colors.redAccent;
    final label = '${isPositive ? '▲' : '▼'}${formatPercent(delta.ratio)}';
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(color: color),
    );
  }
}

String _scoreLabel(double score) {
  if (score >= 0.8) {
    return '太棒了';
  }
  if (score >= 0.5) {
    return '不错';
  }
  return '待提升';
}

Color _scoreColor(BuildContext context, double score) {
  if (score >= 0.8) {
    return Colors.green;
  }
  if (score >= 0.5) {
    return Colors.orange;
  }
  return Theme.of(context).colorScheme.error;
}

class _ScaleDownText extends StatelessWidget {
  const _ScaleDownText({
    required this.text,
    this.style,
    this.alignment = Alignment.centerLeft,
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
