import 'package:equatable/equatable.dart';

import 'crop_stage.dart';

/// Entity representing a planted crop in the farm (D2: Entity with Serialization)
final class Crop extends Equatable {
  final String cropId;
  final String name;
  final String description;
  final CropStage stage;
  final int daysPlanted;
  final int daysToMature;
  final int yieldAmount;
  final String harvestItemId;
  final String? requiredSeason;
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final int spriteRowIndex;
  final int framesCount;
  final int skipFirstFrames;
  final CropStage ySortingFromStage;

  const Crop({
    required this.cropId,
    required this.name,
    required this.description,
    required this.stage,
    required this.daysPlanted,
    required this.daysToMature,
    required this.yieldAmount,
    required this.harvestItemId,
    this.requiredSeason,
    required this.spritesheetPath,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.spriteRowIndex,
    required this.framesCount,
    required this.skipFirstFrames,
    required this.ySortingFromStage,
  });

  /// Calculate growth progress (0.0 to 1.0)
  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  /// Check if crop is fully mature
  bool get isMature => daysPlanted >= daysToMature;

  /// Check if crop can be harvested
  bool get canHarvest => stage.canHarvest;

  /// Check if crop is ready to harvest
  bool get isReadyToHarvest => isMature && canHarvest;

  /// Check if crop should use Y-sorting (for taller plants)
  bool get shouldUseYSorting => stage.index >= ySortingFromStage.index;

  /// Advance crop growth by one day
  Crop advanceDay() {
    final newDays = daysPlanted + 1;
    final progress = newDays / daysToMature;

    CropStage newStage;
    if (newDays >= daysToMature) {
      newStage = CropStage.mature;
    } else if (progress >= 0.85) {
      newStage = CropStage.growing3;
    } else if (progress >= 0.70) {
      newStage = CropStage.growing2;
    } else if (progress >= 0.55) {
      newStage = CropStage.growing1;
    } else if (progress >= 0.40) {
      newStage = CropStage.youngPlant;
    } else if (progress >= 0.20) {
      newStage = CropStage.sprout;
    } else {
      newStage = CropStage.seed;
    }

    return copyWith(daysPlanted: newDays, stage: newStage);
  }

  /// Serialization (D2)
  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'name': name,
      'description': description,
      'stage': stage.toJson(),
      'daysPlanted': daysPlanted,
      'daysToMature': daysToMature,
      'yieldAmount': yieldAmount,
      'harvestItemId': harvestItemId,
      'requiredSeason': requiredSeason,
      'spritesheetPath': spritesheetPath,
      'spriteWidth': spriteWidth,
      'spriteHeight': spriteHeight,
      'spriteRowIndex': spriteRowIndex,
      'framesCount': framesCount,
      'skipFirstFrames': skipFirstFrames,
      'ySortingFromStage': ySortingFromStage.toJson(),
    };
  }

  /// Deserialization (D2)
  static Crop fromJson(Map<String, dynamic> json) {
    return Crop(
      cropId: json['cropId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      stage: CropStage.fromJson(json['stage'] as String),
      daysPlanted: json['daysPlanted'] as int,
      daysToMature: json['daysToMature'] as int,
      yieldAmount: json['yieldAmount'] as int,
      harvestItemId: json['harvestItemId'] as String,
      requiredSeason: json['requiredSeason'] as String?,
      spritesheetPath: json['spritesheetPath'] as String,
      spriteWidth: json['spriteWidth'] as int,
      spriteHeight: json['spriteHeight'] as int,
      spriteRowIndex: json['spriteRowIndex'] as int,
      framesCount: json['framesCount'] as int,
      skipFirstFrames: json['skipFirstFrames'] as int,
      ySortingFromStage: CropStage.fromJson(
        json['ySortingFromStage'] as String,
      ),
    );
  }

  /// Create a copy with modifications
  Crop copyWith({
    String? cropId,
    String? name,
    String? description,
    CropStage? stage,
    int? daysPlanted,
    int? daysToMature,
    int? yieldAmount,
    String? harvestItemId,
    String? requiredSeason,
    String? spritesheetPath,
    int? spriteWidth,
    int? spriteHeight,
    int? spriteRowIndex,
    int? framesCount,
    int? skipFirstFrames,
    CropStage? ySortingFromStage,
  }) {
    return Crop(
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      daysPlanted: daysPlanted ?? this.daysPlanted,
      daysToMature: daysToMature ?? this.daysToMature,
      yieldAmount: yieldAmount ?? this.yieldAmount,
      harvestItemId: harvestItemId ?? this.harvestItemId,
      requiredSeason: requiredSeason ?? this.requiredSeason,
      spritesheetPath: spritesheetPath ?? this.spritesheetPath,
      spriteWidth: spriteWidth ?? this.spriteWidth,
      spriteHeight: spriteHeight ?? this.spriteHeight,
      spriteRowIndex: spriteRowIndex ?? this.spriteRowIndex,
      framesCount: framesCount ?? this.framesCount,
      skipFirstFrames: skipFirstFrames ?? this.skipFirstFrames,
      ySortingFromStage: ySortingFromStage ?? this.ySortingFromStage,
    );
  }

  @override
  List<Object?> get props => [
        cropId,
        name,
        description,
        stage,
        daysPlanted,
        daysToMature,
        yieldAmount,
        harvestItemId,
        requiredSeason,
        spritesheetPath,
        spriteWidth,
        spriteHeight,
        spriteRowIndex,
        framesCount,
        skipFirstFrames,
        ySortingFromStage,
      ];

  @override
  String toString() =>
      'Crop(id: $cropId, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
