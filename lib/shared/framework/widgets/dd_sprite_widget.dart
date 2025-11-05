import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({super.key, required this.sprite})
    : _width = GameplaySpriteAnimationConfig.kStandardSize,
      _height = GameplaySpriteAnimationConfig.kStandardSize;

  const DDSpriteWidget.small({super.key, required this.sprite})
    : _width = GameplaySpriteAnimationConfig.kSmallSize,
      _height = GameplaySpriteAnimationConfig.kSmallSize;

  const DDSpriteWidget.large({super.key, required this.sprite})
    : _width = GameplaySpriteAnimationConfig.kLargeSize,
      _height = GameplaySpriteAnimationConfig.kLargeSize;

  const DDSpriteWidget.extraLarge({super.key, required this.sprite})
    : _width = GameplaySpriteAnimationConfig.kExtraLargeSize,
      _height = GameplaySpriteAnimationConfig.kExtraLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height, child: sprite.asWidget());
  }
}
