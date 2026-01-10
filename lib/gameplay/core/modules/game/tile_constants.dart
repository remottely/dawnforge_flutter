import 'package:bonfire/bonfire.dart';

final class TileConstants {
  TileConstants._();

  static const int kMaxVisibleTiles = 24;
  static const int kBossConversationVisibleTiles = 32;

  static const double kTileDimensionSmall = 8.0;
  static const double kTileDimensionStandard = 16.0;
  static const double kTileDimensionLarge = 24.0;
  static const double kTileDimensionExtraLarge = 32.0;
  static const double kTileDimensionSuperLarge = 48.0;
  static const double kTileDimension128 = 128.0;

  static final Vector2 tileSizeSmall = Vector2.all(kTileDimensionSmall);
  static final Vector2 tileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final Vector2 tileSizeLarge = Vector2.all(kTileDimensionLarge);
  static final Vector2 tileSizeExtraLarge = Vector2.all(
    kTileDimensionExtraLarge,
  );
  static final Vector2 tileSizeSuperLarge = Vector2.all(
    kTileDimensionSuperLarge,
  );
  static final Vector2 tileSize128 = Vector2.all(kTileDimension128);

  static final Vector2 tileSizeSunny = Vector2(96, 64);
  static final Vector2 tileSizeCute = Vector2(48, 48);
  static final Vector2 tileSizeFarmer = Vector2(48, 48);

  static const double kCharacterDimensionDemo = 64.0;
  static final Vector2 tileSizeDemo = Vector2(
    kCharacterDimensionDemo,
    kCharacterDimensionDemo,
  );
}
