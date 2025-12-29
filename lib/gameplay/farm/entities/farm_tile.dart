import 'package:equatable/equatable.dart';

import 'crop.dart';
import 'soil_state.dart';

/// Entity representing a tile in the farm (D2: Entity with Serialization)
final class FarmTile extends Equatable {
  final int x;
  final int y;
  final SoilState soilState;
  final Crop? crop;
  final int? lastWateredDay;

  const FarmTile({
    required this.x,
    required this.y,
    this.soilState = SoilState.untilled,
    this.crop,
    this.lastWateredDay,
  });

  /// Check if tile is empty (no crop planted)
  bool get isEmpty => crop == null;

  /// Check if tile is occupied (has crop)
  bool get isOccupied => crop != null;

  /// Check if tile can receive a plant
  bool get canPlant => isEmpty && soilState.canPlant;

  /// Check if crop can be harvested
  bool get canHarvest => isOccupied && crop!.canHarvest;

  /// Check if tile is ready to harvest
  bool get isReadyToHarvest => isOccupied && crop!.isReadyToHarvest;

  /// Check if tile needs watering (based on current day)
  bool needsWatering(int currentDay) {
    if (lastWateredDay == null) return soilState == SoilState.tilled;
    return lastWateredDay != currentDay;
  }

  /// Till the soil
  FarmTile till() {
    return copyWith(soilState: SoilState.tilled);
  }

  /// Water the tile
  FarmTile water(int currentDay) {
    return copyWith(
      soilState: SoilState.watered,
      lastWateredDay: currentDay,
    );
  }

  /// Plant a crop on this tile
  FarmTile plant(Crop newCrop) {
    if (!canPlant) return this;
    return copyWith(crop: newCrop);
  }

  /// Harvest the crop and reset tile
  FarmTile harvest() {
    if (!canHarvest) return this;
    return FarmTile(
      x: x,
      y: y,
      soilState: SoilState.untilled,
      crop: null,
      lastWateredDay: null,
    );
  }

  /// Advance day logic - update crop growth if watered
  FarmTile advanceDay(int dayEnded) {
    final wasWateredThatDay =
        lastWateredDay != null && lastWateredDay == dayEnded;

    // Consome água mesmo sem crop
    if (wasWateredThatDay && soilState == SoilState.watered) {
      // Se não tem crop, apenas consome a água
      if (crop == null) {
        return copyWith(
          soilState: SoilState.tilled,
          lastWateredDay: null,
        );
      }

      // Se tem crop, faz crescer
      final advancedCrop = crop!.advanceDay();

      return copyWith(
        crop: advancedCrop,
        soilState: SoilState.tilled,
        lastWateredDay: null,
      );
    }

    // Não foi regado ou já não está watered
    return this;
  }

  /// Serialization (D2)
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'soilState': soilState.toJson(),
      'crop': crop?.toJson(),
      'lastWateredDay': lastWateredDay,
    };
  }

  /// Deserialization (D2)
  static FarmTile fromJson(
    Map<String, dynamic> json,
    Crop? Function(String cropId) cropResolver,
  ) {
    final cropData = json['crop'] as Map<String, dynamic>?;
    return FarmTile(
      x: json['x'] as int,
      y: json['y'] as int,
      soilState: SoilState.fromJson(json['soilState'] as String),
      crop: cropData != null ? Crop.fromJson(cropData) : null,
      lastWateredDay: json['lastWateredDay'] as int?,
    );
  }

  /// Create a copy with modifications
  FarmTile copyWith({
    int? x,
    int? y,
    SoilState? soilState,
    Crop? crop,
    int? lastWateredDay,
  }) {
    return FarmTile(
      x: x ?? this.x,
      y: y ?? this.y,
      soilState: soilState ?? this.soilState,
      crop: crop ?? this.crop,
      lastWateredDay: lastWateredDay ?? this.lastWateredDay,
    );
  }

  @override
  List<Object?> get props => [x, y, soilState, crop, lastWateredDay];

  @override
  String toString() =>
      'FarmTile(x: $x, y: $y, soil: $soilState, crop: ${crop?.name ?? "empty"})';
}
