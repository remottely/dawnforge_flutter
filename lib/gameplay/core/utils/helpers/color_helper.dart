import 'package:flutter/material.dart';

class ColorHelper {
  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) {
      return null;
    }

    try {
      final cleanHexString = hex.replaceAll('#', '');

      if (cleanHexString.length != 8) {
        return null;
      }

      final hexValue = int.parse(cleanHexString, radix: 16);
      return Color(hexValue);
    } catch (e) {
      return null;
    }
  }

  static String toHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0')}'.toUpperCase();

  static Color? fromHexStringWithAlpha(String? hexString, double alpha) {
    final baseColor = fromHex(hexString);
    if (baseColor == null) {
      return null;
    }

    final clampedAlpha = alpha.clamp(0.0, 1.0);
    return baseColor.withValues(alpha: clampedAlpha);
  }

  static bool isValidHexString(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return false;
    }

    final cleanHexString = hexString.replaceAll('#', '');

    if (cleanHexString.length != 8) {
      return false;
    }

    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleanHexString);
  }

  static Color fromRGB(int red, int green, int blue) {
    return Color.fromRGBO(
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
      1.0,
    );
  }

  static Color fromRGBA(int red, int green, int blue, double alpha) {
    return Color.fromRGBO(
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
      alpha.clamp(0.0, 1.0),
    );
  }
}
