import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';

/// [GameplayMapData] centralizes all map configuration in a reusable model
/// Following Flutter pattern of immutable data classes for game configuration
class GameplayMapData {
  // Flutter-style constants for asset paths
  static const String kMap1Asset = 'tiled/map_1.json';
  static const String kDungeon1Asset = 'tiled/dungeon_1.json';

  // Flutter-style constants for background music
  static const String kMap1BackgroundMusic = 'ro1_letters.mp3';
  static const String kDungeon1BackgroundMusic = 'ro1_death_hex.mp3';

  // Flutter-style constants for lighting colors
  static const String kMap1LightingColor = '#d0ffffff';
  static const String kDungeon1LightingColor = '#d0000000';

  // Flutter-style constants for background colors
  static const String kMap1BackgroundColor = '#ff63c74d';
  static const String kDungeon1BackgroundColor = '#ff424242';

  // Flutter-style constants for sensor configurations
  static const List<String> kMap1SensorIds = [
    'sensor_dungeon_1',
    'sensor_dungeon_2',
  ];
  static const List<String> kDungeon1SensorIds = ['sensor_map_1'];

  // Flutter-style constants for property keys
  static const String kBackgroundMusicPropertyKey = 'backgroundMusic';
  static const String kLightingColorPropertyKey = 'lightingColor';
  static const String kBackgroundColorPropertyKey = 'backgroundColor';

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

  /// Gets all available map configurations in a centralized way
  /// Following Flutter pattern of static factory methods
  static const List<GameplayMapData> allMaps = [
    // Map 1 configuration
    const GameplayMapData(
      id: MapId.map1,
      asset: kMap1Asset,
      sensorIds: kMap1SensorIds,
      backgroundMusic: kMap1BackgroundMusic,
      lightingColor: kMap1LightingColor,
      backgroundColor: kMap1BackgroundColor,
    ),

    // Dungeon 1 configuration
    const GameplayMapData(
      id: MapId.dungeon1,
      asset: kDungeon1Asset,
      sensorIds: kDungeon1SensorIds,
      backgroundMusic: kDungeon1BackgroundMusic,
      lightingColor: kDungeon1LightingColor,
      backgroundColor: kDungeon1BackgroundColor,
    ),
  ];

  /// Gets a specific map configuration by ID
  /// Following Flutter pattern of named factory constructors
  static GameplayMapData? byId(MapId id) {
    try {
      return allMaps.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Converts configuration to properties map format
  /// Following Flutter pattern of data transformation methods
  Map<String, dynamic> get properties => {
    kBackgroundMusicPropertyKey: backgroundMusic,
    kLightingColorPropertyKey: lightingColor,
    kBackgroundColorPropertyKey: backgroundColor,
  };
}
