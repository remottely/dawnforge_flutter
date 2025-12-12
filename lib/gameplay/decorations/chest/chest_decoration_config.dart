import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';

final class ChestDecorationConfig {
  ChestDecorationConfig._();

  // Constants
  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusExtraSmall;
  static const int kVisionCheckInterval = 500;
  static const String kVisionCheckIntervalId = 'SeePlayer';
  static final String interactionPromptText = GameplayStringsLocation.instance
      .getString('chest_decoration_open');
  static const double kHealAmountPerPotion = 30.0;

  // Component size
  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize / 1.5;

  // Animations
  static Future<SpriteAnimation> loadAnimation() => SpriteAnimation.load(
    'gameplay/decorations/chest_decoration_8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: _textureSize,
    ),
  );

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 0.0,
    hitboxStartPositionY: 4.0,
  );

  // Text configuration
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
