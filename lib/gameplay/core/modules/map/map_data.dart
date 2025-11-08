import 'package:darkness_dungeon/gameplay/core/modules/map/map_config.dart';

class MapData {
  final String id;
  final String asset;
  final List<String> sensorIds;
  final String backgroundMusic;
  final String lightingColor;
  final String backgroundColor;

  const MapData({
    required this.id,
    required this.asset,
    required this.sensorIds,
    required this.backgroundMusic,
    required this.lightingColor,
    required this.backgroundColor,
  });

  Map<String, dynamic> get properties => {
    MapConfig.kBackgroundMusicPropertyKey: backgroundMusic,
    MapConfig.kLightingColorPropertyKey: lightingColor,
    MapConfig.kBackgroundColorPropertyKey: backgroundColor,
  };
}
