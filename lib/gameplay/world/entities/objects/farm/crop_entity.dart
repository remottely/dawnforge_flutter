import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';
import 'package:equatable/equatable.dart';

import 'crop_stage_type.dart';

/// Entity representing a planted crop in the farm (D2: Entity with Serialization)
final class CropEntity extends Equatable {
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
  final CropStageType? ySortingFromStage;
  final bool isTree;

  const CropEntity({
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
    this.isTree = false,
  });

  /// Calculate growth progress (0.0 to 1.0)
  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  /// Check if crop is fully harvestable
  bool get isMature => daysPlanted >= daysToMature;

  /// Check if crop can be harvested
  bool get canHarvest => stage.canHarvest;

  /// Check if crop is ready to harvest
  bool get isReadyToHarvest => isMature && canHarvest;

  /// Check if crop should use Y-sorting (for taller plants)
  bool get shouldUseYSorting =>
      ySortingFromStage != null && stage.index >= ySortingFromStage!.index;

  /// Advance crop growth by one day
  CropEntity advanceDay() {
    final newDays = daysPlanted + 1;
    final progress = newDays / daysToMature;
    final newStage = CropStageType.fromProgress(progress);

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
      'harvestItemId': harvestItemId.toJson(),
      'requiredSeason': requiredSeason,
      'spritesheetPath': spritesheetPath,
      'spriteWidth': spriteWidth,
      'spriteHeight': spriteHeight,
      'spriteRowIndex': spriteRowIndex,
      'framesCount': framesCount,
      'skipFirstFrames': skipFirstFrames,
      'ySortingFromStage': ySortingFromStage?.toJson(),
      'isTree': isTree,
    };
  }

  /// Deserialization (D2)
  static CropEntity fromJson(Map<String, dynamic> json) {
    return CropEntity(
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
      ySortingFromStage: CropStageType.fromJsonNullable(
        json['ySortingFromStage'] as String?,
      ),
      isTree: json['isTree'] as bool? ?? false,
    );
  }

  /// Create a copy with modifications
  CropEntity copyWith({
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
    bool? isTree,
  }) {
    return CropEntity(
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
      isTree: isTree ?? this.isTree,
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
        isTree,
      ];

  @override
  String toString() =>
      'Crop(id: $cropId, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
