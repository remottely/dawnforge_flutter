import '../../world/entities/objects/farm/crop_stage_type.dart';
import '../../inventory/entities/hand/hand_item_id.dart';

final class CropModel {
  final String cropId;
  final String name;
  final String description;
  final CropStageType stage;
  final int daysPlanted;
  final int daysToMature;
  final int yieldAmount;
  final HandItemId harvestItemId;
  final String? requiredSeason;
  final String spritesheetPath;
  final int spriteWidth;
  final int spriteHeight;
  final int spriteRowIndex;
  final int framesCount;
  final int skipFirstFrames;
  final CropStageType ySortingFromStage;

  const CropModel({
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

  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  bool get isMature => daysPlanted >= daysToMature;

  bool get canHarvest => stage.canHarvest;

  bool get shouldUseYSorting => stage.index >= ySortingFromStage.index;

  CropModel advanceDay() {
    final newDays = daysPlanted + 1;
    final progress = newDays / daysToMature;
    final newStage = CropStageType.fromProgress(progress);

    return copyWith(daysPlanted: newDays, stage: newStage);
  }

  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'name': name,
      'description': description,
      'stage': stage.toJson(),
      'daysPlanted': daysPlanted,
      'daysToMature': daysToMature,
      'yieldAmount': yieldAmount,
      'harvestItemId': harvestItemId.toJson(),
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

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      cropId: json['cropId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      stage: CropStageType.fromJson(json['stage'] as String),
      daysPlanted: json['daysPlanted'] as int,
      daysToMature: json['daysToMature'] as int,
      yieldAmount: json['yieldAmount'] as int,
      harvestItemId: HandItemId.fromJson(json['harvestItemId'] as String),
      requiredSeason: json['requiredSeason'] as String?,
      spritesheetPath: json['spritesheetPath'] as String,
      spriteWidth: json['spriteWidth'] as int,
      spriteHeight: json['spriteHeight'] as int,
      spriteRowIndex: json['spriteRowIndex'] as int,
      framesCount: json['framesCount'] as int,
      skipFirstFrames: json['skipFirstFrames'] as int,
      ySortingFromStage: CropStageType.fromJson(
        json['ySortingFromStage'] as String,
      ),
    );
  }

  CropModel copyWith({
    String? cropId,
    String? name,
    String? description,
    CropStageType? stage,
    int? daysPlanted,
    int? daysToMature,
    int? yieldAmount,
    HandItemId? harvestItemId,
    String? requiredSeason,
    String? spritesheetPath,
    int? spriteWidth,
    int? spriteHeight,
    int? spriteRowIndex,
    int? framesCount,
    int? skipFirstFrames,
    CropStageType? ySortingFromStage,
  }) {
    return CropModel(
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
  String toString() =>
      'CropModel(id: $cropId, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
