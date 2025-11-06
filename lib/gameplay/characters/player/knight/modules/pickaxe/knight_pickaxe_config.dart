import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

class KnightPickaxeConfig {
  KnightPickaxeConfig._();

  static const Duration defaultAttackDuration = Duration(milliseconds: 500);

  static Vector2 get _textureSize => GameplayTileConstants.tileSizeStandard;
  static Vector2 get componentSize => _textureSize / 2;

  static Vector2 get defaultStaticOffset => Vector2(8, 14);
  static Vector2 get defaultRightOffset => Vector2(-2, 0);
  static Vector2 get defaultLeftOffset => Vector2(2, 0);

  static const double maxRotationAngle = math.pi / 3; // 60 degrees

  static const double windUpFraction = 0.1;
  static const double strikeFraction = 0.2;
  static const double recoveryFraction = 0.7;
}
