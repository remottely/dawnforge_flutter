import 'package:dawnforge/game/features/farm/managers/farm_manager.dart';
import 'package:dawnforge/game/features/farm/services/crop_factory_service.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/systems/world/world_state_manager.dart';

/// Bootstrap e reset dos singletons do jogo para testes.
///
/// Os managers são singletons de processo: sem reset explícito, o estado de um
/// teste vaza para o seguinte e a ordem de execução passa a importar.
///
/// Uso padrão:
/// ```dart
/// setUp(resetAllManagers);
/// ```

/// Alguns notifiers são `late final` e só podem ser inicializados **uma vez**
/// por processo — reinicializar lançaria `LateInitializationError`.
bool _isBootstrapped = false;

/// Inicializa os singletons na mesma ordem do `main.dart`.
///
/// Idempotente: chamadas subsequentes são no-op. Não requer binding do Flutter
/// porque os catálogos são constantes Dart, não assets (ver ADR-0002).
Future<void> bootstrapTestEnvironment() async {
  if (_isBootstrapped) return;
  _isBootstrapped = true;

  await CropFactoryService.instance.initialize();
  await ItemFactoryService.instance.initialize();

  // Ordem obrigatória: EquipmentManager escuta o notifier do InventoryManager.
  InventoryManager.instance.initializeSlots();
  FarmManager.instance.initializeTiles();
  EquipmentManager.instance.initialize();
}

/// Devolve todos os managers ao estado inicial. Chame no `setUp()`.
Future<void> resetAllManagers() async {
  await bootstrapTestEnvironment();

  InventoryManager.instance.reset();
  EquipmentManager.instance.reset();
  FarmManager.instance.reset();
  WorldStateManager.instance.reset();
}
