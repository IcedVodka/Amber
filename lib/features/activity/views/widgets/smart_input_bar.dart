import 'package:flutter/material.dart';

import '../../../categories/models/category.dart';
import '../../../categories/models/category_icons.dart';

class SmartInputBar extends StatefulWidget {
  const SmartInputBar({
    super.key,
    required this.categories,
    required this.onSubmit,
  });

  final List<Category> categories;
  final Future<bool> Function(String text) onSubmit;

  @override
  State<SmartInputBar> createState() => _SmartInputBarState();
}

class _SmartInputBarState extends State<SmartInputBar> {
  final TextEditingController _controller = TextEditingController();
  List<Category> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateSuggestions);
  }

  @override
  void didUpdateWidget(covariant SmartInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _updateSuggestions();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSuggestions);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (_suggestions.isNotEmpty)
              SuggestionPanel(
                suggestions: _suggestions,
                onSelected: _applySuggestion,
              ),
            _InputRow(
              controller: _controller,
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    final ok = await widget.onSubmit(text);
    if (ok) {
      _controller.clear();
    }
  }

  void _applySuggestion(Category category) {
    final text = _controller.text;
    final index = text.lastIndexOf('#');
    final prefix = index == -1 ? text : text.substring(0, index);
    final updated = '${prefix}#${category.id} ';
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
  }

  void _updateSuggestions() {
    final query = _extractQuery(_controller.text);
    if (query == null) {
      setState(() => _suggestions = const []);
      return;
    }
    final active = widget.categories.where((item) => item.enabled).toList();
    if (query.isEmpty) {
      setState(() => _suggestions = active);
      return;
    }
    setState(() {
      _suggestions = active
          .where((item) =>
              item.id.startsWith(query) || item.name.startsWith(query))
          .toList();
    });
  }

  String? _extractQuery(String text) {
    final index = text.lastIndexOf('#');
    if (index == -1) {
      return null;
    }
    final query = text.substring(index + 1);
    if (query.contains(' ')) {
      return null;
    }
    return query;
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入 #分类 内容 1h30m *1.0',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        trailing: IconButton.filled(
          onPressed: onSubmit,
          icon: const Icon(Icons.send_rounded),
        ),
      ),
    );
  }
}

class SuggestionPanel extends StatelessWidget {
  const SuggestionPanel({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<Category> suggestions;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map((item) => _CategoryChip(
                      category: item,
                      onSelected: () => onSelected(item),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.onSelected,
  });

  final Category category;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcon.iconByCode(category.iconCode);
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: category.color.withOpacity(0.2),
        foregroundColor: category.color,
        child: Icon(icon, size: 16),
      ),
      label: Text(category.name),
      onPressed: onSelected,
    );
  }
}
