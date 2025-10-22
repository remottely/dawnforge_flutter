import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp_enemy.dart';
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

abstract class _DungeonBossEnemyData {
  static const double attackDamage = 40.0;
  static const double _life = 200.0;
  static const double _speed = GameplayConstants.kCharacterSpeedSlow;
  static final Vector2 _spriteSize = Vector2(
    GameplayConstants.kTileSizeLarge,
    GameplayConstants.kTileSizeStandard * 1.7,
  );
  static final Vector2 hitboxSize = Vector2(14, 16);
  static final Vector2 hitboxPosition = Vector2(5, 11);
  static final double attackEffectSize =
      GameplayConstants.kTileSizeStandard * 0.62;
  static double get visionRadiusUltraLarge =>
      GameplayConstants.kVisionRadiusUltraLarge;
  static double get visionRadiusLarge => GameplayConstants.kVisionRadiusLarge;
  static void loadHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
  // static final void Function(GameComponent) loadHitBox = (target) =>
  //     target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));
}

class DungeonBossEnemy extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  double attackDamage = _DungeonBossEnemyData.attackDamage;
  bool _hasSeenPlayerFirst = false;
  List<Enemy> spawnedEnemies = [];

  DungeonBossEnemy(Vector2 position)
    : super(
        animation: EnemySpriteAnimations.dungeonBossEnemyDirectionAnimation,
        position: position,
        size: _DungeonBossEnemyData._spriteSize,
        speed: _DungeonBossEnemyData._speed,
        life: _DungeonBossEnemyData._life,
      );

  @override
  Future<void> onLoad() {
    _DungeonBossEnemyData.loadHitBox(this);
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
      seePlayer(
        observed: (p) {
          _hasSeenPlayerFirst = true;
          gameRef.camera.moveToTargetAnimated(
            target: this,
            zoom: GameplayConstants.getCameraZoomFromMaxVisibleTile(
              context,
              maxVisibleTile: GameplayConstants.kBossDialogVisibleTiles,
            ),
            onComplete: _showConversation,
          );
        },
        radiusVision: _DungeonBossEnemyData.visionRadiusUltraLarge,
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
        executeAttack();
      },
      radiusVision: _DungeonBossEnemyData.visionRadiusLarge,
    );

    super.update(dt);
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterEffectSpriteAnimations.characterExplosionRight7(),
        position: position,
        size: GameplayConstants.kTileVector2Standard,
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
          ? DungeonMiniBossEnemy(
              Vector2(positionExplosion.x, positionExplosion.y),
            )
          : ImpEnemy(Vector2(positionExplosion.x, positionExplosion.y));
      gameRef.add(
        AnimatedGameObject(
          animation:
              CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
          position: positionExplosion,
          size: GameplayConstants.kTileVector2Standard,
          loop: false,
        ),
      );
      spawnedEnemies.add(e);
      gameRef.add(e);
    }
  }

  void executeAttack() {
    simpleAttackMelee(
      size: Vector2.all(_DungeonBossEnemyData.attackEffectSize),
      damage: attackDamage,
      interval: 1500,
      animationRight: EnemySpriteAnimations.enemyBasicAttackRight3(),
      execute: () {
        GameplayAudioManager.playAttackEnemyMelee();
      },
    );
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.enemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
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
    final p = position.translated(x, y);
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: p,
        size: GameplayConstants.kTileVector2Standard,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemy(p));
  }
}
