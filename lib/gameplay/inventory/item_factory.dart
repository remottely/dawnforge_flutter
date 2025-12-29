import 'dart:convert';
import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/database/item_icon_database.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/crop_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/seed_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_category.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_type.dart';
import 'package:flutter/services.dart' show rootBundle;

final class ItemFactoryService {
  ItemFactoryService._();

  static final Map<String, Map<String, dynamic>> _itemDatabase = {};
  static bool _isInitialized = false;

  static const String _kDatabasePath = 'assets/items/items_database.json';

  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[ItemFactoryService] Already initialized');
      return;
    }

    try {
      await ItemIconDatabase().initialize();
      developer.log('[ItemFactoryService] ItemIconDatabase initialized');

      final jsonString = await rootBundle.loadString(_kDatabasePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final entry in jsonData.entries) {
        _itemDatabase[entry.key] = entry.value as Map<String, dynamic>;
      }

      _isInitialized = true;
      developer.log('[ItemFactoryService] Loaded ${_itemDatabase.length} items');
    } catch (e, stackTrace) {
      developer.log(
        '[ItemFactoryService] ERROR loading database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Item? createItem(String itemId) {
    if (!_isInitialized) {
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
        case ItemType.seed:
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

  static List<Item> createItems(List<String> itemIds) {
    return itemIds.map(createItem).whereType<Item>().toList();
  }

  static List<String> getAllItemIds() {
    return _itemDatabase.keys.toList();
  }

  static List<String> getItemIdsByType(ItemType type) {
    return _itemDatabase.entries
        .where((e) => e.value['type'] == type.toJson())
        .map((e) => e.key)
        .toList();
  }

  static bool itemExists(String itemId) {
    return _itemDatabase.containsKey(itemId);
  }

  static void reset() {
    _itemDatabase.clear();
    _isInitialized = false;
    developer.log('[ItemFactoryService] Reset');
  }

  static bool get isInitialized => _isInitialized;

  static int get itemCount => _itemDatabase.length;
}
