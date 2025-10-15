import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

/// Mini Boss enemy character for the Darkness Dungeon game
/// Following Flutter naming conventions for enemy entity systems
///
/// This class handles:
/// - Hybrid combat system (melee and ranged attacks)
/// - Advanced AI with close and long-range behavior
/// - Multiple attack patterns based on player distance
/// - Enhanced visual effects and audio feedback
class MiniBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  // 1. Constants (grouped by type)
  static const double kDefaultAttackDamage = 50.0;
  static const double kDefaultLife = 150.0;
  static const double kDefaultSpeed = GameplayConstants.kCurrentTileSize * 1.5;
  static const double kCloseVisionRadius =
      GameplayConstants.kCurrentTileSize * 3;
  static const double kLongVisionRadius =
      GameplayConstants.kCurrentTileSize * 5;
  static const int kMeleeAttackInterval = 300;
  static const double kHitboxSizeX = 6.0;
  static const double kHitboxSizeY = 7.0;
  static const double kHitboxPositionX = 2.5;
  static const double kHitboxPositionY = 8.0;
  static const double kAttackEffectSize =
      GameplayConstants.kCurrentTileSize * 0.62;
  static const double kRangedAttackSize =
      GameplayConstants.kCurrentTileSize * 0.65;
  static const double kMeleeDamageReduction = 3.0; // attack / 3

  // 2. Private instance variables
  final Vector2 _initialPosition;
  double _attackDamage = kDefaultAttackDamage;
  bool _seePlayerClose = false;

  // 3. Constructor
  MiniBossEnemy(this._initialPosition)
    : super(
        animation: EnemySpriteSheet.miniBossAnimations(),
        position: _initialPosition,
        size: Vector2(
          GameplayConstants.kCurrentTileSize * 0.68,
          GameplayConstants.kCurrentTileSize * 0.93,
        ),
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
    _seePlayerClose = false;
    seePlayer(
      observed: (player) {
        _seePlayerClose = true;
        seeAndMoveToPlayer(
          closePlayer: (player) {
            _executeMeleeAttack();
          },
          radiusVision: kCloseVisionRadius,
        );
      },
      radiusVision: kCloseVisionRadius,
    );
    if (!_seePlayerClose) {
      seeAndMoveToAttackRange(
        positioned: (p) {
          _executeRangedAttack();
        },
        radiusVision: kLongVisionRadius,
      );
    }
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
          TileHelper.valueByTileSize(kHitboxSizeX),
          TileHelper.valueByTileSize(kHitboxSizeY),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(kHitboxPositionX),
          TileHelper.valueByTileSize(kHitboxPositionY),
        ),
      ),
    );
  }

  // Processing/Updates methods
  /// Executes ranged fireball attack when player is at distance
  void _executeRangedAttack() {
    simpleAttackRange(
      animation: EffectsSpriteSheet.fireBallAttackRight(),
      animationDestroy: EffectsSpriteSheet.fireBallExplosion(),
      size: Vector2.all(kRangedAttackSize),
      damage: _attackDamage,
      speed: speed * 2.5,
      execute: () {
        GameplayAudioManager.playAttackRange();
      },
      onDestroy: () {
        GameplayAudioManager.playExplosion();
      },
      collision: RectangleHitbox(
        size: Vector2(
          GameplayConstants.kCurrentTileSize / 3,
          GameplayConstants.kCurrentTileSize / 3,
        ),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: GameplayConstants.kCurrentTileSize * 0.9,
        blurBorder: GameplayConstants.kCurrentTileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  /// Executes melee attack when player is close (reduced damage)
  void _executeMeleeAttack() {
    simpleAttackMelee(
      size: Vector2.all(kAttackEffectSize),
      damage: _attackDamage / kMeleeDamageReduction,
      interval: kMeleeAttackInterval,
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
