import 'package:bonfire/bonfire.dart';

final class GameplayTileConstants {
  GameplayTileConstants._();

  static const int kMaxVisibleTiles = 16;
  static const int kBossConversationVisibleTiles = 32;

  static const double kTileDimensionSmall = 8.0;
  static const double kTileDimensionStandard = 16.0;
  static const double kTileDimensionLarge = 24.0;
  static const double kTileDimensionExtraLarge = 32.0;

  static final Vector2 tileSizeSmall = Vector2.all(kTileDimensionSmall);
  static final Vector2 tileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final Vector2 tileSizeLarge = Vector2.all(kTileDimensionLarge);
  static final Vector2 tileSizeExtraLarge = Vector2.all(
    kTileDimensionExtraLarge,
  );
  static final Vector2 tileSizeSunnyWorld = Vector2(96, 64);
}
