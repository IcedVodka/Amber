import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';
import '../../models/timer_session.dart';
import 'category_grid.dart';

class FocusPanel extends StatelessWidget {
  const FocusPanel({
    super.key,
    required this.now,
    required this.categories,
    required this.session,
    required this.activeCategory,
    required this.currentDuration,
    required this.onStartCategory,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final DateTime now;
  final List<Category> categories;
  final TimerSession? session;
  final Category? activeCategory;
  final int currentDuration;
  final ValueChanged<Category> onStartCategory;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return FocusIdlePanel(
        now: now,
        categories: categories,
        onStartCategory: onStartCategory,
      );
    }
    return FocusRunningPanel(
      session: session!,
      category: activeCategory,
      currentDuration: currentDuration,
      baseColor: activeCategory?.color,
      onPause: onPause,
      onResume: onResume,
      onStop: onStop,
    );
  }
}

class FocusIdlePanel extends StatelessWidget {
  const FocusIdlePanel({
    super.key,
    required this.now,
    required this.categories,
    required this.onStartCategory,
  });

  final DateTime now;
  final List<Category> categories;
  final ValueChanged<Category> onStartCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FocusHeader(now: now),
            const SizedBox(height: 12),
            CategoryGrid(
              categories: categories,
              onSelected: onStartCategory,
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        formatFullDate(now),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(formatWeekday(now)),
      trailing: const Chip(label: Text('今天')),
    );
  }
}

class FocusRunningPanel extends StatelessWidget {
  const FocusRunningPanel({
    super.key,
    required this.session,
    required this.category,
    required this.currentDuration,
    required this.baseColor,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final TimerSession session;
  final Category? category;
  final int currentDuration;
  final Color? baseColor;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelColor = baseColor ?? theme.colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(panelColor);
    final foreground =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: panelColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RunningHeader(
              category: category,
              content: session.content,
              foreground: foreground,
            ),
            const SizedBox(height: 12),
            _RunningTimer(
              durationSec: currentDuration,
              foreground: foreground,
            ),
            const SizedBox(height: 12),
            _RunningActions(
              isRunning: session.isRunning,
              foreground: foreground,
              panelColor: panelColor,
              onPause: onPause,
              onResume: onResume,
              onStop: onStop,
            ),
          ],
        ),
      ),
    );
  }
}

class _RunningHeader extends StatelessWidget {
  const _RunningHeader({
    required this.category,
    required this.content,
    required this.foreground,
  });

  final Category? category;
  final String content;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final icon = category == null
        ? Icons.timer_outlined
        : CategoryIcon.iconByCode(category!.iconCode);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: foreground.withOpacity(0.2),
        foregroundColor: foreground,
        child: Icon(icon),
      ),
      title: Text(
        category?.name ?? '当前专注',
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        content,
        style: TextStyle(color: foreground.withOpacity(0.8)),
      ),
    );
  }
}

class _RunningTimer extends StatelessWidget {
  const _RunningTimer({
    required this.durationSec,
    required this.foreground,
  });

  final int durationSec;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        );
    return Text(
      _formatTimer(durationSec),
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }
}

class _RunningActions extends StatelessWidget {
  const _RunningActions({
    required this.isRunning,
    required this.foreground,
    required this.panelColor,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool isRunning;
  final Color foreground;
  final Color panelColor;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.filledTonal(
          onPressed: isRunning ? onPause : onResume,
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          style: IconButton.styleFrom(
            foregroundColor: foreground,
          ),
        ),
        FilledButton(
          onPressed: onStop,
          style: FilledButton.styleFrom(
            backgroundColor: foreground,
            foregroundColor: panelColor,
          ),
          child: const Text('结束'),
        ),
      ],
    );
  }
}

String _formatTimer(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;
  return '${_two(hours)}:${_two(minutes)}:${_two(secs)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
