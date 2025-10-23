import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

abstract class ImpEnemyConfig {
  static const double attackDamage = 10.0;
  static const double life = 80.0;
  static const double speed = GameplayConstants.kCharacterSpeedMedium;
  static const int attackInterval = 300;
  static const double hitboxSize = 6.0;
  static final Vector2 hitboxPosition = Vector2(3.0, 5.0);
  static final Vector2 spriteSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );
  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;
  static void buildHitBox(GameComponent target) => target.add(
    RectangleHitbox(
      size: Vector2(hitboxSize, hitboxSize),
      position: hitboxPosition,
    ),
  );
  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      EnemySpriteAnimations.impEnemyDirectional;
}
