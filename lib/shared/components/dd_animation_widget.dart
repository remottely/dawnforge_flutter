import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class DDAnimationWidget extends StatelessWidget {
  static const double kSmallSize = 50.0;
  static const double kStandardSize = 100.0;
  static const double kLargeSize = 150.0;

  final double width;
  final double height;
  final Future<SpriteAnimation> animation;

  const DDAnimationWidget({
    super.key,
    required this.animation,
    this.width = kStandardSize,
    this.height = kStandardSize,
  });

  const DDAnimationWidget.large({
    super.key,
    required this.animation,
    this.width = kLargeSize,
    this.height = kLargeSize,
  });

  const DDAnimationWidget.small({
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
