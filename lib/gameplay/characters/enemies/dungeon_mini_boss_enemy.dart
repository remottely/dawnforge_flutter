import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:flutter/material.dart';

class DungeonMiniBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  static const double kDefaultAttackDamage = 50.0;
  static const double kDefaultLife = 150.0;
  static const double kDefaultSpeed = GameplayConstants.kCharacterSpeedSlow;
  static const double kCloseVisionRadius =
      GameplayConstants.kVisionRadiusMedium;
  static const double kLongVisionRadius =
      GameplayConstants.kVisionRadiusExtraLarge;
  static const int kMeleeAttackInterval = 300;
  static const double kHitboxSizeX = 6.0;
  static const double kHitboxSizeY = 7.0;
  static const double kHitboxPositionX = 2.5;
  static const double kHitboxPositionY = 8.0;
  static const double kAttackEffectSize =
      GameplayConstants.kTileSizeDefault * 0.62;
  static const double kRangedAttackSize =
      GameplayConstants.kTileSizeDefault * 0.65;
  static const double kMeleeDamageReduction = 3.0;

  final Vector2 _initialPosition;
  double _attackDamage = kDefaultAttackDamage;
  bool _seePlayerClose = false;

  DungeonMiniBossEnemy(this._initialPosition)
    : super(
        animation: EnemySpriteAnimations.dungeonMiniBossEnemyAnimation(),
        position: _initialPosition,
        size: Vector2(
          GameplayConstants.kTileSizeDefault * 0.68,
          GameplayConstants.kTileSizeDefault * 0.93,
        ),
        speed: kDefaultSpeed,
        life: kDefaultLife,
      );

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
          _executeRangedAttack(_attackDamage);
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
      config: TextStyle(fontSize: 5, color: Colors.white, fontFamily: 'Normal'),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void _initializeHitbox() {
    add(
      RectangleHitbox(
        size: Vector2(kHitboxSizeX, kHitboxSizeY),
        position: Vector2(kHitboxPositionX, kHitboxPositionY),
      ),
    );
  }

  void _executeRangedAttack(double damage) {
    GameplayAudioManager.playAttackRange();
    simpleAttackRange(
      animation: CharacterEffectSpriteAnimations.fireBallAttackRight3(),
      animationDestroy:
          CharacterEffectSpriteAnimations.fireBallExplosionRight6(),
      size: Vector2.all(kRangedAttackSize),
      damage: damage,
      speed: speed * 2.5,
      // execute: () {
      //   GameplayAudioManager.playAttackRange();
      // },
      onDestroy: () {
        GameplayAudioManager.playExplosion();
      },
      collision: RectangleHitbox(
        size: Vector2(
          GameplayConstants.kTileSizeDefault / 3,
          GameplayConstants.kTileSizeDefault / 3,
        ),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: GameplayConstants.kTileSizeDefault * 0.9,
        blurBorder: GameplayConstants.kTileSizeDefault,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
      ),
    );
  }

  void _executeMeleeAttack() {
    simpleAttackMelee(
      size: Vector2.all(kAttackEffectSize),
      damage: _attackDamage / kMeleeDamageReduction,
      interval: kMeleeAttackInterval,
      animationRight: EnemySpriteAnimations.enemyMeleeAttackEffect1Right3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  void _handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterEffectSpriteAnimations.explosionSmokeRight5(),
        position: position,
        size: GameplayConstants.kTileVector2Default,
        loop: false,
      ),
    );
  }
}
