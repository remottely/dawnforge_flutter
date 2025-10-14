import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
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
  // 1. Constantes de configuração
  static const double kDefaultAttackDamage = 10.0;
  static const double kDefaultLife = 80.0;
  static const double kDefaultSpeed = GameplayConstants.kCurrentTileSize * 2;
  static const double kVisionRadius = GameplayConstants.kCurrentTileSize * 5;
  static const int kAttackInterval = 300;
  static const double kHitboxSize = 6.0;
  static const double kHitboxPositionX = 3.0;
  static const double kHitboxPositionY = 5.0;
  static const double kAttackEffectSize =
      GameplayConstants.kCurrentTileSize * 0.62;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  double _attackDamage = kDefaultAttackDamage;

  // 3. Construtor
  ImpEnemy(this._initialPosition)
    : super(
        animation: EnemySpriteSheet.impAnimations(),
        position: _initialPosition,
        size: Vector2.all(GameplayConstants.kCurrentTileSize * 0.8),
        speed: kDefaultSpeed,
        life: kDefaultLife,
      );

  // 4. Métodos públicos principais
  @override
  Future<void> onLoad() {
    _setupHitbox();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    seeAndMoveToPlayer(
      radiusVision: kVisionRadius,
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
      config: TextStyle(
        fontSize: TileHelper.valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  // 5. Métodos privados auxiliares
  /// Sets up the hitbox for collision detection
  void _setupHitbox() {
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
