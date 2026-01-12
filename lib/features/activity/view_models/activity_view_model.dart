import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_service.dart';
import '../../categories/models/category.dart';
import '../../categories/view_models/categories_list_provider.dart';
import '../models/timeline_item.dart';
import '../models/timer_session.dart';
import '../repositories/session_repository.dart';
import '../repositories/timeline_repository.dart';
import 'smart_input_parser.dart';

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository(FileService());
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(FileService());
});

final activityViewModelProvider =
    NotifierProvider<ActivityViewModel, ActivityViewState>(
  ActivityViewModel.new,
);

class ActivityViewState {
  const ActivityViewState({
    required this.now,
    required this.categories,
    required this.items,
    required this.session,
    required this.isLoading,
  });

  static const Object _sessionSentinel = Object();

  final DateTime now;
  final List<Category> categories;
  final List<TimelineItem> items;
  final TimerSession? session;
  final bool isLoading;

  List<Category> get activeCategories {
    return categories.where((item) => item.enabled).toList(growable: false);
  }

  ActivityViewState copyWith({
    DateTime? now,
    List<Category>? categories,
    List<TimelineItem>? items,
    Object? session = _sessionSentinel,
    bool? isLoading,
  }) {
    return ActivityViewState(
      now: now ?? this.now,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      session: session == _sessionSentinel
          ? this.session
          : session as TimerSession?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ActivityViewModel extends Notifier<ActivityViewState> {
  Timer? _ticker;

  @override
  ActivityViewState build() {
    ref.onDispose(() => _ticker?.cancel());
    _load();
    return ActivityViewState(
      now: DateTime.now(),
      categories: const [],
      items: const [],
      session: null,
      isLoading: true,
    );
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final categories = await ref.read(categoryRepositoryProvider).load();
    final items = await ref.read(timelineRepositoryProvider).loadFor(now);
    final session = await ref.read(sessionRepositoryProvider).load();
    state = state.copyWith(
      now: now,
      categories: categories,
      items: _sorted(items),
      session: session,
      isLoading: false,
    );
    _syncTicker();
  }

  Future<void> startTimer(Category category, String content) async {
    final now = DateTime.now();
    final session = TimerSession(
      isRunning: true,
      categoryId: category.id,
      content: content,
      startAt: now,
      accumulatedSec: 0,
      lastResumeAt: now,
    );
    state = state.copyWith(now: now, session: session);
    await ref.read(sessionRepositoryProvider).save(session);
    _syncTicker();
  }

  Future<void> pauseTimer() async {
    final session = state.session!;
    final now = DateTime.now();
    final updated = session.copyWith(
      isRunning: false,
      accumulatedSec: session.accumulatedSec +
          now.difference(session.lastResumeAt!).inSeconds,
    );
    state = state.copyWith(now: now, session: updated);
    await ref.read(sessionRepositoryProvider).save(updated);
    _syncTicker();
  }

  Future<void> resumeTimer() async {
    final session = state.session!;
    final now = DateTime.now();
    final updated = session.copyWith(
      isRunning: true,
      lastResumeAt: now,
    );
    state = state.copyWith(now: now, session: updated);
    await ref.read(sessionRepositoryProvider).save(updated);
    _syncTicker();
  }

  Future<void> stopTimer() async {
    final session = state.session!;
    final now = DateTime.now();
    final category = _findCategory(session.categoryId);
    final record = TimeRecord(
      id: _newId('record'),
      categoryId: session.categoryId,
      content: session.content,
      startAt: session.startAt,
      endAt: now,
      durationSec: session.currentDuration,
      weight: category?.defaultWeight ?? 1.0,
    );
    final updated = _sorted([...state.items, record]);
    state = state.copyWith(now: now, items: updated, session: null);
    await ref.read(timelineRepositoryProvider).saveFor(now, updated);
    await ref.read(sessionRepositoryProvider).clear();
    _syncTicker();
  }

  Future<bool> addFromInput(String text) async {
    final parser = SmartInputParser(state.categories);
    final item = parser.parse(text);
    if (item == null) {
      return false;
    }
    final now = DateTime.now();
    final updated = _sorted([...state.items, item]);
    state = state.copyWith(now: now, items: updated);
    await ref.read(timelineRepositoryProvider).saveFor(now, updated);
    return true;
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (state.session?.isRunning ?? false) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        state = state.copyWith(now: DateTime.now());
      });
    }
  }

  Category? _findCategory(String id) {
    for (final item in state.categories) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  List<TimelineItem> _sorted(List<TimelineItem> items) {
    final sorted = [...items];
    sorted.sort((a, b) => a.sortTime.compareTo(b.sortTime));
    return sorted;
  }

  String _newId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
