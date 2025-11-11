import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_pushable_decoration.dart';

final class _BarrelDecorationConfig {
  _BarrelDecorationConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: _componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 6.0,
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
    add(_BarrelDecorationConfig.createHitbox());
    return super.onLoad();
  }
}
