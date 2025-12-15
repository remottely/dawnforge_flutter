import 'package:bonfire/bonfire.dart';

class DDAnimationDirectionalFactory {
  final Future<SpriteAnimation> loadRight;
  final Future<SpriteAnimation> loadLeft;
  final Future<SpriteAnimation>? loadUp;
  final Future<SpriteAnimation>? loadDown;
  final Future<SpriteAnimation>? loadRightUp;
  final Future<SpriteAnimation>? loadRightDown;
  final Future<SpriteAnimation>? loadLeftUp;
  final Future<SpriteAnimation>? loadLeftDown;

  DDAnimationDirectionalFactory({
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

class DDAnimationDirectional {
  final SpriteAnimation right;
  final SpriteAnimation left;
  final SpriteAnimation? up;
  final SpriteAnimation? down;
  final SpriteAnimation? rightUp;
  final SpriteAnimation? leftUp;
  final SpriteAnimation? rightDown;
  final SpriteAnimation? leftDown;

  DDAnimationDirectional({
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
