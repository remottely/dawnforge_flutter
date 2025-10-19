import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

/// Enemy character Imp for the Darkness Dungeon game
/// Following Flutter naming conventions for enemy entity systems
///
/// This class handles:
/// - Fast-paced melee combat with higher speed
/// - Player detection and pursuit mechanics
/// - Death effects and visual feedback
/// - Audio integration for attacks and damage
///
/// Usage patterns:
/// ```dart
/// final imp = ImpEnemy(position);
/// imp.onLoad();
/// ```
class ImpEnemy extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  // 1. Constants (grouped by type)
  static const double kDefaultAttackDamage = 10.0;
  static const double kDefaultLife = 80.0;
  static const double kDefaultSpeed = GameplayConstants.kCharacterSpeedMedium;
  static const int kAttackInterval = 300;
  static const double kHitboxSize = 6.0;
  static const double kHitboxPositionX = 3.0;
  static const double kHitboxPositionY = 5.0;
  static const double kAttackEffectSize =
      GameplayConstants.kTileSizeDefault * 0.62;

  // 2. Private instance variables
  final Vector2 _initialPosition;
  double _attackDamage = kDefaultAttackDamage;

  // 3. Constructor
  ImpEnemy(this._initialPosition)
    : super(
        animation: EnemySpriteSheet.impAnimations(),
        position: _initialPosition,
        size: Vector2.all(GameplayConstants.kTileSizeDefault * 0.8),
        speed: kDefaultSpeed,
        life: kDefaultLife,
      );

  // 4. Lifecycle methods (onLoad, update, onDie)
  @override
  Future<void> onLoad() {
    _initializeHitbox();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    seeAndMoveToPlayer(
      radiusVision: GameplayConstants.kVisionRadiusExtraLarge,
      closePlayer: (player) {
        _executeAttack();
      },
    );
  }

  @override
  void onDie() {
    _handleDeathEffects();
    removeFromParent();
    super.onDie();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    showDamage(
      damage,
      config: TextStyle(fontSize: 5, color: Colors.white, fontFamily: 'Normal'),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  // 5. Private helper methods (grouped by functionality)

  // Setup/Initialization methods
  /// Sets up the hitbox for collision detection
  void _initializeHitbox() {
    add(
      RectangleHitbox(
        size: Vector2(kHitboxSize, kHitboxSize),
        position: Vector2(kHitboxPositionX, kHitboxPositionY),
      ),
    );
  }

  // Processing/Updates methods
  /// Executes fast melee attack when player is in range
  void _executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(kAttackEffectSize),
      damage: _attackDamage,
      interval: kAttackInterval,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  // Cleanup/Utility methods
  /// Handles visual and audio effects when enemy dies
  void _handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation: EffectsSpriteSheet.smokeExplosion(),
        position: position,
        size: GameplayConstants.kTileVector2Default,
        loop: false,
      ),
    );
  }
}
