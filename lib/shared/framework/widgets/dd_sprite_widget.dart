import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  final double _width;
  final double _height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({required this.sprite, super.key})
    : _width = SpriteAnimationConstants.kSizeStandard,
      _height = SpriteAnimationConstants.kSizeStandard;

  const DDSpriteWidget.small({required this.sprite, super.key})
    : _width = SpriteAnimationConstants.kSizeSmall,
      _height = SpriteAnimationConstants.kSizeSmall;

  const DDSpriteWidget.large({required this.sprite, super.key})
    : _width = SpriteAnimationConstants.kSizeLarge,
      _height = SpriteAnimationConstants.kSizeLarge;

  const DDSpriteWidget.extraLarge({required this.sprite, super.key})
    : _width = SpriteAnimationConstants.kSizeExtraLarge,
      _height = SpriteAnimationConstants.kSizeExtraLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width, height: _height, child: sprite.asWidget());
  }
}
