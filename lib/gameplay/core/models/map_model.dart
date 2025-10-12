import 'package:darkness_dungeon/gameplay/core/constants/gameplay_map_constants.dart';

/// [MapModel] centralizes all map configuration in a reusable model
/// Following Flutter pattern of immutable data classes for game configuration
class MapModel {
  final MapId id;
  final String asset;
  final List<String> sensorIds;
  final String backgroundMusic;
  final String lightingColor;
  final String backgroundColor;

  const MapModel({
    required this.id,
    required this.asset,
    required this.sensorIds,
    required this.backgroundMusic,
    required this.lightingColor,
    required this.backgroundColor,
  });

  /// Gets all available map configurations in a centralized way
  /// Following Flutter pattern of static factory methods
  static List<MapModel> get allMaps => [
    // Map 1 configuration
    const MapModel(
      id: MapId.map1,
      asset: 'tiled/map_1.json',
      sensorIds: ['sensor_dungeon_1', 'sensor_dungeon_2'],
      backgroundMusic: 'ro1_letters.mp3',
      lightingColor: '#d0ffffff',
      backgroundColor: '#ff63c74d',
    ),

    // Dungeon 1 configuration
    const MapModel(
      id: MapId.dungeon1,
      asset: 'tiled/dungeon_1.json',
      sensorIds: ['sensor_map_1'],
      backgroundMusic: 'ro1_death_hex.mp3',
      lightingColor: '#d0000000',
      backgroundColor: '#ff424242',
    ),
  ];

  /// Gets a specific map configuration by ID
  /// Following Flutter pattern of named factory constructors
  static MapModel? byId(MapId id) {
    try {
      return allMaps.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Converts configuration to properties map format
  /// Following Flutter pattern of data transformation methods
  Map<String, dynamic> get properties => {
    'mapBackgroundMusic': backgroundMusic,
    'mapLightingColor': lightingColor,
    'mapBackgroundColor': backgroundColor,
  };
}
