import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class DDAnimationWidget extends StatelessWidget {
  static const _kSmallSize = 50.0; // TODO(Kevin): unify with DDSpriteWidget
  static const _kStandardSize = 100.0; // TODO(Kevin): unify with DDSpriteWidget
  static const _kLargeSize = 150.0; // TODO(Kevin): unify with DDSpriteWidget

  final double width;
  final double height;
  final Future<SpriteAnimation> animation;

  const DDAnimationWidget({
    super.key,
    required this.animation,
    this.width = _kStandardSize,
    this.height = _kStandardSize,
  });

  const DDAnimationWidget.large({
    super.key,
    required this.animation,
    this.width = _kLargeSize,
    this.height = _kLargeSize,
  });

  const DDAnimationWidget.small({
    super.key,
    required this.animation,
    this.width = _kSmallSize,
    this.height = _kSmallSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: animation.asWidget());
  }
}
