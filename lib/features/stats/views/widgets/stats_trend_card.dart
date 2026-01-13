import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/stats_models.dart';

class StatsTrendCard extends StatelessWidget {
  const StatsTrendCard({
    super.key,
    required this.data,
    required this.dimension,
  });

  final StatsTrendData data;
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
              _title(dimension),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: StatsTrendChart(data: data),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsTrendChart extends StatelessWidget {
  const StatsTrendChart({
    super.key,
    required this.data,
  });

  final StatsTrendData data;

  @override
  Widget build(BuildContext context) {
    if (data.points.isEmpty) {
      return const _TrendEmpty();
    }
    return _TrendLineChart(data: data);
  }
}

class _TrendEmpty extends StatelessWidget {
  const _TrendEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '暂无数据',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _TrendLineChart extends StatelessWidget {
  const _TrendLineChart({required this.data});

  final StatsTrendData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = _chartMaxHours(data.points);
    final interval = _chartInterval(maxY);
    final lineColor = theme.colorScheme.primary;
    final targetHours = data.targetSec / 3600;
    final spots = _buildSpots(data.points);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: _buildGridData(theme, interval),
        titlesData: _buildTitlesData(theme, interval, data.points),
        borderData: FlBorderData(show: false),
        extraLinesData: _buildExtraLinesData(theme, data, targetHours),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 2.4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}

FlGridData _buildGridData(ThemeData theme, double interval) {
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: interval,
    getDrawingHorizontalLine: (value) => FlLine(
      color: theme.dividerColor.withOpacity(0.3),
      strokeWidth: 1,
    ),
  );
}

FlTitlesData _buildTitlesData(
  ThemeData theme,
  double interval,
  List<TrendPoint> points,
) {
  final labelStyle = theme.textTheme.labelSmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval,
        reservedSize: 40,
        getTitlesWidget: (value, meta) =>
            _leftTitle(value, meta, labelStyle),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) =>
            _bottomTitle(value, meta, points, labelStyle),
      ),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
}

ExtraLinesData _buildExtraLinesData(
  ThemeData theme,
  StatsTrendData data,
  double targetHours,
) {
  if (!data.showTargetLine) {
    return ExtraLinesData(horizontalLines: const []);
  }
  return ExtraLinesData(
    horizontalLines: [
      HorizontalLine(
        y: targetHours,
        color: theme.colorScheme.outline.withOpacity(0.6),
        strokeWidth: 1,
        dashArray: const [4, 4],
      ),
    ],
  );
}

List<FlSpot> _buildSpots(List<TrendPoint> points) {
  return List.generate(
    points.length,
    (index) => FlSpot(
      index.toDouble(),
      points[index].value / 3600,
    ),
  );
}

Widget _leftTitle(double value, TitleMeta meta, TextStyle? style) {
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 6,
    child: Text('${_formatHour(value)}h', style: style),
  );
}

Widget _bottomTitle(
  double value,
  TitleMeta meta,
  List<TrendPoint> points,
  TextStyle? style,
) {
  final index = value.round();
  if (value != index.toDouble()) {
    return const SizedBox.shrink();
  }
  if (index < 0 || index >= points.length) {
    return const SizedBox.shrink();
  }
  final point = points[index];
  if (!point.showLabel) {
    return const SizedBox.shrink();
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(point.label, style: style),
  );
}

double _chartMaxHours(List<TrendPoint> points) {
  final maxSec = points.fold<double>(
    0,
    (current, point) => max(current, point.value),
  );
  final hours = maxSec / 3600;
  if (hours <= 1) {
    return 1;
  }
  if (hours <= 2) {
    return 2;
  }
  if (hours <= 4) {
    return 4;
  }
  if (hours <= 6) {
    return 6;
  }
  if (hours <= 8) {
    return 8;
  }
  if (hours <= 10) {
    return 10;
  }
  return (hours / 5).ceil() * 5;
}

double _chartInterval(double maxY) {
  if (maxY <= 2) {
    return 0.5;
  }
  if (maxY <= 4) {
    return 1;
  }
  if (maxY <= 8) {
    return 2;
  }
  return (maxY / 4).ceilToDouble();
}

String _formatHour(double value) {
  if (value < 1) {
    return value.toStringAsFixed(1);
  }
  if (value % 1 != 0) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(0);
}

String _title(StatsDimension dimension) {
  switch (dimension) {
    case StatsDimension.day:
      return '精力分布 (24h)';
    case StatsDimension.week:
      return '有效时长趋势';
    case StatsDimension.custom:
      return '有效时长趋势';
  }
}
