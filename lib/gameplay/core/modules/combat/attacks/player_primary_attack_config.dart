import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class PlayerPrimaryAttackConfig {
  PlayerPrimaryAttackConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<SpriteAnimation> loadFxAnimationRight3() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );
}
