# Planejamento de Arquitetura - Módulo Inventory (e padrão para outros módulos)

Este documento apresenta opções modulares de arquitetura para refatoração do sistema de inventário, com foco em replicabilidade para outros módulos (farm, world, etc) em um jogo estilo Stardew Valley.

---

## Tópico A: Estrutura de Pastas e Camadas

### Opção A1: Estrutura por Feature + Camada (Híbrido)
```
lib/gameplay/inventory/
  ├── domain/
  │   ├── entities/          # Objetos de negócio puros
  │   └── usecases/          # Casos de uso isolados
  ├── data/
  │   ├── models/            # Modelos de dados (JSON, Save)
  │   └── services/          # Serviços específicos (item_factory, price_calculator)
  ├── presentation/
  │   ├── widgets/           # Overlays e componentes UI
  │   └── state/             # ValueNotifiers e estado reativo
  └── core/
      ├── managers/          # Singletons de coordenação
      └── constants/         # Constantes do módulo
```
**Prós:** Separação clara entre lógica de negócio (domain), dados (data) e apresentação. Facilita testes unitários isolando domínio. Padrão familiar para devs mobile.
**Contras:** Mais pastas, pode parecer over-engineering para módulos simples.

### Opção A2: Estrutura Flat por Responsabilidade (Game-First)
```
lib/gameplay/inventory/
  ├── entities/              # Item, Slot, Equipment (objetos puros)
  ├── usecases/              # add_item_use_case, equip_item_use_case, etc
  ├── managers/              # inventory_manager, equipment_manager (singleton state)
  ├── services/              # item_factory, item_price_service
  ├── models/                # item_save_data, inventory_save_data
  ├── widgets/               # inventory_overlay, equipment_overlay
  └── constants/             # inventory_constants
```
**Prós:** Estrutura plana e direta, fácil navegação. Menos hierarquia = menos boilerplate. Mais intuitivo para gamedev.
**Contras:** Menos separação formal entre camadas, pode misturar conceitos conforme cresce.

### Opção A3: Estrutura por Tipo de Objeto (Domain-Driven)
```
lib/gameplay/inventory/
  ├── items/                 # Tudo relacionado a items
  │   ├── entities/
  │   ├── usecases/
  │   ├── services/
  │   └── models/
  ├── equipment/             # Tudo relacionado a equipamento
  │   ├── entities/
  │   ├── usecases/
  │   ├── managers/
  │   └── widgets/
  ├── storage/               # Tudo relacionado a armazenamento
  │   ├── entities/
  │   ├── usecases/
  │   └── managers/
  └── shared/                # Modelos compartilhados
```
**Prós:** Alta coesão por domínio, cada sub-módulo é independente. Facilita trabalho em equipe (diferentes devs em diferentes domínios).
**Contras:** Duplicação de estrutura, pode ser verbose demais para módulos pequenos. Dificulta visão global.

---

## Tópico B: UseCases - Interface ou Concreto?

### Opção B1: UseCases Concretos (KISS)
```dart
class AddItemToInventoryUseCase {
  final InventoryManager _manager;
  final ItemFactory _factory;
  
  AddItemToInventoryUseCase(this._manager, this._factory);
  
  bool call(String itemId, int quantity) {
    final item = _factory.createItem(itemId);
    return _manager.addItem(item, quantity);
  }
}
```
**Prós:** Simples, direto, sem interfaces desnecessárias. Menos arquivos. Fácil de testar com mocks simples.
**Contras:** Menos flexível para trocar implementações (mas você disse que não é prioridade).

### Opção B2: UseCases com Interface Base (Padrão)
```dart
abstract class UseCase<Input, Output> {
  Output call(Input input);
}

class AddItemToInventoryUseCase implements UseCase<AddItemInput, bool> {
  // implementação
}
```
**Prós:** Padrão unificado para todos os casos de uso. Facilita pipelines genéricos (logging, error handling). Melhor para documentação.
**Contras:** Mais boilerplate, pode ser overkill para operações simples.

### Opção B3: UseCases como Funções/Static Methods
```dart
class InventoryUseCases {
  static bool addItem(InventoryManager manager, String itemId, int qty) {
    // lógica
  }
  
  static bool removeItem(InventoryManager manager, String itemId, int qty) {
    // lógica
  }
}
```
**Prós:** Zero boilerplate, extremamente simples. Bom para operações stateless.
**Contras:** Dificulta injeção de dependências, testabilidade menor, não é orientado a objetos.

---

## Tópico C: Gestão de Estado

### Opção C1: Manager Singleton + ValueNotifier (Atual Aprimorado)
```dart
class InventoryManager {
  static final instance = InventoryManager._();
  
  final ValueNotifier<List<InventorySlot>> slotsNotifier = ValueNotifier([]);
  
  bool addItem(Item item) {
    // lógica
    slotsNotifier.value = [..._slots]; // notifica listeners
  }
}
```
**Prós:** Simples, reativo, funciona bem com Flutter. Estado global acessível de qualquer lugar. Perfeito para jogos single-player.
**Contras:** Singleton pode dificultar testes isolados. Estado global pode causar side effects.

### Opção C2: Manager como Serviço Injetável + Streams
```dart
class InventoryManager {
  final _slotsController = StreamController<List<InventorySlot>>.broadcast();
  Stream<List<InventorySlot>> get slotsStream => _slotsController.stream;
  
  bool addItem(Item item) {
    // lógica
    _slotsController.add(_slots);
  }
}
```
**Prós:** Mais testável (instância injetada). Streams são mais poderosas que ValueNotifiers. Permite múltiplas instâncias.
**Contras:** Mais complexo, precisa gerenciar lifecycle dos streams. Overhead para casos simples.

### Opção C3: Event Bus + Immutable State
```dart
class InventoryState {
  final List<InventorySlot> slots;
  InventoryState copyWith({List<InventorySlot>? slots}) => ...;
}

class InventoryManager {
  InventoryState _state;
  final eventBus = EventBus();
  
  void addItem(Item item) {
    _state = _state.copyWith(slots: [...]);
    eventBus.fire(InventoryChangedEvent(_state));
  }
}
```
**Prós:** Estado imutável = mais seguro. Desacoplamento total entre produtor e consumidor. Facilita debug (event log).
**Contras:** Mais complexo, requer biblioteca de event bus. Pode ser overkill para jogos simples.

---

## Tópico D: Modelos de Dados (Entities vs Models)

### Opção D1: Entity Pura + Model para Persistência (Clean Architecture Clássico)
```dart
// Entity (domain layer)
class Item {
  final String id;
  final String name;
  // sem toJson/fromJson
}

// Model (data layer)
class ItemModel {
  final String id;
  final String name;
  
  ItemModel.fromEntity(Item entity) : id = entity.id, name = entity.name;
  Item toEntity() => Item(id: id, name: name);
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory ItemModel.fromJson(Map<String, dynamic> json) => ...;
}
```
**Prós:** Separação total entre domínio e dados. Entity pura e testável. Model lida com serialização.
**Contras:** Duplicação de código (duas classes para um conceito). Conversões constantes entre entity/model.

### Opção D2: Entity com Serialização (Pragmático)
```dart
class Item {
  final String id;
  final String name;
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Item.fromJson(Map<String, dynamic> json) => Item(id: json['id'], name: json['name']);
}
```
**Prós:** Simples, direto, menos código. Entity serve para tudo (domínio + persistência).
**Contras:** Mistura responsabilidades (domínio + serialização). Menos puro em termos de Clean Architecture.

### Opção D3: Entity + SaveData Separado (Híbrido Game-Focused)
```dart
class Item {
  final String id;
  final String name;
  // lógica de domínio pura
}

class ItemSaveData {
  final String id;
  Map<String, dynamic> toJson() => {'id': id};
  static Item toItem(ItemSaveData data, ItemFactory factory) => factory.create(data.id);
}
```
**Prós:** Entity limpa, SaveData focado em persistência mínima. Útil quando save é diferente do modelo completo (comum em jogos).
**Contras:** Três conceitos (Entity, SaveData, Factory) para um objeto. Pode confundir.

---

## Tópico E: Persistência e Save/Load

### Opção E1: Manager Centralizado com toJson/fromJson
```dart
class InventoryManager {
  Map<String, dynamic> toJson() {
    return {
      'slots': _slots.map((s) => s.toJson()).toList(),
      'maxSlots': _maxSlots,
    };
  }
  
  void fromJson(Map<String, dynamic> json) {
    // restaura estado
  }
}
```
**Prós:** Simples, cada manager sabe como se salvar. Centralizado.
**Contras:** Manager acumula responsabilidades. Dificulta versionamento de save.

### Opção E2: UseCase de Save/Load Específico
```dart
class SaveInventoryUseCase {
  final InventoryManager manager;
  
  Map<String, dynamic> call() {
    return {
      'version': 1,
      'slots': manager.slots.map((s) => s.toJson()).toList(),
    };
  }
}

class LoadInventoryUseCase {
  final InventoryManager manager;
  final ItemFactory factory;
  
  void call(Map<String, dynamic> data) {
    // valida versão, restaura
  }
}
```
**Prós:** Responsabilidade única. Facilita versionamento e migrações. Manager não precisa saber sobre serialização.
**Contras:** Mais arquivos, pode parecer overkill.

### Opção E3: Serializer Service
```dart
class InventorySerializer {
  Map<String, dynamic> serialize(InventoryManager manager) { ... }
  void deserialize(Map<String, dynamic> data, InventoryManager manager) { ... }
}
```
**Prós:** Separação clara, fácil de testar serialização isoladamente. Útil se múltiplos formatos (JSON, binary).
**Contras:** Mais uma camada, precisa acessar internals do manager.

---

## Tópico F: Comunicação UI/Game World (Overlays)

### Opção F1: ValueNotifier Direto (Atual)
```dart
class InventoryOverlay extends StatelessWidget {
  Widget build(context) {
    return ValueListenableBuilder(
      valueListenable: InventoryManager.instance.slotsNotifier,
      builder: (context, slots, _) => ...,
    );
  }
}
```
**Prós:** Simples, direto, sem intermediários. Flutter-native.
**Contras:** Acoplamento UI -> Manager. Dificulta trocar implementação.

### Opção F2: ViewModel/Controller Intermediário
```dart
class InventoryViewModel {
  final InventoryManager _manager;
  
  ValueNotifier<List<InventorySlotUI>> get slotsUI => ...;
  
  void onSlotTapped(int index) {
    // chama use case
  }
}
```
**Prós:** Separação UI/Lógica. ViewModel pode transformar dados para UI. Testável isoladamente.
**Contras:** Mais boilerplate. Pode ser overkill para UIs simples.

### Opção F3: Bloc/Cubit Pattern
```dart
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final AddItemUseCase addItemUseCase;
  
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    if (event is AddItemEvent) {
      await addItemUseCase.call(...);
      yield InventoryLoadedState(...);
    }
  }
}
```
**Prós:** Padrão robusto, testável, eventos claros. Bom para UIs complexas com múltiplas fontes de evento.
**Contras:** Muito boilerplate, pode ser overkill para jogos. Curva de aprendizado.

---

## Tópico G: Testabilidade

### Opção G1: Mocks Manuais com Interfaces
```dart
abstract class IInventoryManager {
  bool addItem(Item item);
}

class InventoryManager implements IInventoryManager { ... }

// No teste:
class MockInventoryManager implements IInventoryManager {
  @override
  bool addItem(Item item) => true;
}
```
**Prós:** Controle total sobre mocks. Não depende de bibliotecas.
**Contras:** Mais código, precisa manter mocks atualizados.

### Opção G2: Mockito/Mocktail
```dart
class MockInventoryManager extends Mock implements InventoryManager {}

test('should add item', () {
  final mock = MockInventoryManager();
  when(() => mock.addItem(any())).thenReturn(true);
  // teste
});
```
**Prós:** Menos código, geração automática de mocks. Padrão da comunidade Flutter.
**Contras:** Dependência externa, pode ser confuso para iniciantes.

### Opção G3: Testes de Integração sem Mocks (Pragmático)
```dart
test('inventory integration', () {
  final manager = InventoryManager();
  final factory = ItemFactory();
  final useCase = AddItemUseCase(manager, factory);
  
  final result = useCase.call('sword', 1);
  expect(result, true);
  expect(manager.slots.length, 1);
});
```
**Prós:** Testa comportamento real, sem mocks. Mais confiável.
**Contras:** Mais lento, dificulta teste de edge cases específicos.

---

## Tópico H: Dependency Injection

### Opção H1: Service Locator (GetIt)
```dart
final getIt = GetIt.instance;

void setupInventory() {
  getIt.registerSingleton<InventoryManager>(InventoryManager());
  getIt.registerFactory<AddItemUseCase>(() => AddItemUseCase(getIt(), getIt()));
}

// Uso:
final useCase = getIt<AddItemUseCase>();
```
**Prós:** Simples, desacopla criação. Facilita testes (registrar mocks). Padrão mobile.
**Contras:** Service locator é anti-pattern para alguns. Pode criar dependências ocultas.

### Opção H2: Constructor Injection Manual
```dart
class InventoryViewModel {
  final AddItemUseCase addItemUseCase;
  final RemoveItemUseCase removeItemUseCase;
  
  InventoryViewModel({
    required this.addItemUseCase,
    required this.removeItemUseCase,
  });
}
```
**Prós:** Explícito, fácil de entender, sem magia. Testável facilmente.
**Contras:** Verboso, precisa passar dependências manualmente na árvore.

### Opção H3: Singleton Simples (Atual)
```dart
class InventoryManager {
  static final instance = InventoryManager._();
}

// Uso direto:
InventoryManager.instance.addItem(...);
```
**Prós:** Zero boilerplate, acesso direto, perfeito para jogos single-player.
**Contras:** Dificulta testes, estado global, menos flexível.

---

## Tópico I: Managers vs Services - Nomenclatura e Responsabilidade

### Opção I1: Manager = State + Operations, Service = Stateless Helpers
```dart
class InventoryManager {
  List<Item> _items; // ESTADO
  bool addItem(Item item) { ... } // OPERAÇÃO
}

class ItemPriceService {
  int calculatePrice(Item item) { ... } // STATELESS
}
```
**Prós:** Separação clara: Manager tem estado, Service é puro. Intuitivo.
**Contras:** Nomenclatura pode confundir (ambos fazem "coisas").

### Opção I2: Manager = Singleton State, UseCase = Operations, Service = External
```dart
class InventoryManager {
  List<Item> _items; // ESTADO global
}

class AddItemUseCase {
  bool call(...) { ... } // OPERAÇÃO
}

class ApiService {
  Future<Item> fetchItem() { ... } // EXTERNO
}
```
**Prós:** Responsabilidades muito claras. Manager só guarda estado, UseCase faz lógica, Service comunica com externo.
**Contras:** Mais camadas, pode parecer over-engineering.

### Opção I3: Repository = CRUD, Manager = Orchestration
```dart
class InventoryRepository {
  bool add(Item item) { ... }
  bool remove(String id) { ... }
  Item? get(String id) { ... }
}

class InventoryManager {
  final InventoryRepository repo;
  
  void equipItem(String id) {
    final item = repo.get(id);
    // lógica complexa de equipar
    EquipmentManager.instance.equip(item);
  }
}
```
**Prós:** Repository focado em CRUD, Manager em orquestração. Comum em apps mobile.
**Contras:** Mais camadas, pode ser overkill para jogos onde não há backend.

---

## Tópico J: Eventos e Reatividade entre Módulos

### Opção J1: Event Bus Global
```dart
EventBus.instance.fire(ItemEquippedEvent(item));

// Em outro módulo:
EventBus.instance.on<ItemEquippedEvent>().listen((event) {
  // reage ao equipamento
});
```
**Prós:** Desacopla totalmente módulos. Fácil adicionar novos listeners.
**Contras:** Dificulta debug (quem ouve o quê?). Pode criar side effects inesperados.

### Opção J2: Callbacks Diretos
```dart
class EquipmentManager {
  void Function(Item)? onItemEquipped;
  
  void equip(Item item) {
    // lógica
    onItemEquipped?.call(item);
  }
}
```
**Prós:** Simples, explícito, fácil de debugar.
**Contras:** Acopla módulos, dificulta ter múltiplos listeners.

### Opção J3: ValueNotifier/Stream Cross-Module
```dart
class EquipmentManager {
  final ValueNotifier<Item?> equippedItemNotifier = ValueNotifier(null);
}

// Em outro módulo:
EquipmentManager.instance.equippedItemNotifier.addListener(() {
  // reage
});
```
**Prós:** Reativo, múltiplos listeners, Flutter-native.
**Contras:** Acoplamento leve (outros módulos conhecem o manager). Precisa gerenciar dispose.

---

## Tópico K: Organização de Constantes e Configurações

### Opção K1: Constantes Locais ao Módulo
```dart
// lib/gameplay/inventory/constants/inventory_constants.dart
class InventoryConstants {
  static const int kDefaultInventorySize = 30;
  static const int kMaxInventorySize = 48;
}
```
**Prós:** Cada módulo é auto-contido. Fácil de encontrar constantes.
**Contras:** Duplicação se vários módulos usam mesma constante.

### Opção K2: Constantes Globais Compartilhadas
```dart
// lib/shared/constants/game_constants.dart
class GameConstants {
  static const int kDefaultInventorySize = 30;
  static const int kDefaultFarmSize = 100;
}
```
**Prós:** Única fonte de verdade, evita duplicação.
**Contras:** Arquivo pode crescer muito, dificulta modularização.

### Opção K3: Config Objects Injetáveis
```dart
class InventoryConfig {
  final int maxSlots;
  final bool allowUpgrade;
  
  InventoryConfig({this.maxSlots = 30, this.allowUpgrade = true});
}

class InventoryManager {
  final InventoryConfig config;
  InventoryManager(this.config);
}
```
**Prós:** Flexível, testável (injetar configs diferentes), permite configuração runtime.
**Contras:** Mais boilerplate, pode ser overkill para constantes simples.

---

## Tópico L: Factories e Item Creation

### Opção L1: Factory Centralizado com Switch/Map
```dart
class ItemFactory {
  static final _registry = <String, Item Function()>{
    'sword': () => MainHandItem(id: 'sword', ...),
    'shield': () => MainHandItem(id: 'shield', ...),
  };
  
  Item? createItem(String id) => _registry[id]?.call();
}
```
**Prós:** Centralizado, fácil adicionar novos items. Registro explícito.
**Contras:** Pode crescer muito, precisa manter registro atualizado.

### Opção L2: Factory com Database JSON
```dart
class ItemFactory {
  final Map<String, dynamic> _database;
  
  ItemFactory.fromJson(this._database);
  
  Item? createItem(String id) {
    final json = _database[id];
    return json != null ? Item.fromJson(json) : null;
  }
}
```
**Prós:** Dados separados do código, fácil para designers modificarem. Escalável.
**Contras:** Precisa carregar database, possível erro de parsing.

### Opção L3: Factory por Tipo (Strategy Pattern)
```dart
abstract class ItemFactory {
  Item create(String id);
}

class WeaponFactory implements ItemFactory { ... }
class ToolFactory implements ItemFactory { ... }

class ItemFactoryRegistry {
  final Map<String, ItemFactory> _factories;
  
  Item? create(String id) {
    final type = _getType(id);
    return _factories[type]?.create(id);
  }
}
```
**Prós:** Separação por tipo, fácil adicionar novos tipos de item. Extensível.
**Contras:** Mais complexo, pode ser overkill se poucos tipos.

---

## Recomendação Inicial (para discussão)

Baseado no contexto de jogo Stardew-like com foco em replicabilidade e simplicidade:

**Estrutura:** A2 (Flat por Responsabilidade)
**UseCases:** B1 (Concretos sem interface)
**Estado:** C1 (Singleton + ValueNotifier)
**Dados:** D2 (Entity com Serialização)
**Save/Load:** E2 (UseCase específico)
**UI:** F1 (ValueNotifier direto)
**Testes:** G2 (Mocktail)
**DI:** H3 (Singleton simples)
**Naming:** I2 (Manager/UseCase/Service)
**Eventos:** J3 (ValueNotifier cross-module)
**Constantes:** K1 (Locais ao módulo)
**Factory:** L2 (Database JSON)

Essa combinação prioriza simplicidade, testabilidade e padrão replicável, mantendo o foco em gamedev ao invés de over-engineering mobile.

Aguardo sua seleção tipo "Subway" para refinar! 🎮


escolha do kevin: A2, B1, C1, D2, E2, F2, G2, H1, I2, J3, K1, L2. 