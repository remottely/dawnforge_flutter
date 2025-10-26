import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  static const _kSmallSize = 50.0;
  static const _kStandardSize = 100.0;
  static const _kLargeSize = 150.0;

  final double width;
  final double height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({
    super.key,
    required this.sprite,
    this.width = _kStandardSize,
    this.height = _kStandardSize,
  });

  const DDSpriteWidget.large({
    super.key,
    required this.sprite,
    this.width = _kLargeSize,
    this.height = _kLargeSize,
  });

  const DDSpriteWidget.small({
    super.key,
    required this.sprite,
    this.width = _kSmallSize,
    this.height = _kSmallSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: sprite.asWidget());
  }
}
