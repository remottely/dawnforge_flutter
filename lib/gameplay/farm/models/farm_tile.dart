import 'crop.dart';
import 'soil_state.dart';

/// Representa um tile individual de fazenda
final class FarmTile {
  /// Coordenada X no mapa
  final int x;

  /// Coordenada Y no mapa
  final int y;

  /// Estado do solo
  final SoilState soilState;

  /// Crop plantada (null = vazio)
  final Crop? crop;

  /// Última vez que foi regado
  final DateTime? lastWatered;

  const FarmTile({
    required this.x,
    required this.y,
    this.soilState = SoilState.untilled,
    this.crop,
    this.lastWatered,
  });

  /// Tile está vazio?
  bool get isEmpty => crop == null;

  /// Tile está ocupado?
  bool get isOccupied => crop != null;

  /// Pode plantar?
  bool get canPlant => isEmpty && soilState == SoilState.tilled;

  /// Pode colher?
  bool get canHarvest => isOccupied && crop!.canHarvest;

  /// Precisa regar?
  bool get needsWatering {
    if (lastWatered == null) return soilState == SoilState.tilled;
    final hoursSinceWatered = DateTime.now().difference(lastWatered!).inHours;
    return hoursSinceWatered >= 24;
  }

  /// Arar tile
  FarmTile till() {
    return copyWith(soilState: SoilState.tilled);
  }

  /// Regar tile
  FarmTile water() {
    return copyWith(soilState: SoilState.watered, lastWatered: DateTime.now());
  }

  /// Plantar crop
  FarmTile plant(Crop crop) {
    if (!canPlant) return this;
    return copyWith(crop: crop);
  }

  /// Colher crop
  FarmTile harvest() {
    if (!canHarvest) return this;
    return FarmTile(
      x: x,
      y: y,
      soilState: SoilState.untilled, // Volta ao estado inicial
      crop: null, // Remove crop
      lastWatered: null, // Remove informação de rega
    );
  }

  /// Avançar 1 dia
  FarmTile advanceDay() {
    if (crop == null) return this;

    // Aplicar multiplicador de velocidade do solo
    final speedMultiplier = soilState.growthSpeedMultiplier;
    if (speedMultiplier <= 0) return this;

    return copyWith(crop: crop!.advanceDay());
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'soilState': soilState.toJson(),
      'crop': crop?.toJson(),
      'lastWatered': lastWatered?.toIso8601String(),
    };
  }

  /// Deserialização de JSON
  factory FarmTile.fromJson(Map<String, dynamic> json) {
    return FarmTile(
      x: json['x'] as int,
      y: json['y'] as int,
      soilState: SoilState.fromJson(json['soilState'] as String),
      crop: json['crop'] != null
          ? Crop.fromJson(json['crop'] as Map<String, dynamic>)
          : null,
      lastWatered: json['lastWatered'] != null
          ? DateTime.parse(json['lastWatered'] as String)
          : null,
    );
  }

  /// Criar cópia com modificações
  FarmTile copyWith({
    int? x,
    int? y,
    SoilState? soilState,
    Crop? crop,
    DateTime? lastWatered,
  }) {
    return FarmTile(
      x: x ?? this.x,
      y: y ?? this.y,
      soilState: soilState ?? this.soilState,
      crop: crop ?? this.crop,
      lastWatered: lastWatered ?? this.lastWatered,
    );
  }

  @override
  String toString() =>
      'FarmTile(x: $x, y: $y, soil: $soilState, crop: ${crop?.name ?? "empty"})';
}
