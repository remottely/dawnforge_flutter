import 'crop_stage_model.dart';

final class CropModel {
  final String cropId;
  final String name;
  final String description;
  final CropStageModel stage;
  final int daysPlanted;
  final int daysToMature;
  final int yieldAmount;
  final String harvestItemId;
  final String? requiredSeason;
  final String iconPath;

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
    required this.iconPath,
  });

  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  bool get isMature => daysPlanted >= daysToMature;

  bool get canHarvest => stage.canHarvest;

  CropModel advanceDay() {
    final newDays = daysPlanted + 1;
    final progress = newDays / daysToMature;

    CropStageModel newStage;
    if (newDays >= daysToMature) {
      newStage = CropStageModel.mature;
    } else if (progress >= 0.85) {
      newStage = CropStageModel.growing3;
    } else if (progress >= 0.70) {
      newStage = CropStageModel.growing2;
    } else if (progress >= 0.55) {
      newStage = CropStageModel.growing1;
    } else if (progress >= 0.40) {
      newStage = CropStageModel.youngPlant;
    } else if (progress >= 0.20) {
      newStage = CropStageModel.sprout;
    } else {
      newStage = CropStageModel.seed;
    }

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
      'harvestItemId': harvestItemId,
      'requiredSeason': requiredSeason,
      'iconPath': iconPath,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      cropId: json['cropId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      stage: CropStageModel.fromJson(json['stage'] as String),
      daysPlanted: json['daysPlanted'] as int,
      daysToMature: json['daysToMature'] as int,
      yieldAmount: json['yieldAmount'] as int,
      harvestItemId: json['harvestItemId'] as String,
      requiredSeason: json['requiredSeason'] as String?,
      iconPath: json['iconPath'] as String,
    );
  }

  CropModel copyWith({
    String? cropId,
    String? name,
    String? description,
    CropStageModel? stage,
    int? daysPlanted,
    int? daysToMature,
    int? yieldAmount,
    String? harvestItemId,
    String? requiredSeason,
    String? iconPath,
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
      iconPath: iconPath ?? this.iconPath,
    );
  }

  @override
  String toString() =>
      'CropModel(id: $cropId, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
