import 'crop_stage_model.dart';

/// Representa uma crop plantada em um tile
final class CropModel {
  /// ID da crop (carrot, potato, etc)
  final String cropId;

  /// Nome exibido
  final String name;

  /// Descrição da crop
  final String description;

  /// Estágio atual de crescimento
  final CropStageModel stage;

  /// Dias desde plantio
  final int daysPlanted;

  /// Dias necessários para maturar
  final int daysToMature;

  /// Quantidade colhida quando madura
  final int yieldAmount;

  /// ID do item colhido
  final String harvestItemId;

  /// Estação necessária (null = qualquer estação)
  final String? requiredSeason;

  /// Sprite da crop
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

  /// Progresso de crescimento (0.0-1.0)
  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  /// Está madura?
  bool get isMature => daysPlanted >= daysToMature;

  /// Pode colher?
  bool get canHarvest => stage.canHarvest;

  /// Avançar 1 dia de crescimento
  CropModel advanceDay() {
    final newDays = daysPlanted + 1;

    // Determinar novo estágio baseado no progresso
    CropStageModel newStage;
    if (newDays >= daysToMature) {
      newStage = CropStageModel.mature;
    } else if (newDays >= (daysToMature * 0.66)) {
      newStage = CropStageModel.growing;
    } else if (newDays >= (daysToMature * 0.33)) {
      newStage = CropStageModel.sprout;
    } else {
      newStage = CropStageModel.seed;
    }

    return copyWith(daysPlanted: newDays, stage: newStage);
  }

  /// Serialização para JSON
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

  /// Deserialização de JSON
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

  /// Criar cópia com modificações
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
