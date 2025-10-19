import 'package:bonfire/bonfire.dart';

class GameplayConstants {
  static const double kCurrentTileSize = 16; // TODO: NOW - 32 > 16
  static Vector2 get kCurrentVectorSize => Vector2.all(kDefaultTileSize);

  static const double kLifePotionDecorationHealAmount = 30.0;

  static const double kDefaultSpikeTrapDecorationDamageAmount = 60.0;
  static const int kLayerSpikeTrapDecorationPriority = 1;

  /// NEW
  static const double kSmallTileSize = 8;
  static Vector2 get kSmallVector2 => Vector2.all(kSmallTileSize);

  static const double kDefaultTileSize = 16;
  static Vector2 get kDefaultVector2 => Vector2.all(kDefaultTileSize);

  static const double kLargeTileSize = 32;
  static Vector2 get kLargeVector2 => Vector2.all(kLargeTileSize);

  /// EMOTES
  static Vector2 get kEmoteOffset => Vector2(0, -3);
}
