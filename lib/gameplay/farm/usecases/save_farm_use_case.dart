import 'dart:developer' as developer;

import '../managers/farm_manager.dart';

/// UseCase para salvar o estado da fazenda (padrão E2).
/// 
/// Responsabilidades:
/// - Coletar dados do FarmManager
/// - Adicionar metadados (versão, timestamp)
/// - Retornar dados em formato serializável
class SaveFarmUseCase {
  final FarmManager _manager;

  SaveFarmUseCase(this._manager);

  /// Executa a operação de salvar o estado da fazenda.
  /// 
  /// Retorna um Map com todos os dados necessários para restaurar o estado.
  Map<String, dynamic> call() {
    developer.log(
      'SaveFarmUseCase: Saving farm state',
      name: 'farm.usecases.save_farm',
    );

    final farmData = _manager.toJson();
    final tilesCount = (farmData['tiles'] as List?)?.length ?? 0;

    final saveData = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'farm': farmData,
    };

    developer.log(
      'SaveFarmUseCase: Successfully saved farm state with $tilesCount tiles',
      name: 'farm.usecases.save_farm',
    );

    return saveData;
  }
}
