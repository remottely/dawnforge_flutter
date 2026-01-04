import 'package:equatable/equatable.dart';

import '../../tile_object.dart';
import '../../tile_object_type.dart';
import 'crop_entity.dart';
import 'soil_state.dart';

/// Farm-specific tile object that represents farmable soil and planted crops.
/// This implements TileObject to integrate with the generic GridTile system.
final class FarmObject extends Equatable implements TileObject {
  @override
  final String objectId;

  final SoilState soilState;
  final CropEntity? crop;
  final int? lastWateredDay;

  const FarmObject({
    required this.objectId,
    this.soilState = SoilState.untilled,
    this.crop,
    this.lastWateredDay,
  });

  @override
  String get name => crop?.name ?? soilState.displayName;

  @override
  TileObjectType get type => TileObjectType.farm;

  @override
  bool get blocksMovement => false; // Farm tiles don't block movement

  @override
  bool get isInteractable => true; // Farm tiles can be tilled, planted, watered, etc.

  @override
  bool get shouldUseYSorting =>
      crop != null && crop!.shouldUseYSorting; // Tall crops need Y-sorting

  @override
  Map<String, dynamic> get visualData => {
        'soilState': soilState.toJson(),
        if (crop != null) 'crop': crop!.toJson(),
      };

  /// Check if tile is empty (no crop planted)
  bool get isEmpty => crop == null;

  /// Check if tile is occupied (has crop)
  bool get isOccupied => crop != null;

  /// Check if tile can receive a plant
  bool get canPlantCrop => isEmpty && soilState.canPlantCrop;

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
  FarmObject till() {
    return copyWith(soilState: SoilState.tilled);
  }

  /// Water the tile
  FarmObject water(int currentDay) {
    return copyWith(
      soilState: SoilState.watered,
      lastWateredDay: currentDay,
    );
  }

  /// Plant a crop on this tile
  FarmObject plant(CropEntity newCrop) {
    if (!canPlantCrop) return this;
    return copyWith(crop: newCrop);
  }

  /// Harvest the crop and reset tile
  FarmObject harvest() {
    if (!canHarvest) return this;
    return FarmObject(
      objectId: objectId,
      soilState: SoilState.untilled,
      crop: null,
      lastWateredDay: null,
    );
  }

  /// Advance day logic - update crop growth if watered
  FarmObject advanceDay(int dayEnded) {
    final wasWateredThatDay =
        lastWateredDay != null && lastWateredDay == dayEnded;

    // Consume water even without crop
    if (wasWateredThatDay && soilState == SoilState.watered) {
      // If no crop, just consume water
      if (crop == null) {
        return copyWith(
          soilState: SoilState.tilled,
          lastWateredDay: null,
        );
      }

      // If has crop, grow it
      final advancedCrop = crop!.advanceDay();

      return copyWith(
        crop: advancedCrop,
        soilState: SoilState.tilled,
        lastWateredDay: null,
      );
    }

    // Was not watered or already not watered
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'type': type.toJson(),
      'soilState': soilState.toJson(),
      'crop': crop?.toJson(),
      'lastWateredDay': lastWateredDay,
    };
  }

  static FarmObject fromJson(Map<String, dynamic> json) {
    final cropData = json['crop'] as Map<String, dynamic>?;
    return FarmObject(
      objectId: json['objectId'] as String,
      soilState: SoilState.fromJson(json['soilState'] as String),
      crop: cropData != null ? CropEntity.fromJson(cropData) : null,
      lastWateredDay: json['lastWateredDay'] as int?,
    );
  }

  @override
  FarmObject copyWith({
    String? objectId,
    SoilState? soilState,
    CropEntity? crop,
    int? lastWateredDay,
  }) {
    return FarmObject(
      objectId: objectId ?? this.objectId,
      soilState: soilState ?? this.soilState,
      crop: crop ?? this.crop,
      lastWateredDay: lastWateredDay ?? this.lastWateredDay,
    );
  }

  @override
  List<Object?> get props => [objectId, soilState, crop, lastWateredDay];

  @override
  String toString() =>
      'FarmObject(id: $objectId, soil: $soilState, crop: ${crop?.name ?? "empty"})';
}
