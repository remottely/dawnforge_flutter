import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/features/game_world/world/entities/objects/farm/farm_object.dart';

import '../../inventory/usecases/add_item_use_case.dart';
import '../../inventory/usecases/remove_item_use_case.dart';
import '../../inventory/entities/enums/hand_item_id.dart';
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
    GameLogger.info(
      'PlantSeedUseCase: Attempting to plant seed "${seedItemId.name}" at ($x, $y)',
    );

    // 1. Valida se tem semente no inventário tentando remover
    // (se não tiver, remove falhará)
    final removed = _removeItemUseCase.call(seedItemId, 1);
    if (!removed) {
      GameLogger.warning(
        'PlantSeedUseCase: Player does not have seed "$seedItemId" in inventory',
      );
      return false;
    }

    // 2. Valida se o tile existe e pode receber planta
    final tile = _farmManager.getTile(x, y);
    final farmObject = tile?.object as FarmObject?;

    if (tile == null || farmObject == null) {
      GameLogger.warning('PlantSeedUseCase: Tile at ($x, $y) does not exist');
      return false;
    }

    // Extrai o cropId do seedItemId (remove "_seed" ou "_seed_bag" sufixo)
    final cropId = _extractCropIdFromSeedId(seedItemId);

    // 3. Cria a crop usando o factory
    final crop = _cropFactory.createCrop(cropId);
    if (crop == null) {
      GameLogger.error(
        'PlantSeedUseCase: Failed to create crop from id "$cropId"',
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
      GameLogger.warning(
        'PlantSeedUseCase: Tile at ($x, $y) cannot be planted for ${crop.isTree ? "trees (needs untilled)" : "crops (needs tilled/watered)"}',
      );
      // Tenta devolver a semente ao inventário
      _addItemUseCase.call(seedItemId, 1);
      return false;
    }

    // 4. Planta no manager
    final planted = _farmManager.plantSeed(x, y, crop);
    if (!planted) {
      GameLogger.error('PlantSeedUseCase: Failed to plant crop at ($x, $y)');
      // Tenta devolver a semente ao inventário
      _addItemUseCase.call(seedItemId, 1);
      return false;
    }

    GameLogger.info(
      'PlantSeedUseCase: Successfully planted "${cropId.name}" at ($x, $y)',
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
