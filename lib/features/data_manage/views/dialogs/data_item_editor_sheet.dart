import 'package:flutter/material.dart';

import '../../../activity/models/timeline_item.dart';
import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class DataItemEditorSheet extends StatelessWidget {
  const DataItemEditorSheet({
    super.key,
    required this.item,
    required this.categories,
    required this.selectedDate,
    required this.onSubmit,
  });

  final TimelineItem item;
  final List<Category> categories;
  final DateTime selectedDate;
  final Future<void> Function(TimelineItem item) onSubmit;

  @override
  Widget build(BuildContext context) {
    if (item is TimeRecord) {
      return _RecordEditorSheet(
        record: item as TimeRecord,
        categories: categories,
        selectedDate: selectedDate,
        onSubmit: onSubmit,
      );
    }
    if (item is Note) {
      return _NoteEditorSheet(
        note: item as Note,
        selectedDate: selectedDate,
        onSubmit: onSubmit,
      );
    }
    return const SizedBox.shrink();
  }
}

class _RecordEditorSheet extends StatefulWidget {
  const _RecordEditorSheet({
    required this.record,
    required this.categories,
    required this.selectedDate,
    required this.onSubmit,
  });

  final TimeRecord record;
  final List<Category> categories;
  final DateTime selectedDate;
  final Future<void> Function(TimelineItem item) onSubmit;

  @override
  State<_RecordEditorSheet> createState() => _RecordEditorSheetState();
}

class _RecordEditorSheetState extends State<_RecordEditorSheet> {
  late final TextEditingController _contentController;
  late final TextEditingController _weightController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _contentController = TextEditingController(text: record.content);
    _weightController =
        TextEditingController(text: _formatWeight(record.weight));
    _startTime = TimeOfDay.fromDateTime(record.startAt);
    _endTime = TimeOfDay.fromDateTime(record.endAt);
    _selectedCategory = _findCategory(record.categoryId) ??
        (widget.categories.isEmpty ? null : widget.categories.first);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final category = _selectedCategory;
    final icon = CategoryIcon.iconByCode(category?.iconCode);
    final color = category?.color ?? Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, viewInsets.bottom + 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            _EditorHeader(
              title: '编辑记录',
              icon: icon,
              color: color,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            if (widget.categories.isEmpty)
              const _CategoryPlaceholder()
            else
              _CategoryPicker(
                categories: widget.categories,
                value: category?.id ?? widget.record.categoryId,
                onChanged: _handleCategoryChanged,
              ),
            _EditorTextField(
              controller: _contentController,
              labelText: '内容',
              maxLines: 2,
            ),
            _TimePickerTile(
              label: '开始时间',
              timeLabel: _formatTimeOfDay(_startTime),
              onTap: _pickStartTime,
            ),
            _TimePickerTile(
              label: '结束时间',
              timeLabel: _formatTimeOfDay(_endTime),
              onTap: _pickEndTime,
            ),
            _EditorTextField(
              controller: _weightController,
              labelText: '权重',
              helperText: '范围 0.0-1.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            _EditorActions(
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Category? _findCategory(String id) {
    for (final item in widget.categories) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  void _handleCategoryChanged(String? id) {
    if (id == null) {
      return;
    }
    setState(() {
      _selectedCategory = _findCategory(id);
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _startTime = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _endTime = picked;
    });
  }

  Future<void> _submit() async {
    final record = widget.record;
    final categoryId = _selectedCategory?.id ?? record.categoryId;
    final startAt = _combineDate(widget.selectedDate, _startTime);
    var endAt = _combineDate(widget.selectedDate, _endTime);
    if (endAt.isBefore(startAt)) {
      endAt = endAt.add(const Duration(days: 1));
    }
    final durationSec = endAt.difference(startAt).inSeconds;
    final weight = _parseWeight(_weightController.text, record.weight);
    final updated = TimeRecord(
      id: record.id,
      categoryId: categoryId,
      content: _contentController.text,
      startAt: startAt,
      endAt: endAt,
      durationSec: durationSec,
      weight: weight,
    );
    await widget.onSubmit(updated);
    Navigator.pop(context);
  }
}

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({
    required this.note,
    required this.selectedDate,
    required this.onSubmit,
  });

  final Note note;
  final DateTime selectedDate;
  final Future<void> Function(TimelineItem item) onSubmit;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _contentController;
  late TimeOfDay _noteTime;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _noteTime = TimeOfDay.fromDateTime(widget.note.createdAt);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, viewInsets.bottom + 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            _EditorHeader(
              title: '编辑便签',
              icon: Icons.edit_note_outlined,
              color: Theme.of(context).colorScheme.primary,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            _EditorTextField(
              controller: _contentController,
              labelText: '内容',
              maxLines: 4,
            ),
            _TimePickerTile(
              label: '记录时间',
              timeLabel: _formatTimeOfDay(_noteTime),
              onTap: _pickNoteTime,
            ),
            const SizedBox(height: 12),
            _EditorActions(
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickNoteTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _noteTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _noteTime = picked;
    });
  }

  Future<void> _submit() async {
    final createdAt = _combineDate(widget.selectedDate, _noteTime);
    final updated = Note(
      id: widget.note.id,
      content: _contentController.text,
      createdAt: createdAt,
    );
    await widget.onSubmit(updated);
    Navigator.pop(context);
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.onClose,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        child: Icon(icon),
      ),
      title: Text(title),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('分类'),
      trailing: DropdownButton<String>(
        value: value,
        items: [
          for (final item in categories)
            DropdownMenuItem(
              value: item.id,
              child: Text(item.name),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('分类'),
      subtitle: Text('暂无可用分类'),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.label,
    required this.timeLabel,
    required this.onTap,
  });

  final String label;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(timeLabel),
      trailing: const Icon(Icons.schedule_outlined),
      onTap: onTap,
    );
  }
}

class _EditorTextField extends StatelessWidget {
  const _EditorTextField({
    required this.controller,
    required this.labelText,
    this.helperText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String labelText;
  final String? helperText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.onCancel,
    required this.onSubmit,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onSubmit,
            child: const Text('保存'),
          ),
        ),
      ],
    );
  }
}

DateTime _combineDate(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String _formatTimeOfDay(TimeOfDay time) {
  return '${_two(time.hour)}:${_two(time.minute)}';
}

String _formatWeight(double value) => value.toStringAsFixed(1);

double _parseWeight(String raw, double fallback) {
  final parsed = double.tryParse(raw);
  if (parsed == null) {
    return fallback;
  }
  return parsed.clamp(0.0, 1.0).toDouble();
}

String _two(int value) => value.toString().padLeft(2, '0');
