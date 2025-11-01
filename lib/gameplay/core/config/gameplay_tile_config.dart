import 'package:bonfire/bonfire.dart';

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
}
