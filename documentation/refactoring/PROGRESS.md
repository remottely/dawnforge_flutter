# Progresso

Rastreamento vivo. Atualize ao concluir cada tarefa, no mesmo commit.

**Última atualização:** 2026-08-19

---

## Painel

| Métrica | Baseline (19/08) | Atual | Meta |
|---|---:|---:|---:|
| Arquivos de teste executáveis | 5 / 19 | **23 / 23** ✅ | 100% |
| Testes passando | 14 | **589** | — |
| Testes falhando | 16 | **0** ✅ | 0 |
| Cobertura global | ~0% | **22.2%** | ≥ 80% |
| └ `world/entities` | 0% | **95.4%** ✅ | 95% |
| └ `inventory/usecases` | 0% | **95.0%** ✅ | 90% |
| └ `systems/world` | 0% | **92.8%** ✅ | 85% |
| └ `farm/usecases` | 0% | **90.9%** ✅ | 90% |
| `flutter analyze` (lib) | 594 | **66** | 0 |
| `flutter analyze` (test) | 3 | **0** ✅ | 0 |
| Arquivos órfãos | 17 | 17 | 0 |
| Modelos de save | 3 | 3 | 1 |
| Níveis de herança de player | 6 | 6 | 1 |
| Design systems | 2 | 2 | 1 |

Regenerar métricas:

```bash
flutter test --reporter compact | tail -1
flutter analyze lib | tail -1
./tool/coverage.sh
```

> A cobertura global de 22% não é contradição com os 90–95% do domínio: das
> ~6.700 linhas medidas, ~4.300 são entidades Bonfire, handlers de input e
> sistemas de combate, ainda sem teste. O que está coberto é o que decide o
> jogo. Ver [TESTING.md §3.1](../TESTING.md#31-sobre-o-número-global).

---

## Fase 1 — Fundação de testes

### 1.1 Estrutura de `test/`
- [x] `test/helpers/` — builders, fakes, reset de singletons
- [x] `tool/coverage.sh` com gate por camada
- [x] Remover os 14 arquivos 100% comentados
- [x] Migrar `test/gameplay/**` → layout espelhando `lib/`
- [x] Corrigir `gameplay_map_manager_test.dart`

### 1.2 Higiene mecânica ✅
- [x] `dart fix --apply --code=unused_import` — 22 fixes
- [x] `dart fix --apply --code=directives_ordering` — 106 fixes
- [x] ~~`sort_constructors_first`~~ — revertido: conflita com CLAUDE.md §3.3
- [x] `dart fix --apply` restante (18 regras seguras) — 69 fixes
- [x] `dart format .`

**594 → 66 avisos.** Duas descobertas: `sort_constructors_first` contraria a
convenção de ordem de classe do projeto, e `always_declare_return_types` /
`strict_top_level_inference` **geraram código que não compila** via `dart fix`
(ver [01-fase-1 §1.2.2](01-fase-1-fundacao-de-testes.md#122--dart-fix-corrompeu-código-com-duas-regras)).

### 1.3 Código morto
- [ ] Remover área de save morta (~1.200 linhas)
- [ ] Remover órfãos confirmados
- [ ] Consolidar `farm_constants.dart`

### 1.4 Risco real
- [ ] `unrelated_type_equality_checks` — `CropFactoryService.getCropsBySeason`
- [ ] `dead_code` / `dead_null_aware_expression`
- [ ] `overridden_fields`
- [ ] **Match de behavior por string** (bloqueante para 3.2)
- [ ] `unnecessary_non_null_assertion` / `unnecessary_null_comparison`

### 1.5 Logging
- [ ] `print` → `GameLogger` (43)
- [ ] Remover `avoid_print: false` do `analysis_options.yaml`

---

## Fase 2 — Cobertura de domínio

| Módulo | Meta | Atual | Status |
|---|---:|---:|---|
| `world/entities` | 95% | 95.4% | ✅ concluído |
| `inventory/usecases` | 90% | 95.0% | ✅ concluído |
| `systems/world` | 85% | 92.8% | ✅ concluído |
| `farm/usecases` | 90% | 90.9% | ✅ concluído |
| `inventory` managers/services/entities | 85% | 70.8% | 🟡 falta cobrir os `items/` |
| `time` | 90% | 51.5% | 🟡 falta `TimeManager` (baseado em `Timer`) |
| `farm` managers/services | 85% | 40.1% | 🟡 falta `FarmViewModel` e handlers |
| `core` | 80% | 23.1% | 🟡 falta `SettingsManager` |
| `systems/save` (ativo) | 90% | 21.2% | 🔴 **bloqueado por 3.1** — `SaveManager` sem seam |
| `market` | 80% | 6.3% | 🟡 falta `MarketManager` |
| `database` (invariantes) | — | ✅ | 54 invariantes de catálogo |
| `modules/*_model`, `*_controller` | 70% | 0% | ⬜ próxima frente |

**Escrito nesta fase:** 23 arquivos de teste, 589 casos, ~5.700 linhas.

---

## Fase 3 — Refatoração estrutural

- [ ] 3.1 Unificar save + extrair `ISaveRepository` 🔴
- [ ] 3.2 Migrar players para behaviors 🔴
- [ ] 3.3 Tirar regra de negócio do `FarmManager` 🟡
- [ ] 3.4 Unificar `Season` / `SeasonType` 🟡
- [ ] 3.5 Consolidar design system 🟡
- [ ] 3.6 Extrair `DayChangeCoordinator` 🟡
- [ ] 3.7 Corrigir `copyWith` que não seta `null` 🟢
- [ ] 3.8 Compensação em `HarvestCropUseCase` 🟢

---

## Fase 4 — Padronização

- [ ] 4.1 Enums → `lowerCamelCase` (com migração de save v1→v2) 🔴
- [ ] 4.2 Zerar lints restantes
- [ ] 4.3 Limpar código comentado
- [ ] 4.4 Padronizar sufixos de arquivo
- [ ] 4.5 Uniformizar estilo de import
- [ ] 4.6 Documentação pública mínima

---

## Histórico

| Data | Fase | O que mudou |
|---|---|---|
| 2026-08-19 | — | Diagnóstico inicial; `CLAUDE.md`, `ARCHITECTURE.md`, `TESTING.md` reescritos; `analysis_options.yaml` ativado (estava 100% comentado); plano de 4 fases e ADRs 0001–0004 criados |
| 2026-08-19 | 1.1 | Estrutura de teste reconstruída espelhando `lib/`; helpers (builders, reset de singletons, mocks) e `tool/coverage.sh` criados; 14 arquivos de teste mortos removidos; 2 testes desatualizados substituídos por invariantes de mapa |
| 2026-08-19 | 2 | 589 testes escritos: entidades de mundo, inventário, tempo, use cases de farm e inventário, managers, services, save e invariantes de catálogo. 7 defeitos reais encontrados (ver Descobertas) |
| 2026-08-19 | 1.2 | Higiene mecânica: 594 → 66 avisos. `sort_constructors_first` revertida por conflitar com a convenção de ordem de classe; `dart fix` de `always_declare_return_types`/`strict_top_level_inference` gerou código não-compilável e foi descartado |

---

## Descobertas durante a execução

Registre aqui o que o trabalho revelar e que não estava no diagnóstico — vira tarefa de fase.

| Data | Descoberta | Onde | Ação |
|---|---|---|---|
| 2026-08-19 | `GridTile.copyWith` não consegue setar `object` para `null`; `removeObject()` não remove | `world/entities/grid_tile.dart` | Fase 3.7 |
| 2026-08-19 | `CropFactoryService.getCropsBySeason` compara `SeasonType` com `String` — sempre `false` | `farm/services/crop_factory_service.dart` | Fase 1.4 |
| 2026-08-19 | `SeasonType.next()` percorre `any` e `unknown`, quebrando o ciclo de estações | `inventory/entities/enums/season.dart` | Fase 3.4 |
| 2026-08-19 | `SaveData.fromJson` engole exceção e devolve objeto vazio — corrupção silenciosa | `systems/save/save_data_model.dart` | Fase 3.1 |
| 2026-08-19 | `HarvestCropUseCase` perde o item se o inventário estiver cheio | `farm/usecases/harvest_crop_use_case.dart` | Fase 3.8 |
| 2026-08-19 | `InventoryManager._currentMaxSlots` é `static` — vaza entre testes | `inventory/managers/inventory_manager.dart` | Fase 3 (candidato) |
| 2026-08-19 | `FarmManager`, `EquipmentManager` e `ItemFactoryService` são `final class` — impossível criar dobra de teste | vários | Fase 3 (candidato) — avaliar remover `final` ou manter instância real |
| 2026-08-19 | `CropRegrowData` não estava exportado no barrel `world_entities.dart` apesar de ser parte da API pública de `CropEntity` | `world/entities/world_entities.dart` | ✅ corrigido |
| 2026-08-19 | 🐛 **`copyWith` que não seta `null` é sistêmico** — 4 ocorrências: `GridTile.removeObject`, `GridTile.removeMetadata`, `FarmObject.advanceDay` (`lastWateredDay`), `DayState.nextDay` (`festivalId`) | 3 entidades diferentes | Fase 3.7 — reescopada de 🟢 para 🟡; testes já documentam o comportamento atual |
| 2026-08-19 | `ItemIconData.toJson` grava a chave `columnIndex` mas o campo é `spriteColumnIndex` — assimetria a considerar em qualquer renomeação | `inventory/entities/data/item_icon_data.dart` | Fase 4.1 (junto com a migração de save) |
| 2026-08-19 | 🐛 `PlantSeedUseCase` remove a semente **antes** de checar se o tile existe — plantar num tile inexistente consome a semente sem devolver. Os outros 3 caminhos de falha devolvem | `farm/usecases/plant_seed_use_case.dart` | Fase 3.3 — teste documenta o comportamento atual |
| 2026-08-19 | ⚖️ Conteúdo inconsistente: `tomato` e `apple` começam em `CropStageType.seedling` no catálogo (radish e strawberry começam em `planted`). `createCrop` preserva o stage, então o tomate nasce 2 estágios adiantado | `database/smallburg_crop_entity_database_def.dart` | decisão de game design — provavelmente proposital para a árvore, não para o tomate |
