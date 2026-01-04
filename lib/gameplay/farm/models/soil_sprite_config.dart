import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/modern_farm/modern_farm_soil_state_sprite_database_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item_icon_data.dart';

class SoilSpriteConfig {
  final Map<String, ItemIconData> soilStates;

  SoilSpriteConfig({
    required this.soilStates,
  });

  static Future<SoilSpriteConfig> load() async {
    developer.log('[SoilSpriteConfig] Loading soil database...');

    final config = SoilSpriteConfig(
      soilStates: Map<String, ItemIconData>.from(
        ModernFarmSoilStateSpriteDatabaseDef.soilStateSpriteList,
      ),
    );

    developer.log(
      '[SoilSpriteConfig] ✅ Loaded ${config.soilStates.length} soil states',
    );

    return config;
  }

  ItemIconData? getPosition(String stateName) {
    return soilStates[stateName];
  }
}
