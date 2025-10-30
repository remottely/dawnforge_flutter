import 'package:bonfire/bonfire.dart';

// enum GameDifficulty { easy, normal, hard, nightmare }

class GameplayTileConfig {
  static const int kMaxVisibleTiles = 16;
  static const int kBossConversationVisibleTiles = 32;

  static const double kTileDimensionSmall = 8.0;
  static const double kTileDimensionStandard = 16.0;
  static const double kTileDimensionLarge = 24.0;
  static const double kTileDimensionExtraLarge = 32.0;

  static final Vector2 fTileSizeSmall = Vector2.all(kTileDimensionSmall);
  static final Vector2 fTileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final Vector2 fTileSizeLarge = Vector2.all(kTileDimensionLarge);
  static final Vector2 fTileSizeExtraLarge = Vector2.all(
    kTileDimensionExtraLarge,
  );

  // static const double kCharacterSpeedSlow = 24.0;
  // static const double kCharacterSpeedMedium = 32.0;
  // static const double kCharacterSpeedFast = 40.0;

  // static const double kPropertyAmountSmall = 30.0;
  // static const double kPropertyAmountMedium = 60.0;
  // static const double kPropertyAmountLarge = 120.0;

  // static const double kVisionRadiusSmall = 32.0;
  // static const double kVisionRadiusMedium = 48.0;
  // static const double kVisionRadiusLarge = 64.0;
  // static const double kVisionRadiusExtraLarge = 80.0;
  // static const double kVisionRadiusUltraLarge = 96.0;
}
