import 'crop_stage.dart';

/// Representa uma crop plantada em um tile
final class Crop {
  /// ID da crop (carrot, potato, etc)
  final String cropId;

  /// Nome exibido
  final String name;

  /// Descrição da crop
  final String description;

  /// Estágio atual de crescimento
  final CropStage stage;

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
    required this.iconPath,
  });

  /// Progresso de crescimento (0.0-1.0)
  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  /// Está madura?
  bool get isMature => daysPlanted >= daysToMature;

  /// Pode colher?
  bool get canHarvest => stage.canHarvest;

  /// Avançar 1 dia de crescimento
  Crop advanceDay() {
    final newDays = daysPlanted + 1;

    // Determinar novo estágio baseado no progresso
    CropStage newStage;
    if (newDays >= daysToMature) {
      newStage = CropStage.mature;
    } else if (newDays >= (daysToMature * 0.66)) {
      newStage = CropStage.growing;
    } else if (newDays >= (daysToMature * 0.33)) {
      newStage = CropStage.sprout;
    } else {
      newStage = CropStage.seed;
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
  factory Crop.fromJson(Map<String, dynamic> json) {
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
      iconPath: json['iconPath'] as String,
    );
  }

  /// Criar cópia com modificações
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
    String? iconPath,
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
      iconPath: iconPath ?? this.iconPath,
    );
  }

  @override
  String toString() =>
      'Crop(id: $cropId, name: $name, stage: $stage, days: $daysPlanted/$daysToMature)';
}
