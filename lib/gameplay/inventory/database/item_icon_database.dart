import '../models/item_icon_data.dart';
import '../../database/item_icon_database.dart';

class ItemIconDatabase {
  static final ItemIconDatabase _instance = ItemIconDatabase._internal();
  factory ItemIconDatabase() => _instance;
  ItemIconDatabase._internal();

  final Map<String, ItemIconData> _icons = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final globalSpritesheetPath = ItemIconDatabaseDef.spritesheetPath;
    final globalSpriteWidth = ItemIconDatabaseDef.spriteWidth;
    final globalSpriteHeight = ItemIconDatabaseDef.spriteHeight;

    for (final entry in ItemIconDatabaseDef.items.entries) {
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

  ItemIconData? getIconData(String itemKey) {
    return _icons[itemKey];
  }

  bool get isInitialized => _initialized;
}
