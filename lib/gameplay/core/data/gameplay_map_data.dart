import 'package:darkness_dungeon/gameplay/core/config/gameplay_map_config.dart';

enum MapId { map1, dungeon1 }

class GameplayMapData {
  final MapId id;
  final String asset;
  final List<String> sensorIds;
  final String backgroundMusic;
  final String lightingColor;
  final String backgroundColor;

  const GameplayMapData({
    required this.id,
    required this.asset,
    required this.sensorIds,
    required this.backgroundMusic,
    required this.lightingColor,
    required this.backgroundColor,
  });

  Map<String, dynamic> get properties => {
    GameplayMapConfig.kBackgroundMusicPropertyKey: backgroundMusic,
    GameplayMapConfig.kLightingColorPropertyKey: lightingColor,
    GameplayMapConfig.kBackgroundColorPropertyKey: backgroundColor,
  };
}
