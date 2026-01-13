import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/stats_models.dart';
import '../../utils/stats_formatters.dart';

class StatsCategoryBreakdownCard extends StatelessWidget {
  const StatsCategoryBreakdownCard({
    super.key,
    required this.items,
  });

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _BreakdownCardContent(items: items),
    );
  }
}

class _BreakdownCardContent extends StatelessWidget {
  const _BreakdownCardContent({required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 360;
        final padding = isWide
            ? const EdgeInsets.fromLTRB(20, 20, 20, 20)
            : const EdgeInsets.all(16);
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分类占比 (Net Time)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _BreakdownBody(items: items),
            ],
          ),
        );
      },
    );
  }
}

class _BreakdownBody extends StatelessWidget {
  const _BreakdownBody({required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        return _BreakdownLayout(items: items, isCompact: isCompact);
      },
    );
  }
}

class _BreakdownLayout extends StatelessWidget {
  const _BreakdownLayout({
    required this.items,
    required this.isCompact,
  });

  final List<CategoryBreakdown> items;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _BreakdownColumn(items: items);
    }
    return _BreakdownRow(items: items);
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DonutChartWithOffset(items: items),
        const SizedBox(width: 16),
        Expanded(child: _CategoryList(items: items)),
      ],
    );
  }
}

class _BreakdownColumn extends StatelessWidget {
  const _BreakdownColumn({required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DonutChartWithOffset(
          items: items,
          alignment: Alignment.center,
        ),
        const SizedBox(height: 12),
        _CategoryList(items: items),
      ],
    );
  }
}

class _DonutChartWithOffset extends StatelessWidget {
  const _DonutChartWithOffset({
    required this.items,
    this.alignment = Alignment.topLeft,
  });

  final List<CategoryBreakdown> items;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
        child: StatsDonutChart(items: items),
      ),
    );
  }
}

class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({
    super.key,
    required this.items,
  });

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    final totalSec = items.fold<int>(0, (sum, item) => sum + item.netSec);
    final baseColor =
        Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6);
    final sections = _buildSections(items, baseColor);
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 34,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
            ),
          ),
          _DonutCenter(totalSec: totalSec),
        ],
      ),
    );
  }
}

class _DonutCenter extends StatelessWidget {
  const _DonutCenter({required this.totalSec});

  final int totalSec;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          formatDuration(totalSec),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

List<PieChartSectionData> _buildSections(
  List<CategoryBreakdown> items,
  Color baseColor,
) {
  if (items.isEmpty) {
    return [
      PieChartSectionData(
        value: 1,
        color: baseColor,
        radius: 46,
        showTitle: false,
      ),
    ];
  }
  return items
      .map(
        (item) => PieChartSectionData(
          value: item.ratio,
          color: item.color,
          radius: 46,
          showTitle: false,
        ),
      )
      .toList(growable: false);
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        '暂无分类数据',
        style: Theme.of(context).textTheme.labelMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .map(
            (item) => _CategoryTile(item: item),
          )
          .toList(growable: false),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: _CategoryInfoRow(item: item),
    );
  }
}

class _CategoryDot extends StatelessWidget {
  const _CategoryDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: color.withOpacity(0.18),
      foregroundColor: color,
      child: Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CategoryInfoRow extends StatelessWidget {
  const _CategoryInfoRow({required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryDot(color: item.color),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _CategoryDuration(seconds: item.netSec),
          const SizedBox(width: 8),
          _CategoryPercent(ratio: item.ratio),
        ],
      ),
    );
  }
}

class _CategoryDuration extends StatelessWidget {
  const _CategoryDuration({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
    return Text(
      formatDuration(seconds),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _CategoryPercent extends StatelessWidget {
  const _CategoryPercent({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '(${formatPercent(ratio)})',
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
