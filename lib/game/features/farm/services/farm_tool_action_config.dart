import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/utils/offset_helper.dart';
import 'package:dawnforge/game/features/farm/components/farm_tile_view.dart';
import 'package:dawnforge/game/features/farm/constants/farm_feedback_config.dart';
import 'package:dawnforge/game/features/farm/farm_service_locator.dart' as farm_di;
import 'package:dawnforge/game/features/farm/services/farm_action_service.dart';
import 'package:dawnforge/game/features/farm/services/farm_feedback_service.dart';
import 'package:dawnforge/game/features/farm/usecases/plant_seed_use_case.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

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
      final HandItemId? equipment = player.controller.model.equipment;

      switch (equipment) {
        case HandItemId.shovel:
          _handleTillSoil(bestTarget.tileX, bestTarget.tileY);
          return;
        case HandItemId.wateringCan:
          _handleWater(bestTarget.tileX, bestTarget.tileY);
          return;
        case HandItemId.harvestBasket:
          _handleHarvest(player.gameRef, bestTarget.tileX, bestTarget.tileY);
          return;
        default:
          if (equipment?.isSeed ?? false) {
            final equippedItem = EquipmentManager.instance.getEquippedItem();
            final seedItemId = equippedItem?.id;
            if (seedItemId == null) {
              FarmFeedbackService.instance.showFloatingText(
                FarmFeedbackDef.kCannotPlant,
              );
              return;
            }

            _handlePlant(
              seedItemId: seedItemId,
              x: bestTarget.tileX,
              y: bestTarget.tileY,
            );
          }
          return;
      }
    }
  }

  static bool _handleTillSoil(int x, int y) {
    final _feedbackService = FarmFeedbackService.instance;
    final result = _actionService.tillSoil(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kSoilTilled);
    }
    return true;
  }

  static bool _handleWater(int x, int y) {
    final _feedbackService = FarmFeedbackService.instance;
    final result = _actionService.waterTile(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kCropWatered);
    }
    return true;
  }

  static bool _handlePlant({
    required HandItemId seedItemId,
    required int x,
    required int y,
  }) {
    final _feedbackService = FarmFeedbackService.instance;

    final planted = farm_di.getIt<PlantSeedUseCase>().call(x, y, seedItemId);

    if (planted) {
      _feedbackService.showFloatingText(FarmFeedbackDef.kSeedPlanted);
    } else {
      _feedbackService.showFloatingText(FarmFeedbackDef.kCannotPlant);
    }
    return planted;
  }

  static bool _handleHarvest(BonfireGameInterface gameRef, int x, int y) {
    final _feedbackService = FarmFeedbackService.instance;
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
