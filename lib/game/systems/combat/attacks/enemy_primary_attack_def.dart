import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class EnemyPrimaryAttackDef {
  EnemyPrimaryAttackDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeSmall;
  static final Vector2 componentSize = _textureSize;

  static Future<SpriteAnimation> loadAnimationFxRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 3,
      textureSize: _textureSize,
    ),
  );
}
