import '../../../main.dart';
import '../constants/game_constants.dart';

/// [TileHelper] responsible for tile size calculations and conversions
/// Following Flutter naming conventions for game utility systems
class TileHelper {
  /// Converts a value from sprite sheet scale to current tile scale
  /// Following Flutter pattern of static utility methods
  static double valueByTileSize(double value) {
    return value * (tileSize / GameConstants.tileSizeDefault);
  }
}
