import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/sync_view_model.dart';

class SyncProgressDialog extends ConsumerStatefulWidget {
  const SyncProgressDialog({super.key});

  @override
  ConsumerState<SyncProgressDialog> createState() =>
      _SyncProgressDialogState();
}

class _SyncProgressDialogState extends ConsumerState<SyncProgressDialog> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncViewState>(syncViewModelProvider, (prev, next) {
      if (next.syncStatus.isNotEmpty && next.syncStatus != prev?.syncStatus) {
        if (!mounted) {
          return;
        }
        setState(() {
          _logs.add(next.syncStatus);
        });
      }
      if (prev?.isSyncing == true && next.isSyncing == false) {
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      }
    });

    return AlertDialog(
      title: const Text('正在冷同步...'),
      content: SizedBox(
        width: double.maxFinite,
        child: _logs.isEmpty
            ? const _SyncLogPlaceholder()
            : _SyncLogList(logs: _logs),
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
  const _SyncLogList({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) => Text(logs[index]),
    );
  }
}
