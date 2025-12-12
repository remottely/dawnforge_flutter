import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

abstract class DDMobilePlayerView<
  C extends DDMobilePlayerController<M>,
  M extends DDMobilePlayerModel
>
    extends DDBasePlayerView<C, M> {
  final double _baseSpeed;

  bool _isInRunningState = false;

  int _activeActionLockCount = 0;

  bool _pendingAnimationChange = false;

  late final SimpleDirectionAnimation _walkAnimation;
  late final SimpleDirectionAnimation _runAnimation;

  DDMobilePlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required double speed,
  }) : _baseSpeed = speed,
       super(speed: speed, animation: null);

  @protected
  bool get isActionLocked => _activeActionLockCount > 0;

  JoystickDirectionalEvent? _bufferedDirectionalInput;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _walkAnimation = getAnimationWalkDirectional();
    _runAnimation = getAnimationRunDirectional();
    replaceAnimation(_walkAnimation);
  }

  SimpleDirectionAnimation getAnimationWalkDirectional();
  SimpleDirectionAnimation getAnimationRunDirectional();

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

  void _onChangeRunState(bool shouldRun) {
    if (_isInRunningState == shouldRun) return;

    _isInRunningState = shouldRun;

    if (shouldRun) {
      speed = _baseSpeed * controller.model.runSpeedMultiplier;

      if (isActionLocked) {
        _pendingAnimationChange = true;
      } else {
        transitionToRunAnimation();
      }
    } else {
      speed = _baseSpeed;
      if (isActionLocked) {
        _pendingAnimationChange = true;
      } else {
        transitionToWalkAnimation();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_pendingAnimationChange && !isActionLocked) {
      _pendingAnimationChange = false;
      if (_isInRunningState) {
        transitionToRunAnimation();
      } else {
        transitionToWalkAnimation();
      }
    }
  }

  void transitionToRunAnimation() {
    if (isActionLocked) return;

    replaceAnimation(_runAnimation, doIdle: isIdle);
  }

  void transitionToWalkAnimation() {
    if (isActionLocked) return;

    replaceAnimation(_walkAnimation, doIdle: isIdle);
  }

  void lockAction() {
    _activeActionLockCount += 1;
  }

  void unlockAction() {
    if (_activeActionLockCount > 0) {
      _activeActionLockCount -= 1;

      if (_activeActionLockCount == 0) {
        onActionFullyUnlocked();
      }
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
