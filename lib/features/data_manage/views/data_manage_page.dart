import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activity/models/timeline_item.dart';
import '../view_models/data_manage_view_model.dart';
import 'dialogs/data_item_editor_sheet.dart';
import 'widgets/data_manage_content.dart';

class DataManagePage extends ConsumerWidget {
  const DataManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataManageViewModelProvider);
    final notifier = ref.read(dataManageViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据编辑管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _pickDate(context, notifier, state.selectedDate),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : DataManageContent(
              selectedDate: state.selectedDate,
              items: state.items,
              categoryMap: state.categoryMap,
              onPickDate: () =>
                  _pickDate(context, notifier, state.selectedDate),
              onEditItem: (item) =>
                  _openEditor(context, notifier, state, item),
              onDeleteItem: (item) => _confirmDelete(context, notifier, item),
            ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DataManageViewModel notifier,
    DateTime selectedDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    await notifier.pickDate(picked);
  }

  Future<void> _openEditor(
    BuildContext context,
    DataManageViewModel notifier,
    DataManageState state,
    TimelineItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DataItemEditorSheet(
        item: item,
        categories: state.categories,
        selectedDate: state.selectedDate,
        onSubmit: notifier.updateItem,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DataManageViewModel notifier,
    TimelineItem item,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除数据'),
          content: const Text('确定要删除这条记录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (result != true) {
      return;
    }
    await notifier.deleteItem(item);
  }
}
