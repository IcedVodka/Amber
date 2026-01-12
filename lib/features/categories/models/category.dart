import 'dart:ui';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.order,
    required this.enabled,
    required this.defaultWeight,
  });

  final String id;
  final String name;
  final String iconCode;
  final String colorHex;
  final int order;
  final bool enabled;
  final double defaultWeight;

  Color get color => _parseColor(colorHex);

  Category copyWith({
    String? id,
    String? name,
    String? iconCode,
    String? colorHex,
    int? order,
    bool? enabled,
    double? defaultWeight,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
      defaultWeight: defaultWeight ?? this.defaultWeight,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as String,
      colorHex: json['colorHex'] as String,
      order: json['order'] as int,
      enabled: json['enabled'] as bool? ?? true,
      defaultWeight: (json['defaultWeight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorHex': colorHex,
      'order': order,
      'enabled': enabled,
      'defaultWeight': defaultWeight,
    };
  }
}

Color _parseColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final buffer = StringBuffer();
  if (cleaned.length == 6) {
    buffer.write('ff');
  }
  buffer.write(cleaned);
  return Color(int.parse(buffer.toString(), radix: 16));
}
