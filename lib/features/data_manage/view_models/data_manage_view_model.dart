import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_service.dart';
import '../../activity/models/timeline_item.dart';
import '../../activity/repositories/timeline_repository.dart';
import '../../categories/models/category.dart';
import '../../categories/view_models/categories_list_provider.dart';

final dataManageTimelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository(FileService());
});

final dataManageViewModelProvider =
    NotifierProvider<DataManageViewModel, DataManageState>(
  DataManageViewModel.new,
);

class DataManageState {
  const DataManageState({
    required this.isLoading,
    required this.selectedDate,
    required this.items,
    required this.categories,
  });

  final bool isLoading;
  final DateTime selectedDate;
  final List<TimelineItem> items;
  final List<Category> categories;

  Map<String, Category> get categoryMap {
    return {
      for (final item in categories) item.id: item,
    };
  }

  DataManageState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    List<TimelineItem>? items,
    List<Category>? categories,
  }) {
    return DataManageState(
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      items: items ?? this.items,
      categories: categories ?? this.categories,
    );
  }
}

class DataManageViewModel extends Notifier<DataManageState> {
  @override
  DataManageState build() {
    final now = _normalizeDate(DateTime.now());
    Future.microtask(() => _load(now));
    return DataManageState(
      isLoading: true,
      selectedDate: now,
      items: const [],
      categories: const [],
    );
  }

  Future<void> pickDate(DateTime date) async {
    await _load(_normalizeDate(date));
  }

  Future<void> updateItem(TimelineItem updated) async {
    final items = state.items.map((item) {
      if (item.id == updated.id) {
        return updated;
      }
      return item;
    }).toList();
    final sorted = _sorted(items);
    state = state.copyWith(items: sorted);
    await ref
        .read(dataManageTimelineRepositoryProvider)
        .saveFor(state.selectedDate, sorted);
  }

  Future<void> deleteItem(TimelineItem target) async {
    final items = state.items
        .where((item) => item.id != target.id)
        .toList(growable: false);
    state = state.copyWith(items: items);
    await ref
        .read(dataManageTimelineRepositoryProvider)
        .saveFor(state.selectedDate, items);
  }

  Future<void> _load(DateTime date) async {
    state = state.copyWith(isLoading: true, selectedDate: date);
    final categories = await ref.read(categoryRepositoryProvider).load();
    final items =
        await ref.read(dataManageTimelineRepositoryProvider).loadFor(date);
    state = state.copyWith(
      isLoading: false,
      categories: categories,
      items: _sorted(items),
    );
  }

  List<TimelineItem> _sorted(List<TimelineItem> items) {
    final sorted = [...items];
    sorted.sort((a, b) => a.sortTime.compareTo(b.sortTime));
    return sorted;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
