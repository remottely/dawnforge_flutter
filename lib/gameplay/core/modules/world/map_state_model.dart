/// Represents the state of an individual map in the game world
final class MapState {
  /// List of modified decoration IDs
  final List<String> decorationsModified;

  /// List of farm tile positions that have been modified
  final List<String> farmTiles;

  /// List of enemy IDs that have been defeated in this map
  final List<String> enemiesDefeated;

  /// Additional custom data for the map
  final Map<String, dynamic> customData;

  const MapState({
    this.decorationsModified = const [],
    this.farmTiles = const [],
    this.enemiesDefeated = const [],
    this.customData = const {},
  });

  /// Serialize map state to JSON
  Map<String, dynamic> toJson() {
    return {
      'decorationsModified': decorationsModified,
      'farmTiles': farmTiles,
      'enemiesDefeated': enemiesDefeated,
      'customData': customData,
    };
  }

  /// Deserialize map state from JSON
  factory MapState.fromJson(Map<String, dynamic> json) {
    return MapState(
      decorationsModified: List<String>.from(json['decorationsModified'] ?? []),
      farmTiles: List<String>.from(json['farmTiles'] ?? []),
      enemiesDefeated: List<String>.from(json['enemiesDefeated'] ?? []),
      customData: Map<String, dynamic>.from(json['customData'] ?? {}),
    );
  }

  /// Create a copy with modified fields
  MapState copyWith({
    List<String>? decorationsModified,
    List<String>? farmTiles,
    List<String>? enemiesDefeated,
    Map<String, dynamic>? customData,
  }) {
    return MapState(
      decorationsModified: decorationsModified ?? this.decorationsModified,
      farmTiles: farmTiles ?? this.farmTiles,
      enemiesDefeated: enemiesDefeated ?? this.enemiesDefeated,
      customData: customData ?? this.customData,
    );
  }

  @override
  String toString() =>
      'MapState(decorations: ${decorationsModified.length}, '
      'farmTiles: ${farmTiles.length}, enemies: ${enemiesDefeated.length})';
}
