import 'package:flutter/material.dart';

class StatsReportEmptyState extends StatelessWidget {
  const StatsReportEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inbox_outlined),
        title: Text(
          '这段时间还没有记录。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
