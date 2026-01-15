import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/game/features/game_world/decorations/decoration_constants.dart';

final class LifePotionDef {
  LifePotionDef._();

  static const Duration kHealingDuration = Duration(seconds: 1);
  static const double kStandardHealAmount = 50.0;
  static const double kHealAmount = DecorationConstants.kStatsAmountLarge;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<Sprite> loadSprite() =>
      Sprite.load('gameplay/decorations/life_potion_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 3.0,
    hitboxStartPositionY: 3.0,
  )..collisionType = CollisionType.passive;
}
