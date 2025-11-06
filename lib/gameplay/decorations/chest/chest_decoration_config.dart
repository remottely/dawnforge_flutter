import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

final class ChestDecorationConfig {
  ChestDecorationConfig._();

  // Constants
  static const double kVisionRadius =
      GameplayTileConstants.kTileDimensionStandard;
  static const int kVisionCheckInterval = 500;
  static const String kVisionCheckIntervalId = 'SeePlayer';
  static const String kInteractionPromptText = 'Open me!!';
  static const double kHealAmountPerPotion = 30.0;

  // Component size
  static final Vector2 _textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize / 1.5;

  // Smoke explosion size
  static final Vector2 smokeExplosionSize = Vector2.all(
    GameplayTileConstants.kTileDimensionStandard * 0.5,
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

  // Animations

  static Future<SpriteAnimation> get chestAnimation => SpriteAnimation.load(
    'gameplay/decorations/chest_decoration_8.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: _textureSize,
    ),
  );

  static final Vector2 _emoteTextureSize =
      GameplayTileConstants.tileSizeExtraLarge;

  static Future<SpriteAnimation> get emoteAnimation => SpriteAnimation.load(
    CharacterEmoteManager.kExclamationEmoteAsset,
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: _emoteTextureSize,
    ),
  );
}
