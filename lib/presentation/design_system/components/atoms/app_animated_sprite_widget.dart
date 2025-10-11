import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class AppAnimatedSpriteWidget extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const AppAnimatedSpriteWidget({Key? key, required this.animation})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100, height: 100, child: animation.asWidget());
  }
}
