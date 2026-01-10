# Refatoração do Módulo Inventory - Guia de Migração

Este documento detalha as mudanças realizadas na refatoração do módulo inventory e o guia para atualizar o código existente.

## 🏗️ Nova Estrutura de Arquitetura

### Decisões Arquiteturais Implementadas

Baseado nas seleções: **A2, B1, C1, D2, E2, F2, G2, H1, I2, J3, K1, L2**

| Tópico | Escolha | Implementação |
|--------|---------|---------------|
| **A - Estrutura** | A2 - Flat por Responsabilidade | `entities/`, `usecases/`, `managers/`, `services/`, `viewmodels/`, `widgets/`, `models/`, `constants/` |
| **B - UseCases** | B1 - Concretos (KISS) | Classes concretas sem interface base genérica |
| **C - Estado** | C1 - Singleton + ValueNotifier | Managers singleton com ValueNotifier para reatividade |
| **D - Dados** | D2 - Entity com Serialização | Entities com `toJson()`/`fromJson()` integrado |
| **E - Save/Load** | E2 - UseCase Específico | `SaveInventoryUseCase` e `LoadInventoryUseCase` |
| **F - UI** | F2 - ViewModel Intermediário | `InventoryViewModel` transforma dados para UI |
| **G - Testes** | G2 - Mocktail | Mocks automáticos com Mocktail |
| **H - DI** | H1 - GetIt Service Locator | `inventory_service_locator.dart` com GetIt |
| **I - Naming** | I2 - Manager/UseCase/Service | Manager=estado, UseCase=operação, Service=stateless |
| **J - Eventos** | J3 - ValueNotifier cross-module | ValueNotifiers para comunicação entre módulos |
| **K - Constantes** | K1 - Locais ao módulo | `constants/inventory_constants.dart` |
| **L - Factory** | L2 - Database JSON | `ItemFactoryService` lê de `items_database.json` |

---

## 📁 Nova Estrutura de Pastas

```
lib/gameplay/inventory/
├── entities/                      # Objetos de negócio puros com serialização (D2)
│   ├── item.dart                  # Base class Item
│   ├── main_hand_item.dart        # MainHandItem entity
│   ├── inventory_slot.dart        # InventorySlot entity
│   └── equipment_slot.dart        # EquipmentSlot entity
│
├── usecases/                      # Casos de uso concretos (B1)
│   ├── add_item_use_case.dart
│   ├── remove_item_use_case.dart
│   ├── equip_item_use_case.dart
│   ├── unequip_item_use_case.dart
│   ├── save_inventory_use_case.dart
│   └── load_inventory_use_case.dart
│
├── managers/                      # Singletons de estado (C1, I2)
│   ├── inventory_manager.dart
│   └── equipment_manager.dart
│
├── services/                      # Serviços stateless (I2, L2)
│   └── item_factory_service.dart  # Cria items do JSON database
│
├── viewmodels/                    # ViewModels para UI (F2)
│   └── inventory_view_model.dart
│
├── widgets/                       # Componentes UI
│   ├── inventory_overlay.dart
│   ├── equipment_overlay.dart
│   └── ... (outros widgets)
│
├── models/                        # Modelos auxiliares (enums, DTOs)
│   ├── item_type.dart
│   ├── item_rarity.dart
│   ├── equipped_hand_type.dart
│   └── ...
│
├── constants/                     # Constantes locais (K1)
│   └── inventory_constants.dart
│
├── database/                      # Database helpers
│   └── item_icon_database.dart
│
├── items/                         # Implementações específicas de Item
│   ├── consumable_item.dart
│   ├── crop_item.dart
│   ├── material_item.dart
│   ├── seed_item.dart
│   └── tool_item.dart
│
└── inventory_service_locator.dart # GetIt setup (H1)
```

---

## 🔄 Mudanças de Import

### ANTES (old structure):
```dart
import 'package:dawnforge/gameplay/inventory/entities/item.dart';
import 'package:dawnforge/gameplay/inventory/models/inventory_slot.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/gameplay/inventory/item_factory.dart';
```

### DEPOIS (new structure):
```dart
// Entities
import 'package:dawnforge/gameplay/inventory/entities/item.dart';
import 'package:dawnforge/gameplay/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/gameplay/inventory/entities/equipment_slot.dart';

// Managers
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';

// Services
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';

// UseCases
import 'package:dawnforge/gameplay/inventory/usecases/add_item_use_case.dart';

// ViewModels (para widgets)
import 'package:dawnforge/gameplay/inventory/viewmodels/inventory_view_model.dart';

// Service Locator
import 'package:dawnforge/gameplay/inventory/inventory_service_locator.dart';
```

---

## 🚀 Inicialização do Sistema (H1 - GetIt)

### No `main.dart` (ou no setup da sua app):

```dart
import 'package:dawnforge/gameplay/inventory/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup dependencies ANTES de inicializar o service
  setupInventoryDependencies();

  // 2. Inicializar o ItemFactoryService (carrega JSON database)
  await getIt<ItemFactoryService>().initialize();

  // 3. Run app
  runApp(MyApp());
}
```

---

## 📝 Como Usar os UseCases (B1)

### Adicionar Item ao Inventário

**ANTES:**
```dart
final item = ItemFactory.createItem('sword');
if (item != null) {
  InventoryManager.instance.addItem(item, 1);
}
```

**DEPOIS (com UseCase):**
```dart
import 'package:get_it/get_it.dart';
import 'package:dawnforge/gameplay/inventory/usecases/add_item_use_case.dart';

final addItemUseCase = GetIt.instance<AddItemUseCase>();
final success = addItemUseCase('sword', 1);
```

### Equipar Item

**ANTES:**
```dart
EquipmentManager.instance.selectSlotIndex(slotIndex);
```

**DEPOIS (com UseCase):**
```dart
final equipUseCase = GetIt.instance<EquipItemUseCase>();
equipUseCase.selectSlotIndex(slotIndex);
```

### Salvar/Carregar Inventário

**ANTES:**
```dart
// Lógica de save espalhada no código
```

**DEPOIS (com UseCase - E2):**
```dart
// Salvar
final saveUseCase = GetIt.instance<SaveInventoryUseCase>();
final saveData = saveUseCase();
await sharedPreferences.setString('inventory', jsonEncode(saveData));

// Carregar
final loadUseCase = GetIt.instance<LoadInventoryUseCase>();
final saveDataJson = jsonDecode(await sharedPreferences.getString('inventory'));
loadUseCase(saveDataJson);
```

---

## 🎨 Como Usar ViewModel na UI (F2)

### Widget com ViewModel (Recomendado):

```dart
import 'package:get_it/get_it.dart';
import 'package:dawnforge/gameplay/inventory/viewmodels/inventory_view_model.dart';

class InventoryOverlay extends StatefulWidget {
  @override
  _InventoryOverlayState createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay> {
  late final InventoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // Criar ViewModel com dependências injetadas
    _viewModel = InventoryViewModel(
      inventoryManager: GetIt.instance(),
      equipmentManager: GetIt.instance(),
      addItemUseCase: GetIt.instance(),
      removeItemUseCase: GetIt.instance(),
      equipItemUseCase: GetIt.instance(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _viewModel.slotsUI,
      builder: (context, slotsUI, _) {
        return GridView.builder(
          itemCount: slotsUI.length,
          itemBuilder: (context, index) {
            final slotUI = slotsUI[index];
            return GestureDetector(
              onTap: () => _viewModel.onSlotTapped(slotUI.index),
              child: Container(
                color: slotUI.isSelected ? Colors.red : Colors.grey,
                child: slotUI.isEmpty
                    ? Icon(Icons.inventory)
                    : Text(slotUI.item!.name),
              ),
            );
          },
        );
      },
    );
  }
}
```

### Widget Direto com Manager (Alternativa):

```dart
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';

class InventoryOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: InventoryManager.instance.slotsNotifier,
      builder: (context, slots, _) {
        return GridView.builder(
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return Container(
              child: slot.isEmpty
                  ? Icon(Icons.inventory)
                  : Text(slot.item!.name),
            );
          },
        );
      },
    );
  }
}
```

---

## 🧪 Como Escrever Testes (G2 - Mocktail)

### Exemplo de Teste de UseCase:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';
import 'package:dawnforge/gameplay/inventory/usecases/add_item_use_case.dart';

class MockInventoryManager extends Mock implements InventoryManager {}
class MockItemFactoryService extends Mock implements ItemFactoryService {}

void main() {
  group('AddItemUseCase', () {
    late MockInventoryManager mockInventoryManager;
    late MockItemFactoryService mockItemFactory;
    late AddItemUseCase addItemUseCase;

    setUp(() {
      mockInventoryManager = MockInventoryManager();
      mockItemFactory = MockItemFactoryService();
      addItemUseCase = AddItemUseCase(mockInventoryManager, mockItemFactory);
    });

    test('should add item successfully', () {
      // Arrange
      const itemId = 'sword';
      when(() => mockItemFactory.createItem(itemId)).thenReturn(mockItem);
      when(() => mockInventoryManager.addItem(mockItem, 1)).thenReturn(true);

      // Act
      final result = addItemUseCase(itemId, 1);

      // Assert
      expect(result, true);
      verify(() => mockItemFactory.createItem(itemId)).called(1);
      verify(() => mockInventoryManager.addItem(mockItem, 1)).called(1);
    });
  });
}
```

---

## ⚠️ Breaking Changes e Como Resolver

### 1. **ItemFactory.createItem() → ItemFactoryService**

**Erro:**
```
Error: Method not found: 'ItemFactory.createItem'
```

**Solução:**
```dart
// ANTES
final item = ItemFactory.createItem('sword');

// DEPOIS
final itemFactory = GetIt.instance<ItemFactoryService>();
final item = itemFactory.createItem('sword');
```

### 2. **Import de Item mudou de models/ para entities/**

**Erro:**
```
Error: Not found: 'package:dawnforge/gameplay/inventory/models/item.dart'
```

**Solução:**
```dart
// ANTES
import 'package:dawnforge/gameplay/inventory/entities/item.dart';

// DEPOIS
import 'package:dawnforge/gameplay/inventory/entities/item.dart';
```

### 3. **InventoryManager/EquipmentManager mudaram para managers/**

**Erro:**
```
Error: Not found: 'package:dawnforge/gameplay/inventory/inventory_manager.dart'
```

**Solução:**
```dart
// ANTES
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';

// DEPOIS
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
```

### 4. **Lógica de negócio dispersa → UseCase**

**Problema:** Código que manipula inventário diretamente espalhado por toda a app

**Solução:** Centralizar em UseCases:
```dart
// ANTES (lógica espalhada)
final item = ItemFactory.createItem('sword');
if (item != null && InventoryManager.instance.addItem(item, 1)) {
  // faz algo
}

// DEPOIS (UseCase centralizado, testável)
final addItemUseCase = GetIt.instance<AddItemUseCase>();
if (addItemUseCase('sword', 1)) {
  // faz algo
}
```

---

## 🔄 Comunicação Entre Módulos (J3 - ValueNotifier)

### Exemplo: Farm Module observando Inventory

```dart
// No farm module:
class FarmManager {
  void initialize() {
    // Ouvir mudanças no inventário
    InventoryManager.instance.slotsNotifier.addListener(_onInventoryChanged);
  }

  void _onInventoryChanged() {
    // Reagir a mudanças no inventário
    print('Inventário mudou!');
  }

  void dispose() {
    InventoryManager.instance.slotsNotifier.removeListener(_onInventoryChanged);
  }
}
```

---

## 📊 Benefícios da Nova Arquitetura

### ✅ Testabilidade (G2)
- UseCases isolados e facilmente testáveis com mocks
- Dependências injetáveis via GetIt
- Exemplo: `add_item_use_case_test.dart`

### ✅ Separação de Responsabilidades (I2)
- **Manager:** Estado global (InventoryManager, EquipmentManager)
- **UseCase:** Operações de negócio (AddItemUseCase, EquipItemUseCase)
- **Service:** Helpers stateless (ItemFactoryService)
- **ViewModel:** Transformação para UI (InventoryViewModel)

### ✅ Replicabilidade
Esta estrutura pode ser replicada para outros módulos:
- `lib/gameplay/farm/` com mesmos patterns (entities, usecases, managers...)
- `lib/gameplay/world/` com mesmos patterns
- `lib/gameplay/combat/` com mesmos patterns

### ✅ Manutenibilidade
- Estrutura flat e intuitiva (A2)
- Constantes localizadas (K1)
- Código organizado por responsabilidade

---

## 🎯 Próximos Passos Recomendados

### Imediato (essencial):
1. ✅ Adicionar `setupInventoryDependencies()` no `main.dart`
2. ✅ Atualizar todos os imports de `models/item.dart` → `entities/item.dart`
3. ✅ Atualizar todos os imports de managers para `managers/`
4. ⏳ Substituir chamadas diretas a `ItemFactory` por `ItemFactoryService` via GetIt

### Curto Prazo:
5. ⏳ Migrar lógica de save/load para usar `SaveInventoryUseCase` e `LoadInventoryUseCase`
6. ⏳ Criar ViewModels para outros overlays (EquipmentOverlay, etc)
7. ⏳ Expandir testes unitários para cobrir mais UseCases

### Longo Prazo:
8. ⏳ Replicar estrutura para módulo `farm/`
9. ⏳ Replicar estrutura para módulo `world/`
10. ⏳ Documentar padrão de arquitetura em `ARCHITECTURE.md` global

---

## 🆘 Troubleshooting

### Erro: "GetIt: Object/factory with type X is not registered"

**Causa:** Esqueceu de chamar `setupInventoryDependencies()` antes de usar GetIt

**Solução:**
```dart
void main() async {
  setupInventoryDependencies(); // <-- Adicionar isso
  await getIt<ItemFactoryService>().initialize();
  runApp(MyApp());
}
```

### Erro: "ItemFactoryService is not initialized"

**Causa:** Tentou usar ItemFactoryService antes de chamar `.initialize()`

**Solução:**
```dart
await getIt<ItemFactoryService>().initialize(); // <-- Adicionar isso antes de usar
```

### Erro: Imports não encontrados

**Causa:** Estrutura de pastas mudou

**Solução:** Use o mapeamento de imports da seção "🔄 Mudanças de Import" acima

---

## 📚 Referências

- **GetIt:** https://pub.dev/packages/get_it
- **Mocktail:** https://pub.dev/packages/mocktail
- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **KISS Principle:** https://en.wikipedia.org/wiki/KISS_principle

---

**Versão:** 1.0  
**Data:** 28 de Dezembro de 2025  
**Autor:** GitHub Copilot  
**Status:** ✅ Implementação Completa - Aguardando Migração dos Imports
