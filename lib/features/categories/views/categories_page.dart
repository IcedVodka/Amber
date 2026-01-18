import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/view_models/settings_view_model.dart';
import '../../sync/view_models/sync_view_model.dart';
import '../../sync/views/dialogs/sync_progress_dialog.dart';
import '../../../shared/routes/app_routes.dart';
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
    final settings = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
    final syncState = ref.watch(syncViewModelProvider);
    final syncNotifier = ref.read(syncViewModelProvider.notifier);

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
        onOpenDataManage: () => _openDataManage(context),
        selectedTheme: settings.themeOption,
        onThemeChange: settingsNotifier.updateTheme,
        syncConfig: syncState.config,
        syncIsLoading: syncState.isLoading,
        syncIsSyncing: syncState.isSyncing,
        onSyncConfigChanged: syncNotifier.updateConfig,
        onSyncTestConnection: () => _testConnection(context, syncNotifier),
        onSyncColdSync: () => _triggerColdSync(
          context,
          syncNotifier,
          syncState.isSyncing,
        ),
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

  void _openDataManage(BuildContext context) {
    context.push(AppRoutes.dataManage);
  }

  Future<void> _testConnection(
    BuildContext context,
    SyncViewModel notifier,
  ) async {
    final error = await notifier.testConnection();
    if (!context.mounted) {
      return;
    }
    final message = error ?? '连接成功';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _triggerColdSync(
    BuildContext context,
    SyncViewModel notifier,
    bool isSyncing,
  ) {
    if (isSyncing) {
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SyncProgressDialog(),
    );
    notifier.triggerColdSync();
  }
}
