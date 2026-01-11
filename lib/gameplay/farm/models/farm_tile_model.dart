// import 'package:dawnforge/gameplay/core/modules/world/world_state_manager.dart';

// import 'crop_model.dart';
// import 'soil_state_model.dart';

// final class FarmTileModel {
//   final int x;
//   final int y;
//   final SoilStateModel soilState;
//   final CropEntity? crop;
//   final int? lastWateredDay;

//   const FarmTileModel({
//     required this.x,
//     required this.y,
//     this.soilState = SoilStateModel.untilled,
//     this.crop,
//     this.lastWateredDay,
//   });

//   bool get isEmpty => crop == null;

//   bool get isOccupied => crop != null;

//   bool get canPlantCrop =>
//       isEmpty &&
//       (soilState == SoilStateModel.tilled ||
//           soilState == SoilStateModel.watered);

//   bool get canHarvest => isOccupied && crop!.canHarvest;

//   bool get needsWatering {
//     final currentDay = WorldStateManager.instance.currentDay;
//     if (lastWateredDay == null) return soilState == SoilStateModel.tilled;
//     return lastWateredDay != currentDay;
//   }

//   FarmTileModel till() {
//     return copyWith(soilState: SoilStateModel.tilled);
//   }

//   FarmTileModel water() {
//     return copyWith(
//       soilState: SoilStateModel.watered,
//       lastWateredDay: WorldStateManager.instance.currentDay,
//     );
//   }

//   FarmTileModel plant(CropEntity crop) {
//     if (!canPlantCrop) return this;
//     return copyWith(crop: crop);
//   }

//   FarmTileModel harvest() {
//     if (!canHarvest) return this;
//     return FarmTileModel(
//       x: x,
//       y: y,
//       soilState: SoilStateModel.untilled,
//       crop: null,
//       lastWateredDay: null,
//     );
//   }

//   FarmTileModel advanceDay(int dayEnded) {
//     if (crop == null) return this;

//     final wasWateredThatDay =
//         lastWateredDay != null && lastWateredDay == dayEnded;

//     if (!wasWateredThatDay) {
//       return this;
//     }

//     final advancedCrop = crop!.advanceDay();

//     final nextSoilState = soilState == SoilStateModel.watered
//         ? SoilStateModel.tilled
//         : soilState;

//     return copyWith(
//       crop: advancedCrop,
//       soilState: nextSoilState,
//       lastWateredDay: null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'x': x,
//       'y': y,
//       'soilState': soilState.toJson(),
//       'crop': crop?.toJson(),
//       'lastWateredDay': lastWateredDay,
//     };
//   }

//   factory FarmTileModel.fromJson(Map<String, dynamic> json) {
//     return FarmTileModel(
//       x: json['x'] as int,
//       y: json['y'] as int,
//       soilState: SoilStateModel.fromJson(json['soilState'] as String),
//       crop: json['crop'] != null
//           ? CropEntity.fromJson(json['crop'] as Map<String, dynamic>)
//           : null,
//       lastWateredDay: json['lastWateredDay'] as int?,
//     );
//   }

//   FarmTileModel copyWith({
//     int? x,
//     int? y,
//     SoilStateModel? soilState,
//     CropEntity? crop,
//     int? lastWateredDay,
//   }) {
//     return FarmTileModel(
//       x: x ?? this.x,
//       y: y ?? this.y,
//       soilState: soilState ?? this.soilState,
//       crop: crop ?? this.crop,
//       lastWateredDay: lastWateredDay ?? this.lastWateredDay,
//     );
//   }

//   @override
//   String toString() =>
//       'FarmTile(x: $x, y: $y, soil: $soilState, crop: ${crop?.name ?? "empty"})';
// }
