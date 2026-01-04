import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/world/entities/objects/farm/farm_object.dart';
import 'package:darkness_dungeon/gameplay/world/entities/objects/farm/soil_state.dart';

import '../../inventory/usecases/add_item_use_case.dart';
import '../../inventory/usecases/remove_item_use_case.dart';
import '../../inventory/entities/hand_item_id.dart';
import '../managers/farm_manager.dart';
import '../services/crop_factory_service.dart';

/// UseCase para plantar uma semente em um tile da fazenda.
/// 
/// Responsabilidades:
/// - Validar se o jogador tem a semente no inventário
/// - Validar se o tile pode receber a planta
/// - Remover a semente do inventário
/// - Criar a crop a partir do factory
/// - Plantar no manager
class PlantSeedUseCase {
  final FarmManager _farmManager;
  final RemoveItemUseCase _removeItemUseCase;
  final AddItemUseCase _addItemUseCase;
  final CropFactoryService _cropFactory;

  PlantSeedUseCase(
    this._farmManager,
    this._removeItemUseCase,
    this._addItemUseCase,
    this._cropFactory,
  );

  /// Executa a ação de plantar uma semente na posição (x, y).
  /// 
  /// [seedItemId] é o ID do item semente no inventário.
  /// 
  /// Retorna `true` se a operação foi bem-sucedida, `false` caso contrário.
  bool call(int x, int y, HandItemId seedItemId) {
    developer.log(
      'PlantSeedUseCase: Attempting to plant seed "${seedItemId.name}" at ($x, $y)',
      name: 'farm.usecases.plant_seed',
    );

    // 1. Valida se tem semente no inventário tentando remover
    // (se não tiver, remove falhará)
    final removed = _removeItemUseCase.call(seedItemId, 1);
    if (!removed) {
      developer.log(
        'PlantSeedUseCase: Player does not have seed "$seedItemId" in inventory',
        name: 'farm.usecases.plant_seed',
        level: 900, // WARNING
      );
      return false;
    }

    // 2. Valida se o tile existe e pode receber planta
    final tile = _farmManager.getTile(x, y);
    final farmObject = tile?.object as FarmObject?;
    
    if (tile == null || farmObject == null) {
      developer.log(
        'PlantSeedUseCase: Tile at ($x, $y) does not exist',
        name: 'farm.usecases.plant_seed',
        level: 900, // WARNING
      );
      return false;
    }

    // Extrai o cropId do seedItemId (remove "_seed" ou "_seed_bag" sufixo)
    final cropId = _extractCropIdFromSeedId(seedItemId);

    // 3. Cria a crop usando o factory
    final crop = _cropFactory.createCrop(cropId.name);
    if (crop == null) {
      developer.log(
        'PlantSeedUseCase: Failed to create crop from id "$cropId"',
        name: 'farm.usecases.plant_seed',
        level: 1000, // ERROR
      );
      // Devolver a semente ao inventário
      _addItemUseCase.call(seedItemId, 1);
      return false;
    }

    // 3.1 Valida regra de plantio: árvores só em soil untilled; demais seguem regra padrão
    final bool canPlantHere = crop.isTree
      ? farmObject.canPlantTree
      : farmObject.canPlantCrop;

    if (!canPlantHere) {
      developer.log(
        'PlantSeedUseCase: Tile at ($x, $y) cannot be planted for ${crop.isTree ? "trees (needs untilled)" : "crops (needs tilled/watered)"}',
        name: 'farm.usecases.plant_seed',
        level: 900, // WARNING
      );
      // Tenta devolver a semente ao inventário
      _addItemUseCase.call(seedItemId, 1);
      return false;
    }

    // 4. Planta no manager
    final planted = _farmManager.plantSeed(x, y, crop);
    if (!planted) {
      developer.log(
        'PlantSeedUseCase: Failed to plant crop at ($x, $y)',
        name: 'farm.usecases.plant_seed',
        level: 1000, // ERROR
      );
      // Tenta devolver a semente ao inventário
      _addItemUseCase.call(seedItemId, 1);
      return false;
    }

    developer.log(
      'PlantSeedUseCase: Successfully planted "${cropId.name}" at ($x, $y)',
      name: 'farm.usecases.plant_seed',
    );

    return true;
  }

  /// Extrai o cropId a partir do seedItemId.
  /// 
  /// Exemplos:
  /// - "strawberry_seed_bag" -> "strawberry"
  /// - "tomato_seed" -> "tomato"
  /// - "potato_seed_bag" -> "potato"
  HandItemId _extractCropIdFromSeedId(HandItemId seedItemId) {
    var cropIdName = seedItemId.name;

    if (cropIdName.endsWith('_seed_bag')) {
      cropIdName = cropIdName.replaceAll('_seed_bag', '');
    } else if (cropIdName.endsWith('_seed')) {
      cropIdName = cropIdName.replaceAll('_seed', '');
    }

    return HandItemId.fromString(cropIdName);
  }
}
