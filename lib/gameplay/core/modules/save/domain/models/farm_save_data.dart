import 'package:equatable/equatable.dart';

/// Domain model for farm/agriculture save data.
///
/// Represents all farming-related persistent state including
/// crops, animals, buildings, and farm upgrades.
///
/// **Stardew Valley Inspiration:**
/// - Crop growing system
/// - Animal husbandry
/// - Farm buildings and upgrades
/// - Soil quality and irrigation
final class FarmSaveData {
  /// All crop tiles on the farm
  final List<CropTileData> crops;

  /// Farm animals
  final List<FarmAnimalData> animals;

  /// Farm buildings (barns, coops, silos, etc.)
  final List<FarmBuildingData> buildings;

  /// Tilled/hoeed tiles (prepared for planting)
  final List<TilePositionData> tilledTiles;

  /// Watered tiles
  final List<TilePositionData> wateredTiles;

  /// Farm upgrades purchased
  final List<String> unlockedUpgrades;

  /// Farm layout type (standard, forest, hilltop, etc.)
  final String farmLayout;

  const FarmSaveData({
    required this.crops,
    required this.animals,
    required this.buildings,
    required this.tilledTiles,
    required this.wateredTiles,
    required this.unlockedUpgrades,
    required this.farmLayout,
  });

  /// Creates initial empty farm.
  factory FarmSaveData.initial({String layout = 'standard'}) {
    return FarmSaveData(
      crops: const [],
      animals: const [],
      buildings: const [],
      tilledTiles: const [],
      wateredTiles: const [],
      unlockedUpgrades: const [],
      farmLayout: layout,
    );
  }

  factory FarmSaveData.fromJson(Map<String, dynamic> json) {
    return FarmSaveData(
      crops:
          (json['crops'] as List<dynamic>?)
              ?.map((e) => CropTileData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      animals:
          (json['animals'] as List<dynamic>?)
              ?.map((e) => FarmAnimalData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      buildings:
          (json['buildings'] as List<dynamic>?)
              ?.map((e) => FarmBuildingData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tilledTiles:
          (json['tilledTiles'] as List<dynamic>?)
              ?.map((e) => TilePositionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      wateredTiles:
          (json['wateredTiles'] as List<dynamic>?)
              ?.map((e) => TilePositionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unlockedUpgrades:
          (json['unlockedUpgrades'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      farmLayout: json['farmLayout'] as String? ?? 'standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crops': crops.map((crop) => crop.toJson()).toList(),
      'animals': animals.map((animal) => animal.toJson()).toList(),
      'buildings': buildings.map((building) => building.toJson()).toList(),
      'tilledTiles': tilledTiles.map((tile) => tile.toJson()).toList(),
      'wateredTiles': wateredTiles.map((tile) => tile.toJson()).toList(),
      'unlockedUpgrades': unlockedUpgrades,
      'farmLayout': farmLayout,
    };
  }

  bool isValid() {
    return farmLayout.isNotEmpty &&
        crops.every((crop) => crop.isValid()) &&
        animals.every((animal) => animal.isValid());
  }

  /// Gets total number of crops.
  int get totalCrops => crops.length;

  /// Gets total number of animals.
  int get totalAnimals => animals.length;

  /// Gets total number of buildings.
  int get totalBuildings => buildings.length;

  FarmSaveData copyWith({
    List<CropTileData>? crops,
    List<FarmAnimalData>? animals,
    List<FarmBuildingData>? buildings,
    List<TilePositionData>? tilledTiles,
    List<TilePositionData>? wateredTiles,
    List<String>? unlockedUpgrades,
    String? farmLayout,
  }) {
    return FarmSaveData(
      crops: crops ?? this.crops,
      animals: animals ?? this.animals,
      buildings: buildings ?? this.buildings,
      tilledTiles: tilledTiles ?? this.tilledTiles,
      wateredTiles: wateredTiles ?? this.wateredTiles,
      unlockedUpgrades: unlockedUpgrades ?? this.unlockedUpgrades,
      farmLayout: farmLayout ?? this.farmLayout,
    );
  }

  @override
  String toString() {
    return 'FarmSaveData('
        'layout: $farmLayout, '
        'crops: $totalCrops, '
        'animals: $totalAnimals, '
        'buildings: $totalBuildings'
        ')';
  }
}

/// Represents a single crop tile.
final class CropTileData extends Equatable {
  final int tileX;
  final int tileY;
  final String cropId;
  final int growthStage;
  final int maxGrowthStages;
  final int daysSincePlanted;
  final bool isWatered;
  final bool isFertilized;
  final String? fertilizerType;

  const CropTileData({
    required this.tileX,
    required this.tileY,
    required this.cropId,
    required this.growthStage,
    required this.maxGrowthStages,
    required this.daysSincePlanted,
    required this.isWatered,
    required this.isFertilized,
    this.fertilizerType,
  });

  bool isValid() {
    return growthStage >= 0 &&
        growthStage <= maxGrowthStages &&
        maxGrowthStages > 0 &&
        daysSincePlanted >= 0 &&
        cropId.isNotEmpty;
  }

  bool get isReadyToHarvest => growthStage >= maxGrowthStages;

  factory CropTileData.fromJson(Map<String, dynamic> json) {
    return CropTileData(
      tileX: json['tileX'] as int,
      tileY: json['tileY'] as int,
      cropId: json['cropId'] as String,
      growthStage: json['growthStage'] as int,
      maxGrowthStages: json['maxGrowthStages'] as int,
      daysSincePlanted: json['daysSincePlanted'] as int,
      isWatered: json['isWatered'] as bool? ?? false,
      isFertilized: json['isFertilized'] as bool? ?? false,
      fertilizerType: json['fertilizerType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tileX': tileX,
      'tileY': tileY,
      'cropId': cropId,
      'growthStage': growthStage,
      'maxGrowthStages': maxGrowthStages,
      'daysSincePlanted': daysSincePlanted,
      'isWatered': isWatered,
      'isFertilized': isFertilized,
      if (fertilizerType != null) 'fertilizerType': fertilizerType,
    };
  }

  @override
  String toString() =>
      'CropTileData($cropId at [$tileX,$tileY], stage: $growthStage/$maxGrowthStages)';

  @override
  List<Object?> get props => [tileX, tileY, cropId];
}

/// Represents a farm animal.
final class FarmAnimalData {
  final String animalId;
  final String animalType; // cow, chicken, pig, etc.
  final String name;
  final int happiness;
  final int health;
  final int daysSinceLastProduce;
  final int age;
  final String buildingId;

  const FarmAnimalData({
    required this.animalId,
    required this.animalType,
    required this.name,
    required this.happiness,
    required this.health,
    required this.daysSinceLastProduce,
    required this.age,
    required this.buildingId,
  });

  bool isValid() {
    return happiness >= 0 &&
        happiness <= 100 &&
        health >= 0 &&
        health <= 100 &&
        age >= 0 &&
        animalId.isNotEmpty &&
        animalType.isNotEmpty &&
        buildingId.isNotEmpty;
  }

  factory FarmAnimalData.fromJson(Map<String, dynamic> json) {
    return FarmAnimalData(
      animalId: json['animalId'] as String,
      animalType: json['animalType'] as String,
      name: json['name'] as String,
      happiness: json['happiness'] as int,
      health: json['health'] as int,
      daysSinceLastProduce: json['daysSinceLastProduce'] as int,
      age: json['age'] as int,
      buildingId: json['buildingId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'animalType': animalType,
      'name': name,
      'happiness': happiness,
      'health': health,
      'daysSinceLastProduce': daysSinceLastProduce,
      'age': age,
      'buildingId': buildingId,
    };
  }

  @override
  String toString() =>
      'Animal($name the $animalType, happiness: $happiness, health: $health)';
}

/// Represents a farm building.
final class FarmBuildingData {
  final String buildingId;
  final String buildingType;
  final int tileX;
  final int tileY;
  final int upgradeLevel;
  final Map<String, dynamic>? metadata;

  const FarmBuildingData({
    required this.buildingId,
    required this.buildingType,
    required this.tileX,
    required this.tileY,
    required this.upgradeLevel,
    this.metadata,
  });

  factory FarmBuildingData.fromJson(Map<String, dynamic> json) {
    return FarmBuildingData(
      buildingId: json['buildingId'] as String,
      buildingType: json['buildingType'] as String,
      tileX: json['tileX'] as int,
      tileY: json['tileY'] as int,
      upgradeLevel: json['upgradeLevel'] as int? ?? 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buildingId': buildingId,
      'buildingType': buildingType,
      'tileX': tileX,
      'tileY': tileY,
      'upgradeLevel': upgradeLevel,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() =>
      'Building($buildingType at [$tileX,$tileY], level: $upgradeLevel)';
}

/// Represents a tile position.
final class TilePositionData extends Equatable {
  final int tileX;
  final int tileY;

  const TilePositionData({required this.tileX, required this.tileY});

  factory TilePositionData.fromJson(Map<String, dynamic> json) {
    return TilePositionData(
      tileX: json['tileX'] as int,
      tileY: json['tileY'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tileX': tileX, 'tileY': tileY};
  }

  @override
  String toString() => '[$tileX,$tileY]';

  @override
  // TODO: implement props
  List<Object?> get props => [tileX, tileY];
}
