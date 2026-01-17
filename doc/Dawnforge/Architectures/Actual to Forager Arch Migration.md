# 🔄 REFATORAÇÃO: STARDEW → FORAGER (Estrutura Modular)

---

## 📊 **MAPEAMENTO: O QUE MANTER vs REMOVER vs ADAPTAR**

### ✅ **MANTER (Core para Forager)**

- `global/` → input, state machine
- `inventory/`
- `characters/player/`
- `characters/enemies/` (simplificar)
- `database/` (adaptar para Forager items)
- `world/grid_tile.dart`
- `systems/audio/`
- `systems/camera/`
- `systems/combat/`
- `systems/save/`
- `systems/ui/`

### ❌ **REMOVER (Específico de Stardew)**

- `farm/` (Forager não tem farming)
- `mine/` (substituir por resource gathering)
- `characters/npcs/` (Forager não tem NPCs)
- `market/` (sem trading no MVP)
- `time/` (sem calendário/estações)
- `decorations/life_potion/` (simplificar)
- `systems/world/season.dart`

### 🔄 **ADAPTAR/RENOMEAR**

- `database/crop_database.dart` → `item_database.dart`
- `FarmTile` → `ResourceTile`
- `MineTile` → `GatherableTile`

---

## 🎯 **NOVA ESTRUTURA FORAGER (Modular + Packages)**

```
forager_game/
│
├── packages/                                    # 🔥 REUTILIZÁVEIS
│   ├── core_engine/
│   │   └── lib/
│   │       ├── game_loop/
│   │       ├── camera/                          # ← Mover systems/camera/
│   │       └── input/                           # ← Mover global/global_input_handler
│   │
│   ├── tile_system/
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── grid_tile.dart              # ← Mover world/grid_tile.dart
│   │       │   └── tile_position.dart
│   │       ├── grid_manager.dart
│   │       └── world_generator.dart
│   │
│   ├── inventory_system/
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── item.dart
│   │       │   ├── inventory.dart
│   │       │   └── item_stack.dart
│   │       ├── ui/
│   │       │   └── inventory_widget.dart       # ← Mover features/inventory/
│   │       └── inventory_manager.dart
│   │
│   ├── crafting_system/
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── recipe.dart
│   │       │   └── ingredient.dart
│   │       ├── ui/
│   │       │   └── crafting_menu.dart
│   │       └── crafting_manager.dart
│   │
│   ├── combat_system/
│   │   └── lib/
│   │       ├── entities/
│   │       │   ├── combatant.dart
│   │       │   └── health.dart
│   │       ├── ai/
│   │       │   └── enemy_ai.dart               # ← Mover characters/enemies/
│   │       └── combat_manager.dart             # ← Adaptar systems/combat/
│   │
│   ├── progression_system/
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── skill.dart                  # NOVO
│   │       │   ├── skill_tree.dart             # NOVO
│   │       │   └── experience.dart             # NOVO
│   │       ├── ui/
│   │       │   └── skill_tree_widget.dart      # NOVO
│   │       └── progression_manager.dart
│   │
│   ├── resource_system/                         # NOVO (core do Forager)
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── resource.dart
│   │       │   ├── resource_node.dart
│   │       │   └── gatherable.dart
│   │       ├── spawner/
│   │       │   └── resource_spawner.dart
│   │       └── resource_manager.dart
│   │
│   ├── building_system/                         # NOVO
│   │   └── lib/
│   │       ├── models/
│   │       │   ├── building.dart
│   │       │   └── placeable.dart
│   │       ├── ui/
│   │       │   └── build_menu.dart
│   │       └── building_manager.dart
│   │
│   ├── save_system/
│   │   └── lib/
│   │       ├── models/
│   │       │   └── save_data.dart
│   │       ├── serializers/
│   │       │   └── json_serializer.dart
│   │       └── save_manager.dart               # ← Mover systems/save/
│   │
│   ├── audio_system/
│   │   └── lib/
│   │       ├── audio_manager.dart              # ← Mover systems/audio/
│   │       ├── music_player.dart
│   │       └── sfx_player.dart
│   │
│   └── ui_system/
│       └── lib/
│           ├── design_system/
│           │   ├── tokens.dart
│           │   ├── colors.dart
│           │   └── typography.dart
│           ├── widgets/
│           │   ├── game_button.dart            # ← Mover systems/ui/
│           │   ├── game_panel.dart
│           │   └── tooltip.dart
│           └── overlays/
│               ├── pause_menu.dart
│               └── settings_menu.dart          # ← Mover global/global_state_ui_overlay
│
├── lib/                                         # 🎮 GAME ESPECÍFICO
│   ├── core/
│   │   ├── game_coordinator.dart               # NOVO (orquestra tudo)
│   │   └── game_context.dart                   # NOVO
│   │
│   ├── entities/
│   │   ├── player/
│   │   │   └── player.dart                     # ← Mover characters/player/
│   │   │
│   │   ├── enemies/
│   │   │   ├── slime.dart                      # ← Adaptar characters/enemies/
│   │   │   ├── skeleton.dart
│   │   │   └── enemy_spawner.dart
│   │   │
│   │   └── structures/                         # NOVO
│   │       ├── furnace.dart                    # ← Adaptar decorations/
│   │       ├── workbench.dart
│   │       └── chest.dart
│   │
│   ├── tiles/                                   # Herança de GridTile
│   │   ├── resource_tile.dart                  # ← Renomear FarmTile + MineTile
│   │   ├── tree_tile.dart                      # NOVO
│   │   ├── rock_tile.dart                      # NOVO
│   │   ├── ore_tile.dart                       # NOVO
│   │   └── grass_tile.dart                     # NOVO
│   │
│   ├── items/                                   # Implementações de Item
│   │   ├── tools/
│   │   │   ├── pickaxe.dart                    # ← Adaptar database/tool_item_database
│   │   │   ├── axe.dart
│   │   │   └── sword.dart
│   │   │
│   │   ├── resources/
│   │   │   ├── wood.dart                       # ← Adaptar database/material_database
│   │   │   ├── stone.dart
│   │   │   ├── iron_ore.dart
│   │   │   └── coal.dart
│   │   │
│   │   └── consumables/
│   │       ├── health_potion.dart              # ← Mover decorations/life_potion
│   │       └── energy_potion.dart
│   │
│   ├── world/
│   │   ├── island.dart                         # NOVO (biomas)
│   │   ├── biome.dart                          # NOVO
│   │   └── world_state.dart                    # ← Adaptar systems/world/world_state_manager
│   │
│   ├── data/                                    # Databases consolidadas
│   │   ├── item_database.dart                  # ← Merge todos database/
│   │   ├── recipe_database.dart                # NOVO
│   │   ├── skill_database.dart                 # NOVO
│   │   └── enemy_database.dart                 # NOVO
│   │
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── main_menu.dart
│   │   │   ├── game_screen.dart
│   │   │   └── loading_screen.dart
│   │   │
│   │   └── hud/
│   │       ├── health_bar.dart
│   │       ├── energy_bar.dart                 # NOVO
│   │       ├── hotbar.dart
│   │       └── minimap.dart
│   │
│   └── main.dart
│
├── assets/
│   ├── images/
│   ├── audio/
│   └── data/
│
└── pubspec.yaml
```

---

## 🔄 **PLANO DE MIGRAÇÃO (Passo a Passo)**

### **FASE 1: Criar Packages (Semana 1)**

#### **Dia 1: Setup estrutura**

bash

Copy code

`# Criar packages mkdir -p packages/{core_engine,tile_system,inventory_system,crafting_system,combat_system,progression_system,resource_system,building_system,save_system,audio_system,ui_system}/lib`

#### **Dia 2-3: Mover código existente**

**1. tile_system package:**

bash

Copy code

`# Mover mv lib/features/world/grid_tile.dart packages/tile_system/lib/models/ mv lib/features/world/tile_object.dart packages/tile_system/lib/models/ mv lib/features/world/tile_object_type.dart packages/tile_system/lib/models/`

**2. inventory_system package:**

bash

Copy code

`mv lib/features/inventory/* packages/inventory_system/lib/`

**3. combat_system package:**

bash

Copy code

`mv lib/systems/combat/* packages/combat_system/lib/ mv lib/features/characters/enemies/* packages/combat_system/lib/ai/`

**4. audio_system package:**

bash

Copy code

`mv lib/systems/audio/* packages/audio_system/lib/`

**5. save_system package:**

bash

Copy code

`mv lib/systems/save/* packages/save_system/lib/`

**6. core_engine package:**

bash

Copy code

`mv lib/global/global_input_handler.dart packages/core_engine/lib/input/ mv lib/systems/camera/* packages/core_engine/lib/camera/`

**7. ui_system package:**

bash

Copy code

`mv lib/systems/ui/* packages/ui_system/lib/widgets/ mv lib/global/global_state_ui_overlay.dart packages/ui_system/lib/overlays/`

---

### **FASE 2: Adaptar para Forager (Semana 2)**

#### **1. Consolidar Databases**

dart

Copy code

`// lib/data/item_database.dart import 'package:inventory_system/inventory_system.dart';  class ItemDatabase {   static final Map<String, Item> _items = {};      static void initialize() {     // Recursos (ex material_database)     registerItem(WoodItem());     registerItem(StoneItem());     registerItem(IronOreItem());          // Ferramentas (ex tool_item_database)     registerItem(PickaxeItem());     registerItem(AxeItem());          // Consumíveis     registerItem(HealthPotionItem());          // Remover: crop_database, seed_bag_database (não existem no Forager)   }      static void registerItem(Item item) {     _items[item.id] = item;   }      static Item? getItem(String id) => _items[id]; }`

#### **2. Converter FarmTile → ResourceTile**

dart

Copy code

`// lib/tiles/resource_tile.dart import 'package:tile_system/tile_system.dart';  // ANTES: FarmTile (farming logic) // DEPOIS: ResourceTile (gathering logic)  class ResourceTile extends GridTile {   final ResourceType type; // tree, rock, ore   int health;      ResourceTile({     required TilePosition position,     required this.type,   }) : health = type.maxHealth,        super(position: position, id: 'resource_${type.name}_${position.x}_${position.y}');      @override   void onInteract() {     // Player gathering with tool     health -= 10;          if (health <= 0) {       _dropResources();       // Remove from grid     }   }      void _dropResources() {     // Drop wood, stone, ore, etc   } }  // lib/tiles/tree_tile.dart class TreeTile extends ResourceTile {   TreeTile({required TilePosition position})       : super(position: position, type: ResourceType.tree);      @override   void _dropResources() {     // Drop 3-5 wood   } }`

#### **3. Remover código Stardew-specific**

bash

Copy code

`# Deletar rm -rf lib/features/farm/           # Farming não existe no Forager rm -rf lib/features/mine/           # Mining simplificado rm -rf lib/features/market/         # Sem trading no MVP rm -rf lib/features/characters/npcs/ # Sem NPCs rm -rf lib/systems/time/            # Sem calendário rm lib/systems/world/season.dart    # Sem estações rm lib/features/database/crop_database.dart rm lib/features/database/seed_bag_database.dart`

---

### **FASE 3: Adicionar Sistemas Forager (Semana 3-4)**

#### **1. Criar progression_system (NOVO)**

dart

Copy code

`// packages/progression_system/lib/models/skill.dart class Skill {   final String id;   final String name;   final int cost;   final List<String> dependencies;      Skill({     required this.id,     required this.name,     required this.cost,     this.dependencies = const [],   }); }  // lib/data/skill_database.dart class SkillDatabase {   static void initialize() {     registerSkill(Skill(       id: 'mining_speed',       name: 'Faster Mining',       cost: 1,     ));          registerSkill(Skill(       id: 'double_loot',       name: 'Lucky Gatherer',       cost: 2,       dependencies: ['mining_speed'],     ));   } }`

#### **2. Criar building_system (NOVO)**

dart

Copy code

`// packages/building_system/lib/models/building.dart abstract class Building {   final String id;   final TilePosition position;      Building({required this.id, required this.position});      void onInteract();   void update(double dt); }  // lib/entities/structures/furnace.dart class Furnace extends Building {   Item? inputItem;   Item? outputItem;   double processTimer = 0.0;      @override   void onInteract() {     // Open furnace UI   }      @override   void update(double dt) {     if (inputItem != null) {       processTimer += dt;              if (processTimer >= 5.0) { // 5 seconds         outputItem = _smelt(inputItem!);         inputItem = null;         processTimer = 0.0;       }     }   }      Item _smelt(Item input) {     // iron_ore → iron_bar     return IronBarItem();   } }`

#### **3. Criar resource_system (NOVO)**

dart

Copy code

`// packages/resource_system/lib/spawner/resource_spawner.dart class ResourceSpawner {   final GridManager gridManager;   final Random random;      ResourceSpawner(this.gridManager) : random = Random();      void spawnResources(Biome biome, int count) {     for (int i = 0; i < count; i++) {       var pos = _findEmptyPosition();              if (biome == Biome.forest) {         gridManager.setTile(TreeTile(position: pos));       } else if (biome == Biome.desert) {         gridManager.setTile(CactusTile(position: pos));       }     }   }      TilePosition _findEmptyPosition() {     // Find empty spot     return TilePosition(0, 0);   } }`

---

### **FASE 4: Integração (Semana 5)**

#### **Criar GameCoordinator**

dart

Copy code

`// lib/core/game_coordinator.dart import 'package:core_engine/core_engine.dart'; import 'package:tile_system/tile_system.dart'; import 'package:inventory_system/inventory_system.dart'; import 'package:crafting_system/crafting_system.dart'; import 'package:progression_system/progression_system.dart'; import 'package:combat_system/combat_system.dart'; import 'package:building_system/building_system.dart'; import 'package:resource_system/resource_system.dart'; import 'package:save_system/save_system.dart'; import 'package:audio_system/audio_system.dart';  class GameCoordinator {   // Systems (packages)   late final GridManager gridManager;   late final InventoryManager inventoryManager;   late final CraftingManager craftingManager;   late final ProgressionManager progressionManager;   late final CombatManager combatManager;   late final BuildingManager buildingManager;   late final ResourceSpawner resourceSpawner;   late final SaveManager saveManager;   late final AudioManager audioManager;      // Game entities (game-specific)   late final Player player;   late final WorldState worldState;      void init() {     // Initialize systems     gridManager = GridManager(width: 100, height: 100);     inventoryManager = InventoryManager(       inventory: Inventory(rows: 5, columns: 10),     );     craftingManager = CraftingManager();     progressionManager = ProgressionManager();     combatManager = CombatManager();     buildingManager = BuildingManager(gridManager);     resourceSpawner = ResourceSpawner(gridManager);     audioManager = AudioManager();          // Load databases     ItemDatabase.initialize();     RecipeDatabase.initialize();     SkillDatabase.initialize();     EnemyDatabase.initialize();          // Generate world     _generateWorld();          // Spawn player     player = Player(position: TilePosition(50, 50));   }      void _generateWorld() {     // Generate starting island (forest biome)     WorldGenerator generator = WorldGenerator();     var tiles = generator.generate(       width: 50,       height: 50,       biome: Biome.forest,     );          for (var tile in tiles.values) {       gridManager.setTile(tile);     }          // Spawn resources     resourceSpawner.spawnResources(Biome.forest, 100);   }      void update(double dt) {     gridManager.updateAll(dt);     player.update(dt);     combatManager.update(dt);     buildingManager.update(dt);   } }`

---

## 📝 **CHECKLIST DE MIGRAÇÃO**

### **Semana 1: Packages Setup**

- [ ]  Criar 10 packages (estrutura de pastas)
- [ ]  Mover `grid_tile.dart` → `tile_system`
- [ ]  Mover `inventory/` → `inventory_system`
- [ ]  Mover `combat/` → `combat_system`
- [ ]  Mover `audio/` → `audio_system`
- [ ]  Mover `save/` → `save_system`
- [ ]  Mover `camera/` + `input/` → `core_engine`
- [ ]  Mover `ui/` → `ui_system`
- [ ]  Atualizar `pubspec.yaml` (dependencies locais)

### **Semana 2: Adaptar Stardew → Forager**

- [ ]  Consolidar databases (4 → 1 `item_database.dart`)
- [ ]  Converter `FarmTile` → `ResourceTile`
- [ ]  Deletar `farm/`, `mine/`, `market/`, `npcs/`, `time/`
- [ ]  Simplificar enemies (3-5 tipos básicos)
- [ ]  Remover `season.dart`, `crop_database.dart`

### **Semana 3: Adicionar Features Forager**

- [ ]  Criar `progression_system` (skills + XP)
- [ ]  Criar `building_system` (estruturas colocáveis)
- [ ]  Criar `resource_system` (spawner + gathering)
- [ ]  Criar `SkillDatabase` (20 skills)
- [ ]  Criar `RecipeDatabase` (30 recipes)

### **Semana 4: Integração**

- [ ]  Criar `GameCoordinator`
- [ ]  Integrar todos os systems
- [ ]  Testar core loop (gather → craft → build)
- [ ]  Polish input actions
- [ ]  Testar save/load

---

## 🎯 **RESULTADO FINAL**

### **Estrutura Modular:**

- ✅ **10 packages reutilizáveis** (próximos jogos)
- ✅ **Código game-specific** em `lib/`
- ✅ **Separação clara** (systems vs game logic)

### **Código Removido:**

- ❌ ~30% deletado (features Stardew)
- ❌ Databases consolidados (4 → 1)
- ❌ NPCs, farming, time system

### **Código Novo:**

- ✅ `progression_system` (skills)
- ✅ `building_system` (estruturas)
- ✅ `resource_system` (gathering)
- ✅ `GameCoordinator` (orquestração)

---

## 🚀 **PRÓXIMOS 7 DIAS**

### **Dia 1-2:**

bash

Copy code

`# Criar packages mkdir -p packages/{tile_system,inventory_system,combat_system}/lib  # Mover arquivos críticos mv lib/features/world/grid_tile.dart packages/tile_system/lib/models/`

### **Dia 3-4:**

- Atualizar imports
- Testar build (`flutter pub get`)
- Garantir que compila

### **Dia 5-7:**

- Deletar código Stardew
- Consolidar databases
- Criar `ResourceTile`

**Entregável:** Projeto compila com nova estrutura 🎮

---

Quer o código completo de algum package específico ou ajuda com a migração de um sistema? 🔥