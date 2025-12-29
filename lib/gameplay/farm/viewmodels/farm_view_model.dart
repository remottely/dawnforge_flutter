import 'package:darkness_dungeon/gameplay/world/entities/objects/farm/farm_object.dart';
import 'package:flutter/foundation.dart';

import '../../world/entities/objects/farm/soil_state.dart';
import '../managers/farm_manager.dart';
import '../usecases/harvest_crop_use_case.dart';
import '../usecases/plant_seed_use_case.dart';
import '../usecases/till_soil_use_case.dart';
import '../usecases/water_tile_use_case.dart';

/// DTO (Data Transfer Object) for UI representation of a farm tile (F2: ViewModel pattern)
class FarmTileUI {
  final int x;
  final int y;
  final bool isTilled;
  final bool isWatered;
  final bool hasCrop;
  final String? cropName;
  final String? cropSpriteKey;
  final bool isReadyToHarvest;

  FarmTileUI({
    required this.x,
    required this.y,
    required this.isTilled,
    required this.isWatered,
    required this.hasCrop,
    this.cropName,
    this.cropSpriteKey,
    required this.isReadyToHarvest,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmTileUI &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          isTilled == other.isTilled &&
          isWatered == other.isWatered &&
          hasCrop == other.hasCrop &&
          cropName == other.cropName &&
          cropSpriteKey == other.cropSpriteKey &&
          isReadyToHarvest == other.isReadyToHarvest;

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      isTilled.hashCode ^
      isWatered.hashCode ^
      hasCrop.hashCode ^
      cropName.hashCode ^
      cropSpriteKey.hashCode ^
      isReadyToHarvest.hashCode;

  @override
  String toString() {
    return 'FarmTileUI(x: $x, y: $y, tilled: $isTilled, watered: $isWatered, '
        'crop: ${cropName ?? "none"}, ready: $isReadyToHarvest)';
  }
}

/// ViewModel intermediário para UI do farm (F2: ViewModel pattern)
/// 
/// Responsabilidades:
/// - Transformar dados de Entity (FarmTile, Crop) para UI (FarmTileUI)
/// - Expor métodos para ações da UI (onTillSoil, onPlantSeed, etc.)
/// - Escutar mudanças do FarmManager e propagar para UI
/// - Gerenciar ciclo de vida (dispose)
class FarmViewModel {
  final FarmManager _farmManager;
  final TillSoilUseCase _tillSoilUseCase;
  final PlantSeedUseCase _plantSeedUseCase;
  final WaterTileUseCase _waterTileUseCase;
  final HarvestCropUseCase _harvestCropUseCase;

  FarmViewModel(
    this._farmManager,
    this._tillSoilUseCase,
    this._plantSeedUseCase,
    this._waterTileUseCase,
    this._harvestCropUseCase,
  ) {
    // Escuta mudanças no manager e atualiza UI
    _farmManager.tilesNotifier.addListener(_updateTilesUI);
    _updateTilesUI();
  }

  /// ValueNotifier exposto para a UI escutar mudanças
  final ValueNotifier<List<FarmTileUI>> tilesUINotifier = ValueNotifier([]);

  /// Transforma entities (FarmTile) em DTOs para UI (FarmTileUI)
  void _updateTilesUI() {
    final tiles = _farmManager.getAllTiles();
    tilesUINotifier.value = tiles.map((tile) {
      final farmObject = tile.object as FarmObject?;
      return FarmTileUI(
        x: tile.x,
        y: tile.y,
        isTilled: farmObject?.soilState == SoilState.tilled ||
            farmObject?.soilState == SoilState.watered ||
            farmObject?.soilState == SoilState.fertilized,
        isWatered: farmObject?.soilState == SoilState.watered,
        hasCrop: farmObject?.crop != null,
        cropName: farmObject?.crop?.name,
        cropSpriteKey: _getCropSpriteKey(farmObject?.crop?.cropId),
        isReadyToHarvest: farmObject?.isReadyToHarvest ?? false,
      );
    }).toList();
  }

  /// Helper para obter sprite key do crop (pode ser estendido no futuro)
  String? _getCropSpriteKey(String? cropId) {
    if (cropId == null) return null;
    // Retorna o cropId como key por enquanto
    // No futuro pode ser mapeado para sprite paths específicos
    return cropId;
  }

  // ==================== Métodos de Ação para UI ====================

  /// Executa ação de arar solo na posição (x, y)
  void onTillSoil(int x, int y) {
    _tillSoilUseCase.call(x, y);
    // O manager notifica mudanças via ValueNotifier
  }

  /// Executa ação de plantar semente na posição (x, y)
  void onPlantSeed(int x, int y, String seedItemId) {
    _plantSeedUseCase.call(x, y, seedItemId);
    // O manager notifica mudanças via ValueNotifier
  }

  /// Executa ação de regar tile na posição (x, y)
  void onWaterTile(int x, int y) {
    _waterTileUseCase.call(x, y);
    // O manager notifica mudanças via ValueNotifier
  }

  /// Executa ação de colher plantação na posição (x, y)
  void onHarvestCrop(int x, int y) {
    _harvestCropUseCase.call(x, y);
    // O manager notifica mudanças via ValueNotifier
  }

  // ==================== Métodos de Query para UI ====================

  /// Obtém tile UI específico por posição
  FarmTileUI? getTileUI(int x, int y) {
    try {
      return tilesUINotifier.value.firstWhere(
        (tile) => tile.x == x && tile.y == y,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém todas as tiles UI
  List<FarmTileUI> getAllTilesUI() {
    return List.unmodifiable(tilesUINotifier.value);
  }

  /// Obtém tiles UI filtradas por condição
  List<FarmTileUI> getTilesUIWhere(bool Function(FarmTileUI) predicate) {
    return tilesUINotifier.value.where(predicate).toList();
  }

  // ==================== Lifecycle ====================

  /// Libera recursos (remover listeners, dispose notifiers)
  void dispose() {
    _farmManager.tilesNotifier.removeListener(_updateTilesUI);
    tilesUINotifier.dispose();
  }
}
