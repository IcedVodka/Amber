import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/sync_view_model.dart';

class SyncProgressDialog extends ConsumerStatefulWidget {
  const SyncProgressDialog({super.key});

  @override
  ConsumerState<SyncProgressDialog> createState() =>
      _SyncProgressDialogState();
}

class _SyncProgressDialogState extends ConsumerState<SyncProgressDialog> {
  static const int _maxLogs = 200;

  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncViewState>(syncViewModelProvider, (prev, next) {
      if (next.syncStatus.isNotEmpty && next.syncStatus != prev?.syncStatus) {
        if (!mounted) {
          return;
        }
        setState(() {
          _logs.add(next.syncStatus);
          if (_logs.length > _maxLogs) {
            _logs.removeRange(0, _logs.length - _maxLogs);
          }
        });
        _scrollToLatest();
      }
      if (prev?.isSyncing == true && next.isSyncing == false) {
        if (mounted && context.canPop()) {
          context.pop();
        }
      }
    });

    return AlertDialog(
      title: const Text('正在冷同步...'),
      content: SizedBox(
        width: 320,
        height: 240,
        child: _logs.isEmpty
            ? const _SyncLogPlaceholder()
            : _SyncLogList(
                logs: _logs,
                controller: _scrollController,
              ),
      ),
    );
  }
}

class _SyncLogPlaceholder extends StatelessWidget {
  const _SyncLogPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Expanded(child: Text('准备中...')),
      ],
    );
  }
}

class _SyncLogList extends StatelessWidget {
  const _SyncLogList({
    required this.logs,
    required this.controller,
  });

  final List<String> logs;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) => Text(logs[index]),
    );
  }
}
