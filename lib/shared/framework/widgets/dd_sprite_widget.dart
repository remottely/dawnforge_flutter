import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kStandardSize,
      _height = SpriteAnimationConfig.kStandardSize;

  const DDSpriteWidget.small({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kSmallSize,
      _height = SpriteAnimationConfig.kSmallSize;

  const DDSpriteWidget.large({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kLargeSize,
      _height = SpriteAnimationConfig.kLargeSize;

  const DDSpriteWidget.extraLarge({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kExtraLargeSize,
      _height = SpriteAnimationConfig.kExtraLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height, child: sprite.asWidget());
  }
}
