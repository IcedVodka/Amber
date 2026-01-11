import 'package:flutter/material.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.code,
    required this.icon,
    required this.label,
  });

  final String code;
  final IconData icon;
  final String label;
}

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

const List<CategoryIconOption> categoryIconOptions = [
  CategoryIconOption(
    code: 'briefcase',
    icon: Icons.work_rounded,
    label: '工作',
  ),
  CategoryIconOption(
    code: 'coffee',
    icon: Icons.local_cafe_rounded,
    label: '休息',
  ),
  CategoryIconOption(
    code: 'study',
    icon: Icons.menu_book_rounded,
    label: '学习',
  ),
  CategoryIconOption(
    code: 'fitness',
    icon: Icons.fitness_center_rounded,
    label: '运动',
  ),
  CategoryIconOption(
    code: 'heart',
    icon: Icons.favorite_rounded,
    label: '生活',
  ),
  CategoryIconOption(
    code: 'creative',
    icon: Icons.lightbulb_rounded,
    label: '创意',
  ),
];

const List<CategoryColorOption> categoryColorOptions = [
  CategoryColorOption(
    hex: '#FFB000',
    color: Color(0xFFFFB000),
    label: '琥珀',
  ),
  CategoryColorOption(
    hex: '#FF6B6B',
    color: Color(0xFFFF6B6B),
    label: '珊瑚',
  ),
  CategoryColorOption(
    hex: '#1AC98B',
    color: Color(0xFF1AC98B),
    label: '薄荷',
  ),
  CategoryColorOption(
    hex: '#5A6CFF',
    color: Color(0xFF5A6CFF),
    label: '靛蓝',
  ),
  CategoryColorOption(
    hex: '#9B6CFF',
    color: Color(0xFF9B6CFF),
    label: '紫罗兰',
  ),
  CategoryColorOption(
    hex: '#7B9A3C',
    color: Color(0xFF7B9A3C),
    label: '橄榄',
  ),
];

IconData resolveCategoryIcon(String code) {
  for (final option in categoryIconOptions) {
    if (option.code == code) {
      return option.icon;
    }
  }
  return Icons.label_rounded;
}

CategoryIconOption resolveCategoryIconOption(String? code) {
  return categoryIconOptions.firstWhere(
    (option) => option.code == code,
    orElse: () => categoryIconOptions.first,
  );
}

CategoryColorOption resolveCategoryColorOption(String? hex) {
  return categoryColorOptions.firstWhere(
    (option) => option.hex == hex,
    orElse: () => categoryColorOptions.first,
  );
}
