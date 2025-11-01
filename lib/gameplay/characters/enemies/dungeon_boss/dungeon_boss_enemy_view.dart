import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_camera_utils.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/gameplay_ui_state_manager.dart';
import 'package:flutter/material.dart';

class DungeonBossEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final DungeonBossEnemyController _controller = DungeonBossEnemyController();
  List<Enemy> spawnedEnemies = [];
  bool hasSeenPlayerFirst = false;

  DungeonBossEnemyView(Vector2 position)
    : super(
        animation: DungeonBossEnemyConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: DungeonBossEnemyConfig.fComponentSize,
        speed: DungeonBossEnemyConfig.kSpeed,
        life: DungeonBossEnemyConfig.kLife,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    add(DungeonBossEnemyConfig.createHitbox());
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
    _controller.onReceiveDamage(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  void handleBossLogic(double dt) {
    if (!hasSeenPlayerFirst) {
      seePlayer(
        observed: (player) {
          hasSeenPlayerFirst = true;
          gameRef.camera.moveToTargetAnimated(
            target: this,
            zoom: GameplayCameraUtils.getCameraZoomFromMaxVisibleTile(
              context,
              maxVisibleTile: GameplayTileConfig.kBossConversationVisibleTiles,
            ),
            onComplete: () => _showConversation(player),
          );
        },
        radiusVision: DungeonBossEnemyConfig.kVisionRadiusUltraLarge,
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
        playPrimaryAttackAnimation();
      },
      radiusVision: DungeonBossEnemyConfig.kVisionRadiusLarge,
    );
  }

  void playPrimaryAttackAnimation() {
    simpleAttackMelee(
      size: Vector2.all(DungeonBossEnemyConfig.kPrimaryAttackEffectSize),
      damage: DungeonBossEnemyConfig.kPrimaryAttackDamage,
      interval: 1500,
      animationRight:
          CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
      execute: () {
        GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
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
              CharacterEffectsSpriteAnimationsConfig.createExplosionSmokeRight5(),
          position: positionExplosion,
          size: GameplayTileConfig.fTileSizeStandard,
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
      config:
          CharacterEffectsParticlesAnimationsConfig.kEnemyShowDamageTextStyle,
      gravity: CharacterEffectsParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical: CharacterEffectsParticlesAnimationsConfig
          .kShowDamageInitVelocityVertical,
    );
  }

  void handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectsSpriteAnimationsConfig.createExplosionRight7(),
        position: position,
        size: GameplayTileConfig.fTileSizeStandard,
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

  void _showConversation(Player player) {
    GameplayAudioManager.instance.playConversationInteractionSfx();
    GameplayUIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: DungeonBossEnemyConfig.createConversationSequence(),
      logicalKeyboardKeysToNext: [
        GameplayKeyboardConfig.kKeyboardPrimaryAttack,
      ],
      onChangeTalk: _onConversationChanged,
      onFinish: _onConversationFinished,
    );
  }

  void _onConversationChanged(int index) {
    GameplayAudioManager.instance.playConversationInteractionSfx();
  }

  void _onConversationFinished() {
    GameplayAudioManager.instance.playConversationInteractionSfx();
    spawnInitialMinions();
    Future.delayed(Duration(milliseconds: 500), () {
      gameRef.camera.moveToPlayerAnimated(
        zoom: GameplayCameraUtils.getCameraZoomFromMaxVisibleTile(
          context,
          maxVisibleTile: GameplayTileConfig.kMaxVisibleTiles,
        ),
      );
      GameplayAudioManager.instance.playBackgroundMusic(
        GameplayAudioConfig.kMusicBossBattleBackgroundAsset,
      );
    });
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
            CharacterEffectsSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: pos,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemyView(pos));
  }
}
