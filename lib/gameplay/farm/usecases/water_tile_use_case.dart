import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/world/entities/objects/farm/farm_object.dart';

import '../../world/entities/objects/farm/soil_state.dart';
import '../managers/farm_manager.dart';

/// UseCase para regar um tile da fazenda.
/// 
/// Responsabilidades:
/// - Validar se a posição é válida
/// - Validar se o tile pode ser regado
/// - Chamar o manager para executar a ação
/// - Retornar resultado da operação
class WaterTileUseCase {
  final FarmManager _manager;

  WaterTileUseCase(this._manager);

  /// Executa a ação de regar o tile na posição (x, y).
  /// 
  /// Retorna `true` se a operação foi bem-sucedida, `false` caso contrário.
  bool call(int x, int y) {
    developer.log(
      'WaterTileUseCase: Attempting to water tile at ($x, $y)',
      name: 'farm.usecases.water_tile',
    );

    // Valida se as coordenadas são válidas
    if (x < 0 || y < 0) {
      developer.log(
        'WaterTileUseCase: Invalid coordinates ($x, $y)',
        name: 'farm.usecases.water_tile',
        level: 900, // WARNING
      );
      return false;
    }

    // Valida se o tile existe
    final tile = _manager.getTile(x, y);
    final farmObject = tile?.object as FarmObject?;
    
    if (tile == null || farmObject == null) {
      developer.log(
        'WaterTileUseCase: Tile at ($x, $y) does not exist',
        name: 'farm.usecases.water_tile',
        level: 900, // WARNING
      );
      return false;
    }

    // Valida se o tile está arado (pode ser regado)
    if (farmObject.soilState == SoilState.untilled) {
      developer.log(
        'WaterTileUseCase: Tile at ($x, $y) is not tilled, cannot water',
        name: 'farm.usecases.water_tile',
        level: 900, // WARNING
      );
      return false;
    }

    // Chama o manager para executar a ação
    final result = _manager.waterTile(x, y);

    if (result) {
      developer.log(
        'WaterTileUseCase: Successfully watered tile at ($x, $y)',
        name: 'farm.usecases.water_tile',
      );
    } else {
      developer.log(
        'WaterTileUseCase: Failed to water tile at ($x, $y)',
        name: 'farm.usecases.water_tile',
        level: 900, // WARNING
      );
    }

    return result;
  }
}
