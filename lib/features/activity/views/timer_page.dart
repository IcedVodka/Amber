import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/models/category.dart';
import '../../sync/view_models/sync_view_model.dart';
import '../view_models/activity_view_model.dart';
import 'dialogs/stop_timer_dialog.dart';
import 'widgets/focus_panel.dart';
import 'widgets/smart_input_bar.dart';
import 'widgets/timeline_list.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncViewState>(syncViewModelProvider, (prev, next) {
      if (next.errorId == prev?.errorId) {
        return;
      }
      final message = next.errorMessage;
      if (message == null || message.isEmpty) {
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });

    final state = ref.watch(activityViewModelProvider);
    final notifier = ref.read(activityViewModelProvider.notifier);
    final syncState = ref.watch(syncViewModelProvider);
    final syncNotifier = ref.read(syncViewModelProvider.notifier);

    if (state.isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final session = state.session;
    final activeCategory = session == null
        ? null
        : _findCategory(state.categories, session.categoryId);
    final categoryMap = {
      for (final item in state.categories) item.id: item,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FocusPanel(
              categories: state.activeCategories,
              session: session,
              activeCategory: activeCategory,
              currentDuration: session?.currentDuration ?? 0,
              onStartCategory: _handleStartCategory,
              onPause: notifier.pauseTimer,
              onResume: notifier.resumeTimer,
              onContentChanged: notifier.updateSessionContent,
              onStop: () async {
                final weight = await showDialog<double>(
                  context: context,
                  builder: (_) => StopTimerDialog(
                    category: activeCategory,
                    content: session?.content ?? '',
                    initialWeight: activeCategory?.defaultWeight ?? 1.0,
                  ),
                );
                if (weight == null) {
                  return;
                }
                await notifier.stopTimer(weightOverride: weight);
                _scrollToBottom();
              },
              isSyncing: syncState.isSyncing,
              syncStatus: syncState.syncStatus,
              lastSyncedAt: syncState.lastSyncedAt,
              onHotSync: syncNotifier.triggerHotSync,
            ),
            Expanded(
              child: TimelineList(
                items: state.items,
                categoryMap: categoryMap,
                controller: _scrollController,
              ),
            ),
            SmartInputBar(
              categories: state.activeCategories,
              onSubmit: (text) async {
                final ok = await notifier.addFromInput(text);
                if (ok) {
                  _scrollToBottom();
                }
                return ok;
              },
            ),
          ],
        ),
      ),
    );
  }

  Category? _findCategory(List<Category> categories, String id) {
    for (final item in categories) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> _handleStartCategory(Category category) async {
    await ref
        .read(activityViewModelProvider.notifier)
        .startTimer(category, '');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }
}
