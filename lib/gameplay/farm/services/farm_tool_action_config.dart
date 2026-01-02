import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_tile_view.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_feedback_config.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_service_locator.dart'
    as farm_di;
import 'package:darkness_dungeon/gameplay/farm/services/crop_factory_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_action_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

final class FarmToolActionDef {
  static final FarmActionService _actionService = FarmActionService.instance;

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
      final EquippedHandType? equipment = player.controller.model.equipment;

      switch (equipment) {
        case EquippedHandType.shovel:
          _handleTillSoil(bestTarget.tileX, bestTarget.tileY);
          return;
        case EquippedHandType.wateringCan:
          _handleWater(bestTarget.tileX, bestTarget.tileY);
          return;
        case EquippedHandType.harvestBasket:
          _handleHarvest(player.gameRef, bestTarget.tileX, bestTarget.tileY);
          return;
        default:
          if (equipment?.isSeed ?? false) {
            // Get the actual equipped item to extract cropId
            final equippedItem = getIt<EquipmentManager>().getEquippedItem();

            // Extract cropId from MainHandItem if available
            final cropId =
                (equippedItem is MainHandItem && equippedItem.cropId != null)
                ? equippedItem.cropId!
                : equipment!.name;

            _handlePlant(
              cropId: cropId,
              x: bestTarget.tileX,
              y: bestTarget.tileY,
            );
          }
          return;
      }
    }
  }

  static bool _handleTillSoil(int x, int y) {
    final _feedbackService = farm_di.getIt<FarmFeedbackService>();
    final result = _actionService.tillSoil(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kSoilTilled);
    }
    return true;
  }

  static bool _handleWater(int x, int y) {
    final _feedbackService = farm_di.getIt<FarmFeedbackService>();
    final result = _actionService.waterTile(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kCropWatered);
    }
    return true;
  }

  static bool _handlePlant({
    required String cropId,
    required int x,
    required int y,
  }) {
    final _feedbackService = farm_di.getIt<FarmFeedbackService>();
    final _cropFactory = farm_di.getIt<CropFactoryService>();
    
    // Create crop from cropId
    final crop = _cropFactory.createCrop(cropId);
    if (crop == null) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kCannotPlant);
      return false;
    }
    
    final result = _actionService.plantSeed(x, y, crop);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kSeedPlanted);
    } else {
      _feedbackService.showFloatingText(FarmFeedbackDef.kCannotPlant);
    }
    return result.success;
  }

  static bool _handleHarvest(BonfireGameInterface gameRef, int x, int y) {
    final _feedbackService = farm_di.getIt<FarmFeedbackService>();
    final result = _actionService.harvestCrop(x, y);

    if (result.success && result.crop != null) {
      final message = result.addedToInventory
          ? FarmFeedbackDef.cropHarvested(
              result.crop!.yieldAmount,
              result.crop!.name,
            )
          : FarmFeedbackDef.kInventoryFull;

      _feedbackService.showFloatingText(message);

      if (result.addedToInventory) {
        _feedbackService.refreshInventoryHUD(gameRef);
      }
    }

    return true;
  }
}
