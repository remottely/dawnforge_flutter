import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_pushable_decoration.dart';

final class _BarrelDecorationConfig {
  _BarrelDecorationConfig._();

  static final Vector2 _textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/environment/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    textureSize: _textureSize,
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
