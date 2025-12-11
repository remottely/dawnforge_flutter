import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kSizeStandard,
      _height = SpriteAnimationConfig.kSizeStandard;

  const DDSpriteWidget.small({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kSizeSmall,
      _height = SpriteAnimationConfig.kSizeSmall;

  const DDSpriteWidget.large({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kSizeLarge,
      _height = SpriteAnimationConfig.kSizeLarge;

  const DDSpriteWidget.extraLarge({super.key, required this.sprite})
    : _width = SpriteAnimationConfig.kSizeExtraLarge,
      _height = SpriteAnimationConfig.kSizeExtraLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height, child: sprite.asWidget());
  }
}
