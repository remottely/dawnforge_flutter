import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

class MiniBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final Vector2 initPosition;
  double attack = 50;
  bool _seePlayerClose = false;

  MiniBossEnemy(this.initPosition)
    : super(
        animation: EnemySpriteSheet.miniBossAnimations(),
        position: initPosition,
        size: Vector2(
          GameplayConstants.kCurrentTileSize * 0.68,
          GameplayConstants.kCurrentTileSize * 0.93,
        ),
        speed: GameplayConstants.kCurrentTileSize * 1.5,
        life: 150,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(6),
          TileHelper.valueByTileSize(7),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(2.5),
          TileHelper.valueByTileSize(8),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _seePlayerClose = false;
    this.seePlayer(
      observed: (player) {
        _seePlayerClose = true;
        this.seeAndMoveToPlayer(
          closePlayer: (player) {
            executeAttack();
          },
          radiusVision: GameplayConstants.kCurrentTileSize * 3,
        );
      },
      radiusVision: GameplayConstants.kCurrentTileSize * 3,
    );
    if (!_seePlayerClose) {
      this.seeAndMoveToAttackRange(
        positioned: (p) {
          executeRangedAttack();
        },
        radiusVision: GameplayConstants.kCurrentTileSize * 5,
      );
    }
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: EffectsSpriteSheet.smokeExplosion(),
        position: this.position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
    removeFromParent();
    super.onDie();
  }

  void executeRangedAttack() {
    this.simpleAttackRange(
      animation: EffectsSpriteSheet.fireBallAttackRight(),
      animationDestroy: EffectsSpriteSheet.fireBallExplosion(),
      size: Vector2.all(GameplayConstants.kCurrentTileSize * 0.65),
      damage: attack,
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

  void executeAttack() {
    this.simpleAttackMelee(
      size: Vector2.all(GameplayConstants.kCurrentTileSize * 0.62),
      damage: attack / 3,
      interval: 300,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    this.showDamage(
      damage,
      config: TextStyle(
        fontSize: TileHelper.valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }
}
