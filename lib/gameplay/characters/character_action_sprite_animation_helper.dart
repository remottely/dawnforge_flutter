import 'dart:async';

import 'package:bonfire/bonfire.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  static Future<void> playOnce({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? target,
  }) async {
    final attackAnimationOriginal = await _selectAnimationByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      target: target,
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
    required Movement? target,
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
        target: target,
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

  static Future<void> playOnceExecutionEquipment({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? target,
    required int executionStartFrame,
    required void Function() onExecutionFrames,
    void Function()? onActionStart,
    void Function()? onActionEnd,
  }) async {
    final attackAnimationOriginal = await _selectAnimationByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      target: target,
    );

    onActionStart?.call();
    target?.stopMove(forceIdle: true);

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
        if (target?.isRemoved == true || target?.isRemoving == true) {
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
      target?.idle();
      onActionEnd?.call();
      return;
    }

    try {
      await currentAnimation.playOnce(
        attackAnimation,
        runToTheEnd: true,
        useCompFlip: true,
      );
      target?.idle();
    } finally {
      onActionEnd?.call();
    }
  }

  /// Internal helper to select the correct animation based on movement direction.
  ///
  /// Uses `lastDirectionHorizontal` from Bonfire's Movement mixin, which preserves
  /// the last horizontal facing direction even during purely vertical movement.
  /// This ensures correct sprite orientation (left/right) is maintained when
  /// moving up/down, matching Bonfire's animation system behavior.
  ///
  /// Returns left animation when facing left, right animation otherwise.
  static Future<SpriteAnimation> _selectAnimationByDirection({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Movement? target,
  }) {
    // Use lastDirectionHorizontal which persists across vertical movements
    final horizontalDirection =
        target?.lastDirectionHorizontal ?? Direction.right;
    final isFacingRight = horizontalDirection == Direction.right;

    return isFacingRight ? animationRight : animationLeft;
  }
}
