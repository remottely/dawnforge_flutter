import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class GameplayConstants {
  // CAMERA CONSTANTS
  static const int kMaxVisibleTiles = 16;
  static const int kBossDialogVisibleTiles = 32;

  static double getCameraZoomFromMaxVisibleTile(
    BuildContext context, {
    required int maxVisibleTile,
  }) {
    return getZoomFromMaxVisibleTile(
      context,
      GameplayConstants.kTileSizeStandard,
      maxVisibleTile,
    );
  }

  /// TILE SIZES
  static const double kTileSizeSmall = 8;
  static const double kTileSizeStandard = 16;
  static const double kTileSizeLarge = 24;
  static const double kTileSizeExtraLarge = 32;

  static final Vector2 kTileVector2Small = Vector2.all(kTileSizeSmall);
  static final Vector2 kTileVector2Standard = Vector2.all(kTileSizeStandard);
  static final Vector2 kTileVector2Large = Vector2.all(kTileSizeLarge);
  static final Vector2 kTileVector2ExtraLarge = Vector2.all(
    kTileSizeExtraLarge,
  );

  /// SPEEDS
  static const double kCameraSpeed = 3.0;

  static const double kCharacterSpeedSlow = 24;
  static const double kCharacterSpeedMedium = 32;
  static const double kCharacterSpeedFast = 40;

  /// AMOUNTS
  static const double kPropertyAmountSmall = 30;
  static const double kPropertyAmountMedium = 60;
  static const double kPropertyAmountLarge = 120;

  /// RADIUS VISION
  static const double kVisionRadiusSmall = 32;
  static const double kVisionRadiusMedium = 48;
  static const double kVisionRadiusLarge = 64;
  static const double kVisionRadiusExtraLarge = 80;
  static const double kVisionRadiusUltraLarge = 96;

  /// PRIORITIES
  static const int kPriority1 = 1;
}
