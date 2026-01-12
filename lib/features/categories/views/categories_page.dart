import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../view_models/categories_list_provider.dart';
import '../view_models/categories_reorder_provider.dart';
import 'dialogs/category_editor_sheet.dart';
import 'widgets/categories_page_content.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesListProvider);

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
        onReorder: (oldIndex, newIndex) => ref
            .read(categoriesReorderProvider)
            .reorder(oldIndex, newIndex),
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
          final notifier = ref.read(categoriesListProvider.notifier);
          if (category == null) {
            await notifier.addCategory(
              name: value.name,
              iconCode: value.iconCode,
              colorHex: value.colorHex,
              enabled: value.enabled,
              defaultWeight: value.defaultWeight,
            );
            return;
          }
          await notifier.updateCategory(
            category,
            name: value.name,
            iconCode: value.iconCode,
            colorHex: value.colorHex,
            enabled: value.enabled,
            defaultWeight: value.defaultWeight,
          );
        },
        onDelete: category == null
            ? null
            : () => ref
                .read(categoriesListProvider.notifier)
                .deleteCategory(category),
      ),
    );
  }
}
