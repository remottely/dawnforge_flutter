import 'package:dawnforge/core/utils/logger/game_logger.dart';

import '../managers/farm_manager.dart';
import '../services/crop_factory_service.dart';

/// UseCase para carregar o estado da fazenda (padrão E2).
///
/// Responsabilidades:
/// - Validar versão dos dados salvos
/// - Usar CropFactoryService para resolver Crops
/// - Restaurar estado no FarmManager
class LoadFarmUseCase {
  final FarmManager _manager;
  final CropFactoryService _cropFactory;

  LoadFarmUseCase(this._manager, this._cropFactory);

  /// Executa a operação de carregar o estado da fazenda.
  ///
  /// [data] deve conter os dados salvos previamente pelo SaveFarmUseCase.
  void call(Map<String, dynamic> data) {
    GameLogger.info('LoadFarmUseCase: Loading farm state');

    try {
      // Valida versão
      final version = data['version'] as int? ?? 1;
      if (version > 1) {
        GameLogger.error('LoadFarmUseCase: Unsupported save version: $version');
        throw Exception('Unsupported farm save version: $version');
      }

      // Valida timestamp (opcional, para debug)
      final timestamp = data['timestamp'] as String?;
      if (timestamp != null) {
        GameLogger.info('LoadFarmUseCase: Loading save from $timestamp');
      }

      // Extrai dados da fazenda
      final farmData = data['farm'] as Map<String, dynamic>?;
      if (farmData == null) {
        GameLogger.error('LoadFarmUseCase: No farm data found in save');
        throw Exception('No farm data found in save');
      }

      // Restaura estado usando o manager
      _manager.fromJson(
        farmData,
        // , _cropFactory.createCrop
      );

      final tiles = _manager.getAllTiles();
      GameLogger.info(
        'LoadFarmUseCase: Successfully loaded farm state with ${tiles.length} tiles',
      );
    } catch (e, stackTrace) {
      GameLogger.error(
        'LoadFarmUseCase: Error loading farm state: $e\n$stackTrace',
      );
      rethrow;
    }
  }
}
