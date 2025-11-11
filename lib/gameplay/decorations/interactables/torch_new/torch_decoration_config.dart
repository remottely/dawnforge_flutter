import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class TorchDecorationConfig {
  TorchDecorationConfig._();

  ///-----

  // Constants
  static const double kVisionRadius =
      CharacterConstants.kVisionRadiusSuperSmall;
  static const int kVisionCheckInterval = 500;
  static const String kVisionCheckIntervalId = 'SeePlayer';
  static const String kInteractionPromptText = 'Open me!!';
  static const double kHealAmountPerPotion = 30.0;

  // Component size

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

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<SpriteAnimation> loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/decorations/torch_decoration_6.png',
    SpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: _textureSize,
    ),
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionExtraLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.torchLighting,
  );
}
