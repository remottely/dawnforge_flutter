import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteAnimationWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<SpriteAnimation> animation;

  const DDSpriteAnimationWidget({super.key, required this.animation})
    : _width = GameplaySpriteAnimationConfig.kStandardSize,
      _height = GameplaySpriteAnimationConfig.kStandardSize;

  const DDSpriteAnimationWidget.small({super.key, required this.animation})
    : _width = GameplaySpriteAnimationConfig.kSmallSize,
      _height = GameplaySpriteAnimationConfig.kSmallSize;

  const DDSpriteAnimationWidget.large({super.key, required this.animation})
    : _width = GameplaySpriteAnimationConfig.kLargeSize,
      _height = GameplaySpriteAnimationConfig.kLargeSize;

  const DDSpriteAnimationWidget.extraLarge({super.key, required this.animation})
    : _width = GameplaySpriteAnimationConfig.kExtraLargeSize,
      _height = GameplaySpriteAnimationConfig.kExtraLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: animation.asWidget(),
    );
  }
}
