import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:dawnforge/gameplay/database/smallburg/smallburg_soil_state_sprite_database_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/data/item_icon_data.dart';

class SoilSpriteConfig {
  final Map<String, ItemIconData> soilStates;

  SoilSpriteConfig({required this.soilStates});

  static Future<SoilSpriteConfig> load() async {
    GameLogger.info('[SoilSpriteConfig] Loading soil database...');

    final config = SoilSpriteConfig(
      soilStates: Map<String, ItemIconData>.from(
        SmallBurgSoilStateSpriteDatabaseDef.soilStateSpriteList,
      ),
    );

    GameLogger.info(
      '[SoilSpriteConfig] ✓ Loaded ${config.soilStates.length} soil states',
    );

    return config;
  }

  ItemIconData? getPosition(String stateName) {
    return soilStates[stateName];
  }
}
