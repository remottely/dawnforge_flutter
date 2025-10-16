# 📦 ETAPA 1: FUNDAÇÃO AGRÍCOLA

**Duração:** 2-3 semanas
**Prioridade:** CRÍTICA - Base para todo o sistema

## 🎯 Objetivo da Etapa

Adicionar o sistema de farming funcional ao Darkness Dungeon, mantendo integralmente o sistema de combate/PlayerCharacter e todas as funcionalidades atuais. O objetivo é estabelecer as fundações para todas as mecânicas agrícolas futuras, sem remover ou substituir o core dungeon/castle gameplay.

## 📋 1.1 Transformação do Core Player

### 🔄 Expansão do PlayerCharacter para Atividades Agrícolas

#### Arquivos a Modificar/Adicionar:

#### Mudanças Específicas:

**1.1.1 Adição de Funcionalidades Agrícolas**

**1.1.2 Expansão do Sistema de Movimento**

**1.1.3 Implementação do Sistema de Tools**

```dart
// Sistema de ferramentas agrícolas integrado ao PlayerCharacter
enum FarmTool {
  hand,        // Default - para pickup items
  hoe,         // Para preparar soil
  wateringCan, // Para regar plantas
}

// Adicionar propriedades e métodos agrícolas à PlayerCharacter
FarmTool currentTool = FarmTool.hand;
int energy = 100; // Adicionar sistema de energia

void switchTool(FarmTool newTool) { }
void useTool() { } // Nova ação agrícola
void _handleToolUsage() { } // Lógica central de ferramentas
```

**1.1.4 Sistema de Energia (Energy System)**

## 📋 1.2 Sistema de Farm Tiles

### 🌱 **Grid System para Farming**

#### Arquivos a Criar:

- `/lib/gameplay/farming/farm_tile.dart`
- `/lib/gameplay/farming/farm_grid_manager.dart`
- `/lib/gameplay/farming/crop_types.dart`

#### Implementação:

**1.2.1 Farm Tile States**

```dart
enum TileState {
  grass,    // Estado inicial
  soil,     // Após usar hoe
  watered,  // Após usar watering can
  planted,  // Após plantar seed
  grown,    // Crop ready para harvest
}

class FarmTile extends GameComponent {
  TileState state = TileState.grass;
  CropType? plantedCrop;
  int daysGrowing = 0;
  bool isWatered = false;

  void processDay() { } // Daily growth logic
  void interact(FarmTool tool) { } // Tool interaction
}
```

**1.2.2 Grid Management**

```dart
class FarmGridManager {
  static const int gridWidth = 20;
  static const int gridHeight = 15;
  late List<List<FarmTile>> farmGrid;

  void initializeGrid() { }
  FarmTile? getTileAt(Vector2 position) { }
  void processDailyGrowth() { }
}
```

**1.2.3 Crop System Básico (MVP)**

```dart
enum CropType {
  parsnip, // 4 days growth
}

class CropData {
  final String name;
  final int daysToGrow;
  final int sellPrice;
  final String spriteAsset;

  const CropData({
    required this.name,
    required this.daysToGrow,
    required this.sellPrice,
    required this.spriteAsset,
  });
}

// MVP: Apenas 1 tipo de crop
const Map<CropType, CropData> cropDatabase = {
  CropType.parsnip: CropData(
    name: 'Parsnip',
    daysToGrow: 4,
    sellPrice: 35,
    spriteAsset: 'crops/parsnip.png',
  ),
};
```

---

## 📋 1.3 Game Loop Básico

### ⏰ **Day/Night Cycle System**

#### Arquivos a Criar:

- `/lib/gameplay/core/managers/day_cycle_manager.dart`
- `/lib/gameplay/core/managers/energy_manager.dart`

#### Implementação:

**1.3.1 Day/Night Cycle**

```dart
class DayCycleManager {
  static int currentDay = 1;
  static TimeOfDay currentTime = TimeOfDay.morning;
  static bool isPlayerAsleep = false;

  static void advanceTime() { }
  static void endDay() { }
  static void startNewDay() { }
}

enum TimeOfDay {
  morning,   // 6:00 AM - 12:00 PM
  afternoon, // 12:00 PM - 6:00 PM
  evening,   // 6:00 PM - 12:00 AM
  night,     // 12:00 AM - 6:00 AM (auto-sleep)
}
```

**1.3.2 Energy Management**

```dart
class EnergyManager {
  static int currentEnergy = 100;
  static const int maxEnergy = 100;
  static const int toolUsageCost = 2;

  static void useEnergy(int amount) { }
  static void restoreEnergy() { } // Full restore on sleep
  static bool canUseEnergy(int amount) { }
}
```

**1.3.3 Save System Básico**

```dart
class SaveManager {
  static void saveGameState() {
    // Save:
    // - Current day
    // - Player position
    // - Farm grid state
    // - Player energy
    // - Inventory (when implemented)
  }

  static void loadGameState() { }
  static bool hasSaveFile() { }
}
```

---

## 🎨 Assets Requirements

### 🖼️ **Sprites Necessários**

**Player Sprites:**

- `player_farming_up.png` (adaptação do knight_idle_up)
- `player_farming_down.png`
- `player_farming_left.png`
- `player_farming_right.png`
- `player_tool_hoe.png` (usando hoe)
- `player_tool_watering.png` (usando watering can)

**Farm Tiles:**

- `tile_grass.png` (estado inicial)
- `tile_soil.png` (após hoe)
- `tile_watered.png` (soil + water)
- `tile_planted.png` (com seed)

**Crops:**

- `parsnip_stage1.png` (planted)
- `parsnip_stage2.png` (growing)
- `parsnip_stage3.png` (almost ready)
- `parsnip_stage4.png` (ready to harvest)

**Tools:**

- `tool_hoe.png`
- `tool_watering_can.png`
- `item_parsnip.png` (harvested)
- `seed_parsnip.png`

**UI Elements:**

- `energy_bar_background.png` (reuse stamina bar)
- `energy_bar_fill.png`
- `day_indicator.png`

---

## 🧪 Testing Strategy

### ✅ **Critérios de Aceitação**

**1.3.1 Player Movement & Tools**

- [ ] Player move suavemente pelo farm
- [ ] Tool switching funciona (hand, hoe, watering can)
- [ ] Tool usage animation plays correctly
- [ ] Energy decreases com tool usage
- [ ] Player não pode usar tools sem energy

**1.3.2 Farm Tiles**

- [ ] Grass tiles can be converted to soil com hoe
- [ ] Soil tiles can be watered
- [ ] Visual feedback para cada tile state
- [ ] Grid system funciona corretamente

**1.3.3 Day Cycle**

- [ ] Day advances automatically
- [ ] Player auto-sleeps at midnight
- [ ] Energy restores completamente ao dormir
- [ ] Farm tiles mantêm state entre dias

**1.3.4 Save/Load**

- [ ] Game state persiste entre sessions
- [ ] All tile states saved correctly
- [ ] Player position e energy saved

---

## � **PROMPTS PRONTOS PARA IMPLEMENTAÇÃO**

### 🎯 **Prompt 1.1 - Transformação PlayerCharacter → FarmPlayer**

```
Preciso transformar o sistema de combate do PlayerCharacter em um sistema de farming. Seguindo o padrão de código existente:

Expanda o PlayerCharacter para incluir funcionalidades de farming, mantendo todo o sistema de combate, movimento e animações existentes. Siga os prompts abaixo para adicionar as novas features:

1. Adicionar sistema de ferramentas agrícolas ao PlayerCharacter:
   - Enum FarmTool: hand, hoe, wateringCan
   - Propriedade currentTool
   - Método useTool() para ações agrícolas
   - Tool switching system
   - Tool usage animations

2. Adicionar sistema de energia:
   - Propriedade energy (inicial 100)
   - Energy depletes com uso de ferramentas (2 pontos por uso)
   - Energy visual bar (reuse stamina bar UI)
   - Energy restoration ao dormir

3. Manter e integrar todo o sistema de combate e movimento:
   - Não remover métodos de combate
   - Não remover stamina para combate
   - Não remover collision detection com enemies
   - Adaptar movimento e animações para contexto agrícola, sem perder funcionalidades existentes

Arquivos a modificar:
- /lib/gameplay/player/player_character.dart (adicionar funcionalidades agrícolas)
- Manter toda funcionalidade de movimento e combate
- Implementar tool system completo como adição

Manter padrões de código existentes e nomenclatura consistente.
```

### 🎯 **Prompt 1.2 - Sistema de Farm Tiles**

```
Implementar sistema de grid de farming com tiles interativos:

1. Criar FarmTile component:
   - TileState enum: grass, soil, watered, planted, grown
   - Properties: state, plantedCrop, daysGrowing, isWatered
   - Métodos: interact(FarmTool), processDay(), reset()

2. Criar FarmGridManager:
   - Grid 20x15 de FarmTiles
   - Métodos: initializeGrid(), getTileAt(Vector2), processDailyGrowth()
   - Positioning system para tiles

3. Tool-Tile interaction:
   - Hoe: grass → soil (costs 2 energy)
   - WateringCan: soil → watered (costs 2 energy)
   - Hand: interaction com planted/grown tiles

4. Visual feedback:
   - Sprites para cada tile state
   - Hover effects
   - State transition animations

Arquivos a criar:
- /lib/gameplay/farming/farm_tile.dart
- /lib/gameplay/farming/farm_grid_manager.dart
- /lib/gameplay/farming/crop_types.dart (MVP: apenas parsnip)

Usar Vector2 para posições, manter performance 60fps.
```

### 🎯 **Prompt 1.3 - Day Cycle e Energy System**

```
Implementar ciclo dia/noite e sistema de energia para farming:

1. Day Cycle Manager:
   - TimeOfDay enum: morning, afternoon, evening, night
   - currentDay counter (starts at 1)
   - Automatic time progression
   - Auto-sleep at midnight

2. Energy System:
   - Replace stamina system completamente
   - maxEnergy = 100, starts full
   - Tool usage costs 2 energy
   - Sleep restores to full
   - Visual energy bar (reuse stamina bar)

3. Daily Processing:
   - endDay() triggers crop growth
   - Energy restoration
   - Save game state
   - Advance calendar

4. Save System básico:
   - Player state (level, energy, position)
   - Farm grid state (all tiles)
   - Current day e time
   - JSON format, local storage

Arquivos a criar:
- /lib/gameplay/core/managers/day_cycle_manager.dart
- /lib/gameplay/core/managers/energy_manager.dart
- /lib/gameplay/save/save_manager.dart

Integrar com sistemas existentes de UI e audio.
```

### 🎯 **Prompt 1.4 - Integration e Testing**

```
Integrar todos os sistemas da Etapa 1 e implementar testing:

1. Player Integration:
   - FarmPlayer usa energy para tools
   - Tool usage interage com farm tiles
   - Movement funciona em farm grid
   - Animations smooth entre tools

2. Game Loop Integration:
   - Day cycle processa farm growth
   - Energy restoration ao sleep
   - Save/load preserva all states
   - UI updates correctly

3. Testing Implementation:
   - Unit tests para FarmTile states
   - Energy system tests
   - Save/load validation
   - Performance benchmarks

4. Bug Fixes e Polish:
   - Smooth tool transitions
   - Proper collision detection
   - Memory leak prevention
   - 60fps maintenance

Critérios de Aceitação:
- Player move e usa tools sem bugs
- Farm tiles respondem correctly
- Day cycle funciona automatically
- Save/load preserva todo progresso
- Performance stable 60fps

Implementar error handling e user feedback apropriados.
```

---

## �🚀 Implementation Order

### 📅 **Week 1: Player System**

1. Refactor PlayerCharacter → FarmPlayer
2. Remove combat system
3. Implement tool system
4. Adapt movement e animations
5. Energy system implementation

### 📅 **Week 2: Farm System**

1. Create FarmTile component
2. Implement grid system
3. Tool-tile interaction
4. Visual feedback para tiles
5. Basic crop data structure

### 📅 **Week 3: Game Loop**

1. Day/night cycle implementation
2. Energy restoration system
3. Save/load functionality
4. Integration testing
5. Bug fixes e polish

---

## 🔗 Integration com Etapas Futuras

### 📦 **Preparação para Etapa 2**

- Farm grid ready para crop planting
- Tool system extensível para new tools
- Energy system ready para expansion
- Save system ready para inventory data

### 🎯 **Success Metrics**

- Player consegue usar all 3 tools
- Farm tiles respondem correctly a tool usage
- Energy system funciona sem bugs
- Save/load preserva todo game state
- 60fps performance maintained
- Zero crashes durante core farming loop

---

## ⚠️ **Potential Risks & Mitigations**

**Risk 1:** Performance issues com large farm grid

- **Mitigation:** Implement culling para off-screen tiles

**Risk 2:** Complex state management para tiles

- **Mitigation:** Simple enum-based state machine

**Risk 3:** Animation system conflicts

- **Mitigation:** Reuse existing animation framework

**Risk 4:** Save system complexity

- **Mitigation:** JSON-based save com minimal data

---

## 📝 **Next Steps**

Após conclusão desta etapa, proceder para:

- **ETAPA 2:** Sistema de Farming (crops, inventory, growth)
- Focus: Implementar crop growing e harvest mechanics
- Timeline: 2 semanas adicionais
