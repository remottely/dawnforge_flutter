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

    final String jsonString = await rootBundle.loadString('assets/items/items_icons_database.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final String globalSpritesheetPath = jsonData['spritesheetPath'];
    final int globalSpriteWidth = jsonData['spriteWidth'];
    final int globalSpriteHeight = jsonData['spriteHeight'];
    final Map<String, dynamic> items = jsonData['items'];

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
