import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

/// Enemy character Goblin for the Darkness Dungeon game
/// Following Flutter naming conventions for enemy entity systems
///
/// This class handles:
/// - Basic melee combat with player detection
/// - Movement and collision detection
/// - Death effects and visual feedback
/// - Audio integration for attacks and damage
///
/// Usage patterns:
/// ```dart
/// final goblin = GoblinEnemy(position);
/// goblin.onLoad();
/// ```
class GoblinEnemy extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  // 1. Constants (grouped by type)
  static const double kDefaultAttackDamage = 25.0;
  static const double kDefaultLife = 120.0;
  static const double kDefaultSpeed = GameplayConstants.kCurrentTileSize * 1.5;
  static const double kVisionRadius = GameplayConstants.kCurrentTileSize * 4;
  static const int kAttackInterval = 800;
  static const double kHitboxSize = 7.0;
  static const double kHitboxPositionX = 3.0;
  static const double kHitboxPositionY = 4.0;
  static const double kAttackEffectSize =
      GameplayConstants.kCurrentTileSize * 0.62;

  // 2. Private instance variables
  final Vector2 _initialPosition;
  double _attackDamage = kDefaultAttackDamage;

  // 3. Constructor
  GoblinEnemy(this._initialPosition)
    : super(
        animation: EnemySpriteSheet.goblinAnimations(),
        position: _initialPosition,
        size: Vector2.all(GameplayConstants.kCurrentTileSize * 0.8),
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
      closePlayer: (player) {
        _executeAttack();
      },
      radiusVision: kVisionRadius,
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
      config: TextStyle(
        fontSize: TileHelper.valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  // 5. Private helper methods (grouped by functionality)

  // Setup/Initialization methods
  /// Sets up the hitbox for collision detection
  void _initializeHitbox() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(kHitboxSize),
          TileHelper.valueByTileSize(kHitboxSize),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(kHitboxPositionX),
          TileHelper.valueByTileSize(kHitboxPositionY),
        ),
      ),
    );
  }

  // Processing/Updates methods
  /// Executes melee attack when player is in range
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
        size: Vector2(32, 32),
        loop: false,
      ),
    );
  }
}
