import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_camera_utils.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/gameplay_ui_state_manager.dart';
import 'package:flutter/material.dart';

class DungeonBossEnemyView
    extends DDBaseEnemy<DungeonBossEnemyController, DungeonBossEnemyModel> {
  DungeonBossEnemyView(Vector2 position)
    : super(
        animation: DungeonBossEnemyConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: DungeonBossEnemyConfig.fComponentSize,
        speed: DungeonBossEnemyConfig.kSpeed,
        life: DungeonBossEnemyConfig.kLife,
      );

  @override
  DungeonBossEnemyModel createModel() => DungeonBossEnemyModel();

  @override
  DungeonBossEnemyController createController(DungeonBossEnemyModel model) {
    return DungeonBossEnemyController(
      model: model,
      onSeeAndMoveToPlayer: _onSeeAndMoveToPlayer,
      onFirstPlayerSight: _onFirstPlayerSight,
      onSpawnMinion: _onSpawnMinion,
      onRenderBars: _onRenderBars,
      onSeePlayer: _onSeePlayer,
    );
  }

  @override
  RectangleHitbox createHitbox() => DungeonBossEnemyConfig.createHitbox();

  @override
  void render(Canvas canvas) {
    controller.render(canvas);
    super.render(canvas);
  }

  @override
  void onDie() {
    // Mata todos os minions spawnados
    for (var enemy in controller.model.spawnedEnemies) {
      if (!enemy.isDead) enemy.onDie();
    }
    super.onDie();
  }

  /// Controller callback implementations
  void _onSeeAndMoveToPlayer({
    required double radiusVision,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: radiusVision,
      closePlayer: (player) {
        simpleAttackMelee(
          size: DungeonBossEnemyConfig.kPrimaryAttackFxSize,
          damage: controller.model.attackDamage,
          interval: controller.model.attackInterval,
          animationRight:
              CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
          execute: () {
            GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
          },
        );
      },
    );
  }

  void _onSeePlayer({
    required double radiusVision,
    required void Function(Player) observed,
  }) {
    seePlayer(radiusVision: radiusVision, observed: observed);
  }

  void _onFirstPlayerSight(Player player) {
    gameRef.camera.moveToTargetAnimated(
      target: this,
      zoom: GameplayCameraUtils.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: GameplayTileConfig.kBossConversationVisibleTiles,
      ),
      onComplete: () => _showConversation(player),
    );
  }

  void _onSpawnMinion(double dt) {
    if (controller.model.shouldSpawnMinions(life)) {
      if (checkInterval('spawnMinion', 2000, dt)) {
        _spawnMinionAtDirection();
      }
    }
  }

  void _spawnMinionAtDirection() {
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

    final Enemy enemy = controller.model.spawnedEnemies.length == 2
        ? DungeonMiniBossEnemyView(positionExplosion)
        : ImpEnemyView(positionExplosion);

    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: positionExplosion,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );

    controller.model.addSpawnedEnemy(enemy);
    gameRef.add(enemy);
  }

  void _onRenderBars(Canvas canvas) {
    const double yPosition = 0;
    final double widthBar = (width - 10) / 3;

    if (controller.model.spawnedEnemies.length < 1) {
      canvas.drawLine(
        const Offset(0, yPosition),
        Offset(widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }

    double lastX = widthBar + 5;
    if (controller.model.spawnedEnemies.length < 2) {
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }

    lastX = lastX + widthBar + 5;
    if (controller.model.spawnedEnemies.length < 3) {
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + widthBar, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _showConversation(Player player) {
    GameplayAudioManager.instance.playConversationInteractionSfx();
    GameplayUIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: DungeonBossEnemyConfig.createConversationSequence(),
      logicalKeyboardKeysToNext: [GameplayKeyboardConfig.kPrimaryAttackKey],
      onChangeTalk: _onConversationChanged,
      onFinish: _onConversationFinished,
    );
  }

  void _onConversationChanged(int index) {
    GameplayAudioManager.instance.playConversationInteractionSfx();
  }

  void _onConversationFinished() {
    GameplayAudioManager.instance.playConversationInteractionSfx();
    _spawnInitialMinions();
    Future.delayed(const Duration(milliseconds: 500), () {
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

  void _spawnInitialMinions() {
    _spawnImp(width * -2, 0);
    _spawnImp(width * -2, width);
  }

  void _spawnImp(double x, double y) {
    final pos = position.translated(x, y);
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: pos,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemyView(pos));
  }
}
