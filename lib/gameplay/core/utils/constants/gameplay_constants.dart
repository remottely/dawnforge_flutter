import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class GameplayConstants {
  static const kMaxVisibleTiles = 16;
  static const kBossDialogVisibleTiles = 32;

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

  static const _kTileDimensionSmall = 8.0;
  static const kTileDimensionStandard = 16.0;
  static const _kTileDimensionLarge = 24.0;
  static const _kTileDimensionExtraLarge = 32.0;

  static final fTileSizeSmall = Vector2.all(_kTileDimensionSmall);
  static final fTileSizeStandard = Vector2.all(kTileDimensionStandard);
  static final fTileSizeLarge = Vector2.all(_kTileDimensionLarge);
  static final fTileSizeExtraLarge = Vector2.all(_kTileDimensionExtraLarge);

  static const kCameraSpeed = 3.0;

  static const kCharacterSpeedSlow = 24.0;
  static const kCharacterSpeedMedium = 32.0;
  static const kCharacterSpeedFast = 40.0;

  static const kPropertyAmountSmall = 30.0;
  static const kPropertyAmountMedium = 60.0;
  static const kPropertyAmountLarge = 120.0;

  static const kVisionRadiusSmall = 32.0;
  static const kVisionRadiusMedium = 48.0;
  static const kVisionRadiusLarge = 64.0;
  static const kVisionRadiusExtraLarge = 80.0;
  static const kVisionRadiusUltraLarge = 96.0;

  static const kPriority1 = 1;
}
