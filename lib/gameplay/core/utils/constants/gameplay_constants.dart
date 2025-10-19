import 'package:bonfire/bonfire.dart';

class GameplayConstants {
  /// TILE SIZES
  static const double kTileSizeSmall = 8;
  static const double kTileSizeDefault = 16;
  static const double kTileSizeLarge = 24;
  static const double kTileSizeExtraLarge = 32;

  static Vector2 get kTileVector2Small => Vector2.all(kTileSizeSmall);
  static Vector2 get kTileVector2Default => Vector2.all(kTileSizeDefault);
  static Vector2 get kTileVector2Large => Vector2.all(kTileSizeLarge);
  static Vector2 get kTileVector2ExtraLarge => Vector2.all(kTileSizeExtraLarge);

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
