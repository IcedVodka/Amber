import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../activity/models/timeline_item.dart';
import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class DataManageContent extends StatelessWidget {
  const DataManageContent({
    super.key,
    required this.selectedDate,
    required this.items,
    required this.categoryMap,
    required this.onPickDate,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  final DateTime selectedDate;
  final List<TimelineItem> items;
  final Map<String, Category> categoryMap;
  final VoidCallback onPickDate;
  final ValueChanged<TimelineItem> onEditItem;
  final ValueChanged<TimelineItem> onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _DatePickerCard(date: selectedDate, onTap: onPickDate),
      const SizedBox(height: 12),
      if (items.isEmpty) const _EmptyStateCard(),
      for (final item in items)
        DataManageItemCard(
          item: item,
          categoryMap: categoryMap,
          onEdit: () => onEditItem(item),
          onDelete: () => onDeleteItem(item),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: children,
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  const _DatePickerCard({
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.event_outlined)),
        title: Text(formatFullDate(date)),
        subtitle: Text(formatWeekday(date)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.edit_note_outlined),
        title: Text('这一天还没有数据'),
      ),
    );
  }
}

class DataManageItemCard extends StatelessWidget {
  const DataManageItemCard({
    super.key,
    required this.item,
    required this.categoryMap,
    required this.onEdit,
    required this.onDelete,
  });

  final TimelineItem item;
  final Map<String, Category> categoryMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (item is TimeRecord) {
      final record = item as TimeRecord;
      return _RecordItemTile(
        record: record,
        category: categoryMap[record.categoryId],
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }
    if (item is Note) {
      return _NoteItemTile(
        note: item as Note,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }
    return const SizedBox.shrink();
  }
}

class _RecordItemTile extends StatelessWidget {
  const _RecordItemTile({
    required this.record,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeRecord record;
  final Category? category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = category?.name ?? record.categoryId;
    final content = record.content.isEmpty ? '未命名记录' : record.content;
    final timeLabel =
        '${_formatTime(record.startAt)} - ${_formatTime(record.endAt)}';
    final duration = _formatDuration(record.durationSec);
    final weight = record.weight.toStringAsFixed(1);
    final subtitle = '$content\n$timeLabel · $duration · W $weight';
    final icon = CategoryIcon.iconByCode(category?.iconCode);
    final color = category?.color ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        isThreeLine: true,
        trailing: _ItemActions(
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _NoteItemTile extends StatelessWidget {
  const _NoteItemTile({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final content = note.content.isEmpty ? '空白便签' : note.content;
    final subtitle = _formatTime(note.createdAt);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.edit_note_outlined)),
        title: Text(content),
        subtitle: Text(subtitle),
        trailing: _ItemActions(
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _ItemActions extends StatelessWidget {
  const _ItemActions({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ItemAction>(
      onSelected: (value) {
        if (value == _ItemAction.edit) {
          onEdit();
          return;
        }
        onDelete();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ItemAction.edit,
          child: Text('编辑'),
        ),
        PopupMenuItem(
          value: _ItemAction.delete,
          child: Text('删除'),
        ),
      ],
    );
  }
}

enum _ItemAction { edit, delete }

String _formatTime(DateTime time) {
  return '${_two(time.hour)}:${_two(time.minute)}';
}

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}

String _two(int value) => value.toString().padLeft(2, '0');
