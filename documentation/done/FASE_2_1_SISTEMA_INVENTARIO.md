# 🎯 FASE 2.1 - Sistema de Inventário

> **Objetivo:** Implementar sistema completo de inventário com persistência
>
> **Prioridade:** 🔴 CRÍTICO (Core gameplay)
>
> **Tempo Estimado:** 3-4 dias
>
> **Dependências:** Save/Load (1.1-1.3)

---

## 📋 Estrutura Final

```
lib/gameplay/inventory/
├── models/
│   ├── item.dart                     ✅ Modelo base de item
│   ├── item_type.dart                ✅ Enum de tipos
│   ├── item_rarity.dart              ✅ Enum de raridade
│   ├── inventory_slot.dart           ✅ Slot individual
│   └── equipment_slot.dart           ✅ Slot de equipamento
├── inventory_manager.dart            ✅ Singleton, gerencia inventário
├── equipment_manager.dart            ✅ Singleton, gerencia equipamentos
└── item_factory.dart                 ✅ Factory de itens

lib/gameplay/inventory/items/
├── weapon_item.dart                  ✅ Armas (espadas, machados)
├── tool_item.dart                    ✅ Ferramentas (picareta, machado)
├── consumable_item.dart              ✅ Consumíveis (poções, comida)
├── material_item.dart                ✅ Materiais (madeira, minério)
└── seed_item.dart                    ✅ Sementes (agricultura)

test/gameplay/inventory/
├── inventory_manager_test.dart       ✅ Testes do inventário
├── equipment_manager_test.dart       ✅ Testes de equipamento
└── item_factory_test.dart            ✅ Testes da factory

assets/items/
└── items_database.json               ✅ Database de itens
```

---

## 🚀 PROMPT 1: Criar Modelos Base do Inventário

### Contexto

Precisamos de modelos robustos e type-safe para itens, slots e equipamentos que suportem serialização e diferentes tipos de itens.

### Prompt para o Claude

````
Crie os modelos fundamentais do sistema de inventário:

ARQUIVO 1: lib/gameplay/inventory/models/item_type.dart
```dart
enum ItemType {
  weapon,      // Espadas, machados de combate
  tool,        // Ferramentas (picareta, machado, enxada)
  consumable,  // Poções, comida
  material,    // Madeira, minério, pedra
  seed,        // Sementes para plantar
  equipment,   // Armaduras, acessórios
  quest,       // Itens de quest
  treasure;    // Baús, relíquias

  String toJson() => name;
  static ItemType fromJson(String json) => values.byName(json);
}
````

ARQUIVO 2: lib/gameplay/inventory/models/item_rarity.dart

```dart
enum ItemRarity {
  common,      // Branco
  uncommon,    // Verde
  rare,        // Azul
  epic,        // Roxo
  legendary;   // Dourado

  String toJson() => name;
  static ItemRarity fromJson(String json) => values.byName(json);

  /// Valor de venda multiplicador
  double get sellValueMultiplier {
    switch (this) {
      case ItemRarity.common: return 1.0;
      case ItemRarity.uncommon: return 1.5;
      case ItemRarity.rare: return 2.5;
      case ItemRarity.epic: return 5.0;
      case ItemRarity.legendary: return 10.0;
    }
  }
}
```

ARQUIVO 3: lib/gameplay/inventory/models/item.dart

```dart
/// Modelo base abstrato para todos os itens
abstract class Item {
  final String id;              // ID único do item
  final String name;            // Nome exibido
  final String description;     // Descrição
  final ItemType type;          // Tipo do item
  final ItemRarity rarity;      // Raridade
  final int maxStackSize;       // Tamanho máximo da pilha
  final int baseValue;          // Valor base em moedas
  final String iconPath;        // Caminho do ícone
  final bool isStackable;       // Pode empilhar?
  final bool isDroppable;       // Pode dropar?
  final bool isTradeable;       // Pode negociar?

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.maxStackSize = 1,
    required this.baseValue,
    required this.iconPath,
    this.isStackable = false,
    this.isDroppable = true,
    this.isTradeable = true,
  });

  /// Valor de venda (baseValue * raridade)
  int get sellValue => (baseValue * rarity.sellValueMultiplier).round();

  /// Serialização
  Map<String, dynamic> toJson();

  /// Cria cópia com modificações
  Item copyWith();

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

ARQUIVO 4: lib/gameplay/inventory/models/inventory_slot.dart

```dart
/// Representa um slot individual do inventário
final class InventorySlot {
  final int index;           // Índice do slot (0-based)
  final Item? item;          // Item no slot (null = vazio)
  final int quantity;        // Quantidade de itens

  const InventorySlot({
    required this.index,
    this.item,
    this.quantity = 0,
  });

  /// Slot está vazio?
  bool get isEmpty => item == null || quantity == 0;

  /// Slot está cheio?
  bool get isFull => item != null && quantity >= item!.maxStackSize;

  /// Pode adicionar item?
  bool canAddItem(Item itemToAdd, int quantityToAdd) {
    if (isEmpty) return true;
    if (item!.id != itemToAdd.id) return false;
    if (!item!.isStackable) return false;
    return quantity + quantityToAdd <= item!.maxStackSize;
  }

  /// Adicionar quantidade
  InventorySlot addQuantity(int amount) {
    if (item == null) return this;
    return InventorySlot(
      index: index,
      item: item,
      quantity: (quantity + amount).clamp(0, item!.maxStackSize),
    );
  }

  /// Remover quantidade
  InventorySlot removeQuantity(int amount) {
    if (item == null) return this;
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) {
      return InventorySlot(index: index); // Slot vazio
    }
    return InventorySlot(
      index: index,
      item: item,
      quantity: newQuantity,
    );
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'itemId': item?.id,
      'quantity': quantity,
    };
  }

  /// Deserialização (requer ItemFactory)
  static InventorySlot fromJson(Map<String, dynamic> json, Item? Function(String) itemResolver) {
    final itemId = json['itemId'] as String?;
    return InventorySlot(
      index: json['index'] as int,
      item: itemId != null ? itemResolver(itemId) : null,
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}
```

ARQUIVO 5: lib/gameplay/inventory/models/equipment_slot.dart

```dart
/// Tipos de slot de equipamento
enum EquipmentSlotType {
  weapon,     // Arma principal
  offhand,    // Escudo/arma secundária
  helmet,     // Capacete
  chest,      // Peitoral
  legs,       // Calças
  boots,      // Botas
  accessory1, // Acessório 1
  accessory2; // Acessório 2

  String toJson() => name;
  static EquipmentSlotType fromJson(String json) => values.byName(json);
}

/// Slot de equipamento
final class EquipmentSlot {
  final EquipmentSlotType slotType;
  final Item? equippedItem;

  const EquipmentSlot({
    required this.slotType,
    this.equippedItem,
  });

  bool get isEmpty => equippedItem == null;
  bool get isOccupied => equippedItem != null;

  /// Equipar item
  EquipmentSlot equip(Item item) {
    return EquipmentSlot(slotType: slotType, equippedItem: item);
  }

  /// Desequipar item
  EquipmentSlot unequip() {
    return EquipmentSlot(slotType: slotType);
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'slotType': slotType.toJson(),
      'equippedItemId': equippedItem?.id,
    };
  }

  static EquipmentSlot fromJson(Map<String, dynamic> json, Item? Function(String) itemResolver) {
    final itemId = json['equippedItemId'] as String?;
    return EquipmentSlot(
      slotType: EquipmentSlotType.fromJson(json['slotType']),
      equippedItem: itemId != null ? itemResolver(itemId) : null,
    );
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Enums compilam e serializam
[ ] Item é abstract class com campos obrigatórios
[ ] InventorySlot gerencia quantidade corretamente
[ ] EquipmentSlot gerencia equipamentos
[ ] Serialização funciona
[ ] Documentação Dartdoc completa

### Critérios de Aceitação

- [ ] Modelos compilam sem erros
- [ ] Type-safe (enums ao invés de strings)
- [ ] Imutáveis (final fields, copyWith)
- [ ] Serialização completa
- [ ] Documentação clara

```

---

## 🚀 PROMPT 2: Criar Tipos Concretos de Itens

### Contexto
Agora que temos o modelo base, precisamos criar as classes concretas para diferentes tipos de itens (armas, ferramentas, consumíveis, etc).

### Prompt para o Claude

```

Crie as classes concretas de itens estendendo o modelo base:

ARQUIVO 1: lib/gameplay/inventory/items/weapon_item.dart

```dart
/// Item de arma (combate)
final class WeaponItem extends Item {
  final int damage;           // Dano base
  final double attackSpeed;   // Velocidade de ataque (ataques/segundo)
  final double critChance;    // Chance de crítico (0.0-1.0)
  final double critMultiplier;// Multiplicador de crítico
  final String equippedHandType;    // sword, axe, spear, bow

  const WeaponItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.weapon,
    required this.damage,
    this.attackSpeed = 1.0,
    this.critChance = 0.05,
    this.critMultiplier = 1.5,
    required this.equippedHandType,
  });

  /// DPS médio (considerando críticos)
  double get dps {
    final avgDamage = damage * (1 + critChance * (critMultiplier - 1));
    return avgDamage * attackSpeed;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toJson(),
      'rarity': rarity.toJson(),
      'baseValue': baseValue,
      'iconPath': iconPath,
      'damage': damage,
      'attackSpeed': attackSpeed,
      'critChance': critChance,
      'critMultiplier': critMultiplier,
      'equippedHandType': equippedHandType,
    };
  }

  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    return WeaponItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      baseValue: json['baseValue'],
      iconPath: json['iconPath'],
      rarity: ItemRarity.fromJson(json['rarity']),
      damage: json['damage'],
      attackSpeed: json['attackSpeed'] ?? 1.0,
      critChance: json['critChance'] ?? 0.05,
      critMultiplier: json['critMultiplier'] ?? 1.5,
      equippedHandType: json['equippedHandType'],
    );
  }

  @override
  WeaponItem copyWith({/* campos opcionais */}) {
    // Implementar...
  }
}
```

ARQUIVO 2: lib/gameplay/inventory/items/tool_item.dart

```dart
/// Ferramenta (picareta, machado, enxada)
final class ToolItem extends Item {
  final String toolType;      // pickaxe, axe, hoe, watering_can
  final int powerLevel;       // Nível de poder (1-5)
  final int durability;       // Durabilidade atual
  final int maxDurability;    // Durabilidade máxima

  const ToolItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.tool,
    required this.toolType,
    this.powerLevel = 1,
    required this.durability,
    required this.maxDurability,
  });

  bool get isBroken => durability <= 0;
  double get durabilityPercent => durability / maxDurability;

  /// Usar ferramenta (reduz durabilidade)
  ToolItem use([int amount = 1]) {
    return copyWith(
      durability: (durability - amount).clamp(0, maxDurability),
    );
  }

  /// Reparar ferramenta
  ToolItem repair([int amount = 10]) {
    return copyWith(
      durability: (durability + amount).clamp(0, maxDurability),
    );
  }

  @override
  Map<String, dynamic> toJson() { /* Implementar */ }

  factory ToolItem.fromJson(Map<String, dynamic> json) { /* Implementar */ }

  @override
  ToolItem copyWith({/* campos opcionais */}) { /* Implementar */ }
}
```

ARQUIVO 3: lib/gameplay/inventory/items/consumable_item.dart

```dart
/// Item consumível (poção, comida)
final class ConsumableItem extends Item {
  final int healthRestore;    // HP restaurado
  final int staminaRestore;   // Stamina restaurada
  final int duration;         // Duração do efeito (segundos)
  final List<String> buffs;   // IDs de buffs aplicados

  const ConsumableItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.consumable,
    super.isStackable = true,
    super.maxStackSize = 99,
    this.healthRestore = 0,
    this.staminaRestore = 0,
    this.duration = 0,
    this.buffs = const [],
  });

  @override
  Map<String, dynamic> toJson() { /* Implementar */ }

  factory ConsumableItem.fromJson(Map<String, dynamic> json) { /* Implementar */ }

  @override
  ConsumableItem copyWith({/* campos opcionais */}) { /* Implementar */ }
}
```

ARQUIVO 4: lib/gameplay/inventory/items/material_item.dart

```dart
/// Material de crafting
final class MaterialItem extends Item {
  final String materialType;  // wood, stone, ore, fiber

  const MaterialItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.material,
    super.isStackable = true,
    super.maxStackSize = 999,
    required this.materialType,
  });

  @override
  Map<String, dynamic> toJson() { /* Implementar */ }

  factory MaterialItem.fromJson(Map<String, dynamic> json) { /* Implementar */ }

  @override
  MaterialItem copyWith({/* campos opcionais */}) { /* Implementar */ }
}
```

ARQUIVO 5: lib/gameplay/inventory/items/seed_item.dart

```dart
/// Semente para agricultura
final class SeedItem extends Item {
  final String cropId;        // ID da crop que será plantada
  final int growthTime;       // Tempo de crescimento (dias in-game)
  final int yield;            // Quantidade de items colhidos
  final String season;        // Estação ideal (spring, summer, fall, winter, any)

  const SeedItem({
    required super.id,
    required super.name,
    required super.description,
    required super.baseValue,
    required super.iconPath,
    super.rarity = ItemRarity.common,
    super.type = ItemType.seed,
    super.isStackable = true,
    super.maxStackSize = 99,
    required this.cropId,
    required this.growthTime,
    this.yield = 1,
    this.season = 'any',
  });

  /// Pode plantar na estação atual?
  bool canPlantInSeason(String currentSeason) {
    return season == 'any' || season == currentSeason;
  }

  @override
  Map<String, dynamic> toJson() { /* Implementar */ }

  factory SeedItem.fromJson(Map<String, dynamic> json) { /* Implementar */ }

  @override
  SeedItem copyWith({/* campos opcionais */}) { /* Implementar */ }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Todas as classes estendem Item corretamente
[ ] Campos específicos de cada tipo
[ ] toJson/fromJson funcionam
[ ] copyWith funciona
[ ] Métodos auxiliares implementados

### Critérios de Aceitação

- [ ] 5 tipos de itens criados
- [ ] Cada tipo tem campos específicos
- [ ] Serialização completa
- [ ] Métodos auxiliares úteis
- [ ] Documentação clara

```

---

## 🚀 PROMPT 3: Criar ItemFactory e Database

### Contexto
Precisamos de uma factory para criar itens a partir de IDs e um database JSON com todos os itens disponíveis no jogo.

### Prompt para o Claude

```

Crie a ItemFactory e database de itens:

ARQUIVO 1: lib/gameplay/inventory/item_factory.dart

```dart
final class ItemFactory {
  ItemFactory._();

  static final Map<String, Map<String, dynamic>> _itemDatabase = {};
  static bool _isInitialized = false;

  /// Carregar database de itens
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final jsonString = await rootBundle.loadString('assets/items/items_database.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    for (var entry in jsonData.entries) {
      _itemDatabase[entry.key] = entry.value;
    }

    _isInitialized = true;
    developer.log('[ItemFactory] Loaded ${_itemDatabase.length} items');
  }

  /// Criar item por ID
  static Item? createItem(String itemId) {
    if (!_isInitialized) {
      developer.log('[ItemFactory] ERROR: Not initialized!');
      return null;
    }

    final itemData = _itemDatabase[itemId];
    if (itemData == null) {
      developer.log('[ItemFactory] Item not found: $itemId');
      return null;
    }

    final type = ItemType.fromJson(itemData['type']);

    switch (type) {
      case ItemType.weapon:
        return WeaponItem.fromJson(itemData);
      case ItemType.tool:
        return ToolItem.fromJson(itemData);
      case ItemType.consumable:
        return ConsumableItem.fromJson(itemData);
      case ItemType.material:
        return MaterialItem.fromJson(itemData);
      case ItemType.seed:
        return SeedItem.fromJson(itemData);
      default:
        developer.log('[ItemFactory] Unsupported type: $type');
        return null;
    }
  }

  /// Criar múltiplos itens
  static List<Item> createItems(List<String> itemIds) {
    return itemIds.map(createItem).whereType<Item>().toList();
  }

  /// Listar todos os IDs de itens
  static List<String> getAllItemIds() => _itemDatabase.keys.toList();

  /// Listar itens por tipo
  static List<String> getItemIdsByType(ItemType type) {
    return _itemDatabase.entries
      .where((e) => e.value['type'] == type.toJson())
      .map((e) => e.key)
      .toList();
  }
}
```

ARQUIVO 2: assets/items/items_database.json

```json
{
  "iron_sword": {
    "id": "iron_sword",
    "name": "Iron Sword",
    "description": "A sturdy iron sword for basic combat",
    "type": "weapon",
    "rarity": "common",
    "baseValue": 100,
    "iconPath": "assets/images/items/iron_sword.png",
    "damage": 15,
    "attackSpeed": 1.2,
    "critChance": 0.05,
    "critMultiplier": 1.5,
    "equippedHandType": "sword"
  },
  "iron_pickaxe": {
    "id": "iron_pickaxe",
    "name": "Iron Pickaxe",
    "description": "Mine rocks and ores efficiently",
    "type": "tool",
    "rarity": "common",
    "baseValue": 80,
    "iconPath": "assets/images/items/iron_pickaxe.png",
    "toolType": "pickaxe",
    "powerLevel": 2,
    "durability": 100,
    "maxDurability": 100
  },
  "health_potion": {
    "id": "health_potion",
    "name": "Health Potion",
    "description": "Restores 50 HP instantly",
    "type": "consumable",
    "rarity": "common",
    "baseValue": 25,
    "iconPath": "assets/images/items/health_potion.png",
    "maxStackSize": 99,
    "healthRestore": 50,
    "staminaRestore": 0,
    "duration": 0,
    "buffs": []
  },
  "wood": {
    "id": "wood",
    "name": "Wood",
    "description": "Basic crafting material from trees",
    "type": "material",
    "rarity": "common",
    "baseValue": 5,
    "iconPath": "assets/images/items/wood.png",
    "maxStackSize": 999,
    "materialType": "wood"
  },
  "carrot_seeds": {
    "id": "carrot_seeds",
    "name": "Carrot Seeds",
    "description": "Plant to grow carrots in any season",
    "type": "seed",
    "rarity": "common",
    "baseValue": 10,
    "iconPath": "assets/images/items/carrot_seeds.png",
    "maxStackSize": 99,
    "cropId": "carrot",
    "growthTime": 4,
    "yield": 3,
    "season": "any"
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] ItemFactory.initialize() carrega database
[ ] createItem() retorna item correto por ID
[ ] createItem() retorna null para ID inválido
[ ] Database JSON tem pelo menos 5 itens
[ ] Cada tipo de item tem 1 exemplo

### Critérios de Aceitação

- [ ] Factory funcional
- [ ] Database carrega corretamente
- [ ] Criação de itens funciona
- [ ] Tratamento de erros robusto
- [ ] Database com exemplos de cada tipo

```

---

## 🚀 PROMPT 4: Criar InventoryManager

### Contexto
O InventoryManager é o singleton que gerencia todos os slots do inventário do jogador: adicionar/remover itens, empilhar, buscar, etc.

### Prompt para o Claude

```

Crie o InventoryManager completo:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: InventoryManager.\_()
   - Instance estática: static final instance = InventoryManager.\_()

2. Gerenciamento de Slots:

   - List<InventorySlot> \_slots (tamanho fixo, ex: 30 slots)
   - int get maxSlots
   - int get usedSlots (slots com itens)
   - int get freeSlots (slots vazios)

3. Adicionar Itens:

   - bool addItem(Item item, [int quantity = 1])
   - Empilhar em slots existentes se possível
   - Criar novo slot se necessário
   - Retornar false se inventário cheio
   - Logar operações

4. Remover Itens:

   - bool removeItem(String itemId, [int quantity = 1])
   - Remover de stacks existentes
   - Limpar slot se quantidade = 0
   - Retornar false se não há item suficiente

5. Buscar Itens:

   - int getItemQuantity(String itemId)
   - bool hasItem(String itemId, [int quantity = 1])
   - InventorySlot? getSlotByIndex(int index)
   - List<InventorySlot> getSlotsByItemId(String itemId)

6. Mover/Trocar:

   - bool moveItem(int fromIndex, int toIndex)
   - bool swapSlots(int index1, int index2)

7. Operações em Massa:

   - void clear() (limpar inventário)
   - void sortByType() (ordenar por tipo)
   - void sortByRarity() (ordenar por raridade)
   - void sortByName() (ordenar alfabeticamente)

8. Serialização:
   - Map<String, dynamic> toJson()
   - void fromJson(Map<String, dynamic> json)

ESTRUTURA DO ARQUIVO:
lib/gameplay/inventory/inventory_manager.dart

PADRÃO DE CÓDIGO:

```dart
final class InventoryManager {
  InventoryManager._() {
    // Inicializar slots vazios
    _slots = List.generate(
      _kMaxSlots,
      (index) => InventorySlot(index: index),
    );
  }

  static final instance = InventoryManager._();
  static const int _kMaxSlots = 30;

  late List<InventorySlot> _slots;

  int get maxSlots => _kMaxSlots;
  int get usedSlots => _slots.where((s) => !s.isEmpty).length;
  int get freeSlots => maxSlots - usedSlots;

  /// Adicionar item ao inventário
  bool addItem(Item item, [int quantity = 1]) {
    developer.log('[InventoryManager] Adding $quantity x ${item.name}');

    // 1. Tentar empilhar em slots existentes
    if (item.isStackable) {
      for (var slot in _slots) {
        if (slot.isEmpty) continue;
        if (slot.item!.id != item.id) continue;

        final spaceInSlot = item.maxStackSize - slot.quantity;
        if (spaceInSlot <= 0) continue;

        final amountToAdd = min(quantity, spaceInSlot);
        _slots[slot.index] = slot.addQuantity(amountToAdd);
        quantity -= amountToAdd;

        if (quantity == 0) {
          developer.log('[InventoryManager] Item stacked successfully');
          return true;
        }
      }
    }

    // 2. Criar novos slots
    while (quantity > 0) {
      final emptySlotIndex = _slots.indexWhere((s) => s.isEmpty);
      if (emptySlotIndex == -1) {
        developer.log('[InventoryManager] Inventory full!');
        return false;
      }

      final amountForSlot = item.isStackable
        ? min(quantity, item.maxStackSize)
        : 1;

      _slots[emptySlotIndex] = InventorySlot(
        index: emptySlotIndex,
        item: item,
        quantity: amountForSlot,
      );

      quantity -= amountForSlot;
    }

    developer.log('[InventoryManager] Item added successfully');
    return true;
  }

  /// Remover item do inventário
  bool removeItem(String itemId, [int quantity = 1]) {
    // Implementar lógica completa...
  }

  /// Obter quantidade total de um item
  int getItemQuantity(String itemId) {
    return _slots
      .where((s) => s.item?.id == itemId)
      .fold(0, (sum, slot) => sum + slot.quantity);
  }

  /// Verificar se tem item
  bool hasItem(String itemId, [int quantity = 1]) {
    return getItemQuantity(itemId) >= quantity;
  }

  // Implementar outros métodos...
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona
[ ] addItem() empilha corretamente
[ ] addItem() retorna false se cheio
[ ] removeItem() funciona
[ ] getItemQuantity() conta correto
[ ] moveItem() e swapSlots() funcionam
[ ] Serialização funciona

### Critérios de Aceitação

- [ ] Manager completo e funcional
- [ ] Empilhamento automático
- [ ] Tratamento de inventário cheio
- [ ] Logs detalhados
- [ ] Serialização completa

```

---

## 🚀 PROMPT 5: Criar EquipmentManager

### Contexto
O EquipmentManager gerencia os slots de equipamento do player (arma, armadura, acessórios) e calcula bônus de stats.

### Prompt para o Claude

```

Crie o EquipmentManager completo:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: EquipmentManager.\_()
   - Instance estática: static final instance = EquipmentManager.\_()

2. Slots de Equipamento:

   - Map<EquipmentSlotType, EquipmentSlot> \_equipmentSlots
   - Inicializar todos os tipos de slot

3. Equipar/Desequipar:

   - bool equip(EquipmentSlotType slotType, Item item)
   - Validar que item pode ser equipado no slot
   - Mover item do inventário para equipamento
   - Item? unequip(EquipmentSlotType slotType)
   - Mover item de volta para inventário

4. Consultar Equipamentos:

   - Item? getEquippedItem(EquipmentSlotType slotType)
   - bool isSlotOccupied(EquipmentSlotType slotType)
   - List<Item> getAllEquippedItems()

5. Calcular Stats Totais:

   - int getTotalDamage() (soma damage de armas)
   - int getTotalDefense() (soma defense de armaduras)
   - Map<String, int> getTotalStats() (todos os bônus)

6. Serialização:
   - Map<String, dynamic> toJson()
   - void fromJson(Map<String, dynamic> json)

ESTRUTURA DO ARQUIVO:
lib/gameplay/inventory/equipment_manager.dart

PADRÃO DE CÓDIGO:

```dart
final class EquipmentManager {
  EquipmentManager._() {
    // Inicializar todos os slots vazios
    for (var slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
  }

  static final instance = EquipmentManager._();

  final Map<EquipmentSlotType, EquipmentSlot> _equipmentSlots = {};

  /// Equipar item
  bool equip(EquipmentSlotType slotType, Item item) {
    developer.log('[EquipmentManager] Equipping ${item.name} to $slotType');

    // 1. Validar tipo de item
    if (!_canEquipItemInSlot(item, slotType)) {
      developer.log('[EquipmentManager] Item cannot be equipped in this slot');
      return false;
    }

    // 2. Desequipar item existente (volta para inventário)
    final currentItem = getEquippedItem(slotType);
    if (currentItem != null) {
      if (!InventoryManager.instance.addItem(currentItem)) {
        developer.log('[EquipmentManager] Inventory full, cannot equip');
        return false;
      }
    }

    // 3. Remover do inventário
    if (!InventoryManager.instance.removeItem(item.id, 1)) {
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    // 4. Equipar
    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(item);
    developer.log('[EquipmentManager] Item equipped successfully');
    return true;
  }

  /// Desequipar item
  Item? unequip(EquipmentSlotType slotType) {
    final item = getEquippedItem(slotType);
    if (item == null) return null;

    // Adicionar ao inventário
    if (!InventoryManager.instance.addItem(item)) {
      developer.log('[EquipmentManager] Inventory full, cannot unequip');
      return null;
    }

    // Desequipar
    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.unequip();
    return item;
  }

  /// Validar se item pode ser equipado no slot
  bool _canEquipItemInSlot(Item item, EquipmentSlotType slotType) {
    if (item is WeaponItem) {
      return slotType == EquipmentSlotType.weapon ||
             slotType == EquipmentSlotType.offhand;
    }
    // Implementar validação para outros tipos...
    return false;
  }

  /// Calcular dano total
  int getTotalDamage() {
    int total = 0;
    final weapon = getEquippedItem(EquipmentSlotType.weapon);
    if (weapon is WeaponItem) {
      total += weapon.damage;
    }
    return total;
  }

  // Implementar outros métodos...
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona
[ ] equip() move item inventário → equipamento
[ ] unequip() move item equipamento → inventário
[ ] Validação de tipo de item funciona
[ ] getTotalDamage() calcula correto
[ ] Serialização funciona

### Critérios de Aceitação

- [ ] Manager completo
- [ ] Equip/unequip funcional
- [ ] Integração com InventoryManager
- [ ] Cálculo de stats
- [ ] Serialização completa

```

---

## 🚀 PROMPT 6: Criar Testes e Integração

### Contexto
Criar testes completos e integrar com SaveManager.

### Prompt para o Claude

```

Crie testes completos e integração com SaveManager:

ARQUIVO 1: test/gameplay/inventory/inventory_manager_test.dart
TESTES:

1. test_add_item_to_empty_slot
2. test_add_stackable_item_stacks_correctly
3. test_add_item_returns_false_when_full
4. test_remove_item_decreases_quantity
5. test_get_item_quantity_counts_all_stacks
6. test_move_item_swaps_slots
7. test_serialization_roundtrip

ARQUIVO 2: test/gameplay/inventory/equipment_manager_test.dart
TESTES:

1. test_equip_weapon_success
2. test_equip_returns_false_for_wrong_slot
3. test_unequip_returns_item_to_inventory
4. test_get_total_damage_sums_weapons
5. test_serialization_roundtrip

ARQUIVO 3: test/gameplay/inventory/item_factory_test.dart
TESTES:

1. test_initialize_loads_database
2. test_create_item_returns_correct_type
3. test_create_item_returns_null_for_invalid_id
4. test_get_all_item_ids_returns_all

INTEGRAÇÃO COM SAVEMANAGER:

- Atualizar SaveData para incluir inventoryData e equipmentData
- Salvar/carregar inventário automaticamente
- Testar roundtrip save/load

CHECKLIST DE VALIDAÇÃO:
[ ] Todos os testes passam
[ ] Cobertura >= 80%
[ ] Integração com SaveManager funciona
[ ] Save/load de inventário funciona

### Critérios de Aceitação

- [ ] Testes completos
- [ ] Integração funcional
- [ ] Performance adequada

```

---

## 📊 Checklist de Conclusão da Fase 2.1

### Arquivos Criados
- [ ] Modelos base (Item, InventorySlot, EquipmentSlot)
- [ ] 5 tipos de itens (Weapon, Tool, Consumable, Material, Seed)
- [ ] ItemFactory
- [ ] InventoryManager
- [ ] EquipmentManager
- [ ] Database JSON com 5+ itens
- [ ] Testes completos

### Funcionalidades Validadas
- [ ] Sistema de slots funciona
- [ ] Empilhamento automático
- [ ] Equipar/desequipar funciona
- [ ] Serialização completa
- [ ] Integração com SaveManager

### Próximos Passos
⏭️ Avançar para **FASE 2.2** - Sistema de Agricultura

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
