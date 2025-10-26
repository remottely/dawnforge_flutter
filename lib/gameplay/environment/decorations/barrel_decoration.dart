import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _BarrelDecorationConfig {
  static const _kTexturePath =
      'gameplay/environment/decorations/barrel_decoration_1.png';
  static final Vector2 _componentSize = GameplayConstants.kTileSizeStandard;

  static Future<Sprite> _loadSprite() => Sprite.load(_kTexturePath);
  static final fHitbox = RectangleHitbox(
    position: Vector2(2, 6),
    size: Vector2(11, 4),
  );
}

class BarrelDecorationView extends DDPushableDecoration {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: _BarrelDecorationConfig._loadSprite(),
        size: _BarrelDecorationConfig._componentSize,
      );

  @override
  Future<void> onLoad() {
    add(_BarrelDecorationConfig.fHitbox);

    return super.onLoad();
  }
}
