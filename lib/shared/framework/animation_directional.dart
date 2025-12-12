import 'package:bonfire/bonfire.dart';

class AnimationDirectionalFactory {
  final Future<SpriteAnimation> loadRight;
  final Future<SpriteAnimation> loadLeft;
  final Future<SpriteAnimation>? loadUp;
  final Future<SpriteAnimation>? loadDown;
  final Future<SpriteAnimation>? loadRightUp;
  final Future<SpriteAnimation>? loadRightDown;
  final Future<SpriteAnimation>? loadLeftUp;
  final Future<SpriteAnimation>? loadLeftDown;

  AnimationDirectionalFactory({
    required this.loadRight,
    required this.loadLeft,
    this.loadUp,
    this.loadDown,
    this.loadRightUp,
    this.loadRightDown,
    this.loadLeftUp,
    this.loadLeftDown,
  });
}

class AnimationDirectional {
  final SpriteAnimation right;
  final SpriteAnimation left;
  final SpriteAnimation? up;
  final SpriteAnimation? down;
  final SpriteAnimation? rightUp;
  final SpriteAnimation? leftUp;
  final SpriteAnimation? rightDown;
  final SpriteAnimation? leftDown;

  AnimationDirectional({
    required this.right,
    required this.left,
    this.up,
    this.down,
    this.rightUp,
    this.leftUp,
    this.rightDown,
    this.leftDown,
  });
}
