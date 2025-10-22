import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

abstract class _BarrelDecorationData {
  /// DATA
  static const String _spritePath =
      'gameplay/environment/decorations/barrel_decoration_1.png';
  static final Vector2 _spriteSize = GameplayConstants.kTileVector2Standard;
  static final Vector2 _hitBoxPosition = Vector2(2, 6);
  static final Vector2 _hitBoxSize = Vector2(12, 4);

  /// LOAD
  static Future<Sprite> _loadSprite() => Sprite.load(_spritePath);
  static FutureOr<void> _buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: _hitBoxPosition, size: _hitBoxSize));
}

class BarrelDecoration extends DFPushableDecoration {
  BarrelDecoration({required super.position})
    : super.withSprite(
        sprite: _BarrelDecorationData._loadSprite(),
        size: _BarrelDecorationData._spriteSize,
      );

  @override
  Future<void> onLoad() {
    _BarrelDecorationData._buildHitBox(this);
    return super.onLoad();
  }
}
