import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/features/game_world/database/smallburg/smallburg_farm_consumable_item_database_def.dart';

import 'package:dawnforge/game/features/inventory/items/consumable_item.dart';
import 'package:dawnforge/game/features/inventory/items/material_item.dart';
import 'package:dawnforge/game/features/inventory/items/tool_item.dart';
import 'package:dawnforge/game/features/inventory/items/weapon_item.dart';

import '../entities/hand_item.dart';
import '../items/seed_bag_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../../game_world/database/smallburg/smallburg_weapon_item_database_def.dart';
import '../../game_world/database/smallburg/smallburg_tool_item_database_def.dart';
import '../../game_world/database/smallburg/smallburg_material_item_database_def.dart';
import '../../game_world/database/smallburg/smallburg_seed_bag_item_database_def.dart';

/// Service for creating items from JSON database (L2: Factory with JSON database, I2: Service = External)
final class ItemFactoryService {
  ItemFactoryService._();

  static final instance = ItemFactoryService._();

  final Map<HandItemId, WeaponItem> _weapons = {};
  final Map<HandItemId, ToolItem> _tools = {};
  final Map<HandItemId, ConsumableItem> _consumables = {};
  final Map<HandItemId, MaterialItem> _materials = {};
  final Map<HandItemId, SeedBagItem> _seeds = {};
  bool isInitialized = false;

  // TODO(Kevin): change all this initialize logic??
  Future<void> initialize() async {
    if (isInitialized) {
      GameLogger.info('[ItemFactoryService] Already initialized');
      return;
    }

    try {
      _weapons
        ..clear()
        ..addAll(SmallBurgWeaponItemDatabaseDef.weaponsItemList);

      _tools
        ..clear()
        ..addAll(SmallBurgToolItemDatabaseDef.toolItemList);

      _consumables
        ..clear()
        ..addAll(SmallBurgHarvestLootItemDatabaseDef.harvestLootItemList);

      _materials
        ..clear()
        ..addAll(SmallBurgMaterialItemDatabaseDef.materialItemList);

      _seeds
        ..clear()
        ..addAll(SmallBurgSeedBagItemDatabaseDef.seedBagList);

      final totalItems =
          _weapons.length +
          _tools.length +
          _consumables.length +
          _materials.length +
          _seeds.length;

      GameLogger.info(
        '[ItemFactoryService] Loaded $totalItems items from typed constants',
      );

      isInitialized = true;
    } catch (e, stackTrace) {
      GameLogger.error(
        '[ItemFactoryService] ERROR loading database: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  HandItem? createItem(HandItemId itemId) {
    if (!isInitialized) {
      GameLogger.error(
        '[ItemFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    try {
      final weapon = _weapons[itemId];
      if (weapon != null) {
        return weapon.copyWith();
      }

      final tool = _tools[itemId];
      if (tool != null) {
        return tool.copyWith();
      }

      final consumable = _consumables[itemId];
      if (consumable != null) {
        return consumable.copyWith();
      }

      final seed = _seeds[itemId];
      if (seed != null) {
        return seed.copyWith();
      }

      final material = _materials[itemId];
      if (material != null) {
        return material.copyWith();
      }

      GameLogger.warning('[ItemFactoryService] Item not found: $itemId');
      return null;
    } catch (e, stackTrace) {
      GameLogger.error(
        '[ItemFactoryService] ERROR creating item $itemId: $e\n$stackTrace',
      );
      return null;
    }
  }

  List<HandItem> createItems(List<HandItemId> itemIds) {
    return itemIds.map(createItem).whereType<HandItem>().toList();
  }

  List<HandItemId> getAllItemIds() {
    return {
      ..._weapons.keys,
      ..._tools.keys,
      ..._consumables.keys,
      ..._materials.keys,
      ..._seeds.keys,
    }.toList();
  }

  bool hasItem(String itemId) {
    final idEnum = HandItemId.fromString(itemId);
    return _weapons.containsKey(idEnum) ||
        _tools.containsKey(idEnum) ||
        _consumables.containsKey(idEnum) ||
        _materials.containsKey(idEnum) ||
        _seeds.containsKey(idEnum);
  }
}
