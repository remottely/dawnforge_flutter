import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_pushable_decoration.dart';

final class _BarrelDecorationConfig {
  _BarrelDecorationConfig._();

  static final Vector2 _componentSize = GameplayTileConfig.tileSizeStandard;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/environment/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(2, 6), size: Vector2(11, 4));
}

class BarrelDecorationView extends DDPushableDecoration {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: _BarrelDecorationConfig._loadSprite(),
        size: _BarrelDecorationConfig._componentSize,
      );

  @override
  Future<void> onLoad() {
    add(_BarrelDecorationConfig.createHitbox());

    return super.onLoad();
  }
}
