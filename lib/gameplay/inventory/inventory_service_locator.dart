import 'package:get_it/get_it.dart';

import 'managers/inventory_manager.dart';
import 'managers/equipment_manager.dart';
import 'services/item_factory_service.dart';
import 'usecases/add_item_use_case.dart';
import 'usecases/remove_item_use_case.dart';
import 'usecases/equip_item_use_case.dart';
import 'usecases/unequip_item_use_case.dart';
import 'usecases/save_inventory_use_case.dart';
import 'usecases/load_inventory_use_case.dart';

final getIt = GetIt.instance;

void setupInventoryDependencies() {
  // Services (stateless helpers)
  getIt.registerLazySingleton<ItemFactoryService>(
    () => ItemFactoryService(),
  );

  // Managers (singleton state)
  getIt.registerSingleton<InventoryManager>(InventoryManager.instance);
  getIt.registerSingleton<EquipmentManager>(EquipmentManager.instance);

  // UseCases (operations)
  getIt.registerFactory<AddItemUseCase>(
    () => AddItemUseCase(
      getIt<InventoryManager>(),
      getIt<ItemFactoryService>(),
    ),
  );

  getIt.registerFactory<RemoveItemUseCase>(
    () => RemoveItemUseCase(getIt<InventoryManager>()),
  );

  getIt.registerFactory<EquipItemUseCase>(
    () => EquipItemUseCase(
      getIt<EquipmentManager>(),
      getIt<InventoryManager>(),
    ),
  );

  getIt.registerFactory<UnequipItemUseCase>(
    () => UnequipItemUseCase(getIt<EquipmentManager>()),
  );

  getIt.registerFactory<SaveInventoryUseCase>(
    () => SaveInventoryUseCase(
      getIt<InventoryManager>(),
      getIt<EquipmentManager>(),
    ),
  );

  getIt.registerFactory<LoadInventoryUseCase>(
    () => LoadInventoryUseCase(
      getIt<InventoryManager>(),
      getIt<EquipmentManager>(),
      getIt<ItemFactoryService>(),
    ),
  );
}
