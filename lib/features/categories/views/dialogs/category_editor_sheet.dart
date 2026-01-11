import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../view_models/category_editor_provider.dart';
import '../widgets/category_editor_components.dart';

class CategoryEditorSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = categoryEditorProvider(initial);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = initial != null;

    return SafeArea(
      child: EditorBody(
        bottomInset: viewInsets.bottom,
        children: [
          EditorHeader(
            title: isEditing ? '编辑分类' : '新增分类',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          EditorNameHeader(
            name: state.name,
            icon: state.icon,
            color: state.colorOption,
            enabled: state.enabled,
            onNameChanged: notifier.updateName,
            onEnabledChanged: notifier.updateEnabled,
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: '主题颜色'),
          const SizedBox(height: 12),
          ColorPalette(
            items: [
              for (final seed in state.seeds)
                ColorPaletteItem(
                  color: seed.color,
                  label: seed.label,
                  selected: seed == state.colorSeed,
                  onTap: () => notifier.updateSeed(seed),
                ),
            ],
            rows: 2,
          ),
          const SizedBox(height: 12),
          ColorPalette(
            items: [
              for (final option in state.variants)
                ColorPaletteItem(
                  color: option.color,
                  label: option.label,
                  selected: option.hex == state.colorOption.hex,
                  onTap: () => notifier.updateColorOption(option),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: '图标库'),
          const SizedBox(height: 12),
          IconGroupSelector(
            groups: state.groups,
            selected: state.group,
            onChanged: notifier.updateGroup,
          ),
          const SizedBox(height: 12),
          IconGrid(
            options: state.groupIcons,
            selectedCode: state.icon.code,
            onChanged: notifier.updateIcon,
          ),
          const SizedBox(height: 20),
          EditorActions(
            confirmLabel: isEditing ? '保存' : '添加',
            onSubmit: () => _handleSubmit(context, state),
            onDelete: onDelete == null ? null : () => _handleDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    CategoryEditorState state,
  ) async {
    final value = state.formValue;
    if (value == null) {
      return;
    }
    await onSubmit(value);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final handler = onDelete;
    if (handler == null) {
      return;
    }
    await handler();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
