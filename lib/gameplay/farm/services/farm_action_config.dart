import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_tile_view.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_feedback_config.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_action_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

final class FarmActionConfig {
  static final FarmActionService _actionService = FarmActionService.instance;
  static final FarmFeedbackService _feedbackService =
      FarmFeedbackService.instance;

  static execute({required DDBasePlayerView player}) {
    // Compute the world position in front of the player where the shovel acts
    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(12, 0),
      player.lastDirection,
    );

    final startPos =
        player.rectCollision.center.toVector2() +
        Vector2(attackOffset.x, attackOffset.y);

    // Define a small detection rect around the impact point
    final hitRect = Rect.fromCenter(
      center: Offset(startPos.x, startPos.y),
      width: 16,
      height: 16,
    );

    // Query for farm tile views that overlap the impact area and pick the closest one
    FarmTileView? bestTarget;
    double bestDistSq = double.infinity;

    for (final view in player.gameRef.query<FarmTileView>()) {
      final compRect = view.rectCollision;
      if (!compRect.overlaps(hitRect)) continue;

      final dx = compRect.center.dx - startPos.x;
      final dy = compRect.center.dy - startPos.y;
      final distSq = dx * dx + dy * dy;

      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        bestTarget = view;
      }
    }

    if (bestTarget != null) {
      switch (player.model.equipment) {
        case WeaponType.shovel:
          _handleTillSoil(bestTarget.tileX, bestTarget.tileY);
          return;
        case WeaponType.wateringCan:
          _handleWater(bestTarget.tileX, bestTarget.tileY);
          return;
        case WeaponType.seeds:
          _handlePlant(bestTarget.tileX, bestTarget.tileY);
          return;
        case WeaponType.harvestBasket:
          _handleHarvest(player.gameRef, bestTarget.tileX, bestTarget.tileY);
          return;
        default:
          // Valid target to till soil
          return;
      }
    }
  }

  static bool _handleTillSoil(int x, int y) {
    final result = _actionService.tillSoil(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackConfig.kSoilTilled);
    }
    return true;
  }

  static bool _handleWater(int x, int y) {
    final result = _actionService.waterTile(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackConfig.kCropWatered);
    }
    return true;
  }

  static bool _handlePlant(int x, int y) {
    // TODO: Get crop type from inventory/UI selection
    const cropId = 'carrot'; // TODO(Kevin): remove 'carrot' dependency

    final result = _actionService.plantSeed(x, y, cropId);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackConfig.kSeedPlanted);
    }
    return true;
  }

  static bool _handleHarvest(BonfireGameInterface gameRef, int x, int y) {
    final result = _actionService.harvestCrop(x, y);

    if (result.success && result.crop != null) {
      final message = result.addedToInventory
          ? FarmFeedbackConfig.cropHarvested(
              result.crop!.yieldAmount,
              result.crop!.name,
            )
          : FarmFeedbackConfig.kInventoryFull;

      _feedbackService.showFloatingText(message);

      if (result.addedToInventory) {
        _feedbackService.refreshInventoryHUD(gameRef);
      }
    }

    return true;
  }
}
