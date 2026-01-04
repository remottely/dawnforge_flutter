import 'dart:developer' as developer;

import '../../inventory/entities/hand/hand_item.dart';
import '../../inventory/items/seed_bag_item.dart';
import '../../inventory/items/tool_item.dart';
import '../../inventory/items/weapon_item.dart';
import '../../inventory/entities/hand/hand_item_id.dart';
import '../../world/entities/world_entities.dart';

/// Service for validating farm tool usage (I2: Service = stateless)
class FarmToolService {
  /// Check if a tool can be used on a specific tile
  bool canUseTool(HandItem tool, GridTile tile) {
    final farmObject = tile.object as FarmObject?;
    if (farmObject == null) return false;

    final cropId = _extractCropId(tool);

    switch (tool.id) {
      case HandItemId.shovel:
        return canTill(farmObject);
      case HandItemId.wateringCan:
        return canWater(farmObject);
      case HandItemId.harvestBasket:
        return canHarvest(farmObject);
      default:
        // Check if it's a seed
        if (tool.id.isSeed && cropId != null) {
          return canPlantCrop(farmObject);
        }
        return false;
    }
  }

  /// Check if tile can be tilled
  bool canTill(FarmObject farmObject) {
    final canTill = farmObject.soilState == SoilState.untilled;
    if (!canTill) {
      developer.log('[FarmToolService] Cannot till: soil already tilled');
    }
    return canTill;
  }

  /// Check if tile can be watered
  bool canWater(FarmObject farmObject) {
    if (farmObject.soilState == SoilState.untilled) {
      developer.log('[FarmToolService] Cannot water: soil not tilled yet');
      return false;
    }

    if (farmObject.soilState == SoilState.watered) {
      developer.log('[FarmToolService] Cannot water: already watered');
      return false;
    }

    return true;
  }

  /// Check if tile can receive a plant
  bool canPlantCrop(FarmObject farmObject) {
    if (!farmObject.canPlantCrop) {
      if (farmObject.isOccupied) {
        developer.log(
          '[FarmToolService] Cannot plant: tile already has a crop',
        );
      } else if (!farmObject.soilState.canPlantCrop) {
        developer.log('[FarmToolService] Cannot plant: soil not prepared');
      }
      return false;
    }
    return true;
  }

  /// Check if crop can be harvested
  bool canHarvest(FarmObject farmObject) {
    if (farmObject.isEmpty) {
      developer.log('[FarmToolService] Cannot harvest: no crop planted');
      return false;
    }

    if (!farmObject.canHarvest) {
      developer.log('[FarmToolService] Cannot harvest: crop not ready');
      return false;
    }

    return true;
  }

  /// Get the crop ID from a tool (if it's a seed)
  HandItemId? getCropIdFromTool(HandItem tool) {
    if (!(tool.id.isSeed)) return null;
    return _extractCropId(tool);
  }

  /// Validate if tool is a farm tool
  bool isFarmTool(HandItemId handType) {
    return handType == HandItemId.shovel ||
        handType == HandItemId.wateringCan ||
        handType == HandItemId.harvestBasket ||
        handType.isSeed;
  }

  HandItemId? _extractCropId(HandItem tool) {
    if (tool is SeedBagItem) return tool.cropId;
    if (tool is ToolItem) return null;
    return null;
  }
}
