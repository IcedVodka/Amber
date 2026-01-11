import 'package:flutter/material.dart';

class CategoryColorOption {
  const CategoryColorOption({
    required this.hex,
    required this.color,
    required this.label,
  });

  final String hex;
  final Color color;
  final String label;
}

enum CategoryColorSeed {
  amber('琥珀', Color(0xFFFFB000)),
  coral('珊瑚', Color(0xFFFF6B6B)),
  orange('橙子', Color(0xFFFF8A3D)),
  apricot('杏黄', Color(0xFFFFC857)),
  mint('薄荷', Color(0xFF1AC98B)),
  olive('橄榄', Color(0xFF7B9A3C)),
  ocean('海蓝', Color(0xFF00B4D8)),
  sky('晴空', Color(0xFF3A86FF)),
  indigo('靛蓝', Color(0xFF5A6CFF)),
  violet('紫罗兰', Color(0xFF9B6CFF)),
  rose('玫瑰', Color(0xFFF15BB5)),
  slate('石板', Color(0xFF8D99AE));

  const CategoryColorSeed(this.label, this.color);

  final String label;
  final Color color;
}

List<CategoryColorSeed> get categoryColorSeeds => CategoryColorSeed.values;

final List<CategoryColorOption> categoryColorOptions = [
  for (final seed in categoryColorSeeds) ...variantsForSeed(seed),
];

CategoryColorSeed resolveCategoryColorSeed(String? hex) {
  if (hex == null) {
    return categoryColorSeeds.first;
  }
  final normalized = hex.toUpperCase();
  for (final seed in categoryColorSeeds) {
    for (final option in variantsForSeed(seed)) {
      if (option.hex.toUpperCase() == normalized) {
        return seed;
      }
    }
  }
  return categoryColorSeeds.first;
}

CategoryColorOption resolveCategoryColorOption(String? hex) {
  if (hex == null) {
    return categoryColorOptions.first;
  }
  final normalized = hex.toUpperCase();
  return categoryColorOptions.firstWhere(
    (option) => option.hex.toUpperCase() == normalized,
    orElse: () => categoryColorOptions.first,
  );
}

List<CategoryColorOption> variantsForSeed(CategoryColorSeed seed) {
  return [
    _colorVariant(seed, _tint(seed.color, 0.45), '浅'),
    _colorVariant(seed, seed.color, '中'),
    _colorVariant(seed, _shade(seed.color, 0.25), '深'),
    _colorVariant(seed, _accent(seed.color), '强调'),
  ];
}

CategoryColorOption _colorVariant(
  CategoryColorSeed seed,
  Color color,
  String variant,
) {
  return CategoryColorOption(
    hex: _toHex(color),
    color: color,
    label: '${seed.label}-$variant',
  );
}

Color _tint(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

Color _shade(Color color, double amount) {
  return Color.lerp(color, Colors.black, amount) ?? color;
}

Color _accent(Color color) {
  final hsl = HSLColor.fromColor(color);
  final saturation = (hsl.saturation + 0.18).clamp(0.0, 1.0);
  final lightness = (hsl.lightness + 0.04).clamp(0.0, 1.0);
  return hsl
      .withSaturation(saturation)
      .withLightness(lightness)
      .toColor();
}

String _toHex(Color color) {
  final value = color.value & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
