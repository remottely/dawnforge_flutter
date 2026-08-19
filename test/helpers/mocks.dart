import 'package:dawnforge/game/features/farm/services/crop_factory_service.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/remove_item_use_case.dart';
import 'package:mocktail/mocktail.dart';

import 'test_data_builders.dart';

/// Dobras `mocktail`, para quando o teste precisa **verificar interação** ou
/// **simular falha**. Para estado real e simples, use a instância real com
/// `resetAllManagers()` — mock que só devolve valor fixo esconde mais do que
/// revela.
///
/// ⚠️ `FarmManager`, `EquipmentManager` e `ItemFactoryService` são
/// `final class` e **não podem ser mockados**. Use as instâncias reais.
/// Registrado em `documentation/refactoring/PROGRESS.md` como achado.

class MockInventoryManager extends Mock implements InventoryManager {}

class MockCropFactoryService extends Mock implements CropFactoryService {}

class MockAddItemUseCase extends Mock implements AddItemUseCase {}

class MockRemoveItemUseCase extends Mock implements RemoveItemUseCase {}

/// Registra os fallbacks exigidos pelo `mocktail` ao usar `any()` com tipos
/// não primitivos. Chame uma vez em `setUpAll()`.
void registerCommonFallbacks() {
  registerFallbackValue(HandItemId.unknown);
  registerFallbackValue(anItem());
  registerFallbackValue(aCrop());
  registerFallbackValue(aFarmTile());
  registerFallbackValue(<String, dynamic>{});
}
