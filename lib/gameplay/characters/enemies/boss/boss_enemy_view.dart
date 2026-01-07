import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_def.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_Def.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_calculations.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';
import 'package:flutter/material.dart';

class BossEnemyView
    extends DDBaseEnemyView<BossEnemyController, BossEnemyModel> {
  BossEnemyView({required super.position})
    : super(
        animation: BossEnemyDef.createAnimationWalkDirectional(),
        size: BossEnemyDef.componentSize,
        speed: BossEnemyDef.kSpeed,
        life: BossEnemyDef.kLife,
      );

  @override
  BossEnemyModel createModel() => BossEnemyModel();

  @override
  BossEnemyController createController(BossEnemyModel model) =>
      BossEnemyController(
        model: model,
        onDetectPlayerAndMoveToMeleeAttack:
            onDetectPlayerAndMoveToPrimaryAttack,
        onPlayerFirstDetection: _onPlayerFirstDetection,
        onRequestSpawnMinion: _onRequestSpawnMinion,
        onRenderStatusBars: _onRenderStatusBars,
        onDetectPlayerInCloseVisionRadius: _onDetectPlayerInCloseVisionRadius,
      );

  @override
  RectangleHitbox getHitbox() => BossEnemyDef.createHitbox();

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

  void _onPlayerFirstDetection(Player player) {
    gameRef.camera.moveToTargetAnimated(
      target: this,
      zoom: CameraCalculations.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: TileConstants.kBossConversationVisibleTiles,
      ),
      onComplete: () => _showConversation(player),
    );
  }

  void _onRequestSpawnMinion(double dt) {
    if (controller.model.shouldSpawnMinions(life)) {
      if (checkInterval('spawnMinion', 2000, dt)) {
        _spawnMinionAtDirection();
      }
    }
  }

  void _onRenderStatusBars(Canvas canvas) {
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

  void _onDetectPlayerInCloseVisionRadius({
    required double closeVisionRadius,
    required void Function(Player) observed,
  }) {
    seePlayer(radiusVision: closeVisionRadius, observed: observed);
  }

  void _spawnMinionAtDirection({Direction? direction, Vector2? customOffset}) {
    Vector2 explosionPosition;

    if (customOffset != null) {
      explosionPosition = position + customOffset;
    } else {
      final spawnDirection = direction ?? directionThePlayerIsIn();
      explosionPosition = _getSpawnPositionForDirection(spawnDirection);
    }

    _executeExplosionFx(explosionPosition);

    final DDBaseEnemyView enemy = controller.model.spawnedEnemies.length == 2
        ? MiniBossEnemyView(position: explosionPosition)
        : ImpEnemyView(position: explosionPosition);

    _addEnemy(enemy);
  }

  Vector2 _getSpawnPositionForDirection(Direction? direction) {
    return switch (direction) {
      Direction.left => position.translated(width * -2, 0),
      Direction.right => position.translated(width * 2, 0),
      Direction.up => position.translated(0, height * -2),
      Direction.down => position.translated(0, height * 2),
      Direction.upLeft ||
      Direction.upRight ||
      Direction.downLeft ||
      Direction.downRight ||
      _ => position,
    };
  }

  void _showConversation(Player player) {
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: BossEnemyDef.createConversationSequence(),
      onChangeConversation: (_) =>
          AudioManager.instance.playConversationInteractionSfx(),
      onFinishConversation: _onFinishConversation,
    );
  }

  void _onFinishConversation() {
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
        AudioDef.bgMusicCaveBoss,
      );
    });
  }

  void _spawnInitialMinions() {
    _spawnMinionAtDirection(customOffset: Vector2(width * -2, 0));
    _spawnMinionAtDirection(customOffset: Vector2(width * -2, width));
  }

  void _addEnemy(DDBaseEnemyView enemy) {
    controller.model.addSpawnedEnemy(enemy);
    gameRef.add(enemy);
  }

  void _executeExplosionFx(Vector2 explosionPosition) {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsDef.loadAnimationExplosionSmokeRight(),
        position: explosionPosition,
        size: ImpEnemyDef.componentSize,
        loop: false,
      ),
    );
  }
}
