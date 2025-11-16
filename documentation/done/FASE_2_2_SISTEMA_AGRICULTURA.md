# 🎯 FASE 2.2 - Sistema de Agricultura

> **Objetivo:** Implementar sistema completo de plantio, crescimento e colheita
>
> **Prioridade:** 🟡 IMPORTANTE (Gameplay loop principal)
>
> **Tempo Estimado:** 3-4 dias
>
> **Dependências:** Inventário (2.1), WorldState (1.2), TimeManager (1.2)

---

## 📋 Estrutura Final

```
lib/gameplay/farm/
├── models/
│   ├── crop.dart                     ✅ Modelo de crop plantada
│   ├── crop_stage.dart               ✅ Estágios de crescimento
│   ├── farm_tile.dart                ✅ Tile individual de fazenda
│   └── soil_state.dart               ✅ Estado do solo
├── farm_manager.dart                 ✅ Singleton, gerencia fazenda
├── crop_database.dart                ✅ Database de crops
└── farm_renderer.dart                ✅ Renderização visual

assets/crops/
└── crops_database.json               ✅ Database de crops

test/gameplay/farm/
├── farm_manager_test.dart            ✅ Testes do manager
└── crop_growth_test.dart             ✅ Testes de crescimento
```

---

## 🚀 PROMPT 1: Criar Modelos Base da Fazenda

### Contexto

Precisamos de modelos para representar tiles de fazenda, crops plantadas, estágios de crescimento e estado do solo.

### Prompt para o Claude

````
Crie os modelos fundamentais do sistema de agricultura:

ARQUIVO 1: lib/gameplay/farm/models/soil_state.dart
```dart
/// Estado do solo em um tile de fazenda
enum SoilState {
  untilled,    // Não preparado
  tilled,      // Arado (pronto para plantar)
  watered,     // Regado (crescimento mais rápido)
  fertilized;  // Fertilizado (qualidade maior)

  String toJson() => name;
  static SoilState fromJson(String json) => values.byName(json);

  /// Modificador de velocidade de crescimento
  double get growthSpeedMultiplier {
    switch (this) {
      case SoilState.untilled: return 0.0; // Não cresce
      case SoilState.tilled: return 1.0;
      case SoilState.watered: return 1.5;
      case SoilState.fertilized: return 2.0;
    }
  }
}
````

ARQUIVO 2: lib/gameplay/farm/models/crop_stage.dart

```dart
/// Estágio de crescimento de uma crop
enum CropStage {
  seed,        // Semente plantada
  sprout,      // Broto
  growing,     // Crescendo
  mature,      // Maduro (pode colher)
  withered;    // Morto (passou da época)

  String toJson() => name;
  static CropStage fromJson(String json) => values.byName(json);

  bool get canHarvest => this == CropStage.mature;
  bool get isDead => this == CropStage.withered;
}
```

ARQUIVO 3: lib/gameplay/farm/models/crop.dart

```dart
/// Representa uma crop plantada em um tile
final class Crop {
  final String cropId;           // ID da crop (carrot, potato, etc)
  final String name;             // Nome exibido
  final CropStage stage;         // Estágio atual
  final int daysPlanted;         // Dias desde plantio
  final int daysToMature;        // Dias para maturar
  final int yieldAmount;         // Quantidade colhida
  final String harvestItemId;    // ID do item colhido
  final String? requiredSeason;  // Estação necessária (null = any)
  final String iconPath;         // Sprite da crop

  const Crop({
    required this.cropId,
    required this.name,
    required this.stage,
    required this.daysPlanted,
    required this.daysToMature,
    required this.yieldAmount,
    required this.harvestItemId,
    this.requiredSeason,
    required this.iconPath,
  });

  /// Progresso de crescimento (0.0-1.0)
  double get growthProgress => (daysPlanted / daysToMature).clamp(0.0, 1.0);

  /// Está madura?
  bool get isMature => daysPlanted >= daysToMature;

  /// Pode colher?
  bool get canHarvest => stage.canHarvest;

  /// Avançar 1 dia de crescimento
  Crop advanceDay() {
    final newDays = daysPlanted + 1;

    // Determinar novo estágio
    CropStage newStage;
    if (newDays >= daysToMature) {
      newStage = CropStage.mature;
    } else if (newDays >= (daysToMature * 0.66)) {
      newStage = CropStage.growing;
    } else if (newDays >= (daysToMature * 0.33)) {
      newStage = CropStage.sprout;
    } else {
      newStage = CropStage.seed;
    }

    return copyWith(daysPlanted: newDays, stage: newStage);
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'name': name,
      'stage': stage.toJson(),
      'daysPlanted': daysPlanted,
      'daysToMature': daysToMature,
      'yieldAmount': yieldAmount,
      'harvestItemId': harvestItemId,
      'requiredSeason': requiredSeason,
      'iconPath': iconPath,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      cropId: json['cropId'],
      name: json['name'],
      description: json['description'],
      stage: CropStage.fromJson(json['stage']),
      daysPlanted: json['daysPlanted'],
      daysToMature: json['daysToMature'],
      yieldAmount: json['yieldAmount'],
      harvestItemId: json['harvestItemId'],
      requiredSeason: json['requiredSeason'],
      iconPath: json['iconPath'],
    );
  }

  Crop copyWith({/* campos opcionais */}) {
    // Implementar...
  }
}
```

ARQUIVO 4: lib/gameplay/farm/models/farm_tile.dart

```dart
/// Representa um tile individual de fazenda
final class FarmTile {
  final int x;               // Coordenada X
  final int y;               // Coordenada Y
  final SoilState soilState; // Estado do solo
  final Crop? crop;          // Crop plantada (null = vazio)
  final DateTime? lastWatered; // Última vez regado

  const FarmTile({
    required this.x,
    required this.y,
    this.soilState = SoilState.untilled,
    this.crop,
    this.lastWatered,
  });

  /// Tile está vazio?
  bool get isEmpty => crop == null;

  /// Tile está ocupado?
  bool get isOccupied => crop != null;

  /// Pode plantar?
  bool get canPlant => isEmpty && soilState == SoilState.tilled;

  /// Pode colher?
  bool get canHarvest => isOccupied && crop!.canHarvest;

  /// Precisa regar?
  bool get needsWatering {
    if (lastWatered == null) return soilState == SoilState.tilled;
    final hoursSinceWatered = DateTime.now().difference(lastWatered!).inHours;
    return hoursSinceWatered >= 24;
  }

  /// Arar tile
  FarmTile till() {
    return copyWith(soilState: SoilState.tilled);
  }

  /// Regar tile
  FarmTile water() {
    return copyWith(
      soilState: SoilState.watered,
      lastWatered: DateTime.now(),
    );
  }

  /// Plantar crop
  FarmTile plant(Crop crop) {
    if (!canPlant) return this;
    return copyWith(crop: crop);
  }

  /// Colher crop
  FarmTile harvest() {
    if (!canHarvest) return this;
    return copyWith(
      crop: null,
      soilState: SoilState.untilled, // Volta ao estado inicial
    );
  }

  /// Avançar 1 dia
  FarmTile advanceDay() {
    if (crop == null) return this;
    return copyWith(crop: crop!.advanceDay());
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'soilState': soilState.toJson(),
      'crop': crop?.toJson(),
      'lastWatered': lastWatered?.toIso8601String(),
    };
  }

  factory FarmTile.fromJson(Map<String, dynamic> json) {
    return FarmTile(
      x: json['x'],
      y: json['y'],
      soilState: SoilState.fromJson(json['soilState']),
      crop: json['crop'] != null ? Crop.fromJson(json['crop']) : null,
      lastWatered: json['lastWatered'] != null
        ? DateTime.parse(json['lastWatered'])
        : null,
    );
  }

  FarmTile copyWith({/* campos opcionais */}) {
    // Implementar...
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Enums compilam
[ ] Crop tem estágios de crescimento
[ ] FarmTile gerencia estado corretamente
[ ] Serialização funciona
[ ] Métodos auxiliares implementados

### Critérios de Aceitação

- [ ] Modelos compilam sem erros
- [ ] Imutáveis (copyWith pattern)
- [ ] Serialização completa
- [ ] Lógica de crescimento funciona
- [ ] Documentação clara

```

---

## 🚀 PROMPT 2: Criar CropDatabase

### Contexto
Precisamos de um database JSON com todas as crops disponíveis no jogo e uma classe para carregá-las.

### Prompt para o Claude

```

Crie o CropDatabase e arquivo JSON:

ARQUIVO 1: lib/gameplay/farm/crop_database.dart

```dart
final class CropDatabase {
  CropDatabase._();

  static final Map<String, Map<String, dynamic>> _cropDatabase = {};
  static bool _isInitialized = false;

  /// Carregar database
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final jsonString = await rootBundle.loadString('assets/crops/crops_database.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    for (var entry in jsonData.entries) {
      _cropDatabase[entry.key] = entry.value;
    }

    _isInitialized = true;
    developer.log('[CropDatabase] Loaded ${_cropDatabase.length} crops');
  }

  /// Criar crop por ID
  static Crop? createCrop(String cropId) {
    if (!_isInitialized) {
      developer.log('[CropDatabase] ERROR: Not initialized!');
      return null;
    }

    final cropData = _cropDatabase[cropId];
    if (cropData == null) {
      developer.log('[CropDatabase] Crop not found: $cropId');
      return null;
    }

    return Crop(
      cropId: cropId,
      name: cropData['name'],
      stage: CropStage.seed, // Sempre começa como semente
      daysPlanted: 0,
      daysToMature: cropData['daysToMature'],
      yieldAmount: cropData['yieldAmount'],
      harvestItemId: cropData['harvestItemId'],
      requiredSeason: cropData['requiredSeason'],
      iconPath: cropData['iconPath'],
    );
  }

  /// Listar todas as crops
  static List<String> getAllCropIds() => _cropDatabase.keys.toList();

  /// Listar crops por estação
  static List<String> getCropsBySeason(String season) {
    return _cropDatabase.entries
      .where((e) => e.value['requiredSeason'] == season ||
                    e.value['requiredSeason'] == 'any')
      .map((e) => e.key)
      .toList();
  }
}
```

ARQUIVO 2: assets/crops/crops_database.json

```json
{
  "carrot": {
    "name": "Carrot",
    "description": "A nutritious root vegetable",
    "daysToMature": 4,
    "yieldAmount": 3,
    "harvestItemId": "carrot_item",
    "requiredSeason": "any",
    "iconPath": "assets/images/crops/carrot.png"
  },
  "potato": {
    "name": "Potato",
    "description": "Versatile tuber, great for cooking",
    "daysToMature": 6,
    "yieldAmount": 5,
    "harvestItemId": "potato_item",
    "requiredSeason": "spring",
    "iconPath": "assets/images/crops/potato.png"
  },
  "wheat": {
    "name": "Wheat",
    "description": "Essential grain for bread",
    "daysToMature": 8,
    "yieldAmount": 10,
    "harvestItemId": "wheat_item",
    "requiredSeason": "summer",
    "iconPath": "assets/images/crops/wheat.png"
  },
  "pumpkin": {
    "name": "Pumpkin",
    "description": "Large orange squash",
    "daysToMature": 12,
    "yieldAmount": 1,
    "harvestItemId": "pumpkin_item",
    "requiredSeason": "fall",
    "iconPath": "assets/images/crops/pumpkin.png"
  },
  "turnip": {
    "name": "Turnip",
    "description": "Hardy winter vegetable",
    "daysToMature": 5,
    "yieldAmount": 4,
    "harvestItemId": "turnip_item",
    "requiredSeason": "winter",
    "iconPath": "assets/images/crops/turnip.png"
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] CropDatabase.initialize() carrega JSON
[ ] createCrop() retorna crop válida
[ ] Database tem crops para cada estação
[ ] getCropsBySeason() filtra corretamente

### Critérios de Aceitação

- [ ] Database funcional
- [ ] Pelo menos 5 crops
- [ ] Uma crop para cada estação
- [ ] Serialização funciona

```

---

## 🚀 PROMPT 3: Criar FarmManager

### Contexto
O FarmManager é o singleton que gerencia todos os tiles de fazenda, crescimento de crops e interações do jogador.

### Prompt para o Claude

```

Crie o FarmManager completo:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: FarmManager.\_()
   - Instance estática: static final instance = FarmManager.\_()

2. Gerenciamento de Tiles:

   - Map<String, FarmTile> \_farmTiles (key = "x_y")
   - FarmTile? getTile(int x, int y)
   - void setTile(FarmTile tile)
   - List<FarmTile> getAllTiles()

3. Interações do Jogador:

   - bool tillSoil(int x, int y) (arar)
   - bool waterTile(int x, int y) (regar)
   - bool plantSeed(int x, int y, String seedItemId) (plantar)
   - List<Item>? harvestCrop(int x, int y) (colher)

4. Crescimento Automático:

   - void advanceDay() (avançar todos os tiles 1 dia)
   - void update(double dt) (atualizar visual)
   - Integrar com TimeManager para detectar novo dia

5. Validações:

   - Validar que player tem ferramenta necessária
   - Validar que seed existe no inventário
   - Validar que crop pode ser plantada na estação atual

6. Serialização:
   - Map<String, dynamic> toJson()
   - void fromJson(Map<String, dynamic> json)

ESTRUTURA DO ARQUIVO:
lib/gameplay/farm/farm_manager.dart

PADRÃO DE CÓDIGO:

```dart
final class FarmManager {
  FarmManager._() {
    // Registrar listener de novo dia
    TimeManager.instance.addNewDayListener(_onNewDay);
  }

  static final instance = FarmManager._();

  final Map<String, FarmTile> _farmTiles = {};

  /// Obter tile por coordenadas
  FarmTile? getTile(int x, int y) {
    return _farmTiles['${x}_$y'];
  }

  /// Arar solo
  bool tillSoil(int x, int y) {
    developer.log('[FarmManager] Tilling soil at ($x, $y)');

    // 1. Validar que player tem enxada
    if (!_playerHasTool('hoe')) {
      developer.log('[FarmManager] Player needs hoe');
      return false;
    }

    // 2. Obter ou criar tile
    var tile = getTile(x, y);
    if (tile == null) {
      tile = FarmTile(x: x, y: y);
    }

    // 3. Arar
    if (tile.soilState != SoilState.untilled) {
      developer.log('[FarmManager] Soil already tilled');
      return false;
    }

    _farmTiles['${x}_$y'] = tile.till();
    developer.log('[FarmManager] Soil tilled successfully');
    return true;
  }

  /// Regar tile
  bool waterTile(int x, int y) {
    developer.log('[FarmManager] Watering tile at ($x, $y)');

    // 1. Validar que player tem regador
    if (!_playerHasTool('watering_can')) {
      developer.log('[FarmManager] Player needs watering can');
      return false;
    }

    // 2. Obter tile
    final tile = getTile(x, y);
    if (tile == null || tile.soilState == SoilState.untilled) {
      developer.log('[FarmManager] Cannot water untilled soil');
      return false;
    }

    // 3. Regar
    _farmTiles['${x}_$y'] = tile.water();
    developer.log('[FarmManager] Tile watered successfully');
    return true;
  }

  /// Plantar semente
  bool plantSeed(int x, int y, String seedItemId) {
    developer.log('[FarmManager] Planting $seedItemId at ($x, $y)');

    // 1. Validar que player tem seed
    if (!InventoryManager.instance.hasItem(seedItemId, 1)) {
      developer.log('[FarmManager] Player does not have seed');
      return false;
    }

    // 2. Obter seed do inventário
    final seedItem = _getSeedItemFromInventory(seedItemId);
    if (seedItem == null || seedItem is! SeedItem) {
      developer.log('[FarmManager] Invalid seed item');
      return false;
    }

    // 3. Validar estação
    final currentSeason = WorldStateManager.instance.currentSeason;
    if (!seedItem.canPlantInSeason(currentSeason.name)) {
      developer.log('[FarmManager] Cannot plant in $currentSeason');
      return false;
    }

    // 4. Obter tile
    final tile = getTile(x, y);
    if (tile == null || !tile.canPlant) {
      developer.log('[FarmManager] Cannot plant on this tile');
      return false;
    }

    // 5. Criar crop
    final crop = CropDatabase.createCrop(seedItem.cropId);
    if (crop == null) {
      developer.log('[FarmManager] Invalid crop ID');
      return false;
    }

    // 6. Plantar
    _farmTiles['${x}_$y'] = tile.plant(crop);

    // 7. Remover seed do inventário
    InventoryManager.instance.removeItem(seedItemId, 1);

    developer.log('[FarmManager] Seed planted successfully');
    return true;
  }

  /// Colher crop
  List<Item>? harvestCrop(int x, int y) {
    developer.log('[FarmManager] Harvesting crop at ($x, $y)');

    // 1. Obter tile
    final tile = getTile(x, y);
    if (tile == null || !tile.canHarvest) {
      developer.log('[FarmManager] Nothing to harvest');
      return null;
    }

    final crop = tile.crop!;

    // 2. Criar itens colhidos
    final harvestItem = ItemFactory.createItem(crop.harvestItemId);
    if (harvestItem == null) {
      developer.log('[FarmManager] Invalid harvest item');
      return null;
    }

    final items = List.filled(crop.yieldAmount, harvestItem);

    // 3. Adicionar ao inventário
    for (var item in items) {
      if (!InventoryManager.instance.addItem(item)) {
        developer.log('[FarmManager] Inventory full!');
        break;
      }
    }

    // 4. Limpar tile
    _farmTiles['${x}_$y'] = tile.harvest();

    developer.log('[FarmManager] Harvested ${items.length} x ${crop.name}');
    return items;
  }

  /// Avançar 1 dia (chamado pelo TimeManager)
  void _onNewDay() {
    developer.log('[FarmManager] Advancing all crops 1 day');

    for (var entry in _farmTiles.entries) {
      _farmTiles[entry.key] = entry.value.advanceDay();
    }
  }

  bool _playerHasTool(String toolType) {
    // Verificar equipamento do player
    final equippedWeapon = EquipmentManager.instance
      .getEquippedItem(EquipmentSlotType.weapon);

    if (equippedWeapon is ToolItem && equippedWeapon.toolType == toolType) {
      return true;
    }

    return false;
  }

  Item? _getSeedItemFromInventory(String itemId) {
    // Buscar seed no inventário
    // Implementar...
  }

  // Serialização...
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona
[ ] tillSoil() valida ferramenta
[ ] waterTile() funciona
[ ] plantSeed() valida estação e seed
[ ] harvestCrop() adiciona itens ao inventário
[ ] advanceDay() atualiza todos os tiles
[ ] Serialização funciona

### Critérios de Aceitação

- [ ] Manager completo
- [ ] Todas as interações funcionam
- [ ] Validações robustas
- [ ] Integração com TimeManager
- [ ] Serialização completa

```

---

## 🚀 PROMPT 4: Criar Testes e Integração

### Contexto
Criar testes completos para validar lógica de crescimento e integração com outros sistemas.

### Prompt para o Claude

```

Crie testes completos do sistema de agricultura:

ARQUIVO 1: test/gameplay/farm/farm_manager_test.dart
TESTES:

1. test_till_soil_requires_hoe
2. test_water_tile_requires_watering_can
3. test_plant_seed_validates_season
4. test_plant_seed_removes_from_inventory
5. test_harvest_adds_items_to_inventory
6. test_harvest_clears_tile
7. test_advance_day_grows_crops
8. test_serialization_roundtrip

ARQUIVO 2: test/gameplay/farm/crop_growth_test.dart
TESTES:

1. test_crop_advances_stages_correctly
2. test_crop_becomes_mature_after_days
3. test_watered_soil_grows_faster
4. test_fertilized_soil_grows_fastest
5. test_crop_cannot_grow_in_wrong_season

INTEGRAÇÃO:

- Adicionar farmData ao SaveData
- Salvar/carregar fazenda automaticamente
- Testar roundtrip completo

CHECKLIST DE VALIDAÇÃO:
[ ] Todos os testes passam
[ ] Cobertura >= 80%
[ ] Integração com SaveManager funciona
[ ] Integração com TimeManager funciona

### Critérios de Aceitação

- [ ] Testes completos
- [ ] Lógica de crescimento validada
- [ ] Integrações funcionais

```

---

## 🚀 PROMPT 5: Criar Renderização Visual

### Contexto
Criar componente visual para renderizar tiles de fazenda no mapa usando Bonfire.

### Prompt para o Claude

```

Crie o FarmRenderer para visualização:

ARQUIVO: lib/gameplay/farm/farm_renderer.dart

REQUISITOS:

1. Componente Bonfire:

   - Herdar de GameComponent
   - Renderizar tiles de fazenda no mapa
   - Mostrar sprites diferentes para cada estágio

2. Sprites:

   - Untilled: terra normal
   - Tilled: terra arada
   - Watered: terra molhada
   - Seed: sprite da semente
   - Sprout/Growing/Mature: sprites da crop

3. Animações:

   - Transição suave entre estágios
   - Efeito de água ao regar
   - Partículas ao colher

4. Interação:
   - Highlight ao passar mouse
   - Mostrar tooltip com info da crop
   - Mostrar progresso de crescimento

PADRÃO DE CÓDIGO:

```dart
class FarmTileComponent extends GameComponent {
  final FarmTile farmTile;

  FarmTileComponent(this.farmTile);

  @override
  void render(Canvas canvas) {
    // Renderizar solo
    _renderSoil(canvas);

    // Renderizar crop (se existir)
    if (farmTile.crop != null) {
      _renderCrop(canvas);
    }
  }

  void _renderSoil(Canvas canvas) {
    // Escolher sprite baseado em soilState
    // Implementar...
  }

  void _renderCrop(Canvas canvas) {
    // Escolher sprite baseado em stage
    // Implementar...
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Tiles renderizam corretamente
[ ] Sprites mudam com estágio
[ ] Animações funcionam
[ ] Performance adequada (60 FPS)

### Critérios de Aceitação

- [ ] Renderização funcional
- [ ] Sprites para todos os estágios
- [ ] Animações suaves
- [ ] Performance boa

```

---

## 📊 Checklist de Conclusão da Fase 2.2

### Arquivos Criados
- [ ] Modelos (Crop, FarmTile, SoilState, CropStage)
- [ ] CropDatabase + JSON
- [ ] FarmManager
- [ ] FarmRenderer
- [ ] Testes completos

### Funcionalidades Validadas
- [ ] Plantar/Colher funciona
- [ ] Crescimento automático funciona
- [ ] Validação de estação funciona
- [ ] Integração com TimeManager
- [ ] Serialização completa

### Próximos Passos
⏭️ Avançar para **FASE 3.1** - Sistema de Combate Base

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
