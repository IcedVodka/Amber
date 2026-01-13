import 'package:flutter/material.dart';

class HotSyncEntry extends StatefulWidget {
  const HotSyncEntry({
    super.key,
    required this.isSyncing,
    required this.status,
    required this.lastSyncedAt,
    required this.onPressed,
  });

  final bool isSyncing;
  final String status;
  final DateTime? lastSyncedAt;
  final VoidCallback onPressed;

  @override
  State<HotSyncEntry> createState() => _HotSyncEntryState();
}

class _HotSyncEntryState extends State<HotSyncEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isSyncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HotSyncEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSyncing != widget.isSyncing) {
      if (widget.isSyncing) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: widget.isSyncing ? null : widget.onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                _label(),
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.refresh,
                size: 18,
                color: widget.isSyncing
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label() {
    if (widget.isSyncing) {
      if (widget.status.isEmpty) {
        return '同步中...';
      }
      return widget.status;
    }
    final last = widget.lastSyncedAt;
    if (last == null) {
      return '未同步';
    }
    return '上次同步: ${_two(last.hour)}:${_two(last.minute)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
