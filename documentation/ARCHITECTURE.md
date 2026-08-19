# Arquitetura — Dawnforge

Documento de referência. Complementa o [CLAUDE.md](../CLAUDE.md), que contém as regras curtas do dia a dia.

Última verificação contra o código: **2026-08-19** (`main` @ `f05647bf`).

---

## 1. Princípios

1. **Feature-first, camada dentro da feature.** Navegar por funcionalidade é mais frequente que navegar por camada.
2. **Domínio puro é sagrado.** Entidades e regras de jogo não conhecem Bonfire, Flutter, IO ou singletons. É a única parte 100% testável — e é onde o jogo realmente é.
3. **Engine é detalhe.** `bonfire`/`flame` ficam confinados a `modules/`, `shared/framework/` e `components/`. Uma regra de negócio que importa `package:bonfire` está no lugar errado.
4. **Estado explícito e centralizado.** Um manager singleton por domínio de estado, notificando por `ValueNotifier`. Sem estado escondido em widgets ou componentes.
5. **Simplicidade proporcional ao risco.** Save corrompido e regra de crescimento de plantação errada custam caro → merecem camadas e testes. Um overlay de HUD não.

---

## 2. Mapa de pastas

### 2.1 `lib/core/` — utilitários sem dependência de jogo

```
core/
├── managers/settings_manager.dart      # orientação de tela, preferências
└── utils/
    ├── game_logger.dart                # logging condicionado por ambiente
    ├── app_environment.dart            # flags de build (--dart-define=GAME_ENVIRONMENT)
    └── debug_helpers.dart
```

`AppEnvironment` lê `GAME_ENVIRONMENT` (`DEVELOPMENT` | `STAGING` | `PRODUCTION`, padrão `PRODUCTION`) e deriva flags const — o compilador remove o código morto em release.

```bash
flutter run --dart-define=GAME_ENVIRONMENT=DEVELOPMENT
```

### 2.2 `lib/shared/` — framework reutilizável

```
shared/
├── design_system/            # ATUAL: tokens (spacing, sizes, radius, typography, scale)
├── design_system_old/        # LEGADO: DDButton, DDText, DDDialog — em remoção
├── overlay_design_system/    # base responsiva de overlays
├── framework/                # classes-base de entidades Bonfire
│   ├── character/            # Character + behaviors (composição)
│   ├── player/               # cadeia DDxxxPlayer (herança — em migração)
│   ├── enemies/              # DDBaseEnemy (MVC)
│   ├── decorations/          # DDContactDecoration, DDPushableDecoration, DDInputReceiver
│   ├── interaction/          # mixins de interação/colisão
│   ├── widgets/              # DDSpriteWidget, DDSpriteAnimationWidget
│   └── save/                 # PlayerSaveManager (órfão — candidato a remoção)
└── utils/                    # helpers de sprite animation
```

### 2.3 `lib/game/features/` — domínio por funcionalidade

| Feature | Responsabilidade | Estado do código |
|---|---|---|
| `world/` | Grid genérico: `GridTile`, `TileObject`, `FarmObject`, `CropEntity` | ✅ domínio puro, imutável |
| `farm/` | Arar, regar, plantar, colher, crescimento diário | ✅ com use cases; ⚠️ regra vazando para o manager |
| `inventory/` | Slots, stacking, itens, equipamento | ✅ com use cases |
| `time/` | Relógio, calendário, estações, clima, scheduler | ✅ isolado e testável |
| `market/` | Catálogo, compra/venda | ⚠️ catálogo majoritariamente comentado |
| `gameplay_screen*` | Tela + viewmodel do gameplay | ⚠️ viewmodel grande (325 linhas) |

### 2.4 `lib/game/systems/` — serviços transversais

```
systems/
├── save/            # persistência (ver §5)
├── audio/           # AudioManager + defs
├── map/             # MapManager, transições, MapDef (Tiled)
├── world/           # WorldStateManager (dia/estação/mapa ativo), MapState
├── game/            # GameStateManager, PlayerStateManager, handlers de input
├── combat/          # ataques, defesa, ataque sincronizado
├── camera/          # FX e cálculos de câmera
├── input_actions/   # setup de teclado e joystick
├── overlay/         # HUDs e overlays Flutter sobre o Bonfire
├── ui/              # emotes, diálogos, estado de UI
└── localization/    # delegate + strings (assets/l10n/{en,pt}.json)
```

### 2.5 `lib/game/modules/` — entidades concretas do mundo

`characters/{player,enemies,npcs}` e `decorations/`. Cada entidade usa o trio **Model / Controller / View** + um `*_def.dart`:

```
decorations/torch/
├── torch_decoration_config.dart      # constantes, sprites, textos  (*_def na prática)
├── torch_decoration_model.dart       # estado puro: isOn, isDetectPlayer
├── torch_decoration_controller.dart  # lógica, recebe callbacks — NÃO importa render
└── torch_decoration_view.dart        # componente Bonfire, injeta callbacks no controller
```

O Controller recebe callbacks (`onToggleTorchState`, `onDisplayExclamationEmote`) em vez de referenciar a View. **É isso que torna Model e Controller testáveis sem engine** — preserve esse desenho ao criar novas entidades.

### 2.6 `lib/game/database/` — catálogo de conteúdo

`smallburg_*_database_def.dart`: mapas `HandItemId → Item` / `HandItemId → CropEntity` como constantes Dart tipadas.

Migrado de JSON (assets) para constantes por decisão: type-safety, zero custo de parse/IO, testável sem binding do Flutter. **Não reverter para JSON.**

### 2.7 `lib/game/global/`

- `GlobalStateMachine` — estado global do gameplay (pausado, menu aberto, tempo parado).
- `GlobalInputHandler` — roteamento de input; é *factory*, com `_SharedState` singleton interno (ver commit `1.110.2+1`).
- `GlobalStateOverlay`.

---

## 3. Fluxo de dados

### 3.1 Ação do jogador (caminho canônico)

```
Input (teclado/joystick)
  → GlobalInputHandler / FarmInputHandler
  → getIt<TillSoilUseCase>()(x, y)          # valida + orquestra
  → FarmManager.setTile(...) / notifyChange()
  → tilesNotifier (ValueNotifier)
  → FarmTileView (Bonfire) e/ou Overlay (Flutter) reagem
```

### 3.2 Comunicação entre features

Sem event bus. A feature de origem expõe um `ValueNotifier` público; a de destino escuta.

```dart
// origem — FarmManager
final ValueNotifier<CropEntity?> lastHarvestedNotifier = ValueNotifier(null);

// destino — escuta e reage
FarmManager.instance.lastHarvestedNotifier.addListener(...);
```

Quando a operação é transacional (colher → adicionar ao inventário), **não** use notifier: o UseCase compõe os dois UseCases diretamente. `HarvestCropUseCase(FarmManager, AddItemUseCase)`.

### 3.3 Progressão de tempo

```
TimeManager (Timer periódico)
  → tick de kMinutesPerTick minutos de jogo
  → timeNotifier / tickStream
  → TimeScheduler.handleTick()      # dispara tarefas agendadas, com catch-up
  → virada de dia → dayChangeListeners
       → WorldStateManager.advanceDay()
       → FarmManager.advanceDay()          # crescimento das plantações
       → PlayerStateManager…restoreStaminaFully()
       → GameSaveController.saveGame()
```

O registro desses listeners está hoje em `farm_service_locator.dart` (`_onDayChanged`) — acoplamento a corrigir (ver plano de refatoração).

---

## 4. Regras de domínio — farm

Ponto mais denso do jogo. Fonte da verdade: `FarmObject` + `CropEntity`.

**Solo** (`SoilState`): `untilled → tilled → watered`; `fertilized` existe mas não é usado.

**Plantio:**
- Crop comum exige solo `tilled` **ou** `watered` (`canPlantCrop`).
- Árvore exige solo `untilled` (`canPlantTree`).
- Tile precisa estar vazio (`crop == null`).

**Virada de dia** (`FarmObject.advanceDay(dayEnded)`):
- Árvore: cresce sempre, independente de água; solo permanece.
- Crop: só cresce se `lastWateredDay == dayEnded` **e** `soilState == watered`. Depois de crescer, a água é consumida (`watered → tilled`, `lastWateredDay = null`).
- Não regado: nada acontece, estado preservado.

**Crescimento** (`CropEntity.advanceDay()`): `daysInStage` acumula; ao atingir `stepDays` avança um `CropStageType` e zera. `stepDays = ceil(daysToMature / 7)` na primeira vida, `regrowStepDays` quando está em rebrota.

**Colheita** (`FarmObject.harvest()`):
- Exige `stage == harvestable`.
- Crop sem rebrota → removida do tile.
- Crop com rebrota → volta `regrowStageRollback` estágios (piso: `sprout`), `isRegrowing = true`.

---

## 5. Persistência

### 5.1 Cadeia ativa

```
GameSaveController        # orquestra: coleta de cada manager e restaura
   ↓
SaveManager               # validação, debounce de auto-save, metadata, backup de save corrompido
   ↓
SaveRepository            # conditional import: native (SharedPreferences+gzip) | web (localStorage)
   ↓
SaveData (save_data_model.dart)   # version, timestamp, playerData, worldData, inventoryData, farmData
```

### 5.2 Versionamento

`SaveData.kCurrentVersion` + `_migrateFromVersion()`. **Ao mudar o formato de qualquer bloco de save: incremente a versão e escreva a migração — com teste de round-trip da versão antiga.**

### 5.3 Código morto

`systems/save/domain/`, `systems/save/interfaces/` e `systems/save/models/` não são importados por nada. Três modelos de save coexistem. Remoção planejada na Fase 3 do refactoring.

---

## 6. Sistema de personagens

Duas abordagens convivem — a composição é a direção correta.

### 6.1 Composição (`shared/framework/character/`) — alvo

`Character extends SimplePlayer` + lista de `CharacterBehavior`:

`MovementBehavior`, `CombatBehavior`, `FarmingBehavior`, `MiningBehavior`, `DefenseBehavior`, `ConsumableBehavior`, `EquipmentSyncBehavior`, `EnemyDetectionBehavior`.

`Character` provê: lock de ação com timeout de segurança, buffer de input direcional, regeneração de stamina com contador de ações concorrentes, sincronização `data ↔ entidade`, emotes, detecção de inimigos.

> ⚠️ `_cacheFrequentlyUsedBehaviors()` identifica behaviors por `runtimeType.toString().contains('Movement')`. Quebra com minificação e com qualquer renomeação. Corrigir para `whereType<MovementBehavior>()`.

### 6.2 Herança (`shared/framework/player/`) — legado

```
DDFarmPlayer → DDConsumablePlayer → DDDefensePlayer → DDCombatPlayer → DDMobilePlayer → DDBasePlayer
```

Seis níveis, cada um com Model/View/Controller/Config. É a maior dívida estrutural do projeto: adicionar capacidade exige escolher um ponto na cadeia, e o caminho de import fica com ~200 caracteres. Migração para behaviors está na Fase 3.

---

## 7. Renderização e mapas

- Mapas em Tiled (`assets/images/tiled/**.json`), carregados por `MapManager` / `MapDef`.
- Objetos do Tiled viram decorations/inimigos por nome via registry em `MapDef`.
- Transição entre mapas por `MapTransitionSensor` + `MapTransitionController`.
- Y-sorting para crops altas: `CropEntity.shouldUseYSorting` a partir de `ySortingFromStage`.

---

## 8. UI e overlays

Duas camadas visuais:

1. **Mundo** — componentes Bonfire (`*View`, `FarmTileView`, decorations).
2. **Overlay** — widgets Flutter sobre o `BonfireWidget`, registrados no `GameplayScreen` e ligados/desligados pela `GlobalStateMachine`.

Overlays leem `ValueNotifier`s dos managers com `ValueListenableBuilder`. Design tokens em `shared/design_system/theme/tokens/`.

---

## 9. Fronteiras de teste

| Camada | Testável hoje | Como |
|---|---|---|
| `features/*/entities`, `world/entities` | ✅ trivial | unitário puro |
| `features/*/usecases` | ✅ | injetar fake manager |
| `features/*/managers` | ✅ | `reset()` no `setUp` |
| `features/*/services` | ✅ | direto |
| `features/time/*` | ✅ | `GameTime`/`DayState`/`TimeScheduler` são puros |
| `systems/save/save_data_model` | ✅ | direto |
| `systems/save/save_manager` | ⚠️ | `SaveRepository` é concreto com conditional import → precisa de seam |
| `modules/*/model`, `*/controller` | ✅ | sem instanciar a View |
| `modules/*/view`, `components/` | ❌ | requer game loop Bonfire |
| overlays Flutter | ⚠️ | widget test possível; baixo ROI hoje |

**Meta de cobertura por camada** está em [TESTING.md](TESTING.md).
