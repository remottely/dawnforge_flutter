import 'dart:developer' as developer;

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
    developer.log(
      'LoadFarmUseCase: Loading farm state',
      name: 'farm.usecases.load_farm',
    );

    try {
      // Valida versão
      final version = data['version'] as int? ?? 1;
      if (version > 1) {
        developer.log(
          'LoadFarmUseCase: Unsupported save version: $version',
          name: 'farm.usecases.load_farm',
          level: 1000, // ERROR
        );
        throw Exception('Unsupported farm save version: $version');
      }

      // Valida timestamp (opcional, para debug)
      final timestamp = data['timestamp'] as String?;
      if (timestamp != null) {
        developer.log(
          'LoadFarmUseCase: Loading save from $timestamp',
          name: 'farm.usecases.load_farm',
        );
      }

      // Extrai dados da fazenda
      final farmData = data['farm'] as Map<String, dynamic>?;
      if (farmData == null) {
        developer.log(
          'LoadFarmUseCase: No farm data found in save',
          name: 'farm.usecases.load_farm',
          level: 1000, // ERROR
        );
        throw Exception('No farm data found in save');
      }

      // Restaura estado usando o manager
      _manager.fromJson(farmData, _cropFactory.createCrop);

      final tiles = _manager.getAllTiles();
      developer.log(
        'LoadFarmUseCase: Successfully loaded farm state with ${tiles.length} tiles',
        name: 'farm.usecases.load_farm',
      );
    } catch (e, stackTrace) {
      developer.log(
        'LoadFarmUseCase: Error loading farm state: $e',
        name: 'farm.usecases.load_farm',
        level: 1000, // ERROR
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
