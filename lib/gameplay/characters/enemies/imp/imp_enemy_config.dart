import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// ImpEnemyConfig
/// ---------------------------------------------------------------------------
/// Holds all static data, constants, and utility methods for ImpEnemyView configuration.
/// No business logic here. Use this pattern for other configs.
abstract class ImpEnemyConfig {
  //////////////////////////////////////////////////////////////////////////////
  // STATS & CONSTANTS
  //////////////////////////////////////////////////////////////////////////////
  /// The amount of damage dealt by the Imp enemy per attack
  static const double attackDamage = 10.0;

  /// The total life points of the Imp enemy
  static const double life = 80.0;

  /// The movement speed of the Imp enemy
  static const double speed = GameplayConstants.kCharacterSpeedMedium;

  /// The interval (ms) between attacks
  static const int attackInterval = 300;

  //////////////////////////////////////////////////////////////////////////////
  // SPRITE & DIMENSIONS
  //////////////////////////////////////////////////////////////////////////////
  /// The size of the Imp enemy's hitbox
  static const double hitboxSize = 6.0;

  /// The position offset for the hitbox
  static final Vector2 hitboxPosition = Vector2(3.0, 5.0);

  /// The sprite size for the Imp enemy
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
  static void buildHitBox(GameComponent target) => target.add(
    RectangleHitbox(
      size: Vector2(hitboxSize, hitboxSize),
      position: hitboxPosition,
    ),
  );

  /// Returns the directional animation for the Imp enemy
  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      EnemySpriteAnimations.impEnemyDirectional;
}
