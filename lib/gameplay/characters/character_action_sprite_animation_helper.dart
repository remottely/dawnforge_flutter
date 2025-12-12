import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/animation_directional.dart';

final class CharacterActionSpriteAnimationHelper {
  CharacterActionSpriteAnimationHelper._();

  static Future<void> playOnce({
    required SpriteAnimation animationRight,
    required SpriteAnimation animationLeft,
    SpriteAnimation? animationUp,
    SpriteAnimation? animationDown,
    SpriteAnimation? animationRightUp,
    SpriteAnimation? animationRightDown,
    SpriteAnimation? animationLeftUp,
    SpriteAnimation? animationLeftDown,
    required SimpleDirectionAnimation? currentAnimation,
    required Movement? target,
  }) async {
    final attackAnimation = _cloneSelectedAnimation(
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

  static void playLoop({
    required SpriteAnimation animationRight,
    required SpriteAnimation animationLeft,
    SpriteAnimation? animationUp,
    SpriteAnimation? animationDown,
    SpriteAnimation? animationRightUp,
    SpriteAnimation? animationRightDown,
    SpriteAnimation? animationLeftUp,
    SpriteAnimation? animationLeftDown,
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
      final loopAnimation = _cloneSelectedAnimation(
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
    required SpriteAnimation animationRight,
    required SpriteAnimation animationLeft,
    SpriteAnimation? animationUp,
    SpriteAnimation? animationDown,
    SpriteAnimation? animationRightUp,
    SpriteAnimation? animationRightDown,
    SpriteAnimation? animationLeftUp,
    SpriteAnimation? animationLeftDown,
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

  static SpriteAnimation _selectAnimationByDirection({
    required SpriteAnimation animationRight,
    required SpriteAnimation animationLeft,
    SpriteAnimation? animationUp,
    SpriteAnimation? animationDown,
    SpriteAnimation? animationRightUp,
    SpriteAnimation? animationRightDown,
    SpriteAnimation? animationLeftUp,
    SpriteAnimation? animationLeftDown,
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

  static SpriteAnimation _cloneSelectedAnimation({
    required SpriteAnimation animationRight,
    required SpriteAnimation animationLeft,
    SpriteAnimation? animationUp,
    SpriteAnimation? animationDown,
    SpriteAnimation? animationRightUp,
    SpriteAnimation? animationRightDown,
    SpriteAnimation? animationLeftUp,
    SpriteAnimation? animationLeftDown,
    required Movement? target,
    required bool loop,
  }) {
    final selected = _selectAnimationByDirection(
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

  static Future<AnimationDirectional> loadAnimationDirectionalFromFactory(
    AnimationDirectionalFactory animationsFactory,
  ) async {
    Future<SpriteAnimation?> loadSafe(Future<SpriteAnimation>? loader) async {
      if (loader == null) return null;
      return await loader;
    }

    final loadedList = await Future.wait([
      animationsFactory.loadRight,
      animationsFactory.loadLeft,
      loadSafe(animationsFactory.loadUp),
      loadSafe(animationsFactory.loadDown),
      loadSafe(animationsFactory.loadRightUp),
      loadSafe(animationsFactory.loadRightDown),
      loadSafe(animationsFactory.loadLeftUp),
      loadSafe(animationsFactory.loadLeftDown),
    ]);

    return AnimationDirectional(
      right: loadedList[0]!,
      left: loadedList[1]!,
      up: loadedList[2],
      down: loadedList[3],
      rightUp: loadedList[4],
      rightDown: loadedList[5],
      leftUp: loadedList[6],
      leftDown: loadedList[7],
    );
  }
}
