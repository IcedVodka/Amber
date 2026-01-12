import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/models/category.dart';
import '../view_models/activity_view_model.dart';
import 'dialogs/start_timer_dialog.dart';
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
    final state = ref.watch(activityViewModelProvider);
    final notifier = ref.read(activityViewModelProvider.notifier);

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
              now: state.now,
              categories: state.activeCategories,
              session: session,
              activeCategory: activeCategory,
              currentDuration: session?.currentDuration ?? 0,
              onStartCategory: (category) => _openStartDialog(
                category,
                notifier,
              ),
              onPause: notifier.pauseTimer,
              onResume: notifier.resumeTimer,
              onStop: () async {
                await notifier.stopTimer();
                _scrollToBottom();
              },
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

  Future<void> _openStartDialog(
    Category category,
    ActivityViewModel notifier,
  ) async {
    final content = await showDialog<String>(
      context: context,
      builder: (context) => StartTimerDialog(category: category),
    );
    if (content == null || content.isEmpty) {
      return;
    }
    await notifier.startTimer(category, content);
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
