import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_service.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(FileService());
});

final categoriesViewModelProvider =
    NotifierProvider<CategoriesViewModel, CategoriesState>(
  CategoriesViewModel.new,
);

class CategoriesState {
  const CategoriesState({
    required this.items,
    this.isLoading = false,
  });

  final List<Category> items;
  final bool isLoading;

  List<Category> get activeItems {
    return items;
  }

  CategoriesState copyWith({
    List<Category>? items,
    bool? isLoading,
  }) {
    return CategoriesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoriesViewModel extends Notifier<CategoriesState> {
  @override
  CategoriesState build() {
    _load();
    return const CategoriesState(items: [], isLoading: true);
  }

  Future<void> _load() async {
    final items = await ref.read(categoryRepositoryProvider).load();
    state = CategoriesState(items: _sorted(items));
  }

  Future<void> addCategory({
    required String name,
    required String iconCode,
    required String colorHex,
    required bool enabled,
  }) async {
    final newItem = Category(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconCode: iconCode,
      colorHex: colorHex,
      order: _nextOrder(),
      enabled: enabled,
    );
    final updated = [...state.items, newItem];
    await _persist(updated);
  }

  Future<void> updateCategory(
    Category target, {
    required String name,
    required String iconCode,
    required String colorHex,
    required bool enabled,
  }) async {
    final updated = state.items.map((item) {
      if (item.id != target.id) {
        return item;
      }
      return item.copyWith(
        name: name,
        iconCode: iconCode,
        colorHex: colorHex,
        enabled: enabled,
      );
    }).toList();
    await _persist(updated);
  }

  Future<void> deleteCategory(Category target) async {
    final updated =
        state.items.where((item) => item.id != target.id).toList(growable: false);
    await _persist(updated);
  }

  int _nextOrder() {
    if (state.items.isEmpty) {
      return 1;
    }
    final maxOrder = state.items.map((item) => item.order).reduce(max);
    return maxOrder + 1;
  }

  List<Category> _sorted(List<Category> items) {
    final sorted = [...items];
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  Future<void> _persist(List<Category> items) async {
    final sorted = _sorted(items);
    state = state.copyWith(items: sorted, isLoading: false);
    await ref.read(categoryRepositoryProvider).save(sorted);
  }
}
