import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_config.dart';

class GameplayMapData {
  final String id;
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
