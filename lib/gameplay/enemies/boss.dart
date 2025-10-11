import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/strings_location.dart';
import 'package:darkness_dungeon/gameplay/enemies/imp.dart';
import 'package:darkness_dungeon/gameplay/enemies/mini_boss.dart';
import 'package:darkness_dungeon/gameplay/core/managers/sound_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Boss extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final Vector2 initialPosition;
  double attackDamage = 40;

  bool _hasSeenPlayerFirst = false;
  List<Enemy> spawnedEnemies = [];

  Boss(this.initialPosition)
    : super(
        animation: EnemySpriteSheet.bossAnimations(),
        position: initialPosition,
        size: Vector2(tileSize * 1.5, tileSize * 1.7),
        speed: tileSize * 1.5,
        life: 200,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(14),
          TileHelper.valueByTileSize(16),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(5),
          TileHelper.valueByTileSize(11),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    drawBarSummonEnemy(canvas);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!_hasSeenPlayerFirst) {
      this.seePlayer(
        observed: (p) {
          _hasSeenPlayerFirst = true;
          gameRef.camera.moveToTargetAnimated(
            target: this,
            zoom: 2,
            onComplete: _showConversation,
          );
        },
        radiusVision: tileSize * 6,
      );
    }

    if (life < 150 && spawnedEnemies.length == 0) {
      spawnMinion(dt);
    }

    if (life < 100 && spawnedEnemies.length == 1) {
      spawnMinion(dt);
    }

    if (life < 50 && spawnedEnemies.length == 2) {
      spawnMinion(dt);
    }

    this.seeAndMoveToPlayer(
      closePlayer: (player) {
        executeAttack();
      },
      radiusVision: tileSize * 4,
    );

    super.update(dt);
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: EffectsSpriteSheet.explosion(),
        position: this.position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
    spawnedEnemies.forEach((e) {
      if (!e.isDead) e.onDie();
    });
    removeFromParent();
    super.onDie();
  }

  void spawnMinion(double dt) {
    if (checkInterval('spawnMinion', 2000, dt)) {
      Vector2 positionExplosion = Vector2.zero();

      switch (this.directionThePlayerIsIn()) {
        case Direction.left:
          positionExplosion = this.position.translated(width * -2, 0);
          break;
        case Direction.right:
          positionExplosion = this.position.translated(width * 2, 0);
          break;
        case Direction.up:
          positionExplosion = this.position.translated(0, height * -2);
          break;
        case Direction.down:
          positionExplosion = this.position.translated(0, height * 2);
          break;
        case Direction.upLeft:
        case Direction.upRight:
        case Direction.downLeft:
        case Direction.downRight:
          break;
        default:
      }

      Enemy e = spawnedEnemies.length == 2
          ? MiniBoss(Vector2(positionExplosion.x, positionExplosion.y))
          : Imp(Vector2(positionExplosion.x, positionExplosion.y));

      gameRef.add(
        AnimatedGameObject(
          animation: EffectsSpriteSheet.smokeExplosion(),
          position: positionExplosion,
          size: Vector2(32, 32),
          loop: false,
        ),
      );

      spawnedEnemies.add(e);
      gameRef.add(e);
    }
  }

  void executeAttack() {
    this.simpleAttackMelee(
      size: Vector2.all(tileSize * 0.62),
      damage: attackDamage,
      interval: 1500,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        SoundManager.playAttackEnemyMelee();
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

  void drawBarSummonEnemy(Canvas canvas) {
    double yPosition = 0;
    double widthBar = (width - 10) / 3;
    if (spawnedEnemies.length < 1)
      canvas.drawLine(
        Offset(0, yPosition),
        Offset(widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );

    double lastX = widthBar + 5;
    if (spawnedEnemies.length < 2)
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );

    lastX = lastX + widthBar + 5;
    if (spawnedEnemies.length < 3)
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
  }

  void _showConversation() {
    SoundManager.playInteraction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_kid_1'))],
          person: AnimatedSpriteWidget(animation: NpcSpriteSheet.kidIdleLeft()),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_1'))],
          person: AnimatedSpriteWidget(
            animation: EnemySpriteSheet.bossIdleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_3'))],
          person: AnimatedSpriteWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_2'))],
          person: AnimatedSpriteWidget(
            animation: EnemySpriteSheet.bossIdleRight(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
      ],
      onFinish: () {
        SoundManager.playInteraction();
        spawnInitialMinions();
        Future.delayed(Duration(milliseconds: 500), () {
          gameRef.camera.moveToPlayerAnimated(zoom: 1);
          SoundManager.playBossBackgroundMusic();
        });
      },
      onChangeTalk: (index) {
        SoundManager.playInteraction();
      },
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  void spawnInitialMinions() {
    spawnImp(width * -2, 0);
    spawnImp(width * -2, width);
  }

  void spawnImp(double x, double y) {
    final p = position.translated(x, y);
    gameRef.add(
      AnimatedGameObject(
        animation: EffectsSpriteSheet.smokeExplosion(),
        position: p,
        size: Vector2.all(tileSize),
        loop: false,
      ),
    );
    gameRef.add(Imp(p));
  }
}
