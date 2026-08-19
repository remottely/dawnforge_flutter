# Fase 2 — Cobertura de Domínio

**Objetivo:** cobrir o comportamento **atual** de tudo que a Fase 3 vai mexer.

**Critério de saída:** cobertura global ≥ 80%; entities ≥ 95%; use cases ≥ 90%; save ativo ≥ 90%.

> Testes desta fase documentam o que o código **faz**, não o que deveria fazer. Comportamento suspeito é marcado com comentário apontando para a Fase 3 — e corrigido lá, com o teste mudando junto, deliberadamente.

---

## Ordem de ataque

Priorizada por `risco × probabilidade de mudar na Fase 3`:

```
1. world/entities      ← domínio puro, base de tudo, refatoração da farm depende
2. inventory           ← stacking é sutil e tem edge cases silenciosos
3. farm usecases       ← vão ser reescritos na Fase 3; precisam de oráculo
4. time                ← dispara efeitos em cascata por todo o jogo
5. save                ← corrupção custa o progresso do jogador
6. world state / market / database
```

---

## 2.1 — `game/features/world/entities/` — meta 95% ✅

| Alvo | Casos que importam |
|---|---|
| `SoilState` | `canPlantCrop` só em tilled/watered; `canPlantTree` só em untilled; round-trip JSON |
| `CropStageType` | `nextStage` no último estágio → `null`; `fromProgress` nos limiares; `fromJsonNullable` com `null`/`''`/`'none'`/inválido; `isGrowing` nas bordas |
| `CropRegrowData` | `resetState`, `copyWith`, round-trip |
| `CropEntity` | `advanceDay` avança estágio ao completar `stepDays`; `_initialStageStepDays = ceil(daysToMature/7)`; `growthProgress` com `daysToMature <= 0`; `regrowAfterHarvest` com piso em `sprout`; `shouldUseYSorting`; round-trip completo |
| `FarmObject` | matriz `till`/`water`/`plant`/`plantTree`/`harvest` × estados; `advanceDay` com/sem água; árvore ignora água; colheita de crop com e sem rebrota; `copyWith(setCrop:)` |
| `GridTile` | `placeObject`/`removeObject`; `setMetadata`/`removeMetadata` (incl. último metadata → `null`); igualdade por `Equatable`; round-trip com factory |
| `TileObjectType` | `fromJson` inválido → `unknown` |

**Armadilhas conhecidas a cobrir explicitamente:**
- `GridTile.copyWith` usa `object ?? this.object` → **não consegue setar `object` para `null`**. `removeObject()` depende disso e não funciona como o nome promete. Escreva o teste do comportamento real e marque para a Fase 3.
- `FarmObject.copyWith` resolveu o mesmo problema com o parâmetro extra `setCrop`. Inconsistência entre as duas entidades.

---

## 2.2 — `game/features/inventory/` — meta 90%

| Alvo | Casos que importam |
|---|---|
| `HandItemQuality` | `priceMultiplier`, `starCount`, `fromJson` inválido → `unknown` |
| `HandItemId` | `isSeed`/`isFarmTool`/`isCombatWeapon`/`isEquippable`; `fromString` inválido → `unknown` |
| `SeasonType` | `matches` com `any` nos dois lados; `next()` — ⚠️ hoje passa por `any` e `unknown` |
| `HandItem` | `isStackable`; `sellValue` arredondando por qualidade |
| `InventorySlot` | `canAddItem` (vazio / id diferente / não-stackável / estouraria); `addQuantity` com clamp; `removeQuantity` até zerar → slot vazio |
| `ItemFactoryService` | `createItem` antes de `initialize` → `null`; id desconhecido → `null`; retorna **cópia** (mutação não vaza para o catálogo) |
| `InventoryManager` | `upgradeInventory` nos 3 níveis; `setMaxSlots` para cima e para baixo; `getItemQuantity` somando slots; `findItem`/`findItemReverse` com wrap-around; round-trip JSON |
| `EquipmentManager` | `selectSlotIndex` inválido; sincronização ao mudar o inventário; `fromJson` com índice fora do range → clamp para 0 |
| `AddItemUseCase` | quantidade ≤ 0; stack parcial e overflow para próximo slot; inventário cheio → parcial; item não-stackável ocupa 1 slot por unidade; `addMultiple` |
| `RemoveItemUseCase` | quantidade insuficiente → `false` sem efeito colateral; remoção do fim para o começo; `removeAll` |
| `EquipItemUseCase` | item ausente → `false` |
| `Save/LoadInventoryUseCase` | round-trip preservando slots e slot equipado; JSON malformado → `false` |

**Armadilha:** `InventoryManager._currentMaxSlots` é `static`. Estado vaza entre testes mesmo com nova instância. `resetAllManagers()` cobre isso — sempre use.

---

## 2.3 — `game/features/farm/` — meta 90%

| Alvo | Casos |
|---|---|
| `FarmManager` | `waterTile` em untilled / já regado / tile inexistente; `plantSeed` respeitando regra de árvore; `harvestCrop` só quando `harvestable`; `advanceDay` em massa; round-trip JSON |
| `TillSoilUseCase` | coordenada negativa; solo já arado; criação de tile novo; `lastTilledNotifier` disparado |
| `WaterTileUseCase` | tile inexistente; solo untilled |
| `PlantSeedUseCase` | sem semente no inventário; **semente devolvida** quando o plantio falha (3 caminhos distintos); `_extractCropIdFromSeedId` com `_seed_bag` e `_seed` |
| `HarvestCropUseCase` | crop não pronta; inventário cheio → ⚠️ **item perdido, sem compensação** (documentar, corrigir na Fase 3) |
| `CropFactoryService` | não inicializado → `null`; crop retorna com `daysPlanted = 0` e regrow resetado |
| `Save/LoadFarmUseCase` | round-trip; versão futura → exceção; `farm` ausente → exceção |

---

## 2.4 — `game/features/time/` — meta 90%

| Alvo | Casos |
|---|---|
| `GameTime` | `addMinutes` cruzando meia-noite; `totalMinutes`; round-trip |
| `TimeConstants` | `wrapDay` nas bordas (1, 28, 29); `wrapSeasonIndex` |
| `DayState` | `nextDay` no dia 28 → dia 1 + próxima estação; ciclo de weekday; **sempre injetar `weatherRng`**; round-trip |
| `TimeScheduler` | `scheduleAbsolute`/`scheduleRelative`; dispara na janela correta; catch-up em salto de dia; `RepeatRule` por estação/dia/weekday; regra impossível → tarefa removida sem loop infinito; virada de ano mantém epoch monotônico |
| `WeatherType` | round-trip |

⚠️ `DayState.defaultWeatherRng` usa `Random()` global — teste não determinístico se você não injetar. `TimeManager` usa `Timer.periodic`: teste os métodos manuais, não o timer.

---

## 2.5 — `game/systems/save/` (ativo) — meta 90%

| Alvo | Casos |
|---|---|
| `SaveData` | `fromJson` com JSON válido; **`fromJson` com JSON inválido devolve objeto vazio em vez de lançar** (comportamento perigoso — documentar); `isValid` com `playerData` vazio / timestamp futuro / versão fora do range; migração `_migrateFromVersion`; round-trip; `==`/`hashCode` |
| `SaveManager` | ⚠️ **precisa de seam.** `SaveRepository` é classe concreta com conditional import — não dá para injetar dobra hoje. Extrair interface é tarefa da Fase 3; até lá, cobrir só a lógica pura de `SaveData`. |

---

## 2.6 — `game/systems/world/` e `game/database/`

- `WorldStateManager`: `advanceDay` e virada de estação em `getSeasonForDay` (dias 28/29, 112/113); `unloadInactiveMaps` com e sem mapa atual; round-trip.
- `MapState`: `fromJson` com campos ausentes → defaults.
- `Season`: round-trip.
- **`database/`** — testes de *invariante*, não de cobertura:
  - todo `CropEntity` do catálogo tem `harvestItemId` que existe em `HandItemId`
  - todo `daysToMature > 0`
  - todo `framesCount > 0`
  - toda chave do mapa bate com o `id` do item (`entry.key == entry.value.id`)
  - todo `spritesheetPath` referenciado está registrado no `pubspec.yaml`

  Estes testes pegam erro de conteúdo em segundos — o tipo de bug que só apareceria jogando.

---

## 2.7 — `core/`

- `AppEnvironment`: coerência das flags derivadas.
- `GameLogger`: não lança com mensagem vazia; respeita o ambiente.

---

## Fora de escopo (por decisão)

- `*_view.dart`, `components/`, `FarmTileView` — exigem game loop Bonfire; a lógica já está no Model/Controller/UseCase.
- Overlays Flutter — widget test possível, ROI baixo agora. Reavaliar quando a UI estabilizar.
- `pre_game/` — tela única e estável.

Se algum destes ganhar lógica não-trivial, extraia para uma classe testável em vez de tentar testar o componente.
