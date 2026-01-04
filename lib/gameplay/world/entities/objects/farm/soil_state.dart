/// Entity representing the state of soil in a farm tile (D2: Entity with Serialization)
enum SoilState {
  untilled,
  tilled,
  watered,
  fertilized;

  /// Serialization (D2)
  String toJson() => name;

  /// Deserialization (D2)
  static SoilState fromJson(String json) => values.byName(json);

  /// Check if soil is ready for planting
  bool get canPlantCrop => this == SoilState.tilled || this == SoilState.watered;

  /// Tree planting rule: only on untilled soil
  bool get canPlantTree => this == SoilState.untilled;

  /// Check if soil needs watering
  bool get needsWater => this == SoilState.tilled;

  /// Get human-readable display name
  String get displayName {
    switch (this) {
      case SoilState.untilled:
        return 'Untilled';
      case SoilState.tilled:
        return 'Tilled';
      case SoilState.watered:
        return 'Watered';
      case SoilState.fertilized:
        return 'Fertilized';
    }
  }
}
