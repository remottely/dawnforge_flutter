import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/modules/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class PlayerPrimaryAttackDef {
  PlayerPrimaryAttackDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSizeStandard = _textureSize;
  static final Vector2 componentSizeLarge = _textureSize * 2;

  static Future<SpriteAnimation> loadAnimationFxRight() => SpriteAnimation.load(
    'gameplay/characters/player/player_primary_attack_right_3.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 3,
      textureSize: _textureSize,
    ),
  );
}
