import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

import '../database/crop_database.dart';
import '../models/crop_model.dart';
import '../models/farm_tile_model.dart';
import '../models/soil_state_model.dart';

/// Gerenciador singleton do sistema de agricultura
///
/// Gerencia todos os tiles de fazenda, crescimento de crops e
/// interações do jogador (arar, regar, plantar, colher).
final class FarmManager {
  FarmManager._();

  static final instance = FarmManager._();

  final Map<String, FarmTileModel> _farmTiles = {};

  /// Obter tile por coordenadas
  FarmTileModel? getTile(int x, int y) {
    return _farmTiles['${x}_$y'];
  }

  /// Definir tile
  void setTile(FarmTileModel tile) {
    _farmTiles['${tile.x}_${tile.y}'] = tile;
  }

  /// Obter todos os tiles
  List<FarmTileModel> getAllTiles() => _farmTiles.values.toList();

  /// Limpar todos os tiles
  void clearAll() {
    _farmTiles.clear();
    developer.log('[FarmManager] All tiles cleared');
  }

  /// Resetar farm para estado inicial (novo jogo)
  void reset() {
    _farmTiles.clear();
    developer.log('[FarmManager] Farm state reset');
  }

  /// Arar solo
  /// Retorna true se conseguiu arar
  bool tillSoil(int x, int y) {
    developer.log('[FarmManager] Tilling soil at ($x, $y)');

    // TODO(Kevin): Validar que player tem enxada equipada
    // if (!_playerHasTool('hoe')) {
    //   developer.log('[FarmManager] Player needs hoe');
    //   return false;
    // }

    // Obter ou criar tile
    var tile = getTile(x, y);
    if (tile == null) {
      tile = FarmTileModel(x: x, y: y);
    }

    // Validar estado
    if (tile.soilState != SoilStateModel.untilled) {
      developer.log('[FarmManager] Soil already tilled');
      return false;
    }

    // Arar
    _farmTiles['${x}_$y'] = tile.till();
    developer.log('[FarmManager] ✓ Soil tilled successfully');
    return true;
  }

  /// Regar tile
  /// Retorna true se conseguiu regar
  bool waterTile(int x, int y) {
    developer.log('[FarmManager] Watering tile at ($x, $y)');

    // TODO(Kevin): Validar que player tem regador equipado
    // if (!_playerHasTool('watering_can')) {
    //   developer.log('[FarmManager] Player needs watering can');
    //   return false;
    // }

    // Obter tile
    final tile = getTile(x, y);
    if (tile == null || tile.soilState == SoilStateModel.untilled) {
      developer.log('[FarmManager] Cannot water untilled soil');
      return false;
    }

    // Regar
    _farmTiles['${x}_$y'] = tile.water();
    developer.log('[FarmManager] ✓ Tile watered successfully');
    return true;
  }

  /// Plantar semente
  /// Retorna true se conseguiu plantar
  bool plantSeed(int x, int y, String cropId) {
    developer.log('[FarmManager] Planting $cropId at ($x, $y)');

    // TODO(Kevin): Validar que player tem seed no inventário
    // if (!InventoryManager.instance.hasItem(seedItemId, 1)) {
    //   developer.log('[FarmManager] Player does not have seed');
    //   return false;
    // }

    // TODO(Kevin): Validar estação atual
    // final currentSeason = WorldStateManager.instance.currentSeason;

    // Obter tile
    final tile = getTile(x, y);
    if (tile == null || !tile.canPlant) {
      developer.log('[FarmManager] Cannot plant on this tile');
      return false;
    }

    // Criar crop
    final crop = CropDatabase.createCrop(cropId);
    if (crop == null) {
      developer.log('[FarmManager] Invalid crop ID');
      return false;
    }

    // Plantar
    _farmTiles['${x}_$y'] = tile.plant(crop);

    // TODO(Kevin): Remover seed do inventário
    // InventoryManager.instance.removeItem(seedItemId, 1);

    developer.log('[FarmManager] ✓ Seed planted successfully');
    return true;
  }

  /// Colher crop
  /// Retorna a crop colhida ou null se não pode colher
  CropModel? harvestCrop(int x, int y) {
    developer.log('[FarmManager] Harvesting crop at ($x, $y)');

    // Obter tile
    final tile = getTile(x, y);
    if (tile == null || !tile.canHarvest) {
      developer.log('[FarmManager] Nothing to harvest');
      return null;
    }

    final crop = tile.crop!;

    // TODO(Kevin): Adicionar itens colhidos ao inventário
    // final harvestItem = ItemFactory.createItem(crop.harvestItemId);
    // if (harvestItem != null) {
    //   for (var i = 0; i < crop.yieldAmount; i++) {
    //     InventoryManager.instance.addItem(harvestItem);
    //   }
    // }

    // Limpar tile
    _farmTiles['${x}_$y'] = tile.harvest();

    developer.log(
      '[FarmManager] ✓ Harvested ${crop.yieldAmount}x ${crop.name}',
    );
    return crop;
  }

  /// Avançar 1 dia em todos os tiles
  void advanceDay() {
    developer.log('[FarmManager] Advancing all crops for new day');

    // World day has already been advanced by WorldStateManager when this
    // method is called. The day that just ended is currentDay - 1.
    final dayEnded = WorldStateManager.instance.currentDay - 1;

    var cropsGrown = 0;
    for (var entry in _farmTiles.entries) {
      final oldTile = entry.value;
      FarmTileModel newTile = oldTile;

      if (oldTile.crop != null) {
        final beforeDays = oldTile.crop!.daysPlanted;
        newTile = oldTile.advanceDay(dayEnded);
        final afterDays = newTile.crop?.daysPlanted ?? beforeDays;
        if (afterDays > beforeDays) {
          cropsGrown++;
        }
      } else {
        // No crop: if tile was watered that day, consume the water.
        if (oldTile.soilState == SoilStateModel.watered &&
            oldTile.lastWateredDay == dayEnded) {
          newTile = oldTile.copyWith(
            soilState: SoilStateModel.tilled,
            lastWateredDay: null,
          );
        }
      }

      _farmTiles[entry.key] = newTile;
    }

    developer.log(
      '[FarmManager] ✓ Advanced $cropsGrown crops for day $dayEnded',
    );
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    return {'tiles': _farmTiles.values.map((tile) => tile.toJson()).toList()};
  }

  /// Deserialização de JSON
  void fromJson(Map<String, dynamic> json) {
    _farmTiles.clear();

    final tilesData = json['tiles'] as List<dynamic>?;
    if (tilesData != null) {
      for (var tileData in tilesData) {
        final tile = FarmTileModel.fromJson(tileData as Map<String, dynamic>);
        _farmTiles['${tile.x}_${tile.y}'] = tile;
      }
    }

    developer.log('[FarmManager] Loaded ${_farmTiles.length} tiles');
  }
}
