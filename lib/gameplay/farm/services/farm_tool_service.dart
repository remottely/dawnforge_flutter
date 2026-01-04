import 'dart:developer' as developer;

import '../../inventory/items/main_hand_item.dart';
import '../../inventory/entities/hand_item_type.dart';
import '../../world/entities/world_entities.dart';

/// Service for validating farm tool usage (I2: Service = stateless)
class FarmToolService {
  /// Check if a tool can be used on a specific tile
  bool canUseTool(MainHandItem tool, GridTile tile) {
    final farmObject = tile.object as FarmObject?;
    if (farmObject == null) return false;

    final handType = tool.equippedHandType;

    switch (handType) {
      case HandItemType.shovel:
        return canTill(farmObject);
      case HandItemType.wateringCan:
        return canWater(farmObject);
      case HandItemType.harvestBasket:
        return canHarvest(farmObject);
      default:
        // Check if it's a seed
        if (handType.isSeed && tool.cropId != null) {
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
        developer.log('[FarmToolService] Cannot plant: tile already has a crop');
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
  String? getCropIdFromTool(MainHandItem tool) {
    if (!tool.equippedHandType.isSeed) return null;
    return tool.cropId;
  }

  /// Validate if tool is a farm tool
  bool isFarmTool(HandItemType handType) {
    return handType == HandItemType.shovel ||
        handType == HandItemType.wateringCan ||
        handType == HandItemType.harvestBasket ||
        handType.isSeed;
  }
}
