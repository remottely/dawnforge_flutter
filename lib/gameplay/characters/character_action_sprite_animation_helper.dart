import 'dart:async';

import 'package:bonfire/bonfire.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  static Future<void> playOnce({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    Future<SpriteAnimation>? animationUp,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationRightUp,
    Future<SpriteAnimation>? animationRightDown,
    Future<SpriteAnimation>? animationLeftUp,
    Future<SpriteAnimation>? animationLeftDown,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? target,
  }) async {
    final attackAnimation = await _cloneSelectedAnimation(
      animationRight: animationRight,
      animationLeft: animationLeft,
      animationUp: animationUp,
      animationDown: animationDown,
      animationRightUp: animationRightUp,
      animationRightDown: animationRightDown,
      animationLeftUp: animationLeftUp,
      animationLeftDown: animationLeftDown,
      target: target,
      loop: false,
    );

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
    Future<SpriteAnimation>? animationUp,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationRightUp,
    Future<SpriteAnimation>? animationRightDown,
    Future<SpriteAnimation>? animationLeftUp,
    Future<SpriteAnimation>? animationLeftDown,
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
      final loopAnimation = await _cloneSelectedAnimation(
        animationRight: animationRight,
        animationLeft: animationLeft,
        animationUp: animationUp,
        animationDown: animationDown,
        animationRightUp: animationRightUp,
        animationRightDown: animationRightDown,
        animationLeftUp: animationLeftUp,
        animationLeftDown: animationLeftDown,
        target: target,
        loop: true,
      );
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
    Future<SpriteAnimation>? animationUp,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationRightUp,
    Future<SpriteAnimation>? animationRightDown,
    Future<SpriteAnimation>? animationLeftUp,
    Future<SpriteAnimation>? animationLeftDown,
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
      animationUp: animationUp,
      animationDown: animationDown,
      animationRightUp: animationRightUp,
      animationRightDown: animationRightDown,
      animationLeftUp: animationLeftUp,
      animationLeftDown: animationLeftDown,
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

    final attackAnimation = _cloneAnimation(
      attackAnimationOriginal,
      loop: false,
    );

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

  static Future<SpriteAnimation> _selectAnimationByDirection({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    Future<SpriteAnimation>? animationUp,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationRightUp,
    Future<SpriteAnimation>? animationRightDown,
    Future<SpriteAnimation>? animationLeftUp,
    Future<SpriteAnimation>? animationLeftDown,
    required Movement? target,
  }) {
    final lastDirection = target?.lastDirection ?? Direction.right;

    final horizontalDirection =
        target?.lastDirectionHorizontal ?? Direction.right;
    final horizontalFallback = horizontalDirection == Direction.left
        ? animationLeft
        : animationRight;

    return switch (lastDirection) {
      Direction.right => animationRight,
      Direction.left => animationLeft,
      Direction.up => animationUp ?? horizontalFallback,
      Direction.down => animationDown ?? horizontalFallback,
      Direction.upRight =>
        animationRightUp ??
            animationRight, // TODO(Kevin): use horizontalFallback?
      Direction.downRight =>
        animationRightDown ??
            animationRight, // TODO(Kevin): use horizontalFallback?
      Direction.upLeft =>
        animationLeftUp ??
            animationLeft, // TODO(Kevin): use horizontalFallback?
      Direction.downLeft =>
        animationLeftDown ??
            animationLeft, // TODO(Kevin): use horizontalFallback?
    };
  }

  static Future<SpriteAnimation> _cloneSelectedAnimation({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    Future<SpriteAnimation>? animationUp,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationRightUp,
    Future<SpriteAnimation>? animationRightDown,
    Future<SpriteAnimation>? animationLeftUp,
    Future<SpriteAnimation>? animationLeftDown,
    required Movement? target,
    required bool loop,
  }) async {
    final selected = await _selectAnimationByDirection(
      animationRight: animationRight,
      animationLeft: animationLeft,
      animationUp: animationUp,
      animationDown: animationDown,
      animationRightUp: animationRightUp,
      animationRightDown: animationRightDown,
      animationLeftUp: animationLeftUp,
      animationLeftDown: animationLeftDown,
      target: target,
    );

    return _cloneAnimation(selected, loop: loop);
  }

  static SpriteAnimation _cloneAnimation(
    SpriteAnimation original, {
    required bool loop,
  }) {
    final clonedFrames = original.frames
        .map((frame) => SpriteAnimationFrame(frame.sprite, frame.stepTime))
        .toList();
    return SpriteAnimation(clonedFrames, loop: loop);
  }
}
