import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import 'categories_list_provider.dart';

final categoriesReorderProvider = Provider<CategoriesReorderViewModel>((ref) {
  return CategoriesReorderViewModel(ref);
});

class CategoriesReorderViewModel {
  CategoriesReorderViewModel(this._ref);

  final Ref _ref;

  Future<void> reorder(int oldIndex, int newIndex) async {
    final items = [..._ref.read(categoriesListProvider).activeItems];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    final reordered = _applyOrder(items);
    await _ref.read(categoriesListProvider.notifier).replaceAll(reordered);
  }

  List<Category> _applyOrder(List<Category> items) {
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(order: index + 1),
    ];
  }
}
