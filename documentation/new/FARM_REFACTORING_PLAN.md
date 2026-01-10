# Planejamento de Refatoração - Módulo Farm

**Data:** 28 de dezembro de 2025  
**Arquitetura Base:** A2, B1, C1, D2, E2, F2, G2, H1, I2, J3, K1, L2  
**Referência:** Baseado na refatoração bem-sucedida do módulo Inventory

---

## 📋 Análise da Estrutura Atual

### Estrutura Existente:
```
lib/gameplay/farm/
├── components/
│   └── farm_tile_view.dart
├── constants/
│   └── farm_feedback_config.dart
├── data/
│   └── farm_tile_store.dart
├── database/
│   └── crop_database.dart
├── domain/
│   └── farm_rule_engine.dart
├── handlers/
│   └── farm_input_handler.dart
├── managers/
│   └── farm_manager.dart
├── models/
│   ├── crop_model.dart
│   ├── crop_stage_model.dart
│   ├── farm_tile_model.dart
│   ├── soil_sprite_config.dart
│   └── soil_state_model.dart
└── services/
    ├── farm_action_service.dart
    ├── farm_feedback_service.dart
    └── farm_tool_action_config.dart
```

### Problemas Identificados:
1. ❌ Estrutura mista entre Domain-Driven (domain/, data/) e Feature-based
2. ❌ Models em vez de Entities (não segue D2)
3. ❌ Falta de UseCases explícitos (contraria B1)
4. ❌ Manager possivelmente sem ValueNotifier (C1)
5. ❌ Sem ViewModel para UI (F2)
6. ❌ Sem setup de GetIt para DI (H1)
7. ❌ Sem separação clara entre Save/Load (E2)

---

## 🎯 Estrutura Alvo (Arquitetura A2)

```
lib/gameplay/farm/
├── entities/                    # D2: Objetos de domínio com serialização
│   ├── farm_tile.dart          # Convertido de farm_tile_model.dart
│   ├── crop.dart               # Convertido de crop_model.dart
│   ├── crop_stage.dart         # Convertido de crop_stage_model.dart
│   └── soil_state.dart         # Convertido de soil_state_model.dart
├── usecases/                    # B1: UseCases concretos
│   ├── till_soil_use_case.dart
│   ├── plant_seed_use_case.dart
│   ├── water_tile_use_case.dart
│   ├── harvest_crop_use_case.dart
│   ├── save_farm_use_case.dart     # E2: UseCase específico
│   └── load_farm_use_case.dart     # E2: UseCase específico
├── managers/                    # C1: Singleton + ValueNotifier
│   └── farm_manager.dart       # Refatorado com ValueNotifier
├── services/                    # I2: Serviços stateless
│   ├── crop_factory_service.dart     # L2: Database JSON
│   ├── farm_feedback_service.dart
│   └── farm_tool_service.dart
├── viewmodels/                  # F2: ViewModel intermediário
│   └── farm_view_model.dart
├── widgets/                     # UI Components
│   └── farm_tile_widget.dart   # Convertido de farm_tile_view.dart
├── handlers/
│   └── farm_input_handler.dart # Mantém, mas refatorado
├── constants/                   # K1: Constantes locais
│   ├── farm_constants.dart
│   └── farm_feedback_config.dart
├── database/
│   └── crop_database.json      # L2: Database JSON
├── models/                      # Mantém apenas enums/configs simples
│   └── soil_sprite_config.dart
└── farm_service_locator.dart   # H1: GetIt setup
```

---

## 🔄 Prompts de Execução (Ordem Sequencial)

### **PROMPT 1: Criar Entities (D2)**

Com base na arquitetura D2 (Entity com Serialização), crie as entities no módulo farm seguindo o padrão usado no módulo inventory.

Analise os arquivos existentes:
- lib/gameplay/farm/models/farm_tile_model.dart
- lib/gameplay/farm/models/crop_model.dart
- lib/gameplay/farm/models/crop_stage_model.dart
- lib/gameplay/farm/models/soil_state_model.dart

Crie as novas entities em lib/gameplay/farm/entities/:

1. **farm_tile.dart** - Entity representando um tile da fazenda
   - Mover lógica de farm_tile_model.dart
   - Adicionar toJson/fromJson para serialização
   - Usar Equatable para comparações
   - Propriedades: position (x, y), soilState, crop?, isWatered, lastWateredTime

2. **crop.dart** - Entity representando uma plantação
   - Mover lógica de crop_model.dart
   - Adicionar toJson/fromJson
   - Propriedades: cropId, currentStage, plantedTime, stages (List<CropStage>)

3. **crop_stage.dart** - Entity representando um estágio de crescimento
   - Mover lógica de crop_stage_model.dart
   - Adicionar toJson/fromJson
   - Propriedades: stageName, durationInMinutes, spriteConfig

4. **soil_state.dart** - Entity representando estado do solo
   - Mover lógica de soil_state_model.dart
   - Adicionar toJson/fromJson
   - Enum ou classe com estados: untilled, tilled, watered

Certifique-se de:
- Usar imports relativos para entities
- Adicionar métodos de serialização completos
- Usar padrão similar ao inventory/entities/item.dart
- Manter lógica de negócio nas entities (ex: canPlant, needsWater, isReadyToHarvest)

---

### **PROMPT 2: Criar Services (I2, L2)**


Com base na arquitetura I2 (Manager/UseCase/Service naming) e L2 (Factory com Database JSON), crie os serviços no módulo farm.

Analise os arquivos existentes:
- lib/gameplay/farm/services/farm_action_service.dart
- lib/gameplay/farm/services/farm_feedback_service.dart
- lib/gameplay/farm/services/farm_tool_action_config.dart
- lib/gameplay/farm/database/crop_database.dart

Crie em lib/gameplay/farm/services/:

1. **crop_factory_service.dart** - Serviço stateless para criar crops (L2)
   ```dart
   class CropFactoryService {
     Map<String, dynamic> _database = {};
     
     Future<void> initialize() async {
       // Carrega assets/crops/crops_database.json
     }
     
     Crop? createCrop(String cropId) {
       // Cria crop a partir do database JSON
     }
   }
   ```

2. **farm_feedback_service.dart** - Refatorar serviço existente
   - Manter como serviço stateless
   - Remover dependências diretas de managers
   - Usar padrão I2 (receber dados como parâmetro)

3. **farm_tool_service.dart** - Renomear de farm_tool_action_config.dart
   - Transformar em serviço stateless
   - Métodos para validar se ferramenta pode ser usada
   - Exemplo: `bool canUseTool(MainHandItem tool, FarmTile tile)`

Certifique-se de:
- Services são classes NÃO-FINAL (para permitir mock com Mocktail)
- Não têm estado interno
- Recebem dependências via construtor

---

### **PROMPT 3: Refatorar Manager (C1, J3)**

Com base na arquitetura C1 (Singleton + ValueNotifier) e J3 (ValueNotifier cross-module), refatore o FarmManager.

Analise o arquivo existente:
- lib/gameplay/farm/managers/farm_manager.dart

Crie a versão refatorada em lib/gameplay/farm/managers/farm_manager.dart:

Requisitos:
1. **Estrutura Base**
   ```dart
   class FarmManager {
     FarmManager._() {
       _initializeTiles();
     }
     
     static final instance = FarmManager._();
     
     final Map<String, FarmTile> _tiles = {}; // key: "x,y"
     
     // C1: ValueNotifier para reatividade
     late final ValueNotifier<Map<String, FarmTile>> tilesNotifier;
     
     void _notifyChange() {
       tilesNotifier.value = Map.unmodifiable(_tiles);
     }
   }
   ```

2. **Métodos Core**
   - `bool tillSoil(int x, int y)` - Arar solo
   - `bool plantSeed(int x, int y, String cropId)` - Plantar semente
   - `bool waterTile(int x, int y)` - Regar tile
   - `Crop? harvestCrop(int x, int y)` - Colher plantação
   - `FarmTile? getTile(int x, int y)` - Obter tile
   - `List<FarmTile> getAllTiles()` - Obter todos os tiles

3. **Save/Load** (para uso pelos UseCases E2)
   ```dart
   Map<String, dynamic> toJson() {
     return {
       'tiles': _tiles.values.map((t) => t.toJson()).toList(),
     };
   }
   
   void fromJson(
     Map<String, dynamic> json,
     Crop? Function(String cropId) cropFactory,
   ) {
     // Restaura tiles do JSON
   }
   
   void reset() {
     _tiles.clear();
     _initializeTiles();
     _notifyChange();
   }
   ```

4. **J3: ValueNotifiers para cross-module**
   - `ValueNotifier<FarmTile?> lastTilledNotifier` - Para feedback UI
   - `ValueNotifier<Crop?> lastHarvestedNotifier` - Para inventory

Certifique-se de:
- Manager é NÃO-FINAL (para permitir mock)
- Chamar _notifyChange() após cada modificação
- Adicionar logs com developer.log
- Validações antes de modificar estado

---

### **PROMPT 4: Criar UseCases (B1)**

Com base na arquitetura B1 (UseCases Concretos), crie os casos de uso do módulo farm.

Crie em lib/gameplay/farm/usecases/:

1. **till_soil_use_case.dart**
   ```dart
   class TillSoilUseCase {
     final FarmManager _manager;
     
     TillSoilUseCase(this._manager);
     
     bool call(int x, int y) {
       // Valida condições
       // Chama manager.tillSoil
       // Retorna resultado
     }
   }
   ```

2. **plant_seed_use_case.dart**
   ```dart
   class PlantSeedUseCase {
     final FarmManager _farmManager;
     final InventoryManager _inventoryManager;
     final CropFactoryService _cropFactory;
     
     PlantSeedUseCase(this._farmManager, this._inventoryManager, this._cropFactory);
     
     bool call(int x, int y, String seedItemId) {
       // 1. Valida se tem semente no inventário
       // 2. Valida se tile pode receber planta
       // 3. Remove semente do inventário
       // 4. Planta no manager
       // 5. Retorna resultado
     }
   }
   ```

3. **water_tile_use_case.dart**
   ```dart
   class WaterTileUseCase {
     final FarmManager _manager;
     
     WaterTileUseCase(this._manager);
     
     bool call(int x, int y) {
       // Valida condições
       // Chama manager.waterTile
       // Retorna resultado
     }
   }
   ```

4. **harvest_crop_use_case.dart**
   ```dart
   class HarvestCropUseCase {
     final FarmManager _farmManager;
     final InventoryManager _inventoryManager;
     
     HarvestCropUseCase(this._farmManager, this._inventoryManager);
     
     bool call(int x, int y) {
       // 1. Valida se crop está pronto
       // 2. Colhe do manager
       // 3. Adiciona item no inventário
       // 4. Retorna resultado
     }
   }
   ```

5. **save_farm_use_case.dart** (E2)
   ```dart
   class SaveFarmUseCase {
     final FarmManager _manager;
     
     SaveFarmUseCase(this._manager);
     
     Map<String, dynamic> call() {
       return {
         'version': 1,
         'timestamp': DateTime.now().toIso8601String(),
         'farm': _manager.toJson(),
       };
     }
   }
   ```

6. **load_farm_use_case.dart** (E2)
   ```dart
   class LoadFarmUseCase {
     final FarmManager _manager;
     final CropFactoryService _cropFactory;
     
     LoadFarmUseCase(this._manager, this._cropFactory);
     
     void call(Map<String, dynamic> data) {
       final version = data['version'] as int? ?? 1;
       // Valida versão
       final farmData = data['farm'] as Map<String, dynamic>;
       _manager.fromJson(farmData, _cropFactory.createCrop);
     }
   }
   ```

Certifique-se de:
- UseCases têm método `call()`
- Recebem dependências via construtor
- Lógica de negócio fica nos UseCases, não nos Managers
- Adicionar logs para debug

---

### **PROMPT 5: Criar ViewModel (F2)**

Com base na arquitetura F2 (ViewModel intermediário), crie o ViewModel para UI do farm.

Crie em lib/gameplay/farm/viewmodels/farm_view_model.dart:

```dart
class FarmTileUI {
  final int x;
  final int y;
  final bool isTilled;
  final bool isWatered;
  final bool hasCrop;
  final String? cropSpriteKey;
  final bool isReadyToHarvest;
  
  FarmTileUI({
    required this.x,
    required this.y,
    required this.isTilled,
    required this.isWatered,
    required this.hasCrop,
    this.cropSpriteKey,
    required this.isReadyToHarvest,
  });
}

class FarmViewModel {
  final FarmManager _farmManager;
  final TillSoilUseCase _tillSoilUseCase;
  final PlantSeedUseCase _plantSeedUseCase;
  final WaterTileUseCase _waterTileUseCase;
  final HarvestCropUseCase _harvestCropUseCase;
  
  FarmViewModel(
    this._farmManager,
    this._tillSoilUseCase,
    this._plantSeedUseCase,
    this._waterTileUseCase,
    this._harvestCropUseCase,
  ) {
    _farmManager.tilesNotifier.addListener(_updateTilesUI);
    _updateTilesUI();
  }
  
  final ValueNotifier<List<FarmTileUI>> tilesUINotifier = ValueNotifier([]);
  
  void _updateTilesUI() {
    final tiles = _farmManager.getAllTiles();
    tilesUINotifier.value = tiles.map((tile) {
      return FarmTileUI(
        x: tile.x,
        y: tile.y,
        isTilled: tile.isTilled,
        isWatered: tile.isWatered,
        hasCrop: tile.crop != null,
        cropSpriteKey: tile.crop?.getCurrentSpriteKey(),
        isReadyToHarvest: tile.crop?.isReadyToHarvest() ?? false,
      );
    }).toList();
  }
  
  void onTillSoil(int x, int y) {
    _tillSoilUseCase.call(x, y);
  }
  
  void onPlantSeed(int x, int y, String seedItemId) {
    _plantSeedUseCase.call(x, y, seedItemId);
  }
  
  void onWaterTile(int x, int y) {
    _waterTileUseCase.call(x, y);
  }
  
  void onHarvestCrop(int x, int y) {
    _harvestCropUseCase.call(x, y);
  }
  
  void dispose() {
    _farmManager.tilesNotifier.removeListener(_updateTilesUI);
    tilesUINotifier.dispose();
  }
}
```

Certifique-se de:
- ViewModel transforma dados de Entity para UI
- Expõe métodos para ações da UI
- Escuta mudanças do Manager
- Implementa dispose corretamente

---

### **PROMPT 6: Setup GetIt (H1)**

Com base na arquitetura H1 (Service Locator GetIt), crie o setup de dependências do farm.

Crie em lib/gameplay/farm/farm_service_locator.dart:

```dart
import 'package:get_it/get_it.dart';

import 'managers/farm_manager.dart';
import 'services/crop_factory_service.dart';
import 'services/farm_feedback_service.dart';
import 'services/farm_tool_service.dart';
import 'usecases/till_soil_use_case.dart';
import 'usecases/plant_seed_use_case.dart';
import 'usecases/water_tile_use_case.dart';
import 'usecases/harvest_crop_use_case.dart';
import 'usecases/save_farm_use_case.dart';
import 'usecases/load_farm_use_case.dart';
import 'viewmodels/farm_view_model.dart';
import '../inventory/managers/inventory_manager.dart';

final getIt = GetIt.instance;

Future<void> setupFarmDependencies() async {
  // Services (stateless)
  final cropFactory = CropFactoryService();
  await cropFactory.initialize();
  getIt.registerSingleton<CropFactoryService>(cropFactory);
  
  getIt.registerSingleton<FarmFeedbackService>(FarmFeedbackService());
  getIt.registerSingleton<FarmToolService>(FarmToolService());
  
  // Managers (singleton com estado)
  getIt.registerSingleton<FarmManager>(FarmManager.instance);
  
  // UseCases (factories - nova instância a cada chamada)
  getIt.registerFactory<TillSoilUseCase>(
    () => TillSoilUseCase(getIt()),
  );
  
  getIt.registerFactory<PlantSeedUseCase>(
    () => PlantSeedUseCase(
      getIt<FarmManager>(),
      getIt<InventoryManager>(),
      getIt<CropFactoryService>(),
    ),
  );
  
  getIt.registerFactory<WaterTileUseCase>(
    () => WaterTileUseCase(getIt()),
  );
  
  getIt.registerFactory<HarvestCropUseCase>(
    () => HarvestCropUseCase(
      getIt<FarmManager>(),
      getIt<InventoryManager>(),
    ),
  );
  
  getIt.registerFactory<SaveFarmUseCase>(
    () => SaveFarmUseCase(getIt()),
  );
  
  getIt.registerFactory<LoadFarmUseCase>(
    () => LoadFarmUseCase(getIt(), getIt()),
  );
  
  // ViewModel
  getIt.registerFactory<FarmViewModel>(
    () => FarmViewModel(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
}
```

Certifique-se de:
- Services inicializados antes de registrar (ex: cropFactory.initialize())
- Managers registrados como Singleton
- UseCases registrados como Factory
- Ordem de registro respeita dependências

---

### **PROMPT 7: Criar Testes (G2)**

Com base na arquitetura G2 (Mocktail), crie testes unitários para os UseCases do farm.

Crie em test/gameplay/farm/:

1. **till_soil_use_case_test.dart**
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:dawnforge/gameplay/farm/managers/farm_manager.dart';
   import 'package:dawnforge/gameplay/farm/usecases/till_soil_use_case.dart';
   
   class MockFarmManager extends Mock implements FarmManager {}
   
   void main() {
     late MockFarmManager mockManager;
     late TillSoilUseCase useCase;
     
     setUp(() {
       mockManager = MockFarmManager();
       useCase = TillSoilUseCase(mockManager);
     });
     
     test('should till soil successfully', () {
       when(() => mockManager.tillSoil(any(), any())).thenReturn(true);
       
       final result = useCase.call(0, 0);
       
       expect(result, true);
       verify(() => mockManager.tillSoil(0, 0)).called(1);
     });
     
     test('should fail if tile already tilled', () {
       when(() => mockManager.tillSoil(any(), any())).thenReturn(false);
       
       final result = useCase.call(0, 0);
       
       expect(result, false);
     });
   }
   ```

2. **plant_seed_use_case_test.dart**
   - Testar com semente disponível no inventário
   - Testar sem semente no inventário
   - Testar em tile não preparado
   - Testar sucesso completo

3. **harvest_crop_use_case_test.dart**
   - Testar com crop pronto para colher
   - Testar com crop não maduro
   - Testar adição ao inventário

Certifique-se de:
- Usar Mocktail para mocks
- Registrar fallback values com registerFallbackValue se necessário
- Testar casos de sucesso e falha
- Verificar chamadas aos mocks com verify()

---

### **PROMPT 8: Atualizar Arquivos Existentes**

Atualize os arquivos existentes para usar a nova arquitetura:

1. **lib/gameplay/farm/handlers/farm_input_handler.dart**
   - Atualizar imports para usar managers/ e usecases/
   - Usar GetIt para obter UseCases
   - Exemplo:
   ```dart
   final tillUseCase = getIt<TillSoilUseCase>();
   tillUseCase.call(x, y);
   ```

2. **lib/gameplay/farm/widgets/farm_tile_widget.dart** (renomear de farm_tile_view.dart)
   - Atualizar para usar FarmViewModel
   - ValueListenableBuilder escutando tilesUINotifier
   - Chamar métodos do ViewModel para ações

3. **lib/gameplay/core/modules/save/game_state_collector.dart**
   - Adicionar import de FarmManager
   - Adicionar import de CropFactoryService
   - No método de save, chamar SaveFarmUseCase
   - No método de load, chamar LoadFarmUseCase
   - Exemplo:
   ```dart
   // Save
   final saveFarmUseCase = getIt<SaveFarmUseCase>();
   final farmData = saveFarmUseCase.call();
   
   // Load
   final loadFarmUseCase = getIt<LoadFarmUseCase>();
   loadFarmUseCase.call(farmData);
   ```

4. **lib/main.dart**
   - Adicionar chamada a setupFarmDependencies()
   ```dart
   await setupInventoryDependencies();
   await setupFarmDependencies();
   ```

Certifique-se de:
- Todos os imports atualizados
- Nenhuma referência direta aos models/ antigos
- Uso consistente de GetIt

---

### **PROMPT 9: Criar Constantes (K1)**

Com base na arquitetura K1 (Constantes locais ao módulo), crie as constantes do farm.

Crie em lib/gameplay/farm/constants/farm_constants.dart:

```dart
class FarmConstants {
  // Grid
  static const int kDefaultFarmWidth = 20;
  static const int kDefaultFarmHeight = 20;
  static const double kTileSize = 32.0;
  
  // Timing
  static const int kWaterDurationMinutes = 60; // 1 hora
  static const int kCropGrowthCheckIntervalSeconds = 10;
  
  // Limits
  static const int kMaxCropsPerPlayer = 100;
  
  // Seeds - IDs dos items de semente
  static const String kStrawberrySeedId = 'strawberry_seed_bag';
  static const String kTomatoSeedId = 'tomato_seed_bag';
  static const String kPotatoSeedId = 'potato_seed_bag';
  
  // Harvested Items - IDs dos items colhidos
  static const String kStrawberryId = 'strawberry';
  static const String kTomatoId = 'tomato';
  static const String kPotatoId = 'potato';
  
  // Tools - IDs das ferramentas
  static const String kShovelId = 'shovel';
  static const String kWateringCanId = 'wateringCan';
  static const String kHarvestBasketId = 'harvestBasket';
}
```

Mover farm_feedback_config.dart se necessário, ou refatorar para usar o padrão acima.

Certifique-se de:
- Constantes agrupadas logicamente
- Prefixo 'k' para identificar constantes
- Comentários explicativos

---

### **PROMPT 10: Validação Final**

Execute a validação final da refatoração do módulo farm:

1. **Análise de Código**
   ```bash
   flutter analyze lib/gameplay/farm/
   ```
   - Deve retornar 0 erros
   - Warnings aceitáveis: unused fields, deprecated methods

2. **Testes**
   ```bash
   flutter test test/gameplay/farm/
   ```
   - Todos os testes devem passar

3. **Checklist de Arquitetura**
   - [ ] A2: Estrutura flat com entities/, usecases/, managers/, services/, viewmodels/, widgets/, constants/
   - [ ] B1: UseCases concretos com método call()
   - [ ] C1: Manager singleton com ValueNotifier
   - [ ] D2: Entities com toJson/fromJson
   - [ ] E2: SaveFarmUseCase e LoadFarmUseCase implementados
   - [ ] F2: FarmViewModel criado e funcionando
   - [ ] G2: Testes com Mocktail
   - [ ] H1: GetIt configurado em farm_service_locator.dart
   - [ ] I2: Nomenclatura Manager/UseCase/Service consistente
   - [ ] J3: ValueNotifiers para cross-module communication
   - [ ] K1: FarmConstants criado
   - [ ] L2: CropFactoryService com database JSON

4. **Imports Verificados**
   - [ ] Nenhum import de models/ antigos
   - [ ] Todos importam de entities/
   - [ ] Managers importados de managers/
   - [ ] UseCases importados de usecases/

5. **Integração**
   - [ ] game_state_collector.dart atualizado
   - [ ] main.dart chama setupFarmDependencies()
   - [ ] farm_input_handler.dart usa GetIt
   - [ ] Widgets usam FarmViewModel

Se tudo passar, a refatoração está completa! ✅

---

## 📊 Comparação Antes/Depois

### Antes (Estrutura Mista):
```
❌ Mistura de Domain-Driven e Feature-based
❌ Models sem serialização padronizada
❌ Lógica espalhada entre manager e services
❌ Sem UseCases explícitos
❌ Sem ViewModel
❌ Sem DI configurado
```

### Depois (A2, B1, C1, D2, E2, F2, G2, H1, I2, J3, K1, L2):
```
✅ Estrutura flat clara e navegável
✅ Entities com serialização completa
✅ Lógica organizada em UseCases
✅ Manager focado em estado + ValueNotifier
✅ ViewModel separando UI da lógica
✅ GetIt configurado para DI
✅ Testes com Mocktail
✅ Save/Load em UseCases específicos
✅ Nomenclatura consistente
```

---

## 🎯 Ordem de Execução Recomendada

1. ✅ **PROMPT 1** - Criar Entities → Base para tudo
2. ✅ **PROMPT 2** - Criar Services → Dependências dos UseCases
3. ✅ **PROMPT 9** - Criar Constantes → Usado pelos Entities/Services
4. ✅ **PROMPT 3** - Refatorar Manager → Core do módulo
5. ✅ **PROMPT 4** - Criar UseCases → Lógica de negócio
6. ✅ **PROMPT 5** - Criar ViewModel → Ponte para UI
7. ✅ **PROMPT 6** - Setup GetIt → Conecta todas as peças
8. ✅ **PROMPT 7** - Criar Testes → Validação
9. ✅ **PROMPT 8** - Atualizar Existentes → Integração
10. ✅ **PROMPT 10** - Validação Final → Conclusão

---

## 📝 Notas Importantes

### Diferenças do Inventory:
- Farm tem conceito de **Grid/Tiles** (mapa 2D), Inventory tem **Slots** (lista 1D)
- Farm tem **Crops** com crescimento temporal, Inventory tem items estáticos
- Farm interage mais com **Time System** para crescimento de plantas
- Farm precisa de **cross-module** com Inventory (sementes in, colheitas out)

### Atenção Especial:
1. **CropFactoryService** deve carregar `assets/crops/crops_database.json`
2. **FarmTile** posição (x, y) deve ser chave única no Map do Manager
3. **Growth System** pode precisar de um Timer/Stream para atualizar crops
4. **Water System** expira após tempo (usar DateTime)
5. **Cross-Module**: PlantSeedUseCase remove do Inventory, HarvestCropUseCase adiciona ao Inventory

### Testes Críticos:
- Plantar semente quando não tem no inventário (deve falhar)
- Colher crop não maduro (deve falhar)
- Water expiration (deve secar após 1 hora)
- Crop growth stages (deve avançar após tempo correto)
- Save/Load preservando estado de todas as tiles

---

## ✅ Critérios de Sucesso

A refatoração será considerada bem-sucedida quando:

1. ✅ 0 erros de análise no módulo farm
2. ✅ 100% dos testes passando
3. ✅ Todos os 12 princípios da arquitetura implementados
4. ✅ Save/Load funcionando (FarmTiles persistem entre sessões)
5. ✅ UI respondendo ao FarmViewModel
6. ✅ Cross-module communication funcionando (Inventory ↔ Farm)
7. ✅ Documentação inline e logs adequados
8. ✅ Padrão replicável para próximos módulos (Combat, World, etc)

---

**Status:** 📋 PLANEJAMENTO COMPLETO  
**Próximo Passo:** Executar PROMPT 1 (Criar Entities)
