import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../models/timer_session.dart';
import '../../../sync/views/widgets/hot_sync_entry.dart';
import 'category_grid.dart';

class FocusPanel extends StatelessWidget {
  const FocusPanel({
    super.key,
    required this.categories,
    required this.session,
    required this.activeCategory,
    required this.currentDuration,
    required this.onStartCategory,
    required this.onPause,
    required this.onResume,
    required this.onContentChanged,
    required this.onStop,
    required this.isSyncing,
    required this.syncStatus,
    required this.lastSyncedAt,
    required this.onHotSync,
  });

  final List<Category> categories;
  final TimerSession? session;
  final Category? activeCategory;
  final int currentDuration;
  final ValueChanged<Category> onStartCategory;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onStop;
  final bool isSyncing;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final VoidCallback onHotSync;

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return FocusIdlePanel(
        categories: categories,
        onStartCategory: onStartCategory,
        isSyncing: isSyncing,
        syncStatus: syncStatus,
        lastSyncedAt: lastSyncedAt,
        onHotSync: onHotSync,
      );
    }
    return FocusRunningPanel(
      session: session!,
      category: activeCategory,
      currentDuration: currentDuration,
      baseColor: activeCategory?.color,
      onPause: onPause,
      onResume: onResume,
      onContentChanged: onContentChanged,
      onStop: onStop,
    );
  }
}

class FocusIdlePanel extends StatelessWidget {
  const FocusIdlePanel({
    super.key,
    required this.categories,
    required this.onStartCategory,
    required this.isSyncing,
    required this.syncStatus,
    required this.lastSyncedAt,
    required this.onHotSync,
  });

  final List<Category> categories;
  final ValueChanged<Category> onStartCategory;
  final bool isSyncing;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final VoidCallback onHotSync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IdleHeader(
            isSyncing: isSyncing,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            onHotSync: onHotSync,
          ),
          const SizedBox(height: 12),
          CategoryGrid(
            categories: categories,
            onSelected: onStartCategory,
          ),
        ],
      ),
    );
  }
}

class _IdleHeader extends StatelessWidget {
  const _IdleHeader({
    required this.isSyncing,
    required this.syncStatus,
    required this.lastSyncedAt,
    required this.onHotSync,
  });

  final bool isSyncing;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final VoidCallback onHotSync;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text('准备什么工作？', style: style),
      trailing: HotSyncEntry(
        isSyncing: isSyncing,
        status: syncStatus,
        lastSyncedAt: lastSyncedAt,
        onPressed: onHotSync,
      ),
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
    required this.onContentChanged,
    required this.onStop,
  });

  final TimerSession session;
  final Category? category;
  final int currentDuration;
  final Color? baseColor;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelColor = baseColor ?? theme.colorScheme.primary;
    final brightness = ThemeData.estimateBrightnessForColor(panelColor);
    final foreground =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final muted = foreground.withOpacity(session.isRunning ? 0.9 : 0.6);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: panelColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RunningHeader(
              category: category,
              foreground: muted,
            ),
            const SizedBox(height: 10),
            _RunningTimer(
              durationSec: currentDuration,
              foreground: muted,
              isRunning: session.isRunning,
            ),
            const SizedBox(height: 12),
            _SessionContentEditor(
              content: session.content,
              foreground: foreground,
              onChanged: onContentChanged,
            ),
            const SizedBox(height: 14),
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
    required this.foreground,
  });

  final Category? category;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final label = (category?.name ?? '专注中').toUpperCase();
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground.withOpacity(0.85),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        );
    return Text(label, style: labelStyle, textAlign: TextAlign.center);
  }
}

class _SessionContentEditor extends StatefulWidget {
  const _SessionContentEditor({
    required this.content,
    required this.foreground,
    required this.onChanged,
  });

  final String content;
  final Color foreground;
  final ValueChanged<String> onChanged;

  @override
  State<_SessionContentEditor> createState() => _SessionContentEditorState();
}

class _SessionContentEditorState extends State<_SessionContentEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(covariant _SessionContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content &&
        widget.content != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.content,
        selection: TextSelection.collapsed(offset: widget.content.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: widget.foreground,
          fontWeight: FontWeight.w600,
        );
    final hintStyle = textStyle?.copyWith(
      color: widget.foreground.withOpacity(0.7),
      fontWeight: FontWeight.w500,
    );
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textAlign: TextAlign.center,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      style: textStyle,
      decoration: InputDecoration(
        hintText: '任务内容',
        hintStyle: hintStyle,
        filled: true,
        fillColor: widget.foreground.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class _RunningTimer extends StatelessWidget {
  const _RunningTimer({
    required this.durationSec,
    required this.foreground,
    required this.isRunning,
  });

  final int durationSec;
  final Color foreground;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          fontSize: 42,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final effectiveStyle = isRunning
        ? textStyle
        : textStyle?.copyWith(color: foreground.withOpacity(0.7));
    return Text(
      _formatTimer(durationSec),
      style: effectiveStyle,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleActionButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          backgroundColor: foreground.withOpacity(0.18),
          foregroundColor: foreground,
          onPressed: isRunning ? onPause : onResume,
        ),
        const SizedBox(width: 20),
        _CircleActionButton(
          icon: Icons.stop_rounded,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE76363),
          onPressed: onStop,
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        fixedSize: const Size(56, 56),
        shape: const CircleBorder(),
      ),
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
