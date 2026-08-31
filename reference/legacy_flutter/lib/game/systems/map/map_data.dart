import 'package:dawnforge/game/systems/map/map_def.dart';

class MapData {
  final String id;
  final String asset;
  final List<String> sensorIds;
  final String backgroundMusic;
  final String lightingColor;
  final String backgroundColor;
  final String? initialPlayerPosition;

  const MapData({
    required this.id,
    required this.asset,
    required this.sensorIds,
    required this.backgroundMusic,
    required this.lightingColor,
    required this.backgroundColor,
    this.initialPlayerPosition,
  });

  Map<String, dynamic> get properties => {
    MapDef.kBackgroundMusicPropertyKey: backgroundMusic,
    MapDef.kLightingColorPropertyKey: lightingColor,
    MapDef.kBackgroundColorPropertyKey: backgroundColor,
    if (initialPlayerPosition != null)
      MapDef.kInitialPlayerPositionPropertyKey: initialPlayerPosition,
  };
}
