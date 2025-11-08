import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_calculations.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy.dart';
import 'package:flutter/material.dart';

class BossEnemyView extends DDBaseEnemy<BossEnemyController, BossEnemyModel> {
  BossEnemyView(Vector2 position)
    : super(
        animation: BossEnemyConfig.animation,
        position: position,
        size: BossEnemyConfig.componentSize,
        speed: BossEnemyConfig.kSpeed,
        life: BossEnemyConfig.kLife,
      );

  @override
  BossEnemyModel createModel() => BossEnemyModel();

  @override
  BossEnemyController createController(BossEnemyModel model) {
    return BossEnemyController(
      model: model,
      onSeeAndMoveToMeleeAttack: seeAndMoveToPrimaryAttack,
      onFirstPlayerSight: _onPlayerSighted,
      onSpawnMinion: _onSpawnMinion,
      onRenderBars: _onRenderBars,
      onSeePlayer: _onSeePlayer,
    );
  }

  @override
  RectangleHitbox createHitbox() => BossEnemyConfig.createHitbox();

  @override
  void render(Canvas canvas) {
    controller.render(canvas);
    super.render(canvas);
  }

  @override
  void onDie() {
    for (var enemy in controller.model.spawnedEnemies) {
      if (!enemy.isDead) enemy.onDie();
    }
    super.onDie();
  }

  /// Callbacks
  void _onPlayerSighted(Player player) {
    gameRef.camera.moveToTargetAnimated(
      target: this,
      zoom: CameraCalculations.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: TileConstants.kBossConversationVisibleTiles,
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

  void _onSeePlayer({
    required double closeVisionRadius,
    required void Function(Player) observed,
  }) {
    seePlayer(radiusVision: closeVisionRadius, observed: observed);
  }

  /// Helpers
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
        ? MiniBossEnemyView(positionExplosion)
        : ImpEnemyView(positionExplosion);

    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: positionExplosion,
        size: TileConstants.tileSizeStandard,
        loop: false,
      ),
    );

    controller.model.addSpawnedEnemy(enemy);
    gameRef.add(enemy);
  }

  void _showConversation(Player player) {
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: BossEnemyConfig.createConversationSequence(),
      logicalKeyboardKeysToNext: [KeyboardSetup.kPrimaryAttackKey],
      onChangeTalk: _onConversationChanged,
      onFinish: _onConversationFinished,
    );
  }

  void _onConversationChanged(int index) {
    AudioManager.instance.playConversationInteractionSfx();
  }

  void _onConversationFinished() {
    AudioManager.instance.playConversationInteractionSfx();
    _spawnInitialMinions();
    Future.delayed(const Duration(milliseconds: 500), () {
      gameRef.camera.moveToPlayerAnimated(
        zoom: CameraCalculations.getCameraZoomFromMaxVisibleTile(
          context,
          maxVisibleTile: TileConstants.kMaxVisibleTiles,
        ),
      );
      AudioManager.instance.playBackgroundMusic(
        AudioConfig.kMusicBossBattleBackgroundAsset,
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
        size: TileConstants.tileSizeStandard,
        loop: false,
      ),
    );
    gameRef.add(ImpEnemyView(pos));
  }
}
