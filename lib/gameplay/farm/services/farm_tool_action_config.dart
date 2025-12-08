import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_tile_view.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_feedback_config.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_action_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

final class FarmToolActionConfig {
  static final FarmActionService _actionService = FarmActionService.instance;
  static final FarmFeedbackService _feedbackService =
      FarmFeedbackService.instance;

  static void execute({required DDBasePlayerView player}) {
    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(12, 0),
      player.lastDirection,
    );

    final startPos =
        player.rectCollision.center.toVector2() +
        Vector2(attackOffset.x, attackOffset.y);

    final hitRect = Rect.fromCenter(
      center: Offset(startPos.x, startPos.y),
      width: 16,
      height: 16,
    );

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
      switch (player.controller.model.equipment) {
        case EquippedHandType.shovel:
          _handleTillSoil(bestTarget.tileX, bestTarget.tileY);
          return;
        case EquippedHandType.wateringCan:
          _handleWater(bestTarget.tileX, bestTarget.tileY);
          return;
        case EquippedHandType.strawberry:
          _handlePlant(
            cropId: EquippedHandType.strawberry.name,
            x: bestTarget.tileX,
            y: bestTarget.tileY,
          );
          return;
        case EquippedHandType.harvestBasket:
          _handleHarvest(player.gameRef, bestTarget.tileX, bestTarget.tileY);
          return;
        default:
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

  static bool _handlePlant({
    required String cropId,
    required int x,
    required int y,
  }) {
    // TODO: Get crop type from inventory/UI selection
    // const cropId = 'carrot'; // TODO(Kevin): remove 'carrot' dependency
    // const cropId = 'strawberry'; // TODO(Kevin): remove 'carrot' dependency

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
