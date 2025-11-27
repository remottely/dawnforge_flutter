import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';

final class BarrelDecorationConfig {
  BarrelDecorationConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<Sprite> loadSprite() =>
      Sprite.load('gameplay/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 6.0,
  );

  static Future<SpriteAnimation> loadBreakAnimation() async {
    try {
      return await SpriteAnimation.load(
        // 'gameplay/decorations/barrel_decoration_break_6.png',
        'gameplay/decorations/barrel_decoration_AHUSHAU.png', // TODO(Kevin): creates barrel break sprites
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: _textureSize,
        ),
      );
    } catch (_) {
      return CharacterFxSpriteAnimationsConfig.loadExplosionRight7(); // TODO(Kevin): creates unique crash helper for these scenarios
    }
  }
}
