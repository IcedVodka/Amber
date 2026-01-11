import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../view_models/categories_view_model.dart';
import 'weight/categories_content.dart';
import 'weight/category_editor_sheet.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesViewModelProvider);

    if (state.isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: CategoriesContent(
        items: state.activeItems,
        onAdd: () => _openEditor(context, ref),
        onEdit: (item) => _openEditor(context, ref, category: item),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryEditorSheet(
        initial: category,
        onSubmit: (value) async {
          final notifier = ref.read(categoriesViewModelProvider.notifier);
          if (category == null) {
            await notifier.addCategory(
              name: value.name,
              iconCode: value.iconCode,
              colorHex: value.colorHex,
              enabled: value.enabled,
            );
            return;
          }
          await notifier.updateCategory(
            category,
            name: value.name,
            iconCode: value.iconCode,
            colorHex: value.colorHex,
            enabled: value.enabled,
          );
        },
        onDelete: category == null
            ? null
            : () => ref
                .read(categoriesViewModelProvider.notifier)
                .deleteCategory(category),
      ),
    );
  }
}
