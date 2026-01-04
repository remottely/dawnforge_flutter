import 'dart:developer' as developer;

import '../database/item_icon_database.dart';
import '../entities/item.dart';
import '../items/consumable_item.dart';
import '../items/main_hand_item.dart';
import '../items/material_item.dart';
import '../items/seed_item.dart';
import '../items/tool_item.dart';
import '../models/equipped_hand_type.dart';
import '../../database/weapon_database.dart';
import '../../database/tool_database.dart';
import '../../database/consumable_database.dart';
import '../../database/material_database.dart';
import '../../database/seed_database.dart';

/// Service for creating items from JSON database (L2: Factory with JSON database, I2: Service = External)
class ItemFactoryService {
  final Map<String, WeaponData> _weapons = {};
  final Map<String, ToolData> _tools = {};
  final Map<String, ConsumableData> _consumables = {};
  final Map<String, MaterialData> _materials = {};
  final Map<String, SeedData> _seeds = {};
  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) {
      developer.log('[ItemFactoryService] Already initialized');
      return;
    }

    try {
      await ItemIconDatabase().initialize();
      developer.log('[ItemFactoryService] ItemIconDatabase initialized');

      _weapons
        ..clear()
        ..addAll(ItemWeaponDatabaseDef.weapons);

      _tools
        ..clear()
        ..addAll(ToolDatabaseDef.tools);

      _consumables
        ..clear()
        ..addAll(ConsumableDatabaseDef.consumables);

      _materials
        ..clear()
        ..addAll(MaterialDatabaseDef.materials);

      _seeds
        ..clear()
        ..addAll(SeedDatabaseDef.seeds);

      final totalItems = _weapons.length +
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

  Item? createItem(String itemId) {
    if (!isInitialized) {
      developer.log(
        '[ItemFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    try {
      final iconData = ItemIconDatabase().getIconData(itemId);

      final weaponData = _weapons[itemId];
      if (weaponData != null) {
        return MainHandItem(
          id: weaponData.id,
          name: weaponData.name,
          description: weaponData.description,
          baseValue: weaponData.baseValue,
          iconPath: weaponData.iconPath,
          rarity: weaponData.rarity,
          damage: weaponData.damage,
          attackSpeed: weaponData.attackSpeed,
          critChance: weaponData.critChance,
          critMultiplier: weaponData.critMultiplier,
          equippedHandType:
              EquippedHandType.fromJson(weaponData.equippedHandType),
          cropId: weaponData.cropId,
          iconData: iconData,
          isStackable: weaponData.isStackable,
          maxStackSize: weaponData.maxStackSize,
        );
      }

      final toolData = _tools[itemId];
      if (toolData != null) {
        return ToolItem(
          id: toolData.id,
          name: toolData.name,
          description: toolData.description,
          baseValue: toolData.baseValue,
          iconPath: toolData.iconPath,
          rarity: toolData.rarity,
          toolType: toolData.toolType,
          powerLevel: toolData.powerLevel,
          iconData: iconData,
        );
      }

      final consumableData = _consumables[itemId];
      if (consumableData != null) {
        return ConsumableItem(
          id: consumableData.id,
          name: consumableData.name,
          description: consumableData.description,
          baseValue: consumableData.baseValue,
          iconPath: consumableData.iconPath,
          rarity: consumableData.rarity,
          maxStackSize: consumableData.maxStackSize,
          healthRestore: consumableData.healthRestore,
          staminaRestore: consumableData.staminaRestore,
          duration: consumableData.duration,
          buffs: consumableData.buffs,
          iconData: iconData,
        );
      }

      final seedData = _seeds[itemId];
      if (seedData != null) {
        return SeedItem(
          id: seedData.id,
          name: seedData.name,
          description: seedData.description,
          baseValue: seedData.baseValue,
          iconPath: seedData.iconPath,
          rarity: seedData.rarity,
          maxStackSize: seedData.maxStackSize,
          cropId: seedData.cropId,
          growthTime: seedData.growthTime,
          yield: seedData.yield,
          season: seedData.season,
          iconData: iconData,
        );
      }

      final materialData = _materials[itemId];
      if (materialData != null) {
        return MaterialItem(
          id: materialData.id,
          name: materialData.name,
          description: materialData.description,
          baseValue: materialData.baseValue,
          iconPath: materialData.iconPath,
          rarity: materialData.rarity,
          maxStackSize: materialData.maxStackSize,
          materialType: materialData.materialType,
          iconData: iconData,
        );
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

  List<Item> createItems(List<String> itemIds) {
    return itemIds.map(createItem).whereType<Item>().toList();
  }

  List<String> getAllItemIds() {
    return {
      ..._weapons.keys,
      ..._tools.keys,
      ..._consumables.keys,
      ..._materials.keys,
      ..._seeds.keys,
    }.toList();
  }

  bool hasItem(String itemId) {
    return _weapons.containsKey(itemId) ||
        _tools.containsKey(itemId) ||
        _consumables.containsKey(itemId) ||
        _materials.containsKey(itemId) ||
        _seeds.containsKey(itemId);
  }
}
