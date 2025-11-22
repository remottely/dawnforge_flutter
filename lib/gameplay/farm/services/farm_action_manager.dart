import 'package:bonfire/base/game_component.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';

class FarmActionManager extends GameComponent {
  // FarmActionManager._();

  // static final instance = FarmActionManager._();

  // final FarmActionService _actionService = FarmActionService.instance;
  // final FarmFeedbackService _feedbackService = FarmFeedbackService.instance;

  // bool handleTillSoil(int x, int y) {
  //   final result = _actionService.tillSoil(x, y);
  //   if (result.success) {
  //     _feedbackService.showFloatingText(FarmMessages.kSoilTilled);
  //   }
  //   return true;
  // }

  // ============================================================================
  // Tile Detection
  // ============================================================================

  /// Finds the farm tile currently in contact with the player.
  FarmTileView? getFarmTileInContact() {
    // TODO(Kevin): remove this when all farm tools are reworked
    final allFarmTiles = gameRef.query<FarmTileView>();
    final player = gameRef.player!;

    for (final farmTile in allFarmTiles) {
      if (farmTile.isPlayerOnTile(player)) {
        return farmTile;
      }
    }

    return null;
  }
}
