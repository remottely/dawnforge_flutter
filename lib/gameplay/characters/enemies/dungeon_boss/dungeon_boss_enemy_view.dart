import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DungeonBossEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final DungeonBossEnemyController _controller = DungeonBossEnemyController();
  double attackDamage = DungeonBossEnemyConfig.attackDamage;
  List<Enemy> spawnedEnemies = [];
  bool hasSeenPlayerFirst = false;

  DungeonBossEnemyView(Vector2 position)
    : super(
        animation: EnemySpriteAnimations.dungeonBossEnemyDirectional,
        position: position,
        size: DungeonBossEnemyConfig.spriteSize,
        speed: DungeonBossEnemyConfig.speed,
        life: DungeonBossEnemyConfig.life,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    DungeonBossEnemyConfig.buildHitBox(this);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    _controller.onRender(canvas);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  @override
  void onDie() {
    _controller.onDie();
    removeFromParent();
    super.onDie();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _controller.onReceiveDamage(attacker, damage, id);
    super.onReceiveDamage(attacker, damage, id);
  }

  void handleBossLogic(double dt) {
    if (!hasSeenPlayerFirst) {
      seePlayer(
        observed: (p) {
          hasSeenPlayerFirst = true;
          gameRef.camera.moveToTargetAnimated(
            target: this,
            zoom: GameplayConstants.getCameraZoomFromMaxVisibleTile(
              context,
              maxVisibleTile: GameplayConstants.kBossDialogVisibleTiles,
            ),
            onComplete: _showConversation,
          );
        },
        radiusVision: DungeonBossEnemyConfig.visionRadiusUltraLarge,
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

    seeAndMoveToPlayer(
      closePlayer: (player) {
        playMeleeAttackAnimation();
      },
      radiusVision: DungeonBossEnemyConfig.visionRadiusLarge,
    );
  }

  void playMeleeAttackAnimation() {
    simpleAttackMelee(
      size: Vector2.all(DungeonBossEnemyConfig.attackEffectSize),
      damage: attackDamage,
      interval: 1500,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  void spawnMinion(double dt) {
    if (checkInterval('spawnMinion', 2000, dt)) {
      Vector2 positionExplosion = Vector2.zero();
      switch (directionThePlayerIsIn()) {
        case Direction.left:
          positionExplosion = position.translated(width * -2, 0);
          break;
        case Direction.right:
          positionExplosion = position.translated(width * 2, 0);
          break;
        case Direction.up:
          positionExplosion = position.translated(0, height * -2);
          break;
        case Direction.down:
          positionExplosion = position.translated(0, height * 2);
          break;
        case Direction.upLeft:
        case Direction.upRight:
        case Direction.downLeft:
        case Direction.downRight:
          break;
        default:
      }
      Enemy e = spawnedEnemies.length == 2
          ? DungeonMiniBossEnemyView(
              Vector2(positionExplosion.x, positionExplosion.y),
            )
          : ImpEnemyView(Vector2(positionExplosion.x, positionExplosion.y));
      gameRef.add(
        AnimatedGameObject(
          animation:
              CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
          position: positionExplosion,
          size: GameplayConstants.kTileSizeStandard,
          loop: false,
        ),
      );
      spawnedEnemies.add(e);
      gameRef.add(e);
    }
  }

  void showDamageEffect(double damage) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.enemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  void handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterEffectSpriteAnimations.characterExplosionRight7(),
        position: position,
        size: GameplayConstants.kTileSizeStandard,
        loop: false,
      ),
    );
    spawnedEnemies.forEach((e) {
      if (!e.isDead) e.onDie();
    });
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
          text: [
            TextSpan(
              text: GameplayStringsLocation.instance.getString('talk_kid_1'),
            ),
          ],
          person: DFAnimatedSpriteWidget(
            animation: NpcSpriteAnimations.kidIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [
            TextSpan(
              text: GameplayStringsLocation.instance.getString('talk_boss_1'),
            ),
          ],
          person: DFAnimatedSpriteWidget(
            animation: EnemySpriteAnimations.dungeonBossEnemyIdleRight4(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [
            TextSpan(
              text: GameplayStringsLocation.instance.getString('talk_player_3'),
            ),
          ],
          person: DFAnimatedSpriteWidget(
            animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [
            TextSpan(
              text: GameplayStringsLocation.instance.getString('talk_boss_2'),
            ),
          ],
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
          gameRef.camera.moveToPlayerAnimated(
            zoom: GameplayConstants.getCameraZoomFromMaxVisibleTile(
              context,
              maxVisibleTile: GameplayConstants.kMaxVisibleTiles,
            ),
          );
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
    final pos = position.translated(x, y);
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: pos,
        size: GameplayConstants.kTileSizeStandard,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemyView(pos));
  }
}
