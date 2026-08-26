import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/features/world/entities/objects/farm/farm_object.dart';

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
    GameLogger.info('WaterTileUseCase: Attempting to water tile at ($x, $y)');

    // Valida se as coordenadas são válidas
    if (x < 0 || y < 0) {
      GameLogger.warning('WaterTileUseCase: Invalid coordinates ($x, $y)');
      return false;
    }

    // Valida se o tile existe
    final tile = _manager.getTile(x, y);
    final farmObject = tile?.object as FarmObject?;

    if (tile == null || farmObject == null) {
      GameLogger.warning('WaterTileUseCase: Tile at ($x, $y) does not exist');
      return false;
    }

    // Valida se o tile está arado (pode ser regado)
    if (farmObject.soilState == SoilState.untilled) {
      GameLogger.warning(
        'WaterTileUseCase: Tile at ($x, $y) is not tilled, cannot water',
      );
      return false;
    }

    // Chama o manager para executar a ação
    final result = _manager.waterTile(x, y);

    if (result) {
      GameLogger.info(
        'WaterTileUseCase: Successfully watered tile at ($x, $y)',
      );
    } else {
      GameLogger.warning('WaterTileUseCase: Failed to water tile at ($x, $y)');
    }

    return result;
  }
}
