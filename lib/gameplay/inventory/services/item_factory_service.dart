import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';

import '../database/item_icon_database.dart';
import '../entities/hand/hand_item.dart';
import '../items/seed_item.dart';
import '../entities/hand/hand_item_id.dart';
import '../../database/weapon_database.dart';
import '../../database/tool_database.dart';
import '../../database/consumable_database.dart';
import '../../database/material_database.dart';
import '../../database/seed_database.dart';

/// Service for creating items from JSON database (L2: Factory with JSON database, I2: Service = External)
class ItemFactoryService {
  final Map<HandItemId, MainHandItem> _weapons = {};
  final Map<HandItemId, ToolItem> _tools = {};
  final Map<HandItemId, ConsumableItem> _consumables = {};
  final Map<HandItemId, MaterialItem> _materials = {};
  final Map<HandItemId, SeedItem> _seeds = {};
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

  HandItem? createItem(HandItemId itemId) {
    if (!isInitialized) {
      developer.log(
        '[ItemFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    try {
      final iconData = ItemIconDatabase().getIconData(itemId);

      final weapon = _weapons[itemId];
      if (weapon != null) {
        return weapon.copyWith(iconData: iconData);
      }

      final tool = _tools[itemId];
      if (tool != null) {
        return tool.copyWith(iconData: iconData);
      }

      final consumable = _consumables[itemId];
      if (consumable != null) {
        return consumable.copyWith(iconData: iconData);
      }

      final seed = _seeds[itemId];
      if (seed != null) {
        return seed.copyWith(iconData: iconData);
      }

      final material = _materials[itemId];
      if (material != null) {
        return material.copyWith(iconData: iconData);
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
