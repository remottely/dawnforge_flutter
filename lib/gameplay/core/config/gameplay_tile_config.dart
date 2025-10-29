import 'package:bonfire/bonfire.dart';

// enum GameDifficulty { easy, normal, hard, nightmare }

class GameplayTileConfig {
  static const kMaxVisibleTiles = 16;
  static const kBossConversationVisibleTiles = 32;

  static const kTileDimensionSmall = 8.0;
  static const kTileDimensionStandard = 16.0;
  static const kTileDimensionLarge = 24.0;
  static const kTileDimensionExtraLarge = 32.0;

  static final fTileSizeSmall = Vector2.all(kTileDimensionSmall);
  static final fTileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final fTileSizeLarge = Vector2.all(kTileDimensionLarge);
  static final fTileSizeExtraLarge = Vector2.all(kTileDimensionExtraLarge);

  // static const kCharacterSpeedSlow = 24.0;
  // static const kCharacterSpeedMedium = 32.0;
  // static const kCharacterSpeedFast = 40.0;

  // static const kPropertyAmountSmall = 30.0;
  // static const kPropertyAmountMedium = 60.0;
  // static const kPropertyAmountLarge = 120.0;

  // static const kVisionRadiusSmall = 32.0;
  // static const kVisionRadiusMedium = 48.0;
  // static const kVisionRadiusLarge = 64.0;
  // static const kVisionRadiusExtraLarge = 80.0;
  // static const kVisionRadiusUltraLarge = 96.0;
}
