/// Entity representing a growth stage of a crop (D2: Entity with Serialization)
enum CropStageType {
  planted, // Semente plantada (substitui "seed")
  sprout, // Broto inicial
  seedling, // Muda jovem (substitui "youngPlant")
  budding, // Começando a brotar (substitui "growing1")
  flowering, // Florescendo (substitui "growing2")
  fruiting, // Frutificando (substitui "growing3")
  harvestable; // Pronto para colher (substitui "mature")
  // dead; // Morto (substitui "withered") // TODO(Kevin): create dead logic

  /// Serialization (D2)
  String toJson() => name;

  /// Deserialization for required fields (throws on invalid)
  static CropStageType fromJson(String json) => values.byName(json);

  /// Deserialization that tolerates null/empty/"none" and invalid values, returning null.
  static CropStageType? fromJsonNullable(String? json) {
    if (json == null) return null;
    final normalized = json.trim();
    if (normalized.isEmpty) return null;
    if (normalized.toLowerCase() == 'none') return null;
    try {
      return values.byName(normalized);
    } catch (_) {
      return null;
    }
  }

  /// Check if crop can be harvested at this stage
  bool get canHarvest => this == CropStageType.harvestable;

  // /// Check if crop is dead
  // bool get isDead => this == CropStageType.dead;

  /// Check if this is the initial stage
  bool get isPlanted => this == CropStageType.planted;

  /// Check if crop is fully grown
  bool get isHarvestable => this == CropStageType.harvestable;

  /// Check if crop is in growing phase
  bool get isGrowing =>
      index >= CropStageType.sprout.index &&
      index < CropStageType.harvestable.index;

  /// Get growth stage category for UI purposes
  String get displayName {
    switch (this) {
      case CropStageType.planted:
        return 'Planted';
      case CropStageType.sprout:
        return 'Sprout';
      case CropStageType.seedling:
        return 'Seedling';
      case CropStageType.budding:
        return 'Budding';
      case CropStageType.flowering:
        return 'Flowering';
      case CropStageType.fruiting:
        return 'Fruiting';
      case CropStageType.harvestable:
        return 'Harvestable';
      // case CropStageType.dead:
      //   return 'Dead';
    }
  }

  /// Get sprite frame index for this stage
  int getSpriteFrameIndex() {
    switch (this) {
      case CropStageType.planted:
        return 0;
      case CropStageType.sprout:
        return 1;
      case CropStageType.seedling:
        return 2;
      case CropStageType.budding:
        return 3;
      case CropStageType.flowering:
        return 4;
      case CropStageType.fruiting:
        return 5;
      case CropStageType.harvestable:
        return 6;
      // case CropStageType.dead:
      //   return 7;
    }
  }

  /// Get the next stage (or same if already at dead)
  CropStageType? get nextStage {
    // if (this == CropStageType.dead) return null;
    final nextIndex = index + 1;
    return nextIndex < values.length ? values[nextIndex] : null;
  }

  /// Calculate stage from growth progress (0.0 to 1.0)
  static CropStageType fromProgress(double progress) {
    if (progress >= 1.0) return CropStageType.harvestable;
    if (progress >= 0.85) return CropStageType.fruiting;
    if (progress >= 0.70) return CropStageType.flowering;
    if (progress >= 0.55) return CropStageType.budding;
    if (progress >= 0.40) return CropStageType.seedling;
    if (progress >= 0.20) return CropStageType.sprout;
    return CropStageType.planted;
  }
}
