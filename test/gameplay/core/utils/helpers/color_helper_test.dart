import 'package:darkness_dungeon/gameplay/core/utils/helpers/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorHelper', () {
    group('fromHexString', () {
      test('should convert valid hex string with # prefix to Color', () {
        final color = ColorHelper.fromHexString('#FF0000');

        expect(color, isNotNull);
        expect(color!.red, equals(255));
        expect(color.green, equals(0));
        expect(color.blue, equals(0));
        expect(color.alpha, equals(255));
      });

      test('should convert valid hex string without # prefix to Color', () {
        final color = ColorHelper.fromHexString('00FF00');

        expect(color, isNotNull);
        expect(color!.red, equals(0));
        expect(color.green, equals(255));
        expect(color.blue, equals(0));
        expect(color.alpha, equals(255));
      });

      test('should return null for null input', () {
        final color = ColorHelper.fromHexString(null);
        expect(color, isNull);
      });

      test('should return null for empty string', () {
        final color = ColorHelper.fromHexString('');
        expect(color, isNull);
      });

      test('should return null for invalid hex string', () {
        final color = ColorHelper.fromHexString('invalid');
        expect(color, isNull);
      });

      test('should return null for wrong length hex string', () {
        final color = ColorHelper.fromHexString('#FFF');
        expect(color, isNull);
      });
    });

    group('fromHexStringWithAlpha', () {
      test('should convert hex string with custom alpha', () {
        final color = ColorHelper.fromHexStringWithAlpha('#FF0000', 0.5);

        expect(color, isNotNull);
        expect(color!.red, equals(255));
        expect(color.green, equals(0));
        expect(color.blue, equals(0));
        expect(color.opacity, closeTo(0.5, 0.01));
      });

      test('should clamp alpha values below 0.0', () {
        final color = ColorHelper.fromHexStringWithAlpha('#FF0000', -0.5);

        expect(color, isNotNull);
        expect(color!.opacity, equals(0.0));
      });

      test('should clamp alpha values above 1.0', () {
        final color = ColorHelper.fromHexStringWithAlpha('#FF0000', 1.5);

        expect(color, isNotNull);
        expect(color!.opacity, equals(1.0));
      });
    });

    group('toHexString', () {
      test('should convert Color to hex string', () {
        const color = Color(0xFFFF0000);
        final hexString = ColorHelper.toHexString(color);

        expect(hexString, equals('#FF0000'));
      });

      test('should convert Color with different values to hex string', () {
        const color = Color(0xFF00FF00);
        final hexString = ColorHelper.toHexString(color);

        expect(hexString, equals('#00FF00'));
      });
    });

    group('isValidHexString', () {
      test('should return true for valid hex string with #', () {
        expect(ColorHelper.isValidHexString('#FF0000'), isTrue);
      });

      test('should return true for valid hex string without #', () {
        expect(ColorHelper.isValidHexString('FF0000'), isTrue);
      });

      test('should return false for null', () {
        expect(ColorHelper.isValidHexString(null), isFalse);
      });

      test('should return false for empty string', () {
        expect(ColorHelper.isValidHexString(''), isFalse);
      });

      test('should return false for invalid characters', () {
        expect(ColorHelper.isValidHexString('GG0000'), isFalse);
      });

      test('should return false for wrong length', () {
        expect(ColorHelper.isValidHexString('#FFF'), isFalse);
      });
    });

    group('fromRGB', () {
      test('should create Color from RGB values', () {
        final color = ColorHelper.fromRGB(255, 128, 64);

        expect(color.red, equals(255));
        expect(color.green, equals(128));
        expect(color.blue, equals(64));
        expect(color.alpha, equals(255));
      });

      test('should clamp RGB values above 255', () {
        final color = ColorHelper.fromRGB(300, 300, 300);

        expect(color.red, equals(255));
        expect(color.green, equals(255));
        expect(color.blue, equals(255));
      });

      test('should clamp RGB values below 0', () {
        final color = ColorHelper.fromRGB(-10, -20, -30);

        expect(color.red, equals(0));
        expect(color.green, equals(0));
        expect(color.blue, equals(0));
      });
    });

    group('fromRGBA', () {
      test('should create Color from RGBA values', () {
        final color = ColorHelper.fromRGBA(255, 128, 64, 0.5);

        expect(color.red, equals(255));
        expect(color.green, equals(128));
        expect(color.blue, equals(64));
        expect(color.opacity, closeTo(0.5, 0.01));
      });

      test('should clamp alpha values', () {
        final color1 = ColorHelper.fromRGBA(255, 128, 64, -0.5);
        final color2 = ColorHelper.fromRGBA(255, 128, 64, 1.5);

        expect(color1.opacity, equals(0.0));
        expect(color2.opacity, equals(1.0));
      });
    });
  });
}
