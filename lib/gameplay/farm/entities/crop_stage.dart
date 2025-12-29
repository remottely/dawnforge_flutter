/// Entity representing a growth stage of a crop (D2: Entity with Serialization)
enum CropStage {
  seed,
  sprout,
  youngPlant,
  growing1,
  growing2,
  growing3,
  mature,
  withered;

  /// Serialization (D2)
  String toJson() => name;

  /// Deserialization (D2)
  static CropStage fromJson(String json) => values.byName(json);

  /// Check if crop can be harvested at this stage
  bool get canHarvest => this == CropStage.mature;

  /// Check if crop is dead
  bool get isDead => this == CropStage.withered;

  /// Check if this is the initial stage
  bool get isSeed => this == CropStage.seed;

  /// Check if crop is fully grown
  bool get isMature => this == CropStage.mature;
}
