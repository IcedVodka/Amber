import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'category_options.dart';

class CategoryFormValue {
  const CategoryFormValue({
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.enabled,
  });

  final String name;
  final String iconCode;
  final String colorHex;
  final bool enabled;
}

class CategoryEditorSheet extends StatefulWidget {
  const CategoryEditorSheet({
    super.key,
    this.initial,
    required this.onSubmit,
    this.onDelete,
  });

  final Category? initial;
  final Future<void> Function(CategoryFormValue value) onSubmit;
  final Future<void> Function()? onDelete;

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late CategoryIconOption _iconOption;
  late CategoryColorOption _colorOption;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _iconOption = resolveCategoryIconOption(initial?.iconCode);
    _colorOption = resolveCategoryColorOption(initial?.colorHex);
    _enabled = initial?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initial != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final titleStyle =
        textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EditorHeader(
              title: isEditing ? '编辑分类' : '新增分类',
              titleStyle: titleStyle,
            ),
            const SizedBox(height: 16),
            _NameField(
              controller: _nameController,
              decoration: _buildDecoration(
                colorScheme,
                inputBorder,
                '分类名称',
              ),
            ),
            const SizedBox(height: 12),
            _IconField(
              value: _iconOption,
              decoration: _buildDecoration(colorScheme, inputBorder, '图标'),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _iconOption = value);
              },
            ),
            const SizedBox(height: 12),
            _ColorField(
              value: _colorOption,
              decoration: _buildDecoration(colorScheme, inputBorder, '颜色'),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _colorOption = value);
              },
            ),
            const SizedBox(height: 8),
            _EnabledTile(
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
            const SizedBox(height: 20),
            _EditorActions(
              confirmLabel: isEditing ? '保存' : '添加',
              onSubmit: _handleSubmit,
              onDelete: widget.onDelete == null ? null : _handleDelete,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildDecoration(
    ColorScheme colorScheme,
    OutlineInputBorder inputBorder,
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    await widget.onSubmit(
      CategoryFormValue(
        name: name,
        iconCode: _iconOption.code,
        colorHex: _colorOption.hex,
        enabled: _enabled,
      ),
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null) {
      return;
    }
    await onDelete();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.titleStyle,
  });

  final String title;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: titleStyle),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.decoration,
  });

  final TextEditingController controller;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: decoration,
      textInputAction: TextInputAction.done,
    );
  }
}

class _IconField extends StatelessWidget {
  const _IconField({
    required this.value,
    required this.decoration,
    required this.onChanged,
  });

  final CategoryIconOption value;
  final InputDecoration decoration;
  final ValueChanged<CategoryIconOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CategoryIconOption>(
      value: value,
      decoration: decoration,
      isExpanded: true,
      icon: const Icon(Icons.expand_more),
      items: categoryIconOptions
          .map(
            (option) => DropdownMenuItem<CategoryIconOption>(
              value: option,
              child: _IconOptionLabel(option: option),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.value,
    required this.decoration,
    required this.onChanged,
  });

  final CategoryColorOption value;
  final InputDecoration decoration;
  final ValueChanged<CategoryColorOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CategoryColorOption>(
      value: value,
      decoration: decoration,
      isExpanded: true,
      icon: const Icon(Icons.expand_more),
      items: categoryColorOptions
          .map(
            (option) => DropdownMenuItem<CategoryColorOption>(
              value: option,
              child: _ColorOptionLabel(option: option),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _EnabledTile extends StatelessWidget {
  const _EnabledTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('启用分类'),
      value: value,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.confirmLabel,
    required this.onSubmit,
    this.onDelete,
  });

  final String confirmLabel;
  final Future<void> Function() onSubmit;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Expanded(
        child: FilledButton(
          onPressed: () => onSubmit(),
          child: Text(confirmLabel),
        ),
      ),
    ];

    if (onDelete != null) {
      children.insert(
        0,
        Expanded(
          child: OutlinedButton(
            onPressed: () => onDelete?.call(),
            child: const Text('删除'),
          ),
        ),
      );
    }

    return Row(
      children: [
        children.first,
        if (children.length > 1) const SizedBox(width: 12),
        if (children.length > 1) children.last,
      ],
    );
  }
}

class _IconOptionLabel extends StatelessWidget {
  const _IconOptionLabel({required this.option});

  final CategoryIconOption option;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(option.icon),
        const SizedBox(width: 10),
        Text(option.label),
      ],
    );
  }
}

class _ColorOptionLabel extends StatelessWidget {
  const _ColorOptionLabel({required this.option});

  final CategoryColorOption option;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: option.color),
        const SizedBox(width: 10),
        Text(option.label),
      ],
    );
  }
}
