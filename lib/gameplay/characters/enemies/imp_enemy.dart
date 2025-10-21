import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
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

abstract class _ImpEnemyData {
  static const double attackDamage = 10.0;
  static const double life = 80.0;
  static const double speed = GameplayConstants.kCharacterSpeedMedium;
  static const int attackInterval = 300;
  static const double hitboxSize = 6.0;
  static Vector2 get hitboxPosition => Vector2(3.0, 5.0);
  static Vector2 get size =>
      Vector2.all(GameplayConstants.kTileSizeStandard * 0.8);
  static double get attackEffectSize =>
      GameplayConstants.kTileSizeStandard * 0.62;
  static void loadHitBox(GameComponent target) => target.add(
    RectangleHitbox(
      size: Vector2(hitboxSize, hitboxSize),
      position: hitboxPosition,
    ),
  );
}

class ImpEnemy extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  double _attackDamage = _ImpEnemyData.attackDamage;

  ImpEnemy(Vector2 position)
    : super(
        animation: EnemySpriteAnimations.impEnemyAnimation(),
        position: position,
        size: _ImpEnemyData.size,
        speed: _ImpEnemyData.speed,
        life: _ImpEnemyData.life,
      );

  @override
  Future<void> onLoad() {
    _ImpEnemyData.loadHitBox(this);
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

  void _executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(_ImpEnemyData.attackEffectSize),
      damage: _attackDamage,
      interval: _ImpEnemyData.attackInterval,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  void _handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: position,
        size: GameplayConstants.kTileVector2Standard,
        loop: false,
      ),
    );
  }
}
