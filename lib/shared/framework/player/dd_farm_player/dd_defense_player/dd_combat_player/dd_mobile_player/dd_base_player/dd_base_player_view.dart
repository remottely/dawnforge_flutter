import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:flutter/foundation.dart';

abstract class DDBasePlayerView<
  C extends DDBasePlayerController<M>,
  M extends DDBasePlayerModel
>
    extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final M _model;
  @protected
  final DDBasePlayerConfig config;

  DDBasePlayerView({
    required this.config,
    required super.position,
    required M model,
    required super.animation,
    required super.size,
    required super.life,
    required super.speed,
  }) : _model = model {
    anchor = Anchor.center;
  }

  late final C _controller;
  C get controller => _controller;

  C createController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    configureVisualEffects();

    _controller = createController(
      model: _model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );

    add(config.hitbox);

    _restoreLifeFromModel();
  }

  void _restoreLifeFromModel() {
    final savedLife = _model.life;
    if (savedLife != null && savedLife < life) {
      final damageToApply = life - savedLife;
      handleAttack(AttackOriginEnum.WORLD, damageToApply, 'restore_from_save');
    }
  }

  @override
  void update(double dt) {
    if (isDead) return;

    _syncLifeToModel();
    _controller.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;

    _controller.handleInputAction(player: this, event: event);
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;

    displayDamageVisualEffects(damage);
    super.onReceiveDamage(attacker, damage, id);
    _syncLifeToModel();
  }

  @override
  void onDie() {
    displayDeathVisualEffects();
    removeFromParent();
    super.onDie();
  }

  void configureVisualEffects() {
    setupLighting(config.lighting);
    setupMovementByJoystick(intensityEnabled: true);
  }

  void displayDamageVisualEffects(double damage) {
    showDamage(
      damage,
      config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
    );
  }

  void displayDeathVisualEffects() {
    gameRef.add(config.getDeathMarker.call(position));
  }

  void onDisplayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        asset: EmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  void onDetectEnemyInLongVisionRadius({
    required double longVisionRadius,
    required void Function() notObserved,
    required void Function(List<DDBaseEnemyView> enemies) observed,
  }) {
    seeEnemy(
      radiusVision: longVisionRadius,
      notObserved: notObserved,
      observed: observed as void Function(List<Enemy> enemies),
    );
  }

  void _syncLifeToModel() {
    if (_model.life != life) {
      _model.updateLife(life);
    }
  }
}
