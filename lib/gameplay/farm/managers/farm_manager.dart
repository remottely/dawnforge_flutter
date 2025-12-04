import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

import '../data/farm_tile_store.dart';
import '../domain/farm_rule_engine.dart';
import '../models/crop_model.dart';
import '../models/farm_tile_model.dart';

/// Gerenciador singleton do sistema de agricultura
///
/// Gerencia todos os tiles de fazenda, crescimento de crops e
/// interações do jogador (arar, regar, plantar, colher).
final class FarmManager {
  FarmManager._();

  static final instance = FarmManager._();

  final FarmTileStore _store = FarmTileStore();
  final FarmRuleEngine _rules = const FarmRuleEngine();

  /// Obter tile por coordenadas
  FarmTileModel? getTile(int x, int y) {
    return _store.getTile(x, y);
  }

  /// Definir tile
  void setTile(FarmTileModel tile) {
    _store.saveTile(tile);
  }

  /// Obter todos os tiles
  List<FarmTileModel> getAllTiles() => _store.getAllTiles();

  /// Limpar todos os tiles
  void clearAll() {
    _store.clear();
    developer.log('[FarmManager] All tiles cleared');
  }

  /// Resetar farm para estado inicial (novo jogo)
  void reset() {
    _store.clear();
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
    final tile = _rules.ensureTile(getTile(x, y), x: x, y: y);
    final updatedTile = _rules.till(tile);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);
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
    if (tile == null) {
      developer.log('[FarmManager] Cannot water missing tile');
      return false;
    }

    final updatedTile = _rules.water(tile);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);
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
    final updatedTile = _rules.plant(tile, cropId);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);

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

    final result = _rules.harvest(tile);
    if (result == null) {
      return null;
    }

    _store.saveTile(result.updatedTile);

    developer.log(
      '[FarmManager] ✓ Harvested ${result.harvestedCrop.yieldAmount}x ${result.harvestedCrop.name}',
    );
    return result.harvestedCrop;
  }

  /// Avançar 1 dia em todos os tiles
  void advanceDay() {
    developer.log('[FarmManager] Advancing all crops for new day');

    // World day has already been advanced by WorldStateManager when this
    // method is called. The day that just ended is currentDay - 1.
    final dayEnded = WorldStateManager.instance.currentDay - 1;

    var cropsGrown = 0;
    final tiles = _store.getAllTiles();
    for (final oldTile in tiles) {
      final beforeDays = oldTile.crop?.daysPlanted;
      final newTile = _rules.advanceDay(oldTile, dayEnded);
      final afterDays = newTile.crop?.daysPlanted;

      if (beforeDays != null && afterDays != null && afterDays > beforeDays) {
        cropsGrown++;
      }

      _store.saveTile(newTile);
    }

    developer.log(
      '[FarmManager] ✓ Advanced $cropsGrown crops for day $dayEnded',
    );
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() => _store.toJson();

  /// Deserialização de JSON
  void fromJson(Map<String, dynamic> json) {
    _store.fromJson(json);
  }
}
