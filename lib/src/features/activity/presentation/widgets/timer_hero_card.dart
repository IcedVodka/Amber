import 'package:flutter/material.dart';

class TimerHeroCard extends StatelessWidget {
  const TimerHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.35 : 0.08);
    final titleStyle = theme.textTheme.titleMedium;
    final timeStyle = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    );

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: shadowColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            _TimerProgressRing(
              value: 0.72,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: colorScheme.primary,
            ),
            _TimerInfo(
              titleStyle: titleStyle,
              timeStyle: timeStyle,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerProgressRing extends StatelessWidget {
  const _TimerProgressRing({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
  });

  final double value;
  final Color backgroundColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 200,
        height: 200,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 6,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
        ),
      ),
    );
  }
}

class _TimerInfo extends StatelessWidget {
  const _TimerInfo({
    required this.titleStyle,
    required this.timeStyle,
    required this.colorScheme,
  });

  final TextStyle? titleStyle;
  final TextStyle? timeStyle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final sectionStyle = titleStyle?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final taskStyle = titleStyle?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('当前任务', style: sectionStyle),
        const SizedBox(height: 8),
        Text('UI 设计构思', style: taskStyle),
        const SizedBox(height: 18),
        Text('00:24:18', style: timeStyle),
        const SizedBox(height: 20),
        _PlayButton(colorScheme: colorScheme),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 6,
          shadowColor: colorScheme.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          size: 32,
        ),
      ),
    );
  }
}
