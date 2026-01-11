import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/category_colors.dart';
import '../models/category_icons.dart';

final categoryEditorProvider = AutoDisposeNotifierProviderFamily<
    CategoryEditorNotifier, CategoryEditorState, Category?>(
  CategoryEditorNotifier.new,
);

class CategoryFormValue {
  const CategoryFormValue({
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.enabled,
  });

  final String name;
  final String iconCode;
  final String colorHex;
  final bool enabled;
}

class CategoryEditorState {
  const CategoryEditorState({
    required this.name,
    required this.icon,
    required this.group,
    required this.colorSeed,
    required this.colorOption,
    required this.enabled,
  });

  final String name;
  final CategoryIcon icon;
  final CategoryIconGroup group;
  final CategoryColorSeed colorSeed;
  final CategoryColorOption colorOption;
  final bool enabled;

  List<CategoryColorSeed> get seeds => categoryColorSeeds;
  List<CategoryIconGroup> get groups => CategoryIconGroup.values;
  List<CategoryIcon> get groupIcons => group.icons;
  List<CategoryColorOption> get variants => variantsForSeed(colorSeed);

  bool get canSubmit => name.trim().isNotEmpty;

  CategoryFormValue? get formValue {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return CategoryFormValue(
      name: trimmed,
      iconCode: icon.code,
      colorHex: colorOption.hex,
      enabled: enabled,
    );
  }

  CategoryEditorState copyWith({
    String? name,
    CategoryIcon? icon,
    CategoryIconGroup? group,
    CategoryColorSeed? colorSeed,
    CategoryColorOption? colorOption,
    bool? enabled,
  }) {
    return CategoryEditorState(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      group: group ?? this.group,
      colorSeed: colorSeed ?? this.colorSeed,
      colorOption: colorOption ?? this.colorOption,
      enabled: enabled ?? this.enabled,
    );
  }
}

class CategoryEditorNotifier
    extends AutoDisposeFamilyNotifier<CategoryEditorState, Category?> {
  @override
  CategoryEditorState build(Category? initial) {
    final icon = CategoryIcon.fromCode(initial?.iconCode);
    final colorOption = resolveCategoryColorOption(initial?.colorHex);
    final seed = resolveCategoryColorSeed(colorOption.hex);
    return CategoryEditorState(
      name: initial?.name ?? '',
      icon: icon,
      group: icon.group,
      colorSeed: seed,
      colorOption: colorOption,
      enabled: initial?.enabled ?? true,
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateSeed(CategoryColorSeed seed) {
    final variants = variantsForSeed(seed);
    final selected = variants.firstWhere(
      (option) => option.hex == state.colorOption.hex,
      orElse: () => variants[1],
    );
    state = state.copyWith(colorSeed: seed, colorOption: selected);
  }

  void updateColorOption(CategoryColorOption option) {
    state = state.copyWith(colorOption: option);
  }

  void updateGroup(CategoryIconGroup group) {
    state = state.copyWith(group: group);
  }

  void updateIcon(CategoryIcon icon) {
    state = state.copyWith(icon: icon);
  }

  void updateEnabled(bool value) {
    state = state.copyWith(enabled: value);
  }
}
