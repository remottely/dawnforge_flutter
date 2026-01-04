import '../models/item_icon_data.dart';
import '../../data/game_data_constants.dart';

class ItemIconDatabase {
  static final ItemIconDatabase _instance = ItemIconDatabase._internal();
  factory ItemIconDatabase() => _instance;
  ItemIconDatabase._internal();

  final Map<String, ItemIconData> _icons = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final globalSpritesheetPath = ItemIconDbConstants.spritesheetPath;
    final globalSpriteWidth = ItemIconDbConstants.spriteWidth;
    final globalSpriteHeight = ItemIconDbConstants.spriteHeight;
    final items = ItemIconDbConstants.items;

    items.forEach((key, value) {
      _icons[key] = ItemIconData.fromJson(
        value,
        globalSpritesheetPath,
        globalSpriteWidth,
        globalSpriteHeight,
      );
    });

    _initialized = true;
  }

  ItemIconData? getIconData(String itemKey) {
    return _icons[itemKey];
  }

  bool get isInitialized => _initialized;
}
