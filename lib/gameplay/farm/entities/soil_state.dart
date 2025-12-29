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
  bool get canPlant => this == SoilState.tilled || this == SoilState.watered;

  /// Check if soil needs watering
  bool get needsWater => this == SoilState.tilled;
}
