import 'package:get_it/get_it.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/time/day_state.dart';
import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;

import '../inventory/usecases/add_item_use_case.dart';
import '../inventory/usecases/remove_item_use_case.dart';
import 'managers/farm_manager.dart';
import 'services/crop_factory_service.dart';
import 'services/farm_feedback_service.dart';
import 'services/farm_tool_service.dart';
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
/// IMPORTANTE: Chamar este método após setupInventoryDependencies() em main.dart
Future<void> setupFarmDependencies() async {
  // ==================== Services (stateless, Singleton) ====================
  
  // CropFactoryService: Precisa ser inicializado antes de registrar
  // porque carrega o database JSON de crops
  final cropFactory = CropFactoryService();
  await cropFactory.initialize();
  getIt.registerSingleton<CropFactoryService>(cropFactory);
  
  // FarmFeedbackService: Feedback para UI (sons, mensagens, HUD)
  getIt.registerSingleton<FarmFeedbackService>(FarmFeedbackService());
  
  // FarmToolService: Validação de ferramentas
  getIt.registerSingleton<FarmToolService>(FarmToolService());
  
  // ==================== Managers (stateful, Singleton) ====================
  
  // FarmManager: Core do módulo, gerencia estado de todos os tiles
  getIt.registerSingleton<FarmManager>(FarmManager.instance);

  _registerDayChangeListener();
  
  // ==================== UseCases (stateless, Factory) ====================
  
  // TillSoilUseCase: Arar solo
  getIt.registerFactory<TillSoilUseCase>(
    () => TillSoilUseCase(getIt<FarmManager>()),
  );
  
  // PlantSeedUseCase: Plantar semente (cross-module: Inventory + Farm)
  getIt.registerFactory<PlantSeedUseCase>(
    () => PlantSeedUseCase(
      getIt<FarmManager>(),
      getIt<RemoveItemUseCase>(),
      getIt<AddItemUseCase>(),
      getIt<CropFactoryService>(),
    ),
  );
  
  // WaterTileUseCase: Regar tile
  getIt.registerFactory<WaterTileUseCase>(
    () => WaterTileUseCase(getIt<FarmManager>()),
  );
  
  // HarvestCropUseCase: Colher plantação (cross-module: Farm + Inventory)
  getIt.registerFactory<HarvestCropUseCase>(
    () => HarvestCropUseCase(
      getIt<FarmManager>(),
      getIt<AddItemUseCase>(),
    ),
  );
  
  // SaveFarmUseCase: Salvar estado da fazenda (E2)
  getIt.registerFactory<SaveFarmUseCase>(
    () => SaveFarmUseCase(getIt<FarmManager>()),
  );
  
  // LoadFarmUseCase: Carregar estado da fazenda (E2)
  getIt.registerFactory<LoadFarmUseCase>(
    () => LoadFarmUseCase(
      getIt<FarmManager>(),
      getIt<CropFactoryService>(),
    ),
  );
  
  // ==================== ViewModels (Factory) ====================
  
  // FarmViewModel: ViewModel intermediário para UI (F2)
  getIt.registerFactory<FarmViewModel>(
    () => FarmViewModel(
      getIt<FarmManager>(),
      getIt<TillSoilUseCase>(),
      getIt<PlantSeedUseCase>(),
      getIt<WaterTileUseCase>(),
      getIt<HarvestCropUseCase>(),
    ),
  );
}

void _registerDayChangeListener() {
  if (_timeListenersRegistered) return;
  _timeListenersRegistered = true;

  final time = new_time.TimeManager.instance;
  time.addDayChangeListener(_onDayChanged);
}

void _onDayChanged(DayState previous, DayState current) {
  // Keep world calendar in sync.
  WorldStateManager.instance.advanceDay();

  // Advance crops and soil hydration.
  getIt<FarmManager>().advanceDay();

  // Reset stamina/energy daily if available.
  PlayerStateManager.instance.lastPlayerModel?.restoreStaminaFully();

   // Persist state after any day change (auto cutoff at 2 AM or manual advance).
  // Fire and forget to avoid blocking the tick loop.
  GameSaveController.instance.saveGame();
}
