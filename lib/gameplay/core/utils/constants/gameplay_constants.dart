import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class GameplayConstants {
  static const int kMaxVisibleTiles = 16;
  static const int kBossDialogVisibleTiles = 32;

  static double getCameraZoomFromMaxVisibleTile(
    BuildContext context, {
    required int maxVisibleTile,
  }) {
    return getZoomFromMaxVisibleTile(
      context,
      kTileDimensionStandard,
      maxVisibleTile,
    );
  }

  static const double kTileDimensionSmall = 8;
  static const double kTileDimensionStandard = 16;
  static const double kTileDimensionLarge = 24;
  static const double kTileDimensionExtraLarge = 32;

  static final Vector2 kTileSizeSmall = Vector2.all(kTileDimensionSmall);
  static final Vector2 kTileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final Vector2 kTileSizeLarge = Vector2.all(kTileDimensionLarge);
  static final Vector2 kTileSizeExtraLarge = Vector2.all(
    kTileDimensionExtraLarge,
  );

  static const double kCameraSpeed = 3.0;

  static const double kCharacterSpeedSlow = 24;
  static const double kCharacterSpeedMedium = 32;
  static const double kCharacterSpeedFast = 40;

  static const double kPropertyAmountSmall = 30;
  static const double kPropertyAmountMedium = 60;
  static const double kPropertyAmountLarge = 120;

  static const double kVisionRadiusSmall = 32;
  static const double kVisionRadiusMedium = 48;
  static const double kVisionRadiusLarge = 64;
  static const double kVisionRadiusExtraLarge = 80;
  static const double kVisionRadiusUltraLarge = 96;

  static const int kPriority1 = 1;
}
