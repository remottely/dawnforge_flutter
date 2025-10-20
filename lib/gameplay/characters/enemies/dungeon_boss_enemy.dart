import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DungeonBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final Vector2 initialPosition;
  double attackDamage = 40;

  bool _hasSeenPlayerFirst = false;
  List<Enemy> spawnedEnemies = [];

  DungeonBossEnemy(this.initialPosition)
    : super(
        animation: EnemySpriteAnimations.dungeonBossEnemyAnimation(),
        position: initialPosition,
        size: Vector2(
          GameplayConstants.kTileSizeLarge, // 24 > 32
          GameplayConstants.kTileSizeDefault * 1.7, // 27.2 > 36
        ),
        speed: GameplayConstants.kCharacterSpeedSlow,
        life: 200,
      );

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: Vector2(14, 16), position: Vector2(5, 11)));
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
        radiusVision: GameplayConstants.kVisionRadiusUltraLarge,
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
      radiusVision: GameplayConstants.kVisionRadiusLarge,
    );

    super.update(dt);
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterEffectSpriteAnimations.explosionRight7(),
        position: this.position,
        size: GameplayConstants.kTileVector2Default,
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
          ? DungeonMiniBossEnemy(
              Vector2(positionExplosion.x, positionExplosion.y),
            )
          : ImpEnemy(Vector2(positionExplosion.x, positionExplosion.y));

      gameRef.add(
        AnimatedGameObject(
          animation: CharacterEffectSpriteAnimations.explosionSmokeRight5(),
          position: positionExplosion,
          size: GameplayConstants.kTileVector2Default,
          loop: false,
        ),
      );

      spawnedEnemies.add(e);
      gameRef.add(e);
    }
  }

  void executeAttack() {
    this.simpleAttackMelee(
      size: Vector2.all(GameplayConstants.kTileSizeDefault * 0.62),
      damage: attackDamage,
      interval: 1500,
      animationRight: EnemySpriteAnimations.enemyMeleeAttackEffect1Right3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    this.showDamage(
      damage,
      config: TextStyle(fontSize: 5, color: Colors.white, fontFamily: 'Normal'),
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
    GameplayAudioManager.playInteraction();
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_kid_1'))],
          person: DFAnimatedSpriteWidget(
            animation: NpcSpriteAnimations.kidIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_1'))],
          person: DFAnimatedSpriteWidget(
            animation: EnemySpriteAnimations.dungeonBossEnemyIdleRight4(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_3'))],
          person: DFAnimatedSpriteWidget(
            animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_2'))],
          person: DFAnimatedSpriteWidget(
            animation: EnemySpriteAnimations.dungeonBossEnemyIdleRight4(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
      ],
      onFinish: () {
        GameplayAudioManager.playInteraction();
        spawnInitialMinions();
        Future.delayed(Duration(milliseconds: 500), () {
          gameRef.camera.moveToPlayerAnimated(zoom: 1);
          GameplayAudioManager.playBossBackgroundMusic();
        });
      },
      onChangeTalk: (index) {
        GameplayAudioManager.playInteraction();
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
        animation: CharacterEffectSpriteAnimations.explosionSmokeRight5(),
        position: p,
        size: GameplayConstants.kTileVector2Default,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemy(p));
  }
}
