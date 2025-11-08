import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteAnimationWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<SpriteAnimation> animation;

  const DDSpriteAnimationWidget({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kStandardSize,
      _height = SpriteAnimationConfig.kStandardSize;

  const DDSpriteAnimationWidget.small({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kSmallSize,
      _height = SpriteAnimationConfig.kSmallSize;

  const DDSpriteAnimationWidget.large({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kLargeSize,
      _height = SpriteAnimationConfig.kLargeSize;

  const DDSpriteAnimationWidget.extraLarge({super.key, required this.animation})
    : _width = SpriteAnimationConfig.kExtraLargeSize,
      _height = SpriteAnimationConfig.kExtraLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: animation.asWidget(),
    );
  }
}
