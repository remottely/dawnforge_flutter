import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/farm/entities/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/farm/entities/soil_state.dart';

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
    developer.log(
      'TillSoilUseCase: Attempting to till soil at ($x, $y)',
      name: 'farm.usecases.till_soil',
    );

    // Valida se as coordenadas são válidas
    if (x < 0 || y < 0) {
      developer.log(
        'TillSoilUseCase: Invalid coordinates ($x, $y)',
        name: 'farm.usecases.till_soil',
        level: 900, // WARNING
      );
      return false;
    }

    // Chama o manager para executar a ação
    final result = _tillSoil(x, y);

    if (result) {
      developer.log(
        'TillSoilUseCase: Successfully tilled soil at ($x, $y)',
        name: 'farm.usecases.till_soil',
      );
    } else {
      developer.log(
        'TillSoilUseCase: Failed to till soil at ($x, $y)',
        name: 'farm.usecases.till_soil',
        level: 900, // WARNING
      );
    }

    return result;
  }

  /// Till soil at coordinates
  bool _tillSoil(int x, int y) {
    developer.log('[FarmManager] Tilling soil at ($x, $y)');

    final existingTile = _manager.getTile(x, y);

    // Check if already tilled
    if (existingTile != null && existingTile.soilState != SoilState.untilled) {
      developer.log('[FarmManager] Soil already tilled');
      return false;
    }

    // Create or update tile
    final tile = existingTile ?? FarmTile(x: x, y: y);
    final tilledTile = tile.till();

    _manager.setTile(tilledTile);
    _manager.lastTilledNotifier.value =
        tilledTile; // J3: Cross-module notification
    _manager.notifyChange();

    developer.log('[FarmManager] ✓ Soil tilled successfully');
    return true;
  }
}
