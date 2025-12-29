import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/item_icon_data.dart';

class ItemIconDatabase {
  static final ItemIconDatabase _instance = ItemIconDatabase._internal();
  factory ItemIconDatabase() => _instance;
  ItemIconDatabase._internal();

  final Map<String, ItemIconData> _icons = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final String jsonString = await rootBundle.loadString(
      'assets/database/items_icons_database.json',
    );
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;

    final globalSpritesheetPath = jsonData['spritesheetPath'] as String;
    final globalSpriteWidth = jsonData['spriteWidth'] as int;
    final globalSpriteHeight = jsonData['spriteHeight'] as int;
    final items = jsonData['items'] as Map<String, dynamic>;

    items.forEach((key, value) {
      _icons[key] = ItemIconData.fromJson(
        value as Map<String, dynamic>,
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
