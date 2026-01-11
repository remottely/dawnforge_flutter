
import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:dawnforge/gameplay/world/entities/world_entities.dart';

import '../managers/farm_manager.dart';

/// UseCase para arar o solo de um tile da fazenda.
///
/// Responsabilidades:
/// - Validar se a posição é válida
/// - Chamar o manager para executar a ação
/// - Retornar resultado da operação
class TillSoilUseCase {
  final FarmManager _manager;

  TillSoilUseCase(this._manager);

  /// Executa a ação de arar o solo na posição (x, y).
  ///
  /// Retorna `true` se a operação foi bem-sucedida, `false` caso contrário.
  bool call(int x, int y) {
    GameLogger.info('TillSoilUseCase: Attempting to till soil at ($x, $y)');

    // Valida se as coordenadas são válidas
    if (x < 0 || y < 0) {
      GameLogger.warning('TillSoilUseCase: Invalid coordinates ($x, $y)');
      return false;
    }

    // Chama o manager para executar a ação
    final result = _tillSoil(x, y);

    if (result) {
      GameLogger.info('TillSoilUseCase: Successfully tilled soil at ($x, $y)');
    } else {
      GameLogger.warning('TillSoilUseCase: Failed to till soil at ($x, $y)');
    }

    return result;
  }

  /// Till soil at coordinates
  bool _tillSoil(int x, int y) {
    GameLogger.info('[FarmManager] Tilling soil at ($x, $y)');

    final existingTile = _manager.getTile(x, y);
    final existingFarmObject = existingTile?.object as FarmObject?;

    // Check if already tilled
    if (existingFarmObject != null && existingFarmObject.soilState != SoilState.untilled) {
      GameLogger.warning('[FarmManager] Soil already tilled');
      return false;
    }

    // Create or update tile
    final farmObject = existingFarmObject ?? FarmObject(objectId: 'farm_${x}_$y');
    final tilledFarmObject = farmObject.till();
    final tilledTile = existingTile?.placeObject(tilledFarmObject) ?? 
        GridTile(x: x, y: y, object: tilledFarmObject);

    _manager.setTile(tilledTile);
    _manager.lastTilledNotifier.value =
        tilledTile; // J3: Cross-module notification
    _manager.notifyChange();

    GameLogger.info('[FarmManager] ✓ Soil tilled successfully');
    return true;
  }
}
