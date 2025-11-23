Agora tenho contexto suficiente. Vou fornecer uma visão estratégica completa e bem fundamentada.

# 🏗️ Visão Estratégica: Arquitetura de Gestão de Dados

## 1. Arquitetura de Gestão de Estado

### **O quê: Padrão MVC com Managers Singleton**

Recomendo **manter e expandir o padrão atual** do projeto (MVC + Singleton Managers), que já está bem estabelecido:

```
Config (Constantes) → Model (Estado) → Controller (Lógica) → View (Apresentação)
                                ↓
                         Managers Singleton (Estado Global)
```

### **Por quê:**

1. **Adequação ao Bonfire**: Framework de jogos tem ciclo próprio (`update`, `onLoad`), não reativo como apps tradicionais
2. **Padrão já consolidado**: Projeto tem estrutura robusta em `knight_player` e `sunny_player`
3. **Performance garantida**: Acesso direto sem overhead de streams/listeners
4. **Simplicidade**: Sem curva de aprendizado adicional

### **Trade-offs:**

| Aspecto              | Vantagem                         | Limitação                               |
| -------------------- | -------------------------------- | --------------------------------------- |
| **Performance**      | ✅ Direto, sem latência          | ⚠️ Deve-se evitar polling excessivo     |
| **Manutenibilidade** | ✅ Código linear, fácil debug    | ⚠️ Estado global requer disciplina      |
| **Testabilidade**    | ✅ Models isolados, fácil testar | ⚠️ Managers precisam reset entre testes |

### **Adequação ao MVP:**

✅ **Perfeito** - Entrega rápida sem refatoração arquitetural
✅ **Zero dependências** extras - Usa apenas Dart puro
✅ **Escalável** - Adicionar novos Managers é trivial

---

## 2. Sistema de Salvamento

### **O quê: JSON + SharedPreferences (com fallback Web)**

**Estratégia híbrida multiplataforma:**

```dart
// Estrutura proposta
lib/gameplay/core/modules/save/
├── save_manager.dart           // Singleton, orquestra tudo
├── save_data_model.dart        // Model serializado
├── save_repository.dart        // Abstração de persistência
├── save_repository_native.dart // Desktop/Mobile (SharedPreferences)
└── save_repository_web.dart    // Web (localStorage)
```

### **Por quê:**

1. **JSON**: Formato legível, debugável, versionável, universal
2. **SharedPreferences**: API Flutter nativa, funciona em todas as plataformas
3. **Fallback Web**: LocalStorage tem limite (5-10MB), suficiente para MVP
4. **Sem SQLite**: Over-engineering para dados estruturados simples (farm, inventory, player)

### **Trade-offs:**

| Aspecto            | JSON + SharedPreferences | SQLite                  | Hive                |
| ------------------ | ------------------------ | ----------------------- | ------------------- |
| **Complexidade**   | ✅ Simples               | ⚠️ Schema management    | ⚠️ Type adapters    |
| **Web Support**    | ✅ Nativo                | ❌ Não funciona         | ⚠️ Limitado         |
| **Versionamento**  | ✅ Fácil (chave JSON)    | ⚠️ Migrations complexas | ⚠️ Schema evolution |
| **Debugabilidade** | ✅ Texto legível         | ❌ Binário              | ❌ Binário          |
| **Performance**    | ⚠️ OK até 1MB            | ✅ Excelente            | ✅ Muito rápido     |

### **Quando Salvar:**

```dart
// 1. Auto-save periódico (não bloqueante)
Timer.periodic(Duration(minutes: 2), (_) => SaveManager.instance.autoSave());

// 2. Manual (eventos críticos)
- Transição de mapa ✓
- Noite/Dia (dormir) ✓
- Colheita de farm ✓
- Modificação de inventário ✓

// 3. Checkpoint (antes de eventos irreversíveis)
- Entrar em combate com boss ✓
- Usar item importante ✓
```

### **Versionamento:**

```dart
class SaveData {
  static const int kCurrentVersion = 1;

  final int version;
  final DateTime timestamp;
  final PlayerSaveData player;
  final WorldSaveData world;

  // Migração automática
  factory SaveData.fromJson(Map<String, dynamic> json) {
    final version = json['version'] ?? 1;
    if (version < kCurrentVersion) {
      json = _migrateFromVersion(version, json);
    }
    return SaveData._internal(json);
  }
}
```

### **Adequação ao MVP:**

✅ **Rápido de implementar** - SharedPreferences já no pubspec
✅ **Web-ready** - Funciona em todas as plataformas desde dia 1
✅ **Sem over-engineering** - Adicione SQLite depois se precisar

---

## 3. Arquitetura de Dados do Jogo

### **O quê: Separação em Camadas com Estado Híbrido**

```
┌─────────────────────────────────────────────────────┐
│                   MANAGERS                          │
│  (Estado Global - Singleton)                        │
│                                                      │
│  GameStateManager    WorldStateManager              │
│  InventoryManager    FarmManager                    │
│  TimeManager         PlayerProgressManager          │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│               ENTITY MODELS                          │
│  (Estado Local - Instâncias)                        │
│                                                      │
│  PlayerModel    FarmTileModel    ItemModel          │
│  EnemyModel     DecorationModel  NPCModel           │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│                 PERSISTENCE                          │
│  (Serialização)                                      │
│                                                      │
│  SaveData → JSON → SharedPreferences                │
└─────────────────────────────────────────────────────┘
```

### **Divisão de Responsabilidades:**

#### **A. Managers (Estado Global)**

```dart
// lib/gameplay/core/modules/world/world_state_manager.dart
final class WorldStateManager {
  WorldStateManager._();
  static final instance = WorldStateManager._();

  // Estado em memória
  int currentDay = 1;
  Season currentSeason = Season.spring;
  TimeOfDay timeOfDay = TimeOfDay.morning;

  // Cache de mapas ativos (não todos em memória)
  final Map<String, MapState> _activeMapStates = {};

  MapState? getMapState(String mapId) => _activeMapStates[mapId];

  void unloadInactiveMaps() {
    // Remove mapas que não estão sendo usados
  }
}
```

#### **B. Models (Estado Local)**

```dart
// lib/gameplay/farmable/farm_tile_model.dart
class FarmTileModel {
  PlantType? plantedCrop;
  int growthStage = 0;
  bool isWatered = false;
  DateTime? plantedAt;

  // Validações
  bool get isReadyToHarvest => growthStage >= maxGrowthStage;
  bool get needsWater => !isWatered && timeOfDay == TimeOfDay.morning;

  // Serialização
  Map<String, dynamic> toJson() => {
    'plantedCrop': plantedCrop?.name,
    'growthStage': growthStage,
    'isWatered': isWatered,
    'plantedAt': plantedAt?.toIso8601String(),
  };
}
```

#### **C. Repository Pattern (Abstração)**

```dart
// lib/gameplay/core/modules/save/save_repository.dart
abstract class SaveRepository {
  Future<void> save(String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> load(String key);
  Future<void> delete(String key);

  factory SaveRepository() {
    if (kIsWeb) {
      return SaveRepositoryWeb();
    }
    return SaveRepositoryNative();
  }
}
```

### **Persistência de Mapas (Estratégia Inteligente):**

```dart
// NÃO carregar todos os mapas em memória!
// Salvar apenas:
// 1. Mapa atual (completo)
// 2. Mapas vizinhos (apenas estado, sem assets)
// 3. Outros mapas (apenas modificações do estado padrão)

class MapState {
  final String mapId;
  final List<DecorationState> decorations; // Apenas modificados
  final List<FarmTileState> farmTiles;
  final List<EnemyState> enemies; // Se mortos, não reaparecem

  // Delta do estado padrão (otimização)
  bool get isDefaultState => decorations.isEmpty &&
                              farmTiles.isEmpty &&
                              enemies.isEmpty;
}
```

### **Por quê:**

1. **Managers para estado compartilhado** (dia/noite, estação, inventário global)
2. **Models para estado isolado** (cada tile, cada item, cada inimigo)
3. **Repository para abstrair plataforma** (Web vs Native sem IF's espalhados)

### **Trade-offs:**

| Abordagem              | Prós                   | Contras                                |
| ---------------------- | ---------------------- | -------------------------------------- |
| **Tudo em Managers**   | ❌ Simples no início   | ❌ Difícil manter, Deus Object         |
| **Tudo em Models**     | ❌ Isolado             | ❌ Difícil comunicação, Prop Drilling  |
| **Híbrido (Proposto)** | ✅ Flexível, Escalável | ⚠️ Requer clareza de responsabilidades |

### **Adequação ao MVP:**

✅ **Balanceado** - Não é nem muito simples nem over-engineered
✅ **Expansível** - Adicionar novo Manager/Model é independente
✅ **Testável** - Models puros + Managers mockáveis

---

## 4. Roadmap de Implementação

### **Ordem Lógica (Fundação → Gameplay):**

```
FASE 1: FUNDAÇÃO (Semana 1)
├─ 1.1 Sistema de Save/Load Base
│   ├─ SaveManager singleton
│   ├─ SaveData model + serialização
│   ├─ SaveRepository + implementações
│   └─ Testes de persistência (unit)
│
├─ 1.2 Managers de Estado Global
│   ├─ WorldStateManager (dia/noite/estação)
│   ├─ TimeManager (ciclo temporal)
│   └─ PlayerProgressManager (conquistas/flags)
│
└─ 1.3 Integração Save ↔ Player
    └─ PlayerModel.toJson() / fromJson()

FASE 2: SISTEMAS DE GAMEPLAY (Semana 2-3)
├─ 2.1 Inventário
│   ├─ InventoryManager (global)
│   ├─ ItemModel + ItemType enum
│   ├─ Slot system (equipado vs bag)
│   └─ Save/Load inventário
│
├─ 2.2 Farm System
│   ├─ FarmTileModel (local)
│   ├─ PlantType enum + growth stages
│   ├─ Watering/Harvesting logic
│   └─ Save/Load farm grid
│
└─ 2.3 Ciclo Dia/Noite
    ├─ TimeManager (já criado)
    ├─ Shader transition (visual)
    └─ Save/Load tempo atual

FASE 3: CONTEÚDO (Semana 4)
├─ 3.1 Inimigos
│   ├─ EnemyModel (health, loot)
│   ├─ Spawn logic
│   └─ Save/Load enemies mortos
│
├─ 3.2 Decorações
│   ├─ DecorationModel (state)
│   ├─ Interactive decorations
│   └─ Save/Load decorations
│
└─ 3.3 Estações do Ano
    ├─ Season enum em WorldStateManager
    ├─ Crop availability por season
    └─ Visual effects (particles)

FASE 4: POLISH (Semana 5)
├─ 4.1 Pesca (opcional MVP)
├─ 4.2 Transição de Mapas (já existe)
└─ 4.3 Performance optimization
```

### **Dependências Críticas:**

```
Save System → TUDO (deve estar primeiro)
Inventário → Farm (precisa guardar sementes/colheitas)
Dia/Noite → Farm (crescimento depende de dias)
WorldState → Tudo (estado compartilhado)
```

---

## 5. Estratégia para Funcionalidades Faltantes

### **5.1 Farm System**

```dart
// DECISÃO: Grid-based com state machine
// JUSTIFICATIVA: Performance (cacheable), Simplicidade (não é física)

lib/gameplay/farmable/
├── farm_tile_model.dart        // State machine (tilled, seeded, growing, etc)
├── farm_tile_controller.dart   // Growth logic, interactions
├── farm_tile_view.dart         // Rendering
├── farm_tile_config.dart       // Constants (growth rates, sprites)
└── farm_manager.dart           // Grid management (singleton)

// MVP: 1 crop, 3 growth stages, water system básico
```

### **5.2 Inventory System**

```dart
// DECISÃO: Slot-based com límite (Stardew-style)
// JUSTIFICATIVA: Simplicidade, UI clara, Save pequeno

lib/gameplay/core/modules/inventory/
├── inventory_manager.dart      // Singleton (add/remove/get)
├── item_model.dart             // id, type, quantity, metadata
├── item_type.dart              // enum (Seed, Tool, Resource, etc)
└── inventory_ui.dart           // HUD display (opcional MVP)

// MVP: 10 slots, 3 item types (Seed, Resource, Tool)
```

### **5.3 Ciclo Dia/Noite**

```dart
// DECISÃO: Time-based com easing (não físico)
// JUSTIFICATIVA: Performance, Controle artístico

lib/gameplay/core/modules/time/
├── time_manager.dart           // Singleton (update dt, events)
├── time_of_day.dart            // enum (Morning, Noon, Evening, Night)
├── day_night_shader.dart       // ColorFilter overlay
└── time_config.dart            // Duração de cada período

// MVP: 4 períodos fixos, transição em 5 segundos, sem lighting dinâmico
```

### **5.4 Estações do Ano**

```dart
// DECISÃO: Discrete seasons (não gradual)
// JUSTIFICATIVA: Simplicidade de conteúdo

// Integração em WorldStateManager (já previsto)
enum Season { spring, summer, fall, winter }

// MVP: 1 season (Spring), estrutura pronta para expansão
```

### **5.5 Pesca**

```dart
// DECISÃO: Minigame simplificado (timer-based)
// JUSTIFICATIVA: Escopo menor, menos assets

lib/gameplay/minigames/fishing/
├── fishing_controller.dart     // Timer + input check
├── fishing_ui.dart             // Overlay HUD
└── fish_type.dart              // enum + loot table

// MVP: 1 fish, success/fail, adiciona ao inventário
```

### **5.6 Sistema de Combate (Inimigos)**

```dart
// DECISÃO: Expandir padrão atual (já funcional)
// JUSTIFICATIVA: Knight/Sunny já têm combate

// MVP: 1 inimigo novo, AI básica (chase/attack), loot drop
// Estrutura já existe em /gameplay/characters/enemies/
```

### **5.7 Decorações**

```dart
// DECISÃO: State-based (interacted, destroyed, etc)
// JUSTIFICATIVA: Persistência simples

// MVP: 1 decoração interativa (ex: storage chest)
// Estrutura já existe em /gameplay/decorations/
```

### **5.8 Transição de Mapas**

```dart
// DECISÃO: Manter sistema atual + adicionar state persistence
// JUSTIFICATIVA: MapTransitionSensor já funciona

// ADICIONAR:
// - Salvar estado do mapa ao sair
// - Restaurar estado ao voltar
// - Unload mapas inativos (memória)

// Já existe: MapTransitionSensorView, MapArguments
```

---

## 🎯 Decisões Estratégicas Resumidas

| Sistema        | Solução                  | Justificativa                 | Prioridade  |
| -------------- | ------------------------ | ----------------------------- | ----------- |
| **Estado**     | MVC + Managers           | Já estabelecido, performático | 🔴 Manter   |
| **Save**       | JSON + SharedPreferences | Web-ready, simples, debugável | 🔴 Critical |
| **Inventário** | Slot-based Manager       | Stardew-like, fácil UI        | 🔴 MVP      |
| **Farm**       | Grid State Machine       | Performance, cacheable        | 🔴 MVP      |
| **Tempo**      | Time Manager + Overlay   | Não-físico, controle total    | 🟡 MVP      |
| **Estações**   | Discrete enum            | Simples, expansível           | 🟢 Post-MVP |
| **Pesca**      | Timer minigame           | Escopo pequeno                | 🟢 Post-MVP |
| **Combate**    | Expandir atual           | Já funciona                   | 🟡 MVP      |
| **Mapas**      | Lazy loading + Delta     | Memória otimizada             | 🔴 MVP      |

---

## 🚀 Próximos Passos

1. **Criar documento detalhado** em `documentation/DATA_ARCHITECTURE.md`
2. **Validar com testes** de conceito (POC) de Save/Load
3. **Implementar fundação** (Fase 1) antes de gameplay
4. **Iterar incrementalmente** - não implementar tudo de uma vez

---

**Pronto!** Esta é a visão estratégica de alto nível. Nenhuma linha de código foi escrita, apenas decisões arquiteturais fundamentadas. Quando estiver pronto, posso gerar o documento de arquitetura completo com diagramas, exemplos de código detalhados e guias de implementação passo a passo.
