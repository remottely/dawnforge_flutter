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

  static const Map<HandItemType, ItemIconEntry> items = {
    HandItemType.empty_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 0),
    HandItemType.watermelon_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 1),
    HandItemType.pineapple_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 1999999),
    HandItemType.pumpkin_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 3),
    HandItemType.cabbage_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 4),
    HandItemType.radish_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 5),
    HandItemType.carrot_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 6),
    HandItemType.strawberry_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 7),
    HandItemType.wheat_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 8),
    HandItemType.pepper_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 9),
    HandItemType.turnip_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 10),
    HandItemType.cotton_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 11),
    HandItemType.onion_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 12),
    HandItemType.cauliflower_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 13),
    HandItemType.corn_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 14),
    HandItemType.tomato_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 15),
    HandItemType.tomato_item: ItemIconEntry(rowIndex: 1, columnIndex: 1),
    HandItemType.strawberry_item: ItemIconEntry(rowIndex: 1, columnIndex: 15),
    HandItemType.radish_item: ItemIconEntry(rowIndex: 2, columnIndex: 5),
    HandItemType.grape_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 0),
    HandItemType.prickly_pear_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 1),
    HandItemType.coffee_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 2),
    HandItemType.zuchini_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 3),
    HandItemType.apple_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 8),
    HandItemType.cabbage: ItemIconEntry(rowIndex: 1, columnIndex: 0),
    HandItemType.tomato: ItemIconEntry(rowIndex: 1, columnIndex: 1),
    HandItemType.pumpkin: ItemIconEntry(rowIndex: 1, columnIndex: 2),
    HandItemType.radish: ItemIconEntry(rowIndex: 1, columnIndex: 3),
    HandItemType.wheat: ItemIconEntry(rowIndex: 1, columnIndex: 4),
    HandItemType.corn: ItemIconEntry(rowIndex: 1, columnIndex: 5),
    HandItemType.watermelon: ItemIconEntry(rowIndex: 1, columnIndex: 8),
    HandItemType.onion: ItemIconEntry(rowIndex: 1, columnIndex: 9),
    HandItemType.grape: ItemIconEntry(rowIndex: 1, columnIndex: 10),
    HandItemType.pineapple: ItemIconEntry(rowIndex: 1, columnIndex: 11),
    HandItemType.carrot: ItemIconEntry(rowIndex: 1, columnIndex: 12),
    HandItemType.pepper: ItemIconEntry(rowIndex: 1, columnIndex: 13),
    HandItemType.zuchini: ItemIconEntry(rowIndex: 1, columnIndex: 14),
    HandItemType.strawberry: ItemIconEntry(rowIndex: 1, columnIndex: 15),
    HandItemType.apple: ItemIconEntry(rowIndex: 1, columnIndex: 16),
    HandItemType.prickly_pear: ItemIconEntry(rowIndex: 2, columnIndex: 1),
    HandItemType.cauliflower: ItemIconEntry(rowIndex: 2, columnIndex: 2),
    HandItemType.turnip: ItemIconEntry(rowIndex: 2, columnIndex: 3),
    HandItemType.cotton: ItemIconEntry(rowIndex: 2, columnIndex: 4),
    HandItemType.coffee: ItemIconEntry(rowIndex: 2, columnIndex: 6),
    HandItemType.ironSword: ItemIconEntry(rowIndex: 6, columnIndex: 2),
    HandItemType.wateringCan: ItemIconEntry(rowIndex: 6, columnIndex: 3),
    HandItemType.shovel: ItemIconEntry(rowIndex: 6, columnIndex: 4),
    HandItemType.harvestBasket: ItemIconEntry(rowIndex: 6, columnIndex: 5),
    HandItemType.staff: ItemIconEntry(rowIndex: 6, columnIndex: 7),
    HandItemType.stone: ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    HandItemType.iron_ore: ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    HandItemType.dungeon_key: ItemIconEntry(rowIndex: 6, columnIndex: 6),
    HandItemType.apple_item: ItemIconEntry(rowIndex: 2, columnIndex: 5),
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
