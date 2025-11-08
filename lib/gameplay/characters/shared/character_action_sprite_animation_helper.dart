import 'dart:async';

import 'package:bonfire/bonfire.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  static Future<void> playActionAnimation(
    Future<SpriteAnimation> animationFuture, {
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? movementComponent,
    required int executionStartFrame,
    // required int executionEndFrame,
    required void Function() onExecutionFrames,
    void Function()? onActionStart,
    void Function()? onActionEnd,
  }) async {
    final attackAnimationOriginal = await animationFuture;

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
