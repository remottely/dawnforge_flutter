import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/core/systems/game/tile_constants.dart';
import 'package:dawnforge/game/core/systems/localization/gameplay_strings_location.dart';
import 'package:dawnforge/game/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class ChestDecorationConfig {
  ChestDecorationConfig._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusExtraSmall;
  static const int kVisionCheckInterval = 500;
  static const String kVisionCheckIntervalId = 'SeePlayer';
  static final String interactionPromptText = GameplayStringsLocation.instance
      .getString('chest_decoration_open');
  static const double kHealAmountPerPotion = 30.0;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize / 1.5;

  static Future<SpriteAnimation> loadAnimation() => SpriteAnimation.load(
    'gameplay/decorations/chest_decoration_8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: _textureSize,
    ),
  );

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 0.0,
    hitboxStartPositionY: 4.0,
  );

  static TextPaint createTextConfig(double componentWidth) => TextPaint(
    style: TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: componentWidth / 2,
    ),
  );

  static Vector2 getTextPosition(
    double componentWidth,
    double componentHeight,
  ) => Vector2(componentWidth / -1.5, -componentHeight);
}
