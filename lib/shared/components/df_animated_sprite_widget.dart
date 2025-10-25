import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class DFAnimatedSpriteWidget extends StatelessWidget {
  static const double kStandardSize = 100.0;

  static const double kLargeSize = 150.0;

  static const double kSmallSize = 50.0;

  final Future<SpriteAnimation> animation;

  final double width;

  final double height;

  const DFAnimatedSpriteWidget({
    super.key,
    required this.animation,
    this.width = kStandardSize,
    this.height = kStandardSize,
  });

  const DFAnimatedSpriteWidget.large({
    super.key,
    required this.animation,
    this.width = kLargeSize,
    this.height = kLargeSize,
  });

  const DFAnimatedSpriteWidget.small({
    super.key,
    required this.animation,
    this.width = kSmallSize,
    this.height = kSmallSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: animation.asWidget());
  }
}
