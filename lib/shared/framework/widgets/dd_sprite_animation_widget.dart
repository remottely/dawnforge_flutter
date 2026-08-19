import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:flutter/material.dart';

class DDSpriteAnimationWidget extends StatelessWidget {
  final Future<SpriteAnimation> animation;
  final double _width;
  final double _height;

  const DDSpriteAnimationWidget({
    required this.animation,
    required this._width,
    required this._height,
    super.key,
  });

  const DDSpriteAnimationWidget.standard({required this.animation, super.key})
    : _width = SpriteAnimationConstants.kSizeStandard,
      _height = SpriteAnimationConstants.kSizeStandard;

  const DDSpriteAnimationWidget.small({required this.animation, super.key})
    : _width = SpriteAnimationConstants.kSizeSmall,
      _height = SpriteAnimationConstants.kSizeSmall;

  const DDSpriteAnimationWidget.large({required this.animation, super.key})
    : _width = SpriteAnimationConstants.kSizeLarge,
      _height = SpriteAnimationConstants.kSizeLarge;

  const DDSpriteAnimationWidget.extraLarge({required this.animation, super.key})
    : _width = SpriteAnimationConstants.kSizeExtraLarge,
      _height = SpriteAnimationConstants.kSizeExtraLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.red,
      width: _width,
      height: _height,
      child: FutureBuilder<SpriteAnimation>(
        future: animation,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final spriteAnimation = snapshot.data!;

          return Center(
            // TODO(Kevin): adjust this logic to be bottomCenter and calculate the sprite bottom using hitbox size
            child: Transform.scale(scale: 4, child: spriteAnimation.asWidget()),
          );
        },
      ),
    );
  }
}
