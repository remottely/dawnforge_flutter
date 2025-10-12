import 'package:flutter/material.dart';

/// Helper class for color string manipulation and conversion
/// Following Flutter naming conventions for utility classes
class ColorHelper {
  // Private constructor to prevent instantiation
  ColorHelper._();

  /// Converts a hex color string to a Color object
  /// Supports both '#RRGGBB' and 'RRGGBB' formats
  /// Returns null if the string is null or invalid
  ///
  /// Example:
  /// ```dart
  /// final color = ColorHelper.fromHex('#ffFF0000'); // Red
  /// final color2 = ColorHelper.fromHex('ff00FF00'); // Green
  /// ```
  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) {
      return null;
    }

    try {
      // Remove the '#' symbol if present
      final cleanHexString = hex.replaceAll('#', '');

      // Validate hex string format (must be 6 characters for RGB)
      if (cleanHexString.length != 8) {
        return null;
      }

      // Parse the hex string to integer and create Color
      final hexValue = int.parse(cleanHexString, radix: 16);
      return Color(hexValue | 0xFF000000); // Add alpha channel (fully opaque)
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }

  static String toHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0')}'.toUpperCase();

  // static Color? fromHex(String? hex) {
  //   if (hex == null || hex.isEmpty) {
  //     return null;
  //   }
  //   hex = hex.replaceAll('#', '');
  //   return Color(int.parse(hex, radix: 16));
  // }

  /// Converts a hex color string to a Color object with custom alpha
  /// Supports both '#RRGGBB' and 'RRGGBB' formats
  /// Alpha value should be between 0.0 (transparent) and 1.0 (opaque)
  /// Returns null if the string is null or invalid
  ///
  /// Example:
  /// ```dart
  /// final color = ColorHelper.fromHexStringWithAlpha('#FF0000', 0.5); // Semi-transparent red
  /// ```
  static Color? fromHexStringWithAlpha(String? hexString, double alpha) {
    final baseColor = fromHex(hexString);
    if (baseColor == null) {
      return null;
    }

    // Clamp alpha value between 0.0 and 1.0
    final clampedAlpha = alpha.clamp(0.0, 1.0);
    return baseColor.withValues(alpha: clampedAlpha);
  }

  // /// Converts a Color object to hex string format
  // /// Returns string in '#RRGGBB' format
  // ///
  // /// Example:
  // /// ```dart
  // /// final hexString = ColorHelper.toHexString(Colors.red); // '#F44336'
  // /// ```
  // static String toHexString(Color color) {
  //   final red = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
  //   final green = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
  //   final blue = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
  //   return '#$red$green$blue'.toUpperCase();
  // }

  /// Validates if a string is a valid hex color format
  /// Supports both '#RRGGBB' and 'RRGGBB' formats
  ///
  /// Example:
  /// ```dart
  /// final isValid = ColorHelper.isValidHexString('#FF0000'); // true
  /// final isValid2 = ColorHelper.isValidHexString('invalid'); // false
  /// ```
  static bool isValidHexString(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return false;
    }

    final cleanHexString = hexString.replaceAll('#', '');

    // Check if length is exactly 6 characters
    if (cleanHexString.length != 8) {
      return false;
    }

    // Check if all characters are valid hex digits
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleanHexString);
  }

  /// Creates a Color from individual RGB values
  /// RGB values should be between 0 and 255
  ///
  /// Example:
  /// ```dart
  /// final color = ColorHelper.fromRGB(255, 0, 0); // Red
  /// ```
  static Color fromRGB(int red, int green, int blue) {
    return Color.fromRGBO(
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
      1.0,
    );
  }

  /// Creates a Color from individual RGBA values
  /// RGB values should be between 0 and 255
  /// Alpha value should be between 0.0 and 1.0
  ///
  /// Example:
  /// ```dart
  /// final color = ColorHelper.fromRGBA(255, 0, 0, 0.5); // Semi-transparent red
  /// ```
  static Color fromRGBA(int red, int green, int blue, double alpha) {
    return Color.fromRGBO(
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
      alpha.clamp(0.0, 1.0),
    );
  }
}
