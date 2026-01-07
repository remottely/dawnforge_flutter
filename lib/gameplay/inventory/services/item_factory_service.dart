import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';

import '../entities/hand_item.dart';
import '../items/seed_bag_item.dart';
import '../entities/enums/hand_item_id.dart';
import '../../database/modern_farm/modern_farm_weapon_item_database_def.dart';
import '../../database/modern_farm/modern_farm_tool_item_database_def.dart';
import '../../database/modern_farm/modern_farm_consumable_item_database_def.dart';
import '../../database/modern_farm/modern_farm_material_item_database_def.dart';
import '../../database/modern_farm/modern_farm_seed_bag_item_database_def.dart';

/// Service for creating items from JSON database (L2: Factory with JSON database, I2: Service = External)
class ItemFactoryService {
  final Map<HandItemId, WeaponItem> _weapons = {};
  final Map<HandItemId, ToolItem> _tools = {};
  final Map<HandItemId, ConsumableItem> _consumables = {};
  final Map<HandItemId, MaterialItem> _materials = {};
  final Map<HandItemId, SeedBagItem> _seeds = {};
  bool isInitialized = false;

  // TODO(Kevin): change all this initialize logic??
  Future<void> initialize() async {
    if (isInitialized) {
      developer.log('[ItemFactoryService] Already initialized');
      return;
    }

    try {
      _weapons
        ..clear()
        ..addAll(ModernFarmWeaponItemDatabaseDef.weapons);

      _tools
        ..clear()
        ..addAll(ModernFarmToolItemDatabaseDef.toolItemList);

      _consumables
        ..clear()
        ..addAll(ModernFarmHarvestLootItemDatabaseDef.harvestLootItemList);

      _materials
        ..clear()
        ..addAll(ModernFarmMaterialItemDatabaseDef.materialItemList);

      _seeds
        ..clear()
        ..addAll(ModernFarmSeedBagItemDatabaseDef.seedBagList);

      final totalItems =
          _weapons.length +
          _tools.length +
          _consumables.length +
          _materials.length +
          _seeds.length;

      developer.log(
        '[ItemFactoryService] Loaded $totalItems items from typed constants',
      );

      isInitialized = true;
    } catch (e, stackTrace) {
      developer.log(
        '[ItemFactoryService] ERROR loading database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  HandItem? createItem(HandItemId itemId) {
    if (!isInitialized) {
      developer.log(
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

      developer.log('[ItemFactoryService] Item not found: $itemId');
      return null;
    } catch (e, stackTrace) {
      developer.log(
        '[ItemFactoryService] ERROR creating item $itemId',
        error: e,
        stackTrace: stackTrace,
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
