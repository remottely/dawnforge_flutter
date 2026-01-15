import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/core/modules/game/lightning_constants.dart';
import 'package:dawnforge/game/core/modules/game/tile_constants.dart';
import 'package:dawnforge/game/core/modules/localization/gameplay_strings_location.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class TorchDecorationDef {
  TorchDecorationDef._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusSuperSmall;

  static const int kVisionCheckInterval = 500;

  static const String kVisionCheckIntervalId = 'SeePlayer';

  static final String interactionPromptText = GameplayStringsLocation.instance
      .getString('torch_decoration_light_up');

  static const double kHealAmountPerPotion = 30.0;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;

  static final Vector2 componentSize = _textureSize;

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

  static Future<SpriteAnimation> loadAnimation() => SpriteAnimation.load(
    'gameplay/decorations/torch_decoration_6.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 6,
      textureSize: _textureSize,
    ),
  );

  static final LightingConfig lighting = LightingConfig(
    radius: TileConstants.kTileDimensionStandard,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.torchLighting,
  );
}
