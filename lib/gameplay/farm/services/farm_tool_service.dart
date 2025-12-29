import 'dart:developer' as developer;

import '../../inventory/items/main_hand_item.dart';
import '../../inventory/models/equipped_hand_type.dart';
import '../entities/farm_tile.dart';
import '../entities/soil_state.dart';

/// Service for validating farm tool usage (I2: Service = stateless)
class FarmToolService {
  /// Check if a tool can be used on a specific tile
  bool canUseTool(MainHandItem tool, FarmTile tile) {
    final handType = tool.equippedHandType;

    switch (handType) {
      case EquippedHandType.shovel:
        return canTill(tile);
      case EquippedHandType.wateringCan:
        return canWater(tile);
      case EquippedHandType.harvestBasket:
        return canHarvest(tile);
      default:
        // Check if it's a seed
        if (handType.isSeed && tool.cropId != null) {
          return canPlant(tile);
        }
        return false;
    }
  }

  /// Check if tile can be tilled
  bool canTill(FarmTile tile) {
    final canTill = tile.soilState == SoilState.untilled;
    if (!canTill) {
      developer.log('[FarmToolService] Cannot till: soil already tilled');
    }
    return canTill;
  }

  /// Check if tile can be watered
  bool canWater(FarmTile tile) {
    if (tile.soilState == SoilState.untilled) {
      developer.log('[FarmToolService] Cannot water: soil not tilled yet');
      return false;
    }

    if (tile.soilState == SoilState.watered) {
      developer.log('[FarmToolService] Cannot water: already watered');
      return false;
    }

    return true;
  }

  /// Check if tile can receive a plant
  bool canPlant(FarmTile tile) {
    if (!tile.canPlant) {
      if (tile.isOccupied) {
        developer.log('[FarmToolService] Cannot plant: tile already has a crop');
      } else if (!tile.soilState.canPlant) {
        developer.log('[FarmToolService] Cannot plant: soil not prepared');
      }
      return false;
    }
    return true;
  }

  /// Check if crop can be harvested
  bool canHarvest(FarmTile tile) {
    if (tile.isEmpty) {
      developer.log('[FarmToolService] Cannot harvest: no crop planted');
      return false;
    }

    if (!tile.canHarvest) {
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
  bool isFarmTool(EquippedHandType handType) {
    return handType == EquippedHandType.shovel ||
        handType == EquippedHandType.wateringCan ||
        handType == EquippedHandType.harvestBasket ||
        handType.isSeed;
  }
}
