import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// GoblinEnemyConfig
/// ---------------------------------------------------------------------------
/// Holds all static data, constants, and utility methods for GoblinEnemyView configuration.
/// No business logic here. Use this pattern for other configs.
abstract class GoblinEnemyConfig {
  //////////////////////////////////////////////////////////////////////////////
  // STATS & CONSTANTS
  //////////////////////////////////////////////////////////////////////////////
  /// The amount of damage dealt by the Goblin enemy per attack
  static const double attackDamage = 25.0;

  /// The total life points of the Goblin enemy
  static const double life = 120.0;

  /// The movement speed of the Goblin enemy
  static const double speed = GameplayConstants.kCharacterSpeedSlow;

  /// The interval (ms) between attacks
  static const int attackInterval = 800;

  //////////////////////////////////////////////////////////////////////////////
  // SPRITE & DIMENSIONS
  //////////////////////////////////////////////////////////////////////////////
  /// The size of the Goblin enemy's hitbox
  static final Vector2 hitboxSize = Vector2.all(7.0);

  /// The position offset for the hitbox
  static final Vector2 hitboxPosition = Vector2(3.0, 4.0);

  /// The sprite size for the Goblin enemy
  static final Vector2 spriteSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );

  /// The size of the attack effect
  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  //////////////////////////////////////////////////////////////////////////////
  // ANIMATION & HITBOX
  //////////////////////////////////////////////////////////////////////////////
  /// Adds the hitbox to the given target component
  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));

  /// Returns the directional animation for the Goblin enemy
  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      EnemySpriteAnimations.goblinEnemyDirectional;
}
