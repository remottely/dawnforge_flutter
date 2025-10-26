import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';

class GameplayMapConfig {
  static const kMap1Asset = 'tiled/map_1.json';
  static const kDungeon1Asset = 'tiled/dungeon_1.json';

  static const kMap1BackgroundMusic = 'ro1_letters.mp3';
  static const kDungeon1BackgroundMusic = 'ro1_death_hex.mp3';

  static const kMap1LightingColor = '#d0ffffff';
  static const kDungeon1LightingColor = '#d0000000';

  static const kMap1BackgroundColor = '#ff63c74d';
  static const kDungeon1BackgroundColor = '#ff424242';

  static const kMap1SensorIds = ['sensor_dungeon_1', 'sensor_dungeon_2'];
  static const kDungeon1SensorIds = ['sensor_map_1'];

  static const kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const kLightingColorPropertyKey = 'lightingColor';
  static const kBackgroundColorPropertyKey = 'backgroundColor';

  final MapId id;
  final String asset;
  final List<String> sensorIds;
  final String backgroundMusic;
  final String lightingColor;
  final String backgroundColor;

  const GameplayMapConfig({
    required this.id,
    required this.asset,
    required this.sensorIds,
    required this.backgroundMusic,
    required this.lightingColor,
    required this.backgroundColor,
  });

  static const kAllMaps = [
    const GameplayMapConfig(
      id: MapId.map1,
      asset: kMap1Asset,
      sensorIds: kMap1SensorIds,
      backgroundMusic: kMap1BackgroundMusic,
      lightingColor: kMap1LightingColor,
      backgroundColor: kMap1BackgroundColor,
    ),

    const GameplayMapConfig(
      id: MapId.dungeon1,
      asset: kDungeon1Asset,
      sensorIds: kDungeon1SensorIds,
      backgroundMusic: kDungeon1BackgroundMusic,
      lightingColor: kDungeon1LightingColor,
      backgroundColor: kDungeon1BackgroundColor,
    ),
  ];

  static GameplayMapConfig? byId(MapId id) {
    try {
      return kAllMaps.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get properties => {
    kBackgroundMusicPropertyKey: backgroundMusic,
    kLightingColorPropertyKey: lightingColor,
    kBackgroundColorPropertyKey: backgroundColor,
  };
}
