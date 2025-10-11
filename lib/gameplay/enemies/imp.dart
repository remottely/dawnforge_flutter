import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Imp extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final Vector2 initPosition;
  double attack = 10;

  Imp(this.initPosition)
    : super(
        animation: EnemySpriteSheet.impAnimations(),
        position: initPosition,
        size: Vector2.all(GameplayTileConstants.kCurrentTileSize * 0.8),
        speed: GameplayTileConstants.kCurrentTileSize * 2,
        life: 80,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(6),
          TileHelper.valueByTileSize(6),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(3),
          TileHelper.valueByTileSize(5),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    seeAndMoveToPlayer(
      radiusVision: GameplayTileConstants.kCurrentTileSize * 5,
      closePlayer: (player) {
        executeAttack();
      },
    );
  }

  void executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(GameplayTileConstants.kCurrentTileSize * 0.62),
      damage: attack,
      interval: 300,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: EffectsSpriteSheet.smokeExplosion(),
        position: position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
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
}
