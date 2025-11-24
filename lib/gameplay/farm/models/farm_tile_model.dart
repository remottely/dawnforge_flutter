import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

import 'crop_model.dart';
import 'soil_state_model.dart';

/// Representa um tile individual de fazenda
final class FarmTileModel {
  /// Coordenada X no mapa
  final int x;

  /// Coordenada Y no mapa
  final int y;

  /// Estado do solo
  final SoilStateModel soilState;

  /// Crop plantada (null = vazio)
  final CropModel? crop;

  /// Última vez que foi regado
  /// Último dia do mundo em que foi regado (WorldStateManager.currentDay)
  final int? lastWateredDay;

  const FarmTileModel({
    required this.x,
    required this.y,
    this.soilState = SoilStateModel.untilled,
    this.crop,
    this.lastWateredDay,
  });

  /// Tile está vazio?
  bool get isEmpty => crop == null;

  /// Tile está ocupado?
  bool get isOccupied => crop != null;

  /// Pode plantar?
  bool get canPlant =>
      isEmpty &&
      (soilState == SoilStateModel.tilled ||
          soilState == SoilStateModel.watered);

  /// Pode colher?
  bool get canHarvest => isOccupied && crop!.canHarvest;

  /// Precisa regar?
  bool get needsWatering {
    final currentDay = WorldStateManager.instance.currentDay;
    if (lastWateredDay == null) return soilState == SoilStateModel.tilled;
    return lastWateredDay != currentDay;
  }

  /// Arar tile
  FarmTileModel till() {
    return copyWith(soilState: SoilStateModel.tilled);
  }

  /// Regar tile
  FarmTileModel water() {
    return copyWith(
      soilState: SoilStateModel.watered,
      lastWateredDay: WorldStateManager.instance.currentDay,
    );
  }

  /// Plantar crop
  FarmTileModel plant(CropModel crop) {
    if (!canPlant) return this;
    return copyWith(crop: crop);
  }

  /// Colher crop
  FarmTileModel harvest() {
    if (!canHarvest) return this;
    return FarmTileModel(
      x: x,
      y: y,
      soilState: SoilStateModel.untilled, // Volta ao estado inicial
      crop: null, // Remove crop
      lastWateredDay: null, // Remove informação de rega
    );
  }

  /// Avançar 1 dia
  /// [dayEnded] é o número do dia do jogo que acabou (por exemplo, se o jogo
  /// avançou de 5 para 6, dayEnded = 5). Cresce apenas se o tile foi regado
  /// naquele dia; a água é então consumida (lastWateredDay é limpo).
  FarmTileModel advanceDay(int dayEnded) {
    if (crop == null) return this;

    final wasWateredThatDay =
        lastWateredDay != null && lastWateredDay == dayEnded;

    if (!wasWateredThatDay) {
      // Não foi regado no dia que terminou: sem crescimento
      return this;
    }

    // Cresce 1 dia e consome a água aplicada naquele dia.
    final advancedCrop = crop!.advanceDay();

    final nextSoilState = soilState == SoilStateModel.watered
        ? SoilStateModel.tilled
        : soilState;

    return copyWith(
      crop: advancedCrop,
      soilState: nextSoilState,
      lastWateredDay: null,
    );
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'soilState': soilState.toJson(),
      'crop': crop?.toJson(),
      'lastWateredDay': lastWateredDay,
    };
  }

  /// Deserialização de JSON
  factory FarmTileModel.fromJson(Map<String, dynamic> json) {
    return FarmTileModel(
      x: json['x'] as int,
      y: json['y'] as int,
      soilState: SoilStateModel.fromJson(json['soilState'] as String),
      crop: json['crop'] != null
          ? CropModel.fromJson(json['crop'] as Map<String, dynamic>)
          : null,
      lastWateredDay: json['lastWateredDay'] as int?,
    );
  }

  /// Criar cópia com modificações
  FarmTileModel copyWith({
    int? x,
    int? y,
    SoilStateModel? soilState,
    CropModel? crop,
    int? lastWateredDay,
  }) {
    return FarmTileModel(
      x: x ?? this.x,
      y: y ?? this.y,
      soilState: soilState ?? this.soilState,
      crop: crop ?? this.crop,
      lastWateredDay: lastWateredDay ?? this.lastWateredDay,
    );
  }

  @override
  String toString() =>
      'FarmTile(x: $x, y: $y, soil: $soilState, crop: ${crop?.name ?? "empty"})';
}
