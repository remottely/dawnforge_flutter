final class MapState {
  final List<String> decorationsModified;

  final List<String> farmTiles;

  final List<String> enemiesDefeated;

  final Map<String, dynamic> customData;

  const MapState({
    this.decorationsModified = const [],
    this.farmTiles = const [],
    this.enemiesDefeated = const [],
    this.customData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'decorationsModified': decorationsModified,
      'farmTiles': farmTiles,
      'enemiesDefeated': enemiesDefeated,
      'customData': customData,
    };
  }

  factory MapState.fromJson(Map<String, dynamic> json) {
    return MapState(
      decorationsModified: List<String>.from(json['decorationsModified'] ?? []),
      farmTiles: List<String>.from(json['farmTiles'] ?? []),
      enemiesDefeated: List<String>.from(json['enemiesDefeated'] ?? []),
      customData: Map<String, dynamic>.from(json['customData'] ?? {}),
    );
  }

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
