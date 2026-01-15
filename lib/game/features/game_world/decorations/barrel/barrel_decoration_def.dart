import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/modules/combat/death/character_fx_sprite_animations_def.dart';
import 'package:dawnforge/game/core/modules/game/tile_constants.dart';
import 'package:dawnforge/game/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class BarrelDecorationDef {
  BarrelDecorationDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<Sprite> loadSprite() =>
      Sprite.load('gameplay/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 4.0,
  );

  static Future<SpriteAnimation> loadAnimationBreak() async {
    try {
      return await SpriteAnimation.load(
        // 'gameplay/decorations/barrel_decoration_break_6.png',
        'gameplay/decorations/barrel_decoration_AHUSHAU.png', // TODO(Kevin): creates barrel break sprites
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: _textureSize,
        ),
      );
    } catch (_) {
      return CharacterFxSpriteAnimationsDef.loadAnimationExplosionRight(); // TODO(Kevin): creates unique crash helper for these scenarios
    }
  }
}
