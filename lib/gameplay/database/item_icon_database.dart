import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item_type.dart';

class ItemIconEntry {
  final int rowIndex;
  final int columnIndex;

  const ItemIconEntry({required this.rowIndex, required this.columnIndex});
}

final class ItemIconDatabaseDef {
  ItemIconDatabaseDef._();

  static const String spritesheetPath =
      'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png';
  static const int spriteWidth = 16;
  static const int spriteHeight = 16;

  static const Map<String, ItemIconEntry> items = {
    'empty_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 0),
    'watermelon_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 1),
    'pineapple_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 1999999),
    'pumpkin_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 3),
    'cabbage_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 4),
    'radish_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 5),
    'carrot_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 6),
    'strawberry_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 7),
    'wheat_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 8),
    'pepper_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 9),
    'turnip_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 10),
    'cotton_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 11),
    'onion_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 12),
    'cauliflower_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 13),
    'corn_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 14),
    'tomato_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 15),
    'tomato_item': ItemIconEntry(rowIndex: 1, columnIndex: 1),
    'strawberry_item': ItemIconEntry(rowIndex: 1, columnIndex: 15),
    'radish_item': ItemIconEntry(rowIndex: 2, columnIndex: 5),
    'grape_seed_bag': ItemIconEntry(rowIndex: 11, columnIndex: 0),
    'prickly_pear_seed_bag': ItemIconEntry(rowIndex: 11, columnIndex: 1),
    'coffee_seed_bag': ItemIconEntry(rowIndex: 11, columnIndex: 2),
    'zuchini_seed_bag': ItemIconEntry(rowIndex: 11, columnIndex: 3),
    'apple_seed_bag': ItemIconEntry(rowIndex: 10, columnIndex: 8),
    'cabbage': ItemIconEntry(rowIndex: 1, columnIndex: 0),
    'tomato': ItemIconEntry(rowIndex: 1, columnIndex: 1),
    'pumpkin': ItemIconEntry(rowIndex: 1, columnIndex: 2),
    'radish': ItemIconEntry(rowIndex: 1, columnIndex: 3),
    'wheat': ItemIconEntry(rowIndex: 1, columnIndex: 4),
    'corn': ItemIconEntry(rowIndex: 1, columnIndex: 5),
    'watermelon': ItemIconEntry(rowIndex: 1, columnIndex: 8),
    'onion': ItemIconEntry(rowIndex: 1, columnIndex: 9),
    'grape': ItemIconEntry(rowIndex: 1, columnIndex: 10),
    'pineapple': ItemIconEntry(rowIndex: 1, columnIndex: 11),
    'carrot': ItemIconEntry(rowIndex: 1, columnIndex: 12),
    'pepper': ItemIconEntry(rowIndex: 1, columnIndex: 13),
    'zuchini': ItemIconEntry(rowIndex: 1, columnIndex: 14),
    'strawberry': ItemIconEntry(rowIndex: 1, columnIndex: 15),
    'apple': ItemIconEntry(rowIndex: 1, columnIndex: 16),
    'prickly_pear': ItemIconEntry(rowIndex: 2, columnIndex: 1),
    'cauliflower': ItemIconEntry(rowIndex: 2, columnIndex: 2),
    'turnip': ItemIconEntry(rowIndex: 2, columnIndex: 3),
    'cotton': ItemIconEntry(rowIndex: 2, columnIndex: 4),
    'coffee': ItemIconEntry(rowIndex: 2, columnIndex: 6),
    'ironSword': ItemIconEntry(rowIndex: 6, columnIndex: 2),
    'wateringCan': ItemIconEntry(rowIndex: 6, columnIndex: 3),
    'shovel': ItemIconEntry(rowIndex: 6, columnIndex: 4),
    'harvestBasket': ItemIconEntry(rowIndex: 6, columnIndex: 5),
    'staff': ItemIconEntry(rowIndex: 6, columnIndex: 7),
    'stone': ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    'iron_ore': ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    'dungeon_key': ItemIconEntry(rowIndex: 6, columnIndex: 6),
    'apple_item': ItemIconEntry(rowIndex: 2, columnIndex: 5),
  };

  /// Handy lookup keyed by equipped hand type so weapon templates can share the same authority.
  static const Map<HandItemType, ItemIconEntry> equippedHandIcons = {
    HandItemType.harvestBasket: ItemIconEntry(rowIndex: 6, columnIndex: 5),
    HandItemType.strawberry_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 7),
    HandItemType.apple_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 8),
    HandItemType.radish_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 5),
    HandItemType.tomato_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 15),
    HandItemType.shovel: ItemIconEntry(rowIndex: 6, columnIndex: 4),
    HandItemType.wateringCan: ItemIconEntry(rowIndex: 6, columnIndex: 3),
    HandItemType.staff: ItemIconEntry(rowIndex: 6, columnIndex: 7),
    HandItemType.staff_fire: ItemIconEntry(rowIndex: 6, columnIndex: 7),
    HandItemType.axe: ItemIconEntry(rowIndex: 6, columnIndex: 2),
    HandItemType.sword: ItemIconEntry(rowIndex: 6, columnIndex: 2),
    HandItemType.wand: ItemIconEntry(rowIndex: 6, columnIndex: 7),
    HandItemType.apple: ItemIconEntry(rowIndex: 1, columnIndex: 16),
    HandItemType.strawberry: ItemIconEntry(rowIndex: 1, columnIndex: 15),
    HandItemType.tomato: ItemIconEntry(rowIndex: 1, columnIndex: 1),
  };
}
