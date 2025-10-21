import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

abstract class _BarrelData {
  /// DATA
  static const String _spritePath =
      'gameplay/environment/decorations/barrel_decoration_1.png';
  static Vector2 get _spriteSize => GameplayConstants.kTileVector2Default;
  static Vector2 get _hitBoxPosition => Vector2(2, 6);
  static Vector2 get _hitBoxSize => Vector2(12, 4);

  /// LOAD
  static Future<Sprite> _loadSprite() => Sprite.load(_spritePath);
  static FutureOr<void> _loadHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: _hitBoxPosition, size: _hitBoxSize));
}

class BarrelDecoration extends DFPushableDecoration {
  BarrelDecoration({required super.position})
    : super.withSprite(
        sprite: _BarrelData._loadSprite(),
        size: _BarrelData._spriteSize,
      );

  @override
  Future<void> onLoad() {
    _BarrelData._loadHitBox(this);
    return super.onLoad();
  }
}
