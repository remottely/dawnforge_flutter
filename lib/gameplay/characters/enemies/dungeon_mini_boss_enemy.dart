import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_data.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

abstract class _DungeonMiniBossEnemyData {
  static const double attackDamage = 50.0;
  static const double life = 150.0;
  static const double _speed = GameplayConstants.kCharacterSpeedSlow;
  static const double closeVisionRadius = GameplayConstants.kVisionRadiusMedium;
  static const double longVisionRadius =
      GameplayConstants.kVisionRadiusExtraLarge;
  static const int meleeAttackInterval = 300;
  static Vector2 get hitboxSize => Vector2(6.0, 7.0);
  static Vector2 get hitboxPosition => Vector2(2.5, 8.0);
  static Vector2 get _spriteSize => Vector2(
    GameplayConstants.kTileSizeDefault * 0.68,
    GameplayConstants.kTileSizeDefault * 0.93,
  );
  static double get attackEffectSize =>
      GameplayConstants.kTileSizeDefault * 0.62;
  static double get meleeDamageReduction => 3.0;
  static void loadHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
}

class DungeonMiniBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  double _attackDamage = _DungeonMiniBossEnemyData.attackDamage;
  bool _seePlayerClose = false;

  DungeonMiniBossEnemy(Vector2 position)
    : super(
        animation: EnemySpriteAnimations.dungeonMiniBossEnemyAnimation(),
        position: position,
        size: _DungeonMiniBossEnemyData._spriteSize,
        speed: _DungeonMiniBossEnemyData._speed,
        life: _DungeonMiniBossEnemyData.life,
      );

  @override
  Future<void> onLoad() {
    _DungeonMiniBossEnemyData.loadHitBox(this);
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
          radiusVision: _DungeonMiniBossEnemyData.closeVisionRadius,
        );
      },
      radiusVision: _DungeonMiniBossEnemyData.closeVisionRadius,
    );
    if (!_seePlayerClose) {
      seeAndMoveToAttackRange(
        positioned: (p) {
          _executeCharacterFireballAttack(_attackDamage);
        },
        radiusVision: _DungeonMiniBossEnemyData.longVisionRadius,
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
      config: TextStyle(fontSize: 5, color: Colors.white, fontFamily: 'Normal'),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void _executeCharacterFireballAttack(double damage) {
    simpleAttackRange(
      animation: CharacterFireballAttackData.loadAttackAnimation(),
      animationDestroy: CharacterFireballAttackData.loadExplosionAnimation(),
      size: CharacterFireballAttackData.spriteSize,
      damage: damage,
      speed: speed * CharacterFireballAttackData.kSpeedMultiplier,
      execute: () => CharacterFireballAttackData.playExecutionAudio(),
      onDestroy: () => CharacterFireballAttackData.playExplosionAudio(),
      collision: CharacterFireballAttackData.buildHitbox(),
      lightingConfig: CharacterFireballAttackData.buildLightingConfig(),
    );
  }

  void _executeMeleeAttack() {
    simpleAttackMelee(
      size: Vector2.all(_DungeonMiniBossEnemyData.attackEffectSize),
      damage: _attackDamage / _DungeonMiniBossEnemyData.meleeDamageReduction,
      interval: _DungeonMiniBossEnemyData.meleeAttackInterval,
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
        size: GameplayConstants.kTileVector2Default,
        loop: false,
      ),
    );
  }
}
