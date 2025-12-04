import 'package:bonfire/bonfire.dart';

extension DDBasePlayerExtension on Player {
  void executeMeleeAttack({
    required double damage,
    required Vector2 size,
    Future<SpriteAnimation>? animationRight,
    dynamic id,
    Direction? direction,
    bool withPush = true,
    double? sizePush,
    Vector2? centerOffset,
    double? marginFromCenter,
    bool diagonalEnabled = true,
    void Function(Attackable)? onDamage,
  }) {
    simpleAttackMeleeByDirection(
      direction: direction ?? _getLastDirection(diagonalEnabled),
      animationRight: animationRight,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
      sizePush: sizePush,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
      centerOffset: centerOffset,
      marginFromCenter: marginFromCenter,
      onDamage: onDamage,
    );
  }

  Direction _getLastDirection(bool diagonalEnabled) {
    if (diagonalEnabled) {
      return lastDirection;
    }

    switch (lastDirection) {
      case Direction.left:
      case Direction.right:
      case Direction.up:
      case Direction.down:
        return lastDirection;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        return lastDirectionHorizontal;
    }
  }
}
