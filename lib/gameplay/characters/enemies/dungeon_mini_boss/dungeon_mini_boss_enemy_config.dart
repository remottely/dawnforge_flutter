import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

abstract class DungeonMiniBossEnemyConfig {
  static const double attackDamage = 50.0;

  static const double life = 150.0;

  static const double speed = GameplayConstants.kCharacterSpeedSlow;

  static const double closeVisionRadius = GameplayConstants.kVisionRadiusMedium;

  static const double longVisionRadius =
      GameplayConstants.kVisionRadiusExtraLarge;

  static const int meleeAttackInterval = 300;

  static final Vector2 hitboxSize = Vector2(6.0, 7.0);

  static final Vector2 hitboxPosition = Vector2(2.5, 8.0);

  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.68,
    GameplayConstants.kTileDimensionStandard * 0.93,
  );

  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static final double meleeDamageReduction = 3.0;

  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
}
