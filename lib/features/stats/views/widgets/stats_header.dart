import 'package:flutter/material.dart';

import '../../models/stats_models.dart';

class StatsHeader extends StatelessWidget {
  const StatsHeader({
    super.key,
    required this.dimension,
    required this.viewMode,
    required this.title,
    required this.subtitle,
    required this.onDimensionChanged,
    required this.onViewModeChanged,
    required this.onPrev,
    required this.onNext,
    required this.onPickDate,
  });

  final StatsDimension dimension;
  final StatsViewMode viewMode;
  final String title;
  final String subtitle;
  final ValueChanged<StatsDimension> onDimensionChanged;
  final ValueChanged<StatsViewMode> onViewModeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          _DimensionSelector(
            value: dimension,
            onChanged: onDimensionChanged,
          ),
          const SizedBox(height: 12),
          _DateNavigator(
            title: title,
            subtitle: subtitle,
            onPrev: onPrev,
            onNext: onNext,
            onPick: onPickDate,
          ),
          const SizedBox(height: 12),
          _ViewModeSelector(
            value: viewMode,
            onChanged: onViewModeChanged,
          ),
        ],
      ),
    );
  }
}

class _DimensionSelector extends StatelessWidget {
  const _DimensionSelector({
    required this.value,
    required this.onChanged,
  });

  final StatsDimension value;
  final ValueChanged<StatsDimension> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SegmentedButton<StatsDimension>(
      segments: const [
        ButtonSegment(value: StatsDimension.day, label: Text('日')),
        ButtonSegment(value: StatsDimension.week, label: Text('周')),
        ButtonSegment(value: StatsDimension.custom, label: Text('自定义')),
      ],
      selected: {value},
      onSelectionChanged: (value) => onChanged(value.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        selectedBackgroundColor: theme.colorScheme.primary,
        selectedForegroundColor: theme.colorScheme.onPrimary,
        foregroundColor: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  const _ViewModeSelector({
    required this.value,
    required this.onChanged,
  });

  final StatsViewMode value;
  final ValueChanged<StatsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SegmentedButton<StatsViewMode>(
      segments: const [
        ButtonSegment(
          value: StatsViewMode.dashboard,
          label: Text('仪表盘'),
          icon: Icon(Icons.pie_chart_rounded),
        ),
        ButtonSegment(
          value: StatsViewMode.report,
          label: Text('结案报告'),
          icon: Icon(Icons.description_rounded),
        ),
      ],
      selected: {value},
      onSelectionChanged: (value) => onChanged(value.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        selectedBackgroundColor: theme.colorScheme.surfaceVariant,
        selectedForegroundColor: theme.colorScheme.onSurface,
        foregroundColor: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.title,
    required this.subtitle,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPrev,
        ),
        Expanded(
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _ScaleDownText(
                    text: title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _ScaleDownText(
                    text: subtitle,
                    style: textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ScaleDownText extends StatelessWidget {
  const _ScaleDownText({
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
