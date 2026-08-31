import 'package:get_it/get_it.dart';

import '../managers/inventory_manager.dart';
import '../managers/equipment_manager.dart';
import '../services/item_factory_service.dart';
import '../usecases/add_item_use_case.dart';
import '../usecases/remove_item_use_case.dart';
import '../usecases/equip_item_use_case.dart';
import '../usecases/save_inventory_use_case.dart';
import '../usecases/load_inventory_use_case.dart';

final getIt = GetIt.instance;

Future<void> setupInventoryDependencies() async {
  // Services (stateless helpers) - Initialize first!
  // Managers (singleton state)

  // UseCases (operations)
  getIt.registerFactory<AddItemUseCase>(
    () =>
        AddItemUseCase(InventoryManager.instance, ItemFactoryService.instance),
  );

  getIt.registerFactory<RemoveItemUseCase>(
    () => RemoveItemUseCase(InventoryManager.instance),
  );

  getIt.registerFactory<EquipItemUseCase>(
    () =>
        EquipItemUseCase(EquipmentManager.instance, InventoryManager.instance),
  );

  getIt.registerFactory<SaveInventoryUseCase>(
    () => SaveInventoryUseCase(
      InventoryManager.instance,
      EquipmentManager.instance,
    ),
  );

  getIt.registerFactory<LoadInventoryUseCase>(
    () => LoadInventoryUseCase(
      getIt<AddItemUseCase>(),
      InventoryManager.instance,
      EquipmentManager.instance,
      ItemFactoryService.instance,
    ),
  );
}
