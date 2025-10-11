import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/utils/audio/sound_manager.dart';
import 'package:darkness_dungeon/gameplay/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/utils/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final Vector2 initPosition;
  double attack = 25;

  Goblin(this.initPosition)
    : super(
        animation: EnemySpriteSheet.goblinAnimations(),
        position: initPosition,
        size: Vector2.all(tileSize * 0.8),
        speed: tileSize * 1.5,
        life: 120,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(7),
          TileHelper.valueByTileSize(7),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(3),
          TileHelper.valueByTileSize(4),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    seeAndMoveToPlayer(
      closePlayer: (player) {
        executeAttack();
      },
      radiusVision: tileSize * 4,
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

  void executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(tileSize * 0.62),
      damage: attack,
      interval: 800,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        SoundManager.playAttackEnemyMelee();
      },
    );
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
