import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_config.dart';
import 'package:flutter/material.dart';

class DDSpriteAnimationWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<SpriteAnimation> animation;

  const DDSpriteAnimationWidget({super.key, required this.animation})
    : _width = SpriteAnimationConstants.kSizeStandard,
      _height = SpriteAnimationConstants.kSizeStandard;

  const DDSpriteAnimationWidget.small({super.key, required this.animation})
    : _width = SpriteAnimationConstants.kSizeSmall,
      _height = SpriteAnimationConstants.kSizeSmall;

  const DDSpriteAnimationWidget.large({super.key, required this.animation})
    : _width = SpriteAnimationConstants.kSizeLarge,
      _height = SpriteAnimationConstants.kSizeLarge;

  const DDSpriteAnimationWidget.extraLarge({super.key, required this.animation})
    : _width = SpriteAnimationConstants.kSizeExtraLarge,
      _height = SpriteAnimationConstants.kSizeExtraLarge;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      color: Colors.red.withOpacity(0.2), // ← DEBUG: ver o container
      child: FutureBuilder<DDSpriteAnimation>(
        // future: UISpriteAnimationsConfig.loadAnimationCutePlayerIdleRight(),
        // future: UISpriteAnimationsConfig.loadAnimationKnightPlayerIdleRight2(),
        future: UISpriteAnimationsConfig.loadAnimationSunnyPlayerIdleRight2(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final ddSpriteAnimation = snapshot.data!;
          final spriteAnimation = ddSpriteAnimation.animation;
          final size = ddSpriteAnimation.animation.frames.first.sprite.srcSize;
          // final effectiveSize = ddSpriteAnimation.effectiveSize;

          // if (effectiveSize == null) {
          //   return Center(child: spriteAnimation.asWidget());
          // }

          final scale = 0.05 * size.x;
          // 128;
          // effectiveSize.x; // 100 / 32
          // final scaleX = _width / effectiveSize.x; // 100 / 32
          // final scaleY = _height / effectiveSize.y;
          // final scale = scaleX < scaleY ? scaleX : scaleY;

          return Center(
            child: ClipRect(
              child: OverflowBox(
                // minWidth: 0,
                // minHeight: 0,
                // maxWidth: double.infinity,
                // maxHeight: double.infinity,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    // width: effectiveSize.x,
                    // height: effectiveSize.y,
                    child: spriteAnimation.asWidget(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
