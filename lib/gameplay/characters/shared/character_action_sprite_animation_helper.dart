import 'dart:async';

import 'package:bonfire/bonfire.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  /// Internal helper to select the correct animation based on movement direction.
  ///
  /// Returns left animation for left-facing directions (left, upLeft, downLeft),
  /// and right animation for all other directions.
  static Future<SpriteAnimation> _selectAnimationByDirection({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Movement? movementComponent,
  }) {
    final direction = movementComponent?.lastDirection ?? Direction.right;
    final isLeftFacing =
        direction == Direction.left ||
        direction == Direction.upLeft ||
        direction == Direction.downLeft;

    return isLeftFacing ? animationLeft : animationRight;
  }

  static Future<void> playOnce({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? movementComponent,
  }) async {
    final attackAnimationOriginal = await _selectAnimationByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      movementComponent: movementComponent,
    );

    final clonedFrames = attackAnimationOriginal.frames
        .map((frame) => SpriteAnimationFrame(frame.sprite, frame.stepTime))
        .toList();
    final attackAnimation = SpriteAnimation(clonedFrames, loop: false);

    if (currentAnimation != null) {
      await currentAnimation.playOnce(
        attackAnimation,
        runToTheEnd: true,
        useCompFlip: true,
      );
    }
  }

  static Future<void> playLoop({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? movementComponent,
    String key = '_actionLoop',
    bool flipX = false,
    bool flipY = false,
  }) async {
    if (currentAnimation == null) {
      return;
    }

    if (!currentAnimation.containOther(key)) {
      final attackAnimationOriginal = await _selectAnimationByDirection(
        animationRight: animationRight,
        animationLeft: animationLeft,
        movementComponent: movementComponent,
      );
      final clonedFrames = attackAnimationOriginal.frames
          .map((frame) => SpriteAnimationFrame(frame.sprite, frame.stepTime))
          .toList();
      final loopAnimation = SpriteAnimation(clonedFrames, loop: true);
      await currentAnimation.addOtherAnimation(key, loopAnimation);
    }

    currentAnimation.playOther(key, flipX: flipX, flipY: flipY);
  }

  static void stopLoop({
    required SimpleDirectionAnimation? currentAnimation,
    required SimpleAnimationEnum fallbackAnimation,
    String key = '_actionLoop',
  }) {
    if (currentAnimation == null) {
      return;
    }

    currentAnimation.play(fallbackAnimation);
  }

  static Future<void> playExecutionOnceWithIdle({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? movementComponent,
    required int executionStartFrame,
    required void Function() onExecutionFrames,
    void Function()? onActionStart,
    void Function()? onActionEnd,
  }) async {
    final attackAnimationOriginal = await _selectAnimationByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      movementComponent: movementComponent,
    );

    onActionStart?.call();
    movementComponent?.stopMove(forceIdle: true);
    final GameComponent? gameComponent = movementComponent is GameComponent
        ? movementComponent as GameComponent
        : null;

    double damageStartTime = 0;
    for (
      int i = 0;
      i < executionStartFrame && i < attackAnimationOriginal.frames.length;
      i++
    ) {
      damageStartTime += attackAnimationOriginal.frames[i].stepTime;
    }

    Future.delayed(
      Duration(milliseconds: (damageStartTime * 1000).toInt()),
      () {
        if (gameComponent?.isRemoved == true ||
            gameComponent?.isRemoving == true) {
          return;
        }
        onExecutionFrames();
      },
    );

    final clonedFrames = attackAnimationOriginal.frames
        .map((frame) => SpriteAnimationFrame(frame.sprite, frame.stepTime))
        .toList();
    final attackAnimation = SpriteAnimation(clonedFrames, loop: false);

    if (currentAnimation == null) {
      movementComponent?.idle();
      onActionEnd?.call();
      return;
    }

    try {
      await currentAnimation.playOnce(
        attackAnimation,
        runToTheEnd: true,
        useCompFlip: true,
      );
      movementComponent?.idle();
    } finally {
      onActionEnd?.call();
    }
  }
}
