import 'dart:async';
import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/game/systems/ui/emote_manager.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:flutter/foundation.dart';

abstract class DDBasePlayerView<
  C extends DDBasePlayerController<M>,
  M extends DDBasePlayerModel
>
    extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final M _model;
  @protected
  final DDBasePlayerViewConfig config;

  DDBasePlayerView({
    required this.config,
    required super.position,
    required M model,
  }) : _model = model,
       super(
         animation: null,
         size: config.size,
         life: config.life,
         speed: config.baseSpeed,
       ) {
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
    if (GlobalStateMachine.instance.isTimePaused) {
      // Bloqueia qualquer movimento enquanto o market está aberto.
      stopMove();
      velocity = Vector2.zero();
      return;
    }

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
    if (GlobalStateMachine.instance.isTimePaused) {
      GameLogger.info('[PlayerInput] input ignored: market open');
      return;
    }
    GameLogger.info(
      '[PlayerInput] 🎮 Input recebido: ${event.id} | evento: ${event.event} | equipamento: ${_model.equipment}',
    );

    if (isDead) {
      GameLogger.info('[PlayerInput] ✗ Input ignorado: player está morto');
      return;
    }

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

  @override
  void displayDamageVisualEffects(double damage) {
    // showDamage(
    //   damage,
    //   config: CharacterFxParticlesAnimationsDef.kPlayerShowDamageTextStyle,
    //   gravity: CharacterFxParticlesAnimationsDef.kShowDamageGravity,
    //   initVelocityVertical:
    //       CharacterFxParticlesAnimationsDef.kShowDamageInitVelocityVertical,
    // );
  }

  void displayDeathVisualEffects() {
    gameRef.add(config.getDeathMarker.call(position));
  }

  void onDisplayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        animation: EmoteManager.loadExclamationEmote(),
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
