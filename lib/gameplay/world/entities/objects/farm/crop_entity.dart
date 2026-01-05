import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:equatable/equatable.dart';

import 'crop_stage_type.dart';

/// Entity representing a planted crop in the farm (D2: Entity with Serialization)
final class CropEntity extends Equatable {
  final HandItemId id;
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
  final bool regrows;
  final int regrowStageRollback;
  final int regrowStepDays;
  final bool requireWaterForRegrowth;
  final bool isRegrowing;
  final int daysInStage;

  const CropEntity({
    required this.id,
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
    this.regrows = false,
    this.regrowStageRollback = 2,
    this.regrowStepDays = 2,
    this.requireWaterForRegrowth = true,
    this.isRegrowing = false,
    this.daysInStage = 0,
  });

  /// Calculate growth progress (0.0 to 1.0)
  double get growthProgress {
    if (daysToMature <= 0) return 1.0;
    return (daysPlanted / daysToMature).clamp(0.0, 1.0);
  }

  /// Check if crop is fully harvestable
  bool get isMature => daysPlanted >= daysToMature;

  /// Check if crop can be harvested
  bool get canHarvest => stage.canHarvest;

  /// Check if crop is ready to harvest
  bool get isReadyToHarvest => canHarvest;

  /// Check if crop should use Y-sorting (for taller plants)
  bool get shouldUseYSorting =>
      ySortingFromStage != null && stage.index >= ySortingFromStage!.index;

  /// Advance crop growth by one day (water gating ocorre em FarmObject)
  CropEntity advanceDay() {
    // Árvores sempre avançam; crops só são chamadas quando regadas
    final stepDays = isRegrowing ? regrowStepDays : _initialStageStepDays;

    var nextStage = stage;
    var nextDaysInStage = daysInStage + 1;
    var nextDaysPlanted = daysPlanted + 1;

    if (stage != CropStageType.harvestable && nextDaysInStage >= stepDays) {
      final maybeNext = stage.nextStage;
      if (maybeNext != null) {
        nextStage = maybeNext;
      }
      nextDaysInStage = 0;
    }

    return copyWith(
      stage: nextStage,
      daysPlanted: nextDaysPlanted,
      daysInStage: nextDaysInStage,
    );
  }

  int get _initialStageStepDays {
    final stagesToHarvest = CropStageType.harvestable.index;
    if (stagesToHarvest <= 0) return 1;
    final step = (daysToMature / stagesToHarvest).ceil();
    return step < 1 ? 1 : step;
  }

  /// Serialization (D2)
  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
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
      'regrows': regrows,
      'regrowStageRollback': regrowStageRollback,
      'regrowStepDays': regrowStepDays,
      'requireWaterForRegrowth': requireWaterForRegrowth,
      'isRegrowing': isRegrowing,
      'daysInStage': daysInStage,
    };
  }

  /// Deserialization (D2)
  static CropEntity fromJson(Map<String, dynamic> json) {
    return CropEntity(
      id: HandItemId.fromJson(json['id'] as String),
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
      regrows: json['regrows'] as bool? ?? false,
      regrowStageRollback: json['regrowStageRollback'] as int? ?? 2,
      regrowStepDays: json['regrowStepDays'] as int? ?? 2,
      requireWaterForRegrowth:
          json['requireWaterForRegrowth'] as bool? ?? true,
      isRegrowing: json['isRegrowing'] as bool? ?? false,
      daysInStage: json['daysInStage'] as int? ?? 0,
    );
  }

  /// Create a copy with modifications
  CropEntity copyWith({
    HandItemId? id,
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
    bool? regrows,
    int? regrowStageRollback,
    int? regrowStepDays,
    bool? requireWaterForRegrowth,
    bool? isRegrowing,
    int? daysInStage,
  }) {
    return CropEntity(
      id: id ?? this.id,
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
      regrows: regrows ?? this.regrows,
      regrowStageRollback: regrowStageRollback ?? this.regrowStageRollback,
      regrowStepDays: regrowStepDays ?? this.regrowStepDays,
      requireWaterForRegrowth:
          requireWaterForRegrowth ?? this.requireWaterForRegrowth,
      isRegrowing: isRegrowing ?? this.isRegrowing,
      daysInStage: daysInStage ?? this.daysInStage,
    );
  }

  /// Apply regrowth rollback; returns null if crop does not regrow
  CropEntity? regrowAfterHarvest() {
    if (!regrows) return null;

    final minIndex = CropStageType.sprout.index;
    final targetIndex = stage.index - regrowStageRollback;
    final newIndex = targetIndex < minIndex ? minIndex : targetIndex;
    final newStage = CropStageType.values[newIndex];

    // Reset intra-stage progress: set daysPlanted to the start of the newStage
    final stageCount = CropStageType.values.length - 1;
    final stageStartDays = ((daysToMature * newIndex) / stageCount).floor();

    return copyWith(
      stage: newStage,
      daysPlanted: stageStartDays,
      daysInStage: 0,
      isRegrowing: true,
    );
  }

  @override
  List<Object?> get props => [
        id,
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
        regrows,
        regrowStageRollback,
        regrowStepDays,
        requireWaterForRegrowth,
        isRegrowing,
        daysInStage,
      ];

  @override
  String toString() =>
      'Crop(id: $id, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
