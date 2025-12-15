import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';
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
    return SizedBox(
      width: _width,
      height: _height,
      child: animation.asWidget(),
    );
  }
}
