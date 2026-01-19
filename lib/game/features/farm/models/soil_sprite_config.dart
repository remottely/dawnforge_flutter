import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/features/game_world/database/smallburg/smallburg_soil_state_sprite_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';

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
