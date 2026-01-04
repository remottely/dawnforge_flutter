import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/soil_database.dart';

import '../../database/item_icon_database.dart';

class SoilSpriteConfig {
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final Map<String, SoilStateSprite> soilStates;

  SoilSpriteConfig({
    required this.spritesheetPath,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.soilStates,
  });

  static Future<SoilSpriteConfig> load() async {
    developer.log('[SoilSpriteConfig] Loading soil database...');

    final config = SoilSpriteConfig(
      spritesheetPath: SoilDatabaseDef.spritesheetPath,
      spriteWidth: SoilDatabaseDef.spriteWidth,
      spriteHeight: SoilDatabaseDef.spriteHeight,
      soilStates: Map<String, SoilStateSprite>.from(
        SoilDatabaseDef.soilStates,
      ),
    );

    developer.log(
      '[SoilSpriteConfig] ✅ Loaded ${config.soilStates.length} soil states from ${config.spritesheetPath}',
    );

    return config;
  }

  SoilStateSprite? getPosition(String stateName) {
    return soilStates[stateName];
  }
}
