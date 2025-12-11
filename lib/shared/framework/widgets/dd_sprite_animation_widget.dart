import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteAnimationWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<SpriteAnimation> animation;

  const DDSpriteAnimationWidget({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kSizeStandard,
      _height = SpriteAnimationConfig.kSizeStandard;

  const DDSpriteAnimationWidget.small({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kSizeSmall,
      _height = SpriteAnimationConfig.kSizeSmall;

  const DDSpriteAnimationWidget.large({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kSizeLarge,
      _height = SpriteAnimationConfig.kSizeLarge;

  const DDSpriteAnimationWidget.extraLarge({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kSizeExtraLarge,
      _height = SpriteAnimationConfig.kSizeExtraLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: animation.asWidget(),
    );
  }
}
