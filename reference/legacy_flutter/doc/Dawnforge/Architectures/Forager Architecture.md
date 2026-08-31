# 🎮 FORAGER MVP - ROADMAP COMPLETO + ARQUITETURA MODULAR

---

## 📋 **ESCOPO DO MVP (6-8 MESES)**

### **Features ESSENCIAIS (In Scope)**

✅ Gathering (minerar, cortar árvores, colher) ✅ Crafting básico (20-30 receitas) ✅ Building (10-15 estruturas) ✅ Combat básico (3-5 tipos de inimigos) ✅ Inventory grid (expandível) ✅ Skill tree (15-20 skills) ✅ Resource management ✅ Island expansion (4-6 ilhas) ✅ Save/Load system ✅ Tutorial básico

### **Features FORA do MVP (Post-Launch)**

❌ Dungeons/Bosses ❌ Quests complexas ❌ NPCs/Trading ❌ Multiplayer ❌ Achievements avançados ❌ Pets/Companions ❌ Weather system

---

## 🗓️ **ROADMAP DETALHADO - 24 SEMANAS**

---

### **🏗️ FASE 1: FOUNDATION (Semanas 1-4)**

#### **Semana 1: Setup + Core Architecture**

- [ ]  Setup projeto Flutter + Flame + Bonfire
- [ ]  Estrutura de pastas modular (ver arquitetura abaixo)
- [ ]  Design System base (tokens, cores, tipografia)
- [ ]  Game Loop básico
- [ ]  Camera controller
- [ ]  Input system abstrato

**Entregável:** Tela vazia com player movendo

---

#### **Semana 2: Tile System + World Generation**

- [ ]  GridTile base system
- [ ]  ResourceTile (árvores, pedras, minérios)
- [ ]  World generator (ilha inicial 20x20)
- [ ]  Collision system
- [ ]  Tile rendering otimizado

**Entregável:** Mundo gerado com tiles clicáveis

---

#### **Semana 3: Gathering System**

- [ ]  Tool system (picareta, machado, enxada)
- [ ]  Resource harvesting logic
- [ ]  Drop items no chão
- [ ]  Animações de coleta
- [ ]  Particle effects básicos

**Entregável:** Minerar pedra, cortar árvore

---

#### **Semana 4: Inventory System**

- [ ]  Inventory grid UI (responsive)
- [ ]  Drag & drop items
- [ ]  Stack items
- [ ]  Item tooltips
- [ ]  Hotbar (quick access)

**Entregável:** UI de inventário funcional

---

### **⚙️ FASE 2: CORE LOOP (Semanas 5-10)**

#### **Semana 5: Crafting System - Base**

- [ ]  Crafting UI (lista de receitas)
- [ ]  Recipe validation (check resources)
- [ ]  Craft item logic
- [ ]  Unlock system (receitas descobertas)
- [ ]  10 receitas básicas (tools, estruturas)

**Entregável:** Craftar primeiras ferramentas

---

#### **Semana 6: Building System**

- [ ]  PlaceableObject base class
- [ ]  Building placement preview
- [ ]  Grid snapping
- [ ]  Building collision validation
- [ ]  5 estruturas (fornalha, bancada, storage)

**Entregável:** Colocar estruturas no mundo

---

#### **Semana 7: Resource Processing**

- [ ]  Furnace logic (smelt ores)
- [ ]  Processing timer system
- [ ]  Input/Output slots
- [ ]  Recipe para processamento
- [ ]  UI de estruturas interativas

**Entregável:** Minério → Barra de metal

---

#### **Semana 8: Progression System - Part 1**

- [ ]  Experience/Level system
- [ ]  Skill tree data structure
- [ ]  Skill tree UI (visual nodes)
- [ ]  Unlock skills logic
- [ ]  10 skills básicas (gathering, combat, crafting)

**Entregável:** Ganhar XP e desbloquear skills

---

#### **Semana 9: Combat System - Base**

- [ ]  Enemy base class
- [ ]  Enemy AI (chase, attack, patrol)
- [ ]  Player attack (melee)
- [ ]  Health system (player + enemies)
- [ ]  Damage calculation
- [ ]  2-3 tipos de inimigos

**Entregável:** Matar inimigos básicos

---

#### **Semana 10: Combat System - Polish**

- [ ]  Enemy spawner system
- [ ]  Loot drops de inimigos
- [ ]  Knockback effects
- [ ]  Death animations
- [ ]  Respawn player

**Entregável:** Combat loop completo

---

### **🎨 FASE 3: CONTENT + POLISH (Semanas 11-16)**

#### **Semana 11: Island Expansion**

- [ ]  Island purchase system
- [ ]  Unlock new biomes (forest, desert, snow)
- [ ]  Biome-specific resources
- [ ]  Bridge/portal para outras ilhas
- [ ]  Cost balancing

**Entregável:** Comprar 2ª ilha

---

#### **Semana 12: Advanced Crafting**

- [ ]  20+ novas receitas
- [ ]  Tier system (wood → stone → iron → gold)
- [ ]  Upgrade tools
- [ ]  Crafting categories (UI tabs)
- [ ]  Rare resources

**Entregável:** 30 receitas total

---

#### **Semana 13: Progression System - Part 2**

- [ ]  10 skills adicionais
- [ ]  Skill effects implementation
- [ ]  Passive bonuses
- [ ]  Skill tree balancing
- [ ]  Visual feedback (unlocks)

**Entregável:** 20 skills total

---

#### **Semana 14: Economy System**

- [ ]  Currency system
- [ ]  Item value (preço base)
- [ ]  Shop UI básica (comprar/vender)
- [ ]  Shop inventory rotation
- [ ]  Balance economy

**Entregável:** Vender recursos, comprar items

---

#### **Semana 15: Quality of Life - Part 1**

- [ ]  Settings menu (audio, graphics, controls)
- [ ]  Pause menu
- [ ]  Keyboard shortcuts
- [ ]  Controller support (básico)
- [ ]  UI scaling (mobile/desktop)

**Entregável:** UX polido

---

#### **Semana 16: Save/Load System**

- [ ]  Save game state (JSON/SQLite)
- [ ]  Load game state
- [ ]  Auto-save (a cada 5 min)
- [ ]  Multiple save slots
- [ ]  Save metadata (timestamp, playtime)

**Entregável:** Persistência completa

---

### **✨ FASE 4: BETA PREP (Semanas 17-20)**

#### **Semana 17: Tutorial System**

- [ ]  Tutorial manager (state machine)
- [ ]  Step-by-step guide (primeiros 10 min)
- [ ]  Highlight UI elements
- [ ]  Tutorial tooltips
- [ ]  Skip tutorial option

**Entregável:** Onboarding completo

---

#### **Semana 18: Audio System**

- [ ]  Background music (3-4 tracks)
- [ ]  SFX (gather, craft, combat, UI)
- [ ]  Audio mixing
- [ ]  Volume controls
- [ ]  Spatial audio (enemies)

**Entregável:** Áudio imersivo

---

#### **Semana 19: Visual Polish**

- [ ]  Particle effects (mining, crafting, levelup)
- [ ]  Screen shake (combat, explosions)
- [ ]  Smooth transitions
- [ ]  Lighting effects básicos
- [ ]  UI animations (menus)

**Entregável:** Game feels juicy

---

#### **Semana 20: Content Balance**

- [ ]  Playtest interno (10h gameplay)
- [ ]  Balance recursos (drop rates)
- [ ]  Balance combat (dificuldade)
- [ ]  Balance economia (preços)
- [ ]  Ajustar progression curve

**Entregável:** Game balanceado

---

### **🚀 FASE 5: LAUNCH PREP (Semanas 21-24)**

#### **Semana 21: Bug Fixing**

- [ ]  Fix critical bugs
- [ ]  Performance optimization
- [ ]  Memory leak fixes
- [ ]  Edge case handling
- [ ]  Crash analytics setup

---

#### **Semana 22: Mobile Optimization**

- [ ]  Touch controls polish
- [ ]  UI responsive (tablets/phones)
- [ ]  Performance mobile (60fps)
- [ ]  Battery optimization
- [ ]  APK size optimization

---

#### **Semana 23: Store Assets**

- [ ]  Screenshots (6-8 images)
- [ ]  Trailer (1-2 min)
- [ ]  Store description
- [ ]  Icon/Logo
- [ ]  Press kit

---

#### **Semana 24: Soft Launch**

- [ ]  Deploy Beta (TestFlight/Google Play Beta)
- [ ]  20-50 beta testers
- [ ]  Feedback collection
- [ ]  Final adjustments
- [ ]  Launch Early Access

---

## 🏗️ **ARQUITETURA MODULAR - PACKAGES REUTILIZÁVEIS**

### **Estrutura de Projeto**

```
forager_game/
├── packages/                          # 🔥 PACKAGES REUTILIZÁVEIS
│   ├── core_game_engine/             # Package 1
│   │   ├── lib/
│   │   │   ├── game_loop/
│   │   │   │   ├── game_controller.dart
│   │   │   │   ├── game_state.dart
│   │   │   │   └── game_lifecycle.dart
│   │   │   ├── camera/
│   │   │   │   ├── camera_controller.dart
│   │   │   │   └── camera_follow.dart
│   │   │   ├── input/
│   │   │   │   ├── input_handler.dart
│   │   │   │   ├── input_action.dart
│   │   │   │   └── input_mapper.dart
│   │   │   └── core_game_engine.dart
│   │   └── pubspec.yaml
│   │
│   ├── tile_system/                   # Package 2
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── grid_tile.dart
│   │   │   │   ├── tile_position.dart
│   │   │   │   └── tile_data.dart
│   │   │   ├── grid_manager.dart
│   │   │   ├── tile_renderer.dart
│   │   │   ├── world_generator.dart
│   │   │   └── tile_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── inventory_system/              # Package 3
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── item.dart
│   │   │   │   ├── inventory.dart
│   │   │   │   └── inventory_slot.dart
│   │   │   ├── ui/
│   │   │   │   ├── inventory_widget.dart
│   │   │   │   ├── item_slot_widget.dart
│   │   │   │   └── drag_drop_handler.dart
│   │   │   ├── inventory_manager.dart
│   │   │   └── inventory_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── crafting_system/               # Package 4
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── recipe.dart
│   │   │   │   ├── ingredient.dart
│   │   │   │   └── crafting_station.dart
│   │   │   ├── ui/
│   │   │   │   ├── crafting_menu.dart
│   │   │   │   └── recipe_list.dart
│   │   │   ├── crafting_manager.dart
│   │   │   └── crafting_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── combat_system/                 # Package 5
│   │   ├── lib/
│   │   │   ├── entities/
│   │   │   │   ├── combatant.dart
│   │   │   │   ├── health_component.dart
│   │   │   │   └── damage_dealer.dart
│   │   │   ├── ai/
│   │   │   │   ├── enemy_ai.dart
│   │   │   │   └── behavior_tree.dart
│   │   │   ├── combat_manager.dart
│   │   │   └── combat_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── progression_system/            # Package 6
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── skill.dart
│   │   │   │   ├── skill_tree.dart
│   │   │   │   └── experience.dart
│   │   │   ├── ui/
│   │   │   │   ├── skill_tree_widget.dart
│   │   │   │   └── skill_node_widget.dart
│   │   │   ├── progression_manager.dart
│   │   │   └── progression_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── save_system/                   # Package 7
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── save_data.dart
│   │   │   │   └── save_metadata.dart
│   │   │   ├── serializers/
│   │   │   │   ├── json_serializer.dart
│   │   │   │   └── compressor.dart
│   │   │   ├── storage/
│   │   │   │   ├── local_storage.dart
│   │   │   │   └── cloud_storage.dart
│   │   │   ├── save_manager.dart
│   │   │   └── save_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── audio_system/                  # Package 8
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   │   ├── audio_clip.dart
│   │   │   │   └── audio_settings.dart
│   │   │   ├── audio_manager.dart
│   │   │   ├── music_player.dart
│   │   │   ├── sfx_player.dart
│   │   │   └── audio_system.dart
│   │   └── pubspec.yaml
│   │
│   ├── ui_system/                     # Package 9
│   │   ├── lib/
│   │   │   ├── design_system/
│   │   │   │   ├── tokens.dart
│   │   │   │   ├── colors.dart
│   │   │   │   ├── typography.dart
│   │   │   │   └── spacing.dart
│   │   │   ├── widgets/
│   │   │   │   ├── game_button.dart
│   │   │   │   ├── game_dialog.dart
│   │   │   │   ├── game_panel.dart
│   │   │   │   └── tooltip.dart
│   │   │   ├── overlays/
│   │   │   │   ├── pause_menu.dart
│   │   │   │   └── settings_menu.dart
│   │   │   └── ui_system.dart
│   │   └── pubspec.yaml
│   │
│   └── resource_system/               # Package 10
│       ├── lib/
│       │   ├── models/
│       │   │   ├── resource.dart
│       │   │   ├── resource_node.dart
│       │   │   └── gatherable.dart
│       │   ├── spawner/
│       │   │   ├── resource_spawner.dart
│       │   │   └── spawn_rules.dart
│       │   ├── resource_manager.dart
│       │   └── resource_system.dart
│       └── pubspec.yaml
│
├── lib/                               # 🎮 GAME ESPECÍFICO
│   ├── game/
│   │   ├── entities/
│   │   │   ├── player.dart
│   │   │   ├── enemies/
│   │   │   │   ├── slime.dart
│   │   │   │   ├── skeleton.dart
│   │   │   │   └── goblin.dart
│   │   │   └── structures/
│   │   │       ├── furnace.dart
│   │   │       ├── workbench.dart
│   │   │       └── chest.dart
│   │   │
│   │   ├── tiles/
│   │   │   ├── resource_tile.dart     # Extends GridTile
│   │   │   ├── tree_tile.dart
│   │   │   ├── rock_tile.dart
│   │   │   └── ore_tile.dart
│   │   │
│   │   ├── items/
│   │   │   ├── tools/
│   │   │   │   ├── pickaxe.dart
│   │   │   │   ├── axe.dart
│   │   │   │   └── sword.dart
│   │   │   └── resources/
│   │   │       ├── wood.dart
│   │   │       ├── stone.dart
│   │   │       └── iron_ore.dart
│   │   │
│   │   ├── world/
│   │   │   ├── island.dart
│   │   │   ├── biome.dart
│   │   │   └── world_state.dart
│   │   │
│   │   └── game_coordinator.dart      # Integra todos os systems
│   │
│   ├── data/
│   │   ├── recipes/
│   │   │   └── recipe_database.dart
│   │   ├── items/
│   │   │   └── item_database.dart
│   │   ├── enemies/
│   │   │   └── enemy_database.dart
│   │   └── skills/
│   │       └── skill_database.dart
│   │
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── main_menu.dart
│   │   │   ├── game_screen.dart
│   │   │   └── loading_screen.dart
│   │   └── hud/
│   │       ├── health_bar.dart
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

## 🔧 **ARQUITETURA DOS PACKAGES - DETALHADO**

### **Package 1: core_game_engine**

dart

Copy code

`// lib/core_game_engine.dart library core_game_engine;  export 'game_loop/game_controller.dart'; export 'game_loop/game_state.dart'; export 'camera/camera_controller.dart'; export 'input/input_handler.dart'; export 'input/input_action.dart';  // game_loop/game_controller.dart abstract class GameController {   void init();   void update(double dt);   void render(Canvas canvas);   void dispose(); }  // input/input_action.dart enum InputAction {   moveUp,   moveDown,   moveLeft,   moveRight,   interact,   attack,   openInventory,   openCrafting, }  // input/input_handler.dart class InputHandler {   final Map<InputAction, Set<LogicalKeyboardKey>> _keyBindings = {};   final Map<InputAction, VoidCallback> _actionCallbacks = {};      void registerAction(InputAction action, Set<LogicalKeyboardKey> keys) {     _keyBindings[action] = keys;   }      void onAction(InputAction action, VoidCallback callback) {     _actionCallbacks[action] = callback;   }      void handleKeyEvent(RawKeyEvent event) {     // Implementation   } }`

---

### **Package 2: tile_system**

dart

Copy code

`// lib/tile_system.dart library tile_system;  export 'models/grid_tile.dart'; export 'models/tile_position.dart'; export 'grid_manager.dart'; export 'world_generator.dart';  // models/grid_tile.dart abstract class GridTile {   final TilePosition position;   final String id;   bool isWalkable;   bool isInteractable;      GridTile({     required this.position,     required this.id,     this.isWalkable = true,     this.isInteractable = false,   });      // Lifecycle   void onInit() {}   void onUpdate(double dt) {}   void onRender(Canvas canvas) {}   void onInteract() {}   void onDestroy() {}      // Para herança   Map<String, dynamic> toJson();   static GridTile fromJson(Map<String, dynamic> json); }  // models/tile_position.dart class TilePosition {   final int x;   final int y;      const TilePosition(this.x, this.y);      double distanceTo(TilePosition other) {     return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));   }      List<TilePosition> getNeighbors() {     return [       TilePosition(x + 1, y),       TilePosition(x - 1, y),       TilePosition(x, y + 1),       TilePosition(x, y - 1),     ];   }      @override   bool operator ==(Object other) =>       other is TilePosition && x == other.x && y == other.y;      @override   int get hashCode => Object.hash(x, y); }  // grid_manager.dart class GridManager {   final Map<TilePosition, GridTile> _tiles = {};   final int width;   final int height;      GridManager({required this.width, required this.height});      void setTile(GridTile tile) {     _tiles[tile.position] = tile;   }      GridTile? getTile(TilePosition position) {     return _tiles[position];   }      void removeTile(TilePosition position) {     _tiles[position]?.onDestroy();     _tiles.remove(position);   }      List<GridTile> getTilesInRadius(TilePosition center, double radius) {     return _tiles.values         .where((tile) => tile.position.distanceTo(center) <= radius)         .toList();   }      void updateAll(double dt) {     for (var tile in _tiles.values) {       tile.onUpdate(dt);     }   }      void renderAll(Canvas canvas) {     for (var tile in _tiles.values) {       tile.onRender(canvas);     }   }      List<TilePosition> findPath(TilePosition start, TilePosition end) {     // A* pathfinding implementation     return [];   } }  // world_generator.dart class WorldGenerator {   final Random _random;      WorldGenerator({int? seed}) : _random = Random(seed);      Map<TilePosition, GridTile> generate({     required int width,     required int height,     required BiomeType biome,   }) {     // Noise-based generation     return {};   } }`

---

### **Package 3: inventory_system**

dart

Copy code

`// lib/inventory_system.dart library inventory_system;  export 'models/item.dart'; export 'models/inventory.dart'; export 'ui/inventory_widget.dart'; export 'inventory_manager.dart';  // models/item.dart abstract class Item {   final String id;   final String name;   final String description;   final String iconPath;   final int maxStackSize;   final ItemRarity rarity;      Item({     required this.id,     required this.name,     required this.description,     required this.iconPath,     this.maxStackSize = 99,     this.rarity = ItemRarity.common,   });      // Para uso (consumíveis, ferramentas, etc)   void onUse(GameContext context) {}      // Serialização   Map<String, dynamic> toJson();   static Item fromJson(Map<String, dynamic> json); }  enum ItemRarity {   common,   uncommon,   rare,   epic,   legendary, }  // models/inventory.dart class Inventory {   final int rows;   final int columns;   final Map<int, ItemStack> _slots = {};      Inventory({required this.rows, required this.columns});      int get capacity => rows * columns;      bool addItem(Item item, {int quantity = 1}) {     // Try to stack first     for (var entry in _slots.entries) {       if (entry.value.item.id == item.id &&            entry.value.quantity < item.maxStackSize) {         int spaceLeft = item.maxStackSize - entry.value.quantity;         int toAdd = min(spaceLeft, quantity);         entry.value.quantity += toAdd;         quantity -= toAdd;                  if (quantity == 0) return true;       }     }          // Find empty slot     for (int i = 0; i < capacity; i++) {       if (!_slots.containsKey(i)) {         _slots[i] = ItemStack(item: item, quantity: quantity);         return true;       }     }          return false; // Inventory full   }      bool removeItem(String itemId, {int quantity = 1}) {     // Implementation     return true;   }      ItemStack? getSlot(int index) => _slots[index];      void swapSlots(int indexA, int indexB) {     var temp = _slots[indexA];     _slots[indexA] = _slots[indexB];     _slots[indexB] = temp;   }      int count(String itemId) {     return _slots.values         .where((stack) => stack.item.id == itemId)         .fold(0, (sum, stack) => sum + stack.quantity);   }      Map<String, dynamic> toJson() {     return {       'rows': rows,       'columns': columns,       'slots': _slots.map((k, v) => MapEntry(k.toString(), v.toJson())),     };   } }  class ItemStack {   final Item item;   int quantity;      ItemStack({required this.item, required this.quantity});      Map<String, dynamic> toJson() => {     'item': item.toJson(),     'quantity': quantity,   }; }  // ui/inventory_widget.dart class InventoryWidget extends StatefulWidget {   final Inventory inventory;   final Function(Item, int)? onItemSelected;      const InventoryWidget({     Key? key,     required this.inventory,     this.onItemSelected,   }) : super(key: key);      @override   State<InventoryWidget> createState() => _InventoryWidgetState(); }  class _InventoryWidgetState extends State<InventoryWidget> {   int? _draggedSlotIndex;      @override   Widget build(BuildContext context) {     return Container(       padding: EdgeInsets.all(16),       child: GridView.builder(         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(           crossAxisCount: widget.inventory.columns,           crossAxisSpacing: 4,           mainAxisSpacing: 4,         ),         itemCount: widget.inventory.capacity,         itemBuilder: (context, index) {           return ItemSlotWidget(             itemStack: widget.inventory.getSlot(index),             onDragStarted: () => _draggedSlotIndex = index,             onDragAccepted: () {               if (_draggedSlotIndex != null) {                 widget.inventory.swapSlots(_draggedSlotIndex!, index);                 setState(() {});               }             },             onTap: () {               var stack = widget.inventory.getSlot(index);               if (stack != null) {                 widget.onItemSelected?.call(stack.item, stack.quantity);               }             },           );         },       ),     );   } }`

---

### **Package 4: crafting_system**

dart

Copy code

`// lib/crafting_system.dart library crafting_system;  export 'models/recipe.dart'; export 'models/ingredient.dart'; export 'ui/crafting_menu.dart'; export 'crafting_manager.dart';  // models/recipe.dart class Recipe {   final String id;   final String name;   final String description;   final List<Ingredient> ingredients;   final Item output;   final int outputQuantity;   final double craftTime; // seconds   final String? requiredStation; // null = anywhere   final List<String> requiredSkills;      Recipe({     required this.id,     required this.name,     required this.description,     required this.ingredients,     required this.output,     this.outputQuantity = 1,     this.craftTime = 0.5,     this.requiredStation,     this.requiredSkills = const [],   });      bool canCraft({     required Inventory inventory,     required Set<String> unlockedSkills,     String? currentStation,   }) {     // Check station     if (requiredStation != null && currentStation != requiredStation) {       return false;     }          // Check skills     for (var skill in requiredSkills) {       if (!unlockedSkills.contains(skill)) return false;     }          // Check ingredients     for (var ingredient in ingredients) {       if (inventory.count(ingredient.itemId) < ingredient.quantity) {         return false;       }     }          return true;   }      Map<String, dynamic> toJson() => {     'id': id,     'name': name,     'description': description,     'ingredients': ingredients.map((e) => e.toJson()).toList(),     'output': output.toJson(),     'outputQuantity': outputQuantity,     'craftTime': craftTime,     'requiredStation': requiredStation,     'requiredSkills': requiredSkills,   }; }  // models/ingredient.dart class Ingredient {   final String itemId;   final int quantity;      Ingredient({required this.itemId, required this.quantity});      Map<String, dynamic> toJson() => {     'itemId': itemId,     'quantity': quantity,   }; }  // crafting_manager.dart class CraftingManager {   final Map<String, Recipe> _recipes = {};   final Set<String> _unlockedRecipes = {};      void registerRecipe(Recipe recipe) {     _recipes[recipe.id] = recipe;   }      void unlockRecipe(String recipeId) {     _unlockedRecipes.add(recipeId);   }      List<Recipe> getAvailableRecipes({     required Inventory inventory,     required Set<String> unlockedSkills,     String? currentStation,   }) {     return _unlockedRecipes         .map((id) => _recipes[id]!)         .where((recipe) => recipe.canCraft(               inventory: inventory,               unlockedSkills: unlockedSkills,               currentStation: currentStation,             ))         .toList();   }      Future<Item?> craft({     required Recipe recipe,     required Inventory inventory,   }) async {     // Validate     if (!_unlockedRecipes.contains(recipe.id)) return null;          // Remove ingredients     for (var ingredient in recipe.ingredients) {       inventory.removeItem(ingredient.itemId, quantity: ingredient.quantity);     }          // Wait craft time     if (recipe.craftTime > 0) {       await Future.delayed(Duration(milliseconds: (recipe.craftTime * 1000).toInt()));     }          // Add result     inventory.addItem(recipe.output, quantity: recipe.outputQuantity);          return recipe.output;   } }`

---

### **Package 5: progression_system**

dart

Copy code

`// lib/progression_system.dart library progression_system;  export 'models/skill.dart'; export 'models/skill_tree.dart'; export 'models/experience.dart'; export 'ui/skill_tree_widget.dart'; export 'progression_manager.dart';  // models/skill.dart class Skill {   final String id;   final String name;   final String description;   final String iconPath;   final int cost; // skill points   final List<String> dependencies; // skill IDs required   final SkillEffect effect;      Skill({     required this.id,     required this.name,     required this.description,     required this.iconPath,     required this.cost,     this.dependencies = const [],     required this.effect,   });      Map<String, dynamic> toJson() => {     'id': id,     'name': name,     'description': description,     'cost': cost,     'dependencies': dependencies,   }; }  // models/skill_effect.dart abstract class SkillEffect {   void apply(GameContext context);   void remove(GameContext context); }  class StatBoostEffect extends SkillEffect {   final String statName;   final double amount;   final bool isMultiplier; // false = flat, true = percentage      StatBoostEffect({     required this.statName,     required this.amount,     this.isMultiplier = false,   });      @override   void apply(GameContext context) {     // Implementation   }      @override   void remove(GameContext context) {     // Implementation   } }  // models/experience.dart class ExperienceSystem {   int _currentXP = 0;   int _level = 1;   int _skillPoints = 0;      int get currentXP => _currentXP;   int get level => _level;   int get skillPoints => _skillPoints;      int xpForNextLevel() {     // Formula: 100 * level^1.5     return (100 * pow(level, 1.5)).toInt();   }      void addXP(int amount) {     _currentXP += amount;          while (_currentXP >= xpForNextLevel()) {       _levelUp();     }   }      void _levelUp() {     _currentXP -= xpForNextLevel();     _level++;     _skillPoints += 1;          // Trigger level up event   }      bool spendSkillPoint() {     if (_skillPoints > 0) {       _skillPoints--;       return true;     }     return false;   }      Map<String, dynamic> toJson() => {     'currentXP': _currentXP,     'level': _level,     'skillPoints': _skillPoints,   }; }  // progression_manager.dart class ProgressionManager {   final ExperienceSystem experience = ExperienceSystem();   final Map<String, Skill> _skills = {};   final Set<String> _unlockedSkills = {};      void registerSkill(Skill skill) {     _skills[skill.id] = skill;   }      bool canUnlock(String skillId) {     var skill = _skills[skillId];     if (skill == null) return false;          // Already unlocked     if (_unlockedSkills.contains(skillId)) return false;          // Check skill points     if (experience.skillPoints < skill.cost) return false;          // Check dependencies     for (var depId in skill.dependencies) {       if (!_unlockedSkills.contains(depId)) return false;     }          return true;   }      bool unlockSkill(String skillId, GameContext context) {     if (!canUnlock(skillId)) return false;          var skill = _skills[skillId]!;          // Spend points     for (int i = 0; i < skill.cost; i++) {       experience.spendSkillPoint();     }          // Unlock     _unlockedSkills.add(skillId);          // Apply effect     skill.effect.apply(context);          return true;   }      Set<String> getUnlockedSkills() => Set.from(_unlockedSkills); }`

---

### **Package 6: save_system**

dart

Copy code

`// lib/save_system.dart library save_system;  export 'models/save_data.dart'; export 'save_manager.dart';  // models/save_data.dart class SaveData {   final String id;   final DateTime timestamp;   final int playTimeSeconds;      // Game state   final Map<String, dynamic> playerData;   final Map<String, dynamic> worldData;   final Map<String, dynamic> inventoryData;   final Map<String, dynamic> progressionData;      SaveData({     required this.id,     required this.timestamp,     required this.playTimeSeconds,     required this.playerData,     required this.worldData,     required this.inventoryData,     required this.progressionData,   });      Map<String, dynamic> toJson() => {     'id': id,     'timestamp': timestamp.toIso8601String(),     'playTimeSeconds': playTimeSeconds,     'playerData': playerData,     'worldData': worldData,     'inventoryData': inventoryData,     'progressionData': progressionData,   };      factory SaveData.fromJson(Map<String, dynamic> json) {     return SaveData(       id: json['id'],       timestamp: DateTime.parse(json['timestamp']),       playTimeSeconds: json['playTimeSeconds'],       playerData: json['playerData'],       worldData: json['worldData'],       inventoryData: json['inventoryData'],       progressionData: json['progressionData'],     );   } }  // save_manager.dart class SaveManager {   static const String _savePrefix = 'forager_save_';   final SharedPreferences _prefs;      SaveManager(this._prefs);      Future<void> saveGame({     required String slotId,     required SaveData data,   }) async {     String json = jsonEncode(data.toJson());          // Compress if large     if (json.length > 10000) {       json = _compress(json);     }          await _prefs.setString('$_savePrefix$slotId', json);   }      Future<SaveData?> loadGame(String slotId) async {     String? json = _prefs.getString('$_savePrefix$slotId');     if (json == null) return null;          // Decompress if needed     if (_isCompressed(json)) {       json = _decompress(json);     }          return SaveData.fromJson(jsonDecode(json));   }      Future<List<SaveData>> listSaves() async {     List<SaveData> saves = [];          for (var key in _prefs.getKeys()) {       if (key.startsWith(_savePrefix)) {         String slotId = key.replaceFirst(_savePrefix, '');         var save = await loadGame(slotId);         if (save != null) saves.add(save);       }     }          saves.sort((a, b) => b.timestamp.compareTo(a.timestamp));     return saves;   }      Future<void> deleteSave(String slotId) async {     await _prefs.remove('$_savePrefix$slotId');   }      String _compress(String data) {     // Implementation using dart:io GZipCodec     return data;   }      String _decompress(String data) {     // Implementation     return data;   }      bool _isCompressed(String data) {     // Check header     return false;   } }`

---

## 🎮 **USANDO OS PACKAGES NO JOGO**

dart

Copy code

`// lib/game/tiles/resource_tile.dart import 'package:tile_system/tile_system.dart'; import 'package:resource_system/resource_system.dart';  class ResourceTile extends GridTile {   final Resource resource;   int health;      ResourceTile({     required TilePosition position,     required this.resource,   }) : health = resource.maxHealth,        super(          position: position,          id: 'resource_${resource.id}_${position.x}_${position.y}',          isWalkable: false,          isInteractable: true,        );      @override   void onInteract() {     // Player is harvesting     health -= 10; // Tool damage          if (health <= 0) {       // Drop resources       _dropLoot();       onDestroy();     }   }      void _dropLoot() {     // Spawn items   }      @override   Map<String, dynamic> toJson() => {     'type': 'resource',     'position': {'x': position.x, 'y': position.y},     'resource': resource.id,     'health': health,   }; }  // lib/game/tiles/farm_tile.dart import 'package:tile_system/tile_system.dart';  class FarmTile extends GridTile {   Crop? crop;   double soilMoisture = 0.0;   bool isTilled = false;      FarmTile({     required TilePosition position,   }) : super(          position: position,          id: 'farm_${position.x}_${position.y}',          isWalkable: true,          isInteractable: true,        );      @override   void onUpdate(double dt) {     if (crop != null && isTilled) {       // Update crop growth       crop!.grow(dt, moisture: soilMoisture);              // Decrease moisture       soilMoisture = max(0, soilMoisture - dt * 0.1);     }   }      void till() {     isTilled = true;   }      void water() {     soilMoisture = 100.0;   }      void plant(Crop newCrop) {     if (isTilled && crop == null) {       crop = newCrop;     }   }      Item? harvest() {     if (crop != null && crop!.isFullyGrown) {       var item = crop!.harvestedItem;       crop = null;       return item;     }     return null;   }      @override   Map<String, dynamic> toJson() => {     'type': 'farm',     'position': {'x': position.x, 'y': position.y},     'isTilled': isTilled,     'soilMoisture': soilMoisture,     'crop': crop?.toJson(),   }; }`

---

## 🔄 **INTEGRANDO TODOS OS SYSTEMS**

dart

Copy code

`// lib/game/game_coordinator.dart import 'package:core_game_engine/core_game_engine.dart'; import 'package:tile_system/tile_system.dart'; import 'package:inventory_system/inventory_system.dart'; import 'package:crafting_system/crafting_system.dart'; import 'package:progression_system/progression_system.dart'; import 'package:save_system/save_system.dart'; import 'package:audio_system/audio_system.dart';  class GameCoordinator extends GameController {   // Systems   late final GridManager gridManager;   late final InventoryManager inventoryManager;   late final CraftingManager craftingManager;   late final ProgressionManager progressionManager;   late final SaveManager saveManager;   late final AudioManager audioManager;      // Game state   late final Player player;   late final WorldState worldState;      @override   void init() {     // Initialize systems     gridManager = GridManager(width: 100, height: 100);     inventoryManager = InventoryManager(       inventory: Inventory(rows: 5, columns: 10),     );     craftingManager = CraftingManager();     progressionManager = ProgressionManager();     audioManager = AudioManager();          // Load databases     _loadRecipes();     _loadSkills();          // Generate world     _generateWorld();          // Setup input     _setupInput();   }      void _setupInput() {     InputHandler inputHandler = InputHandler();          inputHandler.onAction(InputAction.interact, () {       var facingTile = player.getFacingTile();       var tile = gridManager.getTile(facingTile);              if (tile != null && tile.isInteractable) {         tile.onInteract();       }     });          inputHandler.onAction(InputAction.openInventory, () {       // Show inventory UI     });          inputHandler.onAction(InputAction.openCrafting, () {       // Show crafting UI     });   }      void _loadRecipes() {     // Load from database     craftingManager.registerRecipe(Recipe(       id: 'wooden_pickaxe',       name: 'Wooden Pickaxe',       description: 'Basic mining tool',       ingredients: [         Ingredient(itemId: 'wood', quantity: 10),         Ingredient(itemId: 'stone', quantity: 5),       ],       output: WoodenPickaxe(),       craftTime: 2.0,     ));          // ... more recipes   }      void _loadSkills() {     progressionManager.registerSkill(Skill(       id: 'mining_1',       name: 'Better Mining',       description: '+20% mining speed',       iconPath: 'assets/skills/mining.png',       cost: 1,       effect: StatBoostEffect(         statName: 'mining_speed',         amount: 0.2,         isMultiplier: true,       ),     ));          // ... more skills   }      void _generateWorld() {     WorldGenerator generator = WorldGenerator(seed: 12345);          var tiles = generator.generate(       width: 100,       height: 100,       biome: BiomeType.forest,     );          for (var tile in tiles.values) {       gridManager.setTile(tile);     }   }      @override   void update(double dt) {     gridManager.updateAll(dt);     player.update(dt);     worldState.update(dt);   }      @override   void render(Canvas canvas) {     gridManager.renderAll(canvas);     player.render(canvas);   }      Future<void> saveGame(String slotId) async {     SaveData data = SaveData(       id: slotId,       timestamp: DateTime.now(),       playTimeSeconds: worldState.playTimeSeconds,       playerData: player.toJson(),       worldData: worldState.toJson(),       inventoryData: inventoryManager.inventory.toJson(),       progressionData: {         'experience': progressionManager.experience.toJson(),         'unlockedSkills': progressionManager.getUnlockedSkills().toList(),       },     );          await saveManager.saveGame(slotId: slotId, data: data);   }      @override   void dispose() {     audioManager.dispose();   } }`

---

## 📦 **PUBLICANDO PACKAGES PARA REUSO**

### **pubspec.yaml de cada package**

yaml

Copy code

`# packages/tile_system/pubspec.yaml name: tile_system description: Modular tile-based world system for 2D games version: 1.0.0  environment:   sdk: '>=3.0.0 <4.0.0'  dependencies:   flutter:     sdk: flutter  dev_dependencies:   flutter_test:     sdk: flutter   flutter_lints: ^2.0.0`

### **Usando packages locais**

yaml

Copy code

`# forager_game/pubspec.yaml name: forager_game description: Forager-like game  dependencies:   flutter:     sdk: flutter   flame: ^1.10.0   bonfire: ^3.0.0      # Local packages   core_game_engine:     path: packages/core_game_engine   tile_system:     path: packages/tile_system   inventory_system:     path: packages/inventory_system   crafting_system:     path: packages/crafting_system   combat_system:     path: packages/combat_system   progression_system:     path: packages/progression_system   save_system:     path: packages/save_system   audio_system:     path: packages/audio_system   ui_system:     path: packages/ui_system   resource_system:     path: packages/resource_system`

### **Publicando no pub.dev (futuro)**

bash

Copy code

`cd packages/tile_system flutter pub publish --dry-run  # Test flutter pub publish             # Real publish`

---

## 🎯 **PRÓXIMOS PASSOS IMEDIATOS**

### **Semana 1 - Action Items**

1. **Dia 1-2: Setup arquitetura**
    
    bash
    
    Copy code
    
    `# Criar estrutura mkdir -p packages/{core_game_engine,tile_system,inventory_system}/lib  # Mover código existente para packages apropriados`
    
2. **Dia 3-4: Implementar GridTile base**
    
    - Criar `GridTile` abstrato
    - Criar `ResourceTile` (árvore, pedra)
    - Testar com 100+ tiles simultâneos
3. **Dia 5-7: Core Loop MVP**
    
    - Player pode mover
    - Player pode colher recursos
    - Resources dropar itens
    - Itens vão para inventory

**Entregável Semana 1:** Player coletando recursos funcionando

---

## 🚀 **DIFERENCIAL COMPETITIVO**

Sua arquitetura modular te permite:

1. **Lançar Forager** (8 meses)
2. **Reusar 60% do código** para próximo jogo
3. **Publicar packages** no pub.dev (marketing + portfólio)
4. **Vender "Flutter Game Engine Kit"** (monetização extra)
5. **Fazer tutoriais** usando seus packages (audiência)

---

## 💰 **PROJEÇÃO DE MONETIZAÇÃO**

### **Cenário Conservador**

- Forager mobile: $4.99
- 10.000 downloads ano 1
- **Revenue: ~$35.000** (após taxas store)

### **Cenário Moderado**

- 50.000 downloads
- **Revenue: ~$175.000**

### **Packages como produto**

- "Flutter 2D Game Engine Kit": $49
- 200 vendas/ano: **$9.800**

---

Quer que eu detalhe algum package específico ou crie o código completo de algum sistema? 🎮