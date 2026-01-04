import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';

class ItemIconEntry {
  final int rowIndex;
  final int columnIndex;

  const ItemIconEntry({required this.rowIndex, required this.columnIndex});
}

final class ItemIconEntryDatabaseDef {
  ItemIconEntryDatabaseDef._();

  static const String spritesheetPath =
      'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png';
  static const int spriteWidth = 16;
  static const int spriteHeight = 16;

  static const Map<HandItemId, ItemIconEntry> itemIconEntryList = {
    HandItemId.empty_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 0),
    HandItemId.watermelon_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 1),
    HandItemId.pineapple_seed_bag: ItemIconEntry(
      rowIndex: 10,
      columnIndex: 1999999,
    ),
    HandItemId.pumpkin_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 3),
    HandItemId.cabbage_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 4),
    HandItemId.radish_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 5),
    HandItemId.carrot_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 6),
    HandItemId.strawberry_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 7),
    HandItemId.wheat_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 8),
    HandItemId.pepper_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 9),
    HandItemId.turnip_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 10),
    HandItemId.cotton_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 11),
    HandItemId.onion_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 12),
    HandItemId.cauliflower_seed_bag: ItemIconEntry(
      rowIndex: 10,
      columnIndex: 13,
    ),
    HandItemId.corn_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 14),
    HandItemId.tomato_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 15),
    HandItemId.tomato_loot_item: ItemIconEntry(rowIndex: 1, columnIndex: 1),
    HandItemId.strawberry_loot_item: ItemIconEntry(rowIndex: 1, columnIndex: 15),
    HandItemId.radish_loot_item: ItemIconEntry(rowIndex: 2, columnIndex: 5),
    HandItemId.grape_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 0),
    HandItemId.prickly_pear_seed_bag: ItemIconEntry(
      rowIndex: 11,
      columnIndex: 1,
    ),
    HandItemId.coffee_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 2),
    HandItemId.zuchini_seed_bag: ItemIconEntry(rowIndex: 11, columnIndex: 3),
    HandItemId.apple_seed_bag: ItemIconEntry(rowIndex: 10, columnIndex: 8),
    HandItemId.cabbage: ItemIconEntry(rowIndex: 1, columnIndex: 0),
    HandItemId.tomato: ItemIconEntry(rowIndex: 1, columnIndex: 1),
    HandItemId.pumpkin: ItemIconEntry(rowIndex: 1, columnIndex: 2),
    HandItemId.radish: ItemIconEntry(rowIndex: 1, columnIndex: 3),
    HandItemId.wheat: ItemIconEntry(rowIndex: 1, columnIndex: 4),
    HandItemId.corn: ItemIconEntry(rowIndex: 1, columnIndex: 5),
    HandItemId.watermelon: ItemIconEntry(rowIndex: 1, columnIndex: 8),
    HandItemId.onion: ItemIconEntry(rowIndex: 1, columnIndex: 9),
    HandItemId.grape: ItemIconEntry(rowIndex: 1, columnIndex: 10),
    HandItemId.pineapple: ItemIconEntry(rowIndex: 1, columnIndex: 11),
    HandItemId.carrot: ItemIconEntry(rowIndex: 1, columnIndex: 12),
    HandItemId.pepper: ItemIconEntry(rowIndex: 1, columnIndex: 13),
    HandItemId.zuchini: ItemIconEntry(rowIndex: 1, columnIndex: 14),
    HandItemId.strawberry: ItemIconEntry(rowIndex: 1, columnIndex: 15),
    HandItemId.apple: ItemIconEntry(rowIndex: 1, columnIndex: 16),
    HandItemId.prickly_pear: ItemIconEntry(rowIndex: 2, columnIndex: 1),
    HandItemId.cauliflower: ItemIconEntry(rowIndex: 2, columnIndex: 2),
    HandItemId.turnip: ItemIconEntry(rowIndex: 2, columnIndex: 3),
    HandItemId.cotton: ItemIconEntry(rowIndex: 2, columnIndex: 4),
    HandItemId.coffee: ItemIconEntry(rowIndex: 2, columnIndex: 6),
    HandItemId.ironSword: ItemIconEntry(rowIndex: 6, columnIndex: 2),
    HandItemId.wateringCan: ItemIconEntry(rowIndex: 6, columnIndex: 3),
    HandItemId.shovel: ItemIconEntry(rowIndex: 6, columnIndex: 4),
    HandItemId.harvestBasket: ItemIconEntry(rowIndex: 6, columnIndex: 5),
    HandItemId.staff: ItemIconEntry(rowIndex: 6, columnIndex: 7),
    HandItemId.stone: ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    HandItemId.iron_ore: ItemIconEntry(rowIndex: 999999, columnIndex: 999999),
    HandItemId.dungeon_key: ItemIconEntry(rowIndex: 6, columnIndex: 6),
    HandItemId.apple_loot_item: ItemIconEntry(rowIndex: 2, columnIndex: 5),
  };
}
