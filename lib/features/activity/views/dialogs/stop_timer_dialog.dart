import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class StopTimerDialog extends StatefulWidget {
  const StopTimerDialog({
    super.key,
    required this.category,
    required this.content,
    required this.initialWeight,
  });

  final Category? category;
  final String content;
  final double initialWeight;

  @override
  State<StopTimerDialog> createState() => _StopTimerDialogState();
}

class _StopTimerDialogState extends State<StopTimerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: _formatWeight(widget.initialWeight));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('结束计时'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogHeader(
            category: widget.category,
            content: widget.content,
          ),
          const SizedBox(height: 12),
          _WeightInput(controller: _controller),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('确认'),
        ),
      ],
    );
  }

  void _submit() {
    final weight = _parseWeight(_controller.text, widget.initialWeight);
    Navigator.of(context).pop(weight);
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.category,
    required this.content,
  });

  final Category? category;
  final String content;

  @override
  Widget build(BuildContext context) {
    final icon = category == null
        ? Icons.timer_outlined
        : CategoryIcon.iconByCode(category!.iconCode);
    final color = category?.color ?? Theme.of(context).colorScheme.primary;
    final title = category?.name ?? '专注任务';
    final subtitle = content.isEmpty ? '未命名任务' : content;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.18),
        foregroundColor: color,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _WeightInput extends StatelessWidget {
  const _WeightInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: '权重',
        helperText: '范围 0.0-1.0',
        border: OutlineInputBorder(),
      ),
    );
  }
}

String _formatWeight(double value) => value.toStringAsFixed(1);

double _parseWeight(String raw, double fallback) {
  final parsed = double.tryParse(raw);
  if (parsed == null) {
    return fallback;
  }
  return parsed.clamp(0.0, 1.0).toDouble();
}
