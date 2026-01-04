import 'dart:developer' as developer;

import '../database/item_icon_database.dart';
import '../entities/item.dart';
import '../items/consumable_item.dart';
import '../items/crop_item.dart';
import '../items/main_hand_item.dart';
import '../items/material_item.dart';
import '../items/seed_item.dart';
import '../items/tool_item.dart';
import '../models/item_category.dart';
import '../models/item_type.dart';
import '../../data/game_data_constants.dart';

/// Service for creating items from JSON database (L2: Factory with JSON database, I2: Service = External)
class ItemFactoryService {
  final Map<String, Map<String, dynamic>> _itemDatabase = {};
  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) {
      developer.log('[ItemFactoryService] Already initialized');
      return;
    }

    try {
      await ItemIconDatabase().initialize();
      developer.log('[ItemFactoryService] ItemIconDatabase initialized');

      final mergedDatabase = <String, Map<String, dynamic>>{};

      void merge(Map<String, Map<String, Object?>> source) {
        for (final entry in source.entries) {
          final value = Map<String, dynamic>.from(entry.value);
          value['id'] ??= entry.key;
          value['name'] ??= entry.key;
          mergedDatabase[entry.key] = value;
        }
      }

      merge(ItemDbConstants.weapons);
      merge(ItemDbConstants.tools);
      merge(ItemDbConstants.consumables);
      merge(ItemDbConstants.materials);
      merge(ItemDbConstants.seeds);

      developer.log(
        '[ItemFactoryService] Loaded ${mergedDatabase.length} items from constants',
      );

      _itemDatabase
        ..clear()
        ..addAll(mergedDatabase);

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

    final itemData = _itemDatabase[itemId];
    if (itemData == null) {
      developer.log('[ItemFactoryService] Item not found: $itemId');
      return null;
    }

    try {
      final iconData = ItemIconDatabase().getIconData(itemId);
      final type = ItemType.fromJson(itemData['type'] as String);

      switch (type) {
        case ItemType.weapon:
          final item = MainHandItem.fromJson(itemData);
          return MainHandItem(
            id: item.id,
            name: item.name,
            description: item.description,
            baseValue: item.baseValue,
            iconPath: item.iconPath,
            rarity: item.rarity,
            damage: item.damage,
            attackSpeed: item.attackSpeed,
            critChance: item.critChance,
            critMultiplier: item.critMultiplier,
            equippedHandType: item.equippedHandType,
            cropId: item.cropId,
            iconData: iconData,
            isStackable: item.isStackable,
            maxStackSize: item.maxStackSize,
          );

        case ItemType.tool:
          final item = ToolItem.fromJson(itemData);
          return ToolItem(
            id: item.id,
            name: item.name,
            description: item.description,
            baseValue: item.baseValue,
            iconPath: item.iconPath,
            rarity: item.rarity,
            toolType: item.toolType,
            powerLevel: item.powerLevel,
            iconData: iconData,
          );

        case ItemType.consumable:
          final item = ConsumableItem.fromJson(itemData);
          return ConsumableItem(
            id: item.id,
            name: item.name,
            description: item.description,
            baseValue: item.baseValue,
            iconPath: item.iconPath,
            rarity: item.rarity,
            maxStackSize: item.maxStackSize,
            healthRestore: item.healthRestore,
            staminaRestore: item.staminaRestore,
            duration: item.duration,
            buffs: item.buffs,
            iconData: iconData,
          );

        case ItemType.cropSeed:
          final item = SeedItem.fromJson(itemData);
          return SeedItem(
            id: item.id,
            name: item.name,
            description: item.description,
            baseValue: item.baseValue,
            iconPath: item.iconPath,
            rarity: item.rarity,
            maxStackSize: item.maxStackSize,
            cropId: item.cropId,
            growthTime: item.growthTime,
            yield: item.yield,
            season: item.season,
            iconData: iconData,
          );

        case ItemType.material:
          final category = itemData['category'] as String?;
          if (category != null) {
            final itemCategory = ItemCategory.fromJson(category);

            if ([
              ItemCategory.vegetables,
              ItemCategory.fruits,
              ItemCategory.flowers,
            ].contains(itemCategory)) {
              final item = CropItem.fromJson(itemData);
              return CropItem(
                id: item.id,
                name: item.name,
                description: item.description,
                baseValue: item.baseValue,
                iconPath: item.iconPath,
                rarity: item.rarity,
                maxStackSize: item.maxStackSize,
                category: item.category,
                quality: item.quality,
                energyRestore: item.energyRestore,
                healthRestore: item.healthRestore,
                season: item.season,
                regrows: item.regrows,
                regrowthDays: item.regrowthDays,
                iconData: iconData,
              );
            }
          }

          final item = MaterialItem.fromJson(itemData);
          return MaterialItem(
            id: item.id,
            name: item.name,
            description: item.description,
            baseValue: item.baseValue,
            iconPath: item.iconPath,
            rarity: item.rarity,
            maxStackSize: item.maxStackSize,
            materialType: item.materialType,
            iconData: iconData,
          );

        default:
          developer.log(
            '[ItemFactoryService] Unsupported type: $type for item $itemId',
          );
          return null;
      }
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
    return _itemDatabase.keys.toList();
  }

  bool hasItem(String itemId) {
    return _itemDatabase.containsKey(itemId);
  }
}
