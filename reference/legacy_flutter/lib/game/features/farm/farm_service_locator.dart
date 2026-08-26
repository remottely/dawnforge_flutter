import 'package:get_it/get_it.dart';
import 'package:dawnforge/game/systems/world/world_state_manager.dart';
import 'package:dawnforge/game/systems/game/player_state_manager.dart';
import 'package:dawnforge/game/systems/save/game_save_controller.dart';
import 'package:dawnforge/game/features/time/day_state.dart';
import 'package:dawnforge/game/features/time/time_manager.dart';

import '../inventory/usecases/add_item_use_case.dart';
import '../inventory/usecases/remove_item_use_case.dart';
import 'managers/farm_manager.dart';
import 'services/crop_factory_service.dart';
import 'usecases/harvest_crop_use_case.dart';
import 'usecases/load_farm_use_case.dart';
import 'usecases/plant_seed_use_case.dart';
import 'usecases/save_farm_use_case.dart';
import 'usecases/till_soil_use_case.dart';
import 'usecases/water_tile_use_case.dart';
import 'viewmodels/farm_view_model.dart';

final getIt = GetIt.instance;
bool _timeListenersRegistered = false;

/// Setup de dependências do módulo Farm (H1: Service Locator GetIt)
///
/// Ordem de registro:
/// 1. Services (stateless) - Inicializados e registrados como Singleton
/// 2. Managers (stateful) - Registrados como Singleton
/// 3. UseCases (stateless) - Registrados como Factory (nova instância a cada chamada)
/// 4. ViewModels - Registrados como Factory
///
Future<void> setupFarmDependencies() async {
  // ==================== Services (stateless, Singleton) ====================

  // ==================== Managers (stateful, Singleton) ====================

  _registerDayChangeListener();

  // ==================== UseCases (stateless, Factory) ====================

  // TillSoilUseCase: Arar solo
  getIt.registerFactory<TillSoilUseCase>(
    () => TillSoilUseCase(FarmManager.instance),
  );

  // PlantSeedUseCase: Plantar semente (cross-module: Inventory + Farm)
  getIt.registerFactory<PlantSeedUseCase>(
    () => PlantSeedUseCase(
      FarmManager.instance,
      getIt<RemoveItemUseCase>(),
      getIt<AddItemUseCase>(),
      CropFactoryService.instance,
    ),
  );

  // WaterTileUseCase: Regar tile
  getIt.registerFactory<WaterTileUseCase>(
    () => WaterTileUseCase(FarmManager.instance),
  );

  // HarvestCropUseCase: Colher plantação (cross-module: Farm + Inventory)
  getIt.registerFactory<HarvestCropUseCase>(
    () => HarvestCropUseCase(FarmManager.instance, getIt<AddItemUseCase>()),
  );

  // SaveFarmUseCase: Salvar estado da fazenda (E2)
  getIt.registerFactory<SaveFarmUseCase>(
    () => SaveFarmUseCase(FarmManager.instance),
  );

  // LoadFarmUseCase: Carregar estado da fazenda (E2)
  getIt.registerFactory<LoadFarmUseCase>(
    () => LoadFarmUseCase(FarmManager.instance, CropFactoryService.instance),
  );

  // ==================== ViewModels (Factory) ====================

  // FarmViewModel: ViewModel intermediário para UI (F2)
  getIt.registerFactory<FarmViewModel>(
    () => FarmViewModel(
      FarmManager.instance,
      // getIt<TillSoilUseCase>(), // TODO(Kevin): put it back? use this implementation?
      // getIt<PlantSeedUseCase>(), // TODO(Kevin): put it back? use this implementation?
      // getIt<WaterTileUseCase>(), // TODO(Kevin): put it back? use this implementation?
      // getIt<HarvestCropUseCase>(), // TODO(Kevin): put it back? use this implementation?
    ),
  );
}

void _registerDayChangeListener() {
  if (_timeListenersRegistered) return;
  _timeListenersRegistered = true;

  final time = TimeManager.instance;
  time.addDayChangeListener(_onDayChanged);
}

void _onDayChanged(DayState previous, DayState current) {
  // TODO(Kevin): verify this method
  // Keep world calendar in sync.
  WorldStateManager.instance.advanceDay();

  // Advance crops and soil hydration.
  FarmManager.instance.advanceDay();

  // Reset stamina/energy daily if available.
  PlayerStateManager.instance.lastPlayerModel?.restoreStaminaFully();

  // Persist state after any day change (auto cutoff at 2 AM or manual advance).
  // Fire and forget to avoid blocking the tick loop.
  GameSaveController.instance.saveGame();
}
