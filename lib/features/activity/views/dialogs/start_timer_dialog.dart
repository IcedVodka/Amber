import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class StartTimerDialog extends StatefulWidget {
  const StartTimerDialog({super.key, required this.category});

  final Category category;

  @override
  State<StartTimerDialog> createState() => _StartTimerDialogState();
}

class _StartTimerDialogState extends State<StartTimerDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcon.iconByCode(widget.category.iconCode);
    return AlertDialog(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: widget.category.color.withOpacity(0.2),
          foregroundColor: widget.category.color,
          child: Icon(icon),
        ),
        title: Text('开始 ${widget.category.name}'),
        subtitle: const Text('输入本次专注内容'),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '例如：功能开发 / 阅读',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('开始计时'),
        ),
      ],
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    Navigator.of(context).pop(value);
  }
}
