import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _BarrelDecorationConfig {
  static final _fComponentSize = GameplayConstants.fTileSizeStandard;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/environment/decorations/barrel_decoration_1.png');

  static final fHitbox = RectangleHitbox(
    position: Vector2(2, 6),
    size: Vector2(11, 4),
  );
}

class BarrelDecorationView extends DDPushableDecoration {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: _BarrelDecorationConfig._loadSprite(),
        size: _BarrelDecorationConfig._fComponentSize,
      );

  @override
  Future<void> onLoad() {
    add(_BarrelDecorationConfig.fHitbox);

    return super.onLoad();
  }
}
