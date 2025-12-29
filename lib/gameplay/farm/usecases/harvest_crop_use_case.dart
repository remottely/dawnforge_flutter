import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/world/entities/objects/farm/farm_object.dart';

import '../../inventory/usecases/add_item_use_case.dart';
import '../managers/farm_manager.dart';

/// UseCase para colher uma plantação de um tile da fazenda.
/// 
/// Responsabilidades:
/// - Validar se o crop está pronto para colher
/// - Colher do manager
/// - Adicionar item colhido ao inventário
/// - Retornar resultado da operação
class HarvestCropUseCase {
  final FarmManager _farmManager;
  final AddItemUseCase _addItemUseCase;

  HarvestCropUseCase(
    this._farmManager,
    this._addItemUseCase,
  );

  /// Executa a ação de colher a plantação na posição (x, y).
  /// 
  /// Retorna `true` se a operação foi bem-sucedida, `false` caso contrário.
  bool call(int x, int y) {
    developer.log(
      'HarvestCropUseCase: Attempting to harvest crop at ($x, $y)',
      name: 'farm.usecases.harvest_crop',
    );

    // 1. Valida se o crop existe e está pronto
    final tile = _farmManager.getTile(x, y);
    final farmObject = tile?.object as FarmObject?;
    
    if (tile == null || farmObject == null) {
      developer.log(
        'HarvestCropUseCase: Tile at ($x, $y) does not exist',
        name: 'farm.usecases.harvest_crop',
        level: 900, // WARNING
      );
      return false;
    }

    if (!farmObject.canHarvest) {
      developer.log(
        'HarvestCropUseCase: Tile at ($x, $y) has no crop or crop is not ready to harvest',
        name: 'farm.usecases.harvest_crop',
        level: 900, // WARNING
      );
      return false;
    }

    final crop = farmObject.crop;
    if (crop == null) {
      developer.log(
        'HarvestCropUseCase: No crop found at ($x, $y)',
        name: 'farm.usecases.harvest_crop',
        level: 1000, // ERROR
      );
      return false;
    }

    // Guarda o harvestItemId antes de colher
    final harvestItemId = crop.harvestItemId;
    final harvestQuantity = crop.yieldAmount;

    developer.log(
      'HarvestCropUseCase: Crop "${crop.cropId}" will yield $harvestQuantity x "$harvestItemId"',
      name: 'farm.usecases.harvest_crop',
    );

    // 2. Colhe do manager
    final harvestedCrop = _farmManager.harvestCrop(x, y);
    if (harvestedCrop == null) {
      developer.log(
        'HarvestCropUseCase: Failed to harvest crop at ($x, $y)',
        name: 'farm.usecases.harvest_crop',
        level: 1000, // ERROR
      );
      return false;
    }

    // 3. Adiciona item ao inventário
    final added = _addItemUseCase.call(
      harvestItemId,
      harvestQuantity,
    );

    if (!added) {
      developer.log(
        'HarvestCropUseCase: Failed to add item "$harvestItemId" to inventory',
        name: 'farm.usecases.harvest_crop',
        level: 1000, // ERROR
      );
      // Nota: O crop já foi removido do tile, então não há como reverter completamente.
      // Em um sistema mais robusto, poderíamos ter uma transação ou compensação.
      return false;
    }

    developer.log(
      'HarvestCropUseCase: Successfully harvested "${harvestedCrop.cropId}" at ($x, $y)',
      name: 'farm.usecases.harvest_crop',
    );

    return true;
  }
}
