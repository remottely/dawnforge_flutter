import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

abstract class GoblinEnemyConfig {
  static const double attackDamage = 25.0;
  static const double life = 120.0;
  static const double speed = GameplayConstants.kCharacterSpeedSlow;
  static const int attackInterval = 800;
  static final Vector2 hitboxSize = Vector2.all(7.0);
  static final Vector2 hitboxPosition = Vector2(3.0, 4.0);
  static final Vector2 spriteSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );
  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;
  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      EnemySpriteAnimations.goblinEnemyDirectional;
}
