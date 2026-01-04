import 'dart:developer' as developer;

import '../../data/game_data_constants.dart';

class SoilSpriteConfig {
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final Map<String, SoilSpritePosition> soilStates;

  SoilSpriteConfig({
    required this.spritesheetPath,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.soilStates,
  });

  factory SoilSpriteConfig.fromJson(Map<String, dynamic> json) {
    final soilStatesMap = <String, SoilSpritePosition>{};
    final states = json['soilStates'] as Map<String, dynamic>;

    for (final entry in states.entries) {
      soilStatesMap[entry.key] = SoilSpritePosition.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }

    return SoilSpriteConfig(
      spritesheetPath: json['spritesheetPath'] as String,
      spriteWidth: json['spriteWidth'] as int,
      spriteHeight: json['spriteHeight'] as int,
      soilStates: soilStatesMap,
    );
  }

  static Future<SoilSpriteConfig> load() async {
    developer.log('[SoilSpriteConfig] Loading soil database...');

    final config = SoilSpriteConfig(
      spritesheetPath: SoilDbConstants.spritesheetPath,
      spriteWidth: SoilDbConstants.spriteWidth,
      spriteHeight: SoilDbConstants.spriteHeight,
      soilStates: SoilDbConstants.soilStates.map(
        (key, value) => MapEntry(
          key,
          SoilSpritePosition(
            rowIndex: value['rowIndex']!,
            columnIndex: value['columnIndex']!,
          ),
        ),
      ),
    );

    developer.log(
      '[SoilSpriteConfig] ✅ Loaded ${config.soilStates.length} soil states from ${config.spritesheetPath}',
    );

    return config;
  }

  SoilSpritePosition? getPosition(String stateName) {
    return soilStates[stateName];
  }
}

class SoilSpritePosition {
  final int rowIndex;
  final int columnIndex;

  SoilSpritePosition({required this.rowIndex, required this.columnIndex});

  factory SoilSpritePosition.fromJson(Map<String, dynamic> json) {
    return SoilSpritePosition(
      rowIndex: json['rowIndex'] as int,
      columnIndex: json['columnIndex'] as int,
    );
  }
}
