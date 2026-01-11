import 'package:flutter/material.dart';

Color tintColor(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

Color shadeColor(Color color, double amount) {
  return Color.lerp(color, Colors.black, amount) ?? color;
}

Color accentColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final saturation = (hsl.saturation + 0.18).clamp(0.0, 1.0);
  final lightness = (hsl.lightness + 0.04).clamp(0.0, 1.0);
  return hsl
      .withSaturation(saturation)
      .withLightness(lightness)
      .toColor();
}

String colorToHex(Color color) {
  final value = color.value & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
