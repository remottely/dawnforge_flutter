import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';

import '../models/item_icon_data.dart';
import '../../database/item_icon_entry_database_def.dart';

class ItemIconDatabase {
  static final ItemIconDatabase _instance = ItemIconDatabase._internal();
  factory ItemIconDatabase() => _instance;
  ItemIconDatabase._internal();

  final Map<HandItemId, ItemIconData> _icons = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final globalSpritesheetPath = ItemIconEntryDatabaseDef.spritesheetPath;
    final globalSpriteWidth = ItemIconEntryDatabaseDef.spriteWidth;
    final globalSpriteHeight = ItemIconEntryDatabaseDef.spriteHeight;

    for (final entry in ItemIconEntryDatabaseDef.itemIconEntryList.entries) {
      final icon = entry.value;
      _icons[entry.key] = ItemIconData(
        spritesheetPath: globalSpritesheetPath,
        spriteWidth: globalSpriteWidth,
        spriteHeight: globalSpriteHeight,
        spriteRowIndex: icon.rowIndex,
        spriteColumnIndex: icon.columnIndex,
      );
    }

    _initialized = true;
  }

  ItemIconData? getIconData(HandItemId itemKey) {
    return _icons[itemKey];
  }

  bool get isInitialized => _initialized;
}
