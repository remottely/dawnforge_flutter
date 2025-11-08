import 'dart:async';

import 'package:bonfire/bonfire.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  static Future<void> playActionAnimation(
    Future<SpriteAnimation> animationFuture, {
    required SimpleDirectionAnimation? currentAnimation,
    required int executionStartFrame,
    // required int executionEndFrame,
    required void Function() onExecutionFrames,
    required Player player,
  }) async {
    final attackAnimationOriginal = await animationFuture;

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
        // if (!isDead && !isRemoved) {
        onExecutionFrames();
        // }
      },
    );

    // final clonedFrames = attackAnimationOriginal.frames
    //     .map((frame) => SpriteAnimationFrame(frame.sprite, frame.stepTime))
    //     .toList();
    // final attackAnimation = SpriteAnimation(clonedFrames, loop: false);

    if (currentAnimation != null) {
      player.idle();
      await currentAnimation.playOnce(
        attackAnimationOriginal,
        runToTheEnd: true,
        useCompFlip: true,
      );
    }
  }
}
