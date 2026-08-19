# 00 — Diagnóstico do Estado Atual

Medido em **2026-08-19**, `main` @ `f05647bf`, Flutter 3.47 / Dart 3.13.

Tudo aqui é verificável. Onde há número, há comando que o produz.

---

## 1. Tamanho

```bash
find lib -name "*.dart" | wc -l          # 299
find lib -name "*.dart" | xargs wc -l    # 30.658 linhas
```

| Camada | Linhas |
|---|---:|
| `lib/game/` | 23.247 |
| `lib/shared/` | 6.833 |
| `lib/pre_game/` | 363 |
| `lib/core/` | 142 |

Maiores arquivos (candidatos a quebra):

| Arquivo | Linhas |
|---|---:|
| `game/modules/characters/player/demo/demo_player_def.dart` | 720 |
| `game/modules/characters/player/smallburg/smallburg_player_def.dart` | 684 |
| `game/modules/characters/player/farmer/farmer_player_def.dart` | 608 |
| `game/features/market/widgets/market_panel.dart` | 542 |
| `game/features/farm/components/farm_tile_view.dart` | 502 |

---

## 2. Testes — o problema central

```bash
flutter test
```

**Resultado antes deste plano: 14 falhas / 19 arquivos.**

| Situação | Arquivos |
|---|---:|
| Não carregam (`Missing definition of main`) — **100% comentados** | 14 |
| Carregam e passam | 3 |
| Carregam e falham | 2 |

Os 14 arquivos comentados importam caminhos que não existem mais:

```dart
// import 'package:dawnforge/features/inventory/managers/inventory_manager.dart';
//                          ^^^^^^^^ hoje é lib/game/features/
```

**Causa raiz:** a reorganização de pastas (`1.106.3+1 refactor: reorganize all app structure`) quebrou os testes, e eles foram comentados em vez de corrigidos. A partir daí a suíte deixou de dar sinal, e nenhuma refatoração posterior teve rede.

Os 2 que falham (`gameplay_map_manager_test.dart`) asseguram mapas `lake_1` e `dungeon_1` que não estão mais em `MapManager.allMaps` — hoje há só `map_test`. Teste desatualizado, não bug.

**Cobertura efetiva: ~0% do que importa.**

---

## 3. Análise estática

`analysis_options.yaml` estava **inteiramente comentado** — sem linter nenhum.

Com o `analysis_options.yaml` novo (`flutter_lints` + extras):

```bash
flutter analyze    # 597 issues
```

| Regra | Ocorrências | Auto-fixável | Natureza |
|---|---:|:---:|---|
| `sort_constructors_first` | 258 | ✅ | estilo |
| `directives_ordering` | 180 | ✅ | estilo |
| `unused_import` | 22 | ✅ | limpeza |
| `prefer_initializing_formals` | 11 | ✅ | estilo |
| `unused_field` | 10 | — | limpeza |
| `overridden_fields` | 9 | — | **risco real** |
| `no_leading_underscores_for_local_identifiers` | 9 | ✅ | estilo |
| `avoid_renaming_method_parameters` | 8 | — | legibilidade |
| `curly_braces_in_flow_control_structures` | 7 | ✅ | estilo |
| `use_super_parameters` / `annotate_overrides` | 10 | ✅ | estilo |
| `dead_code` / `dead_null_aware_expression` | 8 | — | **risco real** |
| `unnecessary_null_comparison` / `unnecessary_non_null_assertion` | 6 | ✅ | **risco real** |
| `unrelated_type_equality_checks` | 2 | — | **bug provável** |

`dart fix --apply` resolve ~438 (73%) sem intervenção humana.

Desligadas de propósito por ora (ver `analysis_options.yaml`):
- `constant_identifier_names` — 99 ocorrências, enums legadas serializadas em save.
- `avoid_print` — 43 ocorrências.

---

## 4. Dívidas estruturais

### 4.1 🔴 Três modelos de save, um em uso

```
systems/save/save_data_model.dart          ← ATIVO (SaveData)
systems/save/models/save_data_model.dart   ← morto, quase idêntico (sem farmData)
systems/save/domain/models/*.dart          ← morto (PlayerSaveData, WorldSaveData,
                                              FarmSaveData, InventorySaveData)
systems/save/models/save_results.dart      ← morto (SaveResult/LoadResult/…)
systems/save/interfaces/*.dart             ← morto (3 interfaces)
systems/save/domain/interfaces/i_saveable.dart ← morto
```

Verificado por análise de referências: nenhum desses arquivos é importado por nada fora da própria pasta morta. **~1.200 linhas de código morto** numa área crítica — pior lugar possível para ambiguidade.

### 4.2 🔴 Cadeia de herança de player com 6 níveis

```
DDFarmPlayer → DDConsumablePlayer → DDDefensePlayer → DDCombatPlayer
             → DDMobilePlayer → DDBasePlayer
```

Cada nível com `_view` / `_model` / `_controller` / `_config`. Efeitos:

- Adicionar capacidade obriga a escolher um ponto na cadeia; escolher errado espalha a mudança.
- Path de import de 180+ caracteres.
- Impossível ter "player que minera mas não combate" sem duplicar.

A alternativa **já existe e funciona**: `Character` + `CharacterBehavior` (`shared/framework/character/behavior/`, 9 behaviors implementados). A cadeia `DD*Player` é o caminho antigo que sobreviveu a um rollback (`1.104.34+1 rollback: put back old player architecture`).

### 4.3 🟡 `Character` casa behavior por string

`shared/framework/character/character.dart:136-148`:

```dart
_cachedMovementBehavior = _behaviors
    .where((b) => b.runtimeType.toString().contains('Movement'))
    .firstOrNull;
```

Quebra com minificação (Web release) e com qualquer renomeação. Correção trivial: `_behaviors.whereType<MovementBehavior>().firstOrNull`.

### 4.4 🟡 Regra de negócio dentro do Manager

`FarmManager` (268 linhas) implementa `waterTile`, `plantSeed`, `harvestCrop`, `advanceDay` com validação e decisão — apesar de existirem `WaterTileUseCase`, `PlantSeedUseCase`, `HarvestCropUseCase`. Os use cases hoje **validam de novo e delegam**, resultando em validação duplicada em dois lugares que podem divergir.

`TillSoilUseCase` foi ainda mais longe: implementa `_tillSoil` internamente e loga com o prefixo `[FarmManager]` — sinal de código copiado do manager sem limpeza.

### 4.5 🟡 Duas enums de estação

| Enum | Local | Valores |
|---|---|---|
| `Season` | `systems/world/season.dart` | spring, summer, fall, winter |
| `SeasonType` | `features/inventory/entities/enums/season.dart` | + `any`, `unknown` |

`WorldStateManager` usa `Season`; `DayState`, `CropEntity` e `TimeScheduler` usam `SeasonType`. Não há conversão entre elas — as duas linhas do tempo podem divergir silenciosamente.

### 4.6 🟡 Dois design systems

`shared/design_system/` (tokens, atual) e `shared/design_system_old/` (DDButton, DDText, DDRadioButton, DDDialogWidget). O "old" ainda é referenciado.

### 4.7 🟡 Acoplamento no service locator

`farm_service_locator.dart` registra o listener de virada de dia e, dentro dele, chama `WorldStateManager`, `FarmManager`, `PlayerStateManager` e `GameSaveController`. Um arquivo de DI está fazendo orquestração de domínio, e com um `TODO(Kevin): verify this method`.

### 4.8 🟢 Arquivos órfãos

Não referenciados por nenhum outro arquivo:

```
shared/framework/save/player_save_manager.dart
shared/framework/widgets/dd_sprite_widget.dart
shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_view.dart
shared/design_system/theme/responsive_widgets.dart
game/modules/characters/player/demo/demo_player.dart
game/features/farm/constants/farm_constants.dart      ← constantes duplicadas em outros defs
game/features/farm/models/soil_state_model.dart
game/features/farm/services/farm_tool_service.dart
game/systems/save/utils/position_helper.dart          ← arquivo de 1 linha
+ 8 arquivos da área de save morta (§4.1)
```

### 4.9 🟢 Código comentado em massa

`inventory_def.dart`: 39 de 44 linhas comentadas. `market_models.dart`: catálogo majoritariamente comentado. `loot_category.dart`: metade dos valores comentados. `pubspec.yaml`: dezenas de assets comentados.

Custo: o leitor (humano ou IA) não consegue distinguir "planejado" de "removido" de "quebrado".

---

## 5. O que está bom — preservar

Nem tudo é dívida. Estes acertos devem ser mantidos e replicados:

- ✅ **`world/entities/` é domínio puro exemplar.** `GridTile`, `TileObject`, `FarmObject`, `CropEntity`: imutáveis, `Equatable`, `copyWith`, `toJson`/`fromJson`, zero dependência de engine. É o padrão a seguir.
- ✅ **`GridTile` + `TileObject`** generaliza corretamente além de farm (móveis, cercas, decorações) sem over-engineering.
- ✅ **Trio Model/Controller/View com callbacks** (ex.: `torch_decoration_*`) desacopla lógica de render de verdade.
- ✅ **`CharacterBehavior`** é composição bem feita — só precisa substituir a herança.
- ✅ **Catálogo em constantes Dart tipadas** (`database/*_database_def.dart`) em vez de JSON: type-safe, sem IO, testável.
- ✅ **`AppEnvironment` com `const`** permite ao compilador eliminar código de debug em release.
- ✅ **Padrão de commit** disciplinado e consistente por centenas de commits.

---

## 6. Riscos priorizados

| # | Risco | Impacto | Prob. | Fase |
|---|---|---|---|---|
| 1 | Refatorar sem teste quebra o jogo em silêncio | 🔴 alto | alta | 1–2 |
| 2 | Ambiguidade no save corrompe progresso do jogador | 🔴 alto | média | 3 |
| 3 | Match por string de behavior quebra em release Web | 🔴 alto | média | 1 |
| 4 | Divergência `Season`/`SeasonType` quebra plantio sazonal | 🟡 médio | média | 3 |
| 5 | Validação duplicada manager/usecase diverge | 🟡 médio | alta | 3 |
| 6 | Cadeia de herança trava novas features | 🟡 médio | alta | 3 |
| 7 | Ruído do linter esconde bug real | 🟡 médio | alta | 1 |

---

## 7. Linha de base para comparação

Registre aqui a cada fase concluída.

| Métrica | Baseline (2026-08-19) | Meta final |
|---|---:|---:|
| Arquivos de teste executáveis | 5 / 19 | 100% |
| Testes passando | 14 | — |
| Testes falhando | 16 | 0 |
| Cobertura global | ~0% | ≥ 80% |
| `flutter analyze` (lib) | 594 | 0 |
| Arquivos órfãos | 17 | 0 |
| Modelos de save | 3 | 1 |
| Níveis de herança de player | 6 | 1 + behaviors |
| Design systems | 2 | 1 |

O acompanhamento contínuo desses números fica em [PROGRESS.md](PROGRESS.md) — este arquivo registra apenas a fotografia inicial.

---

## 8. O que a cobertura revelou

Escrever os testes da Fase 2 encontrou defeitos que a leitura do código não tinha encontrado. Todos estão em [PROGRESS.md → Descobertas](PROGRESS.md#descobertas-durante-a-execução) com destino de fase:

| Defeito | Gravidade |
|---|---|
| `copyWith` que não seta `null` — **4 ocorrências** em 3 entidades; `GridTile.removeObject()` não remove nada | 🟡 sistêmico |
| `SaveData.fromJson` engole a exceção e devolve save vazio — corrupção silenciosa | 🔴 |
| `HarvestCropUseCase` perde o loot se o inventário estiver cheio (a crop já saiu do tile) | 🟡 |
| `PlantSeedUseCase` consome a semente sem devolver quando o tile não existe | 🟡 |
| `CropFactoryService.getCropsBySeason` compara enum com String — sempre devolve lista vazia | 🟡 |
| `SeasonType.next()` percorre `any` e `unknown` — o ciclo de estações tem 6 passos, não 4 | 🟡 |
| `tomato` e `apple` nascem 2 estágios adiantados no catálogo | ⚖️ design |

Isso é o argumento do ADR-0003 em forma concreta: **sete defeitos reais, nenhum deles visível sem teste** — e todos em código que a Fase 3 ia refatorar às cegas.
