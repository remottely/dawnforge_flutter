import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class DDSpriteWidget extends StatelessWidget {
  static const double kSmallSize = 50.0;
  static const double kStandardSize = 100.0;
  static const double kLargeSize = 150.0;

  final double width;
  final double height;
  final Future<Sprite> sprite;

  const DDSpriteWidget({
    super.key,
    required this.sprite,
    this.width = kStandardSize,
    this.height = kStandardSize,
  });

  const DDSpriteWidget.large({
    super.key,
    required this.sprite,
    this.width = kLargeSize,
    this.height = kLargeSize,
  });

  const DDSpriteWidget.small({
    super.key,
    required this.sprite,
    this.width = kSmallSize,
    this.height = kSmallSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: sprite.asWidget());
  }
}
