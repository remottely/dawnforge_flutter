import 'dart:async';
import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

abstract class DDMobilePlayerView<
  C extends DDMobilePlayerController<M>,
  M extends DDMobilePlayerModel
>
    extends DDBasePlayerView<C, M> {
  @protected
  final DDMobilePlayerViewConfig config;
  final double _baseSpeed;

  DDMobilePlayerView({
    required this.config,
    required super.position,
    required super.model,
  }) : _baseSpeed = config.baseSpeed,
       super(config: config);

  int _activeActionLockCount = 0;

  @protected
  bool get isActionLocked => _activeActionLockCount > 0;

  JoystickDirectionalEvent? _bufferedDirectionalInput;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    replaceAnimation(config.animationWalkDirectional);
  }

  @override
  C createController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  }) {
    return createMobileController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: _onChangeRunState,
    );
  }

  C createMobileController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
  });

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    _bufferedDirectionalInput = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );

    if (isActionLocked) return;

    super.onJoystickChangeDirectional(event);
  }

  void _onChangeRunState(bool isRunning) {
    if (isRunning) {
      speed = _baseSpeed * controller.model.config.runSpeedMultiplier;

      _transitionToRunAnimation();
    } else {
      speed = _baseSpeed;

      _transitionToWalkAnimation();
    }
  }

  void _transitionToRunAnimation() {
    if (isActionLocked) return;

    replaceAnimation(config.animationRunDirectional, doIdle: isIdle);
  }

  void _transitionToWalkAnimation() {
    if (isActionLocked) return;

    replaceAnimation(config.animationWalkDirectional, doIdle: isIdle);
  }

  void lockAction() {
    _activeActionLockCount += 1;
    developer.log(
      '[MobilePlayerView] 🔒 Action LOCKED (count: $_activeActionLockCount)',
    );
  }

  void unlockAction() {
    if (_activeActionLockCount > 0) {
      _activeActionLockCount -= 1;
      developer.log(
        '[MobilePlayerView] 🔓 Action UNLOCKED (count: $_activeActionLockCount)',
      );

      if (_activeActionLockCount == 0) {
        developer.log('[MobilePlayerView] ✅ Action FULLY UNLOCKED');
        onActionFullyUnlocked();
      }
    } else {
      developer.log(
        '[MobilePlayerView] ⚠️ Tentativa de unlock quando já estava unlocked!',
      );
    }
  }

  @protected
  void onActionFullyUnlocked() {
    _restoreBufferedMovementInput();
  }

  void _restoreBufferedMovementInput() {
    final JoystickDirectionalEvent? bufferedEvent = _bufferedDirectionalInput;
    if (bufferedEvent != null &&
        bufferedEvent.directional != JoystickMoveDirectional.IDLE) {
      super.onJoystickChangeDirectional(bufferedEvent);
    }
  }
}
