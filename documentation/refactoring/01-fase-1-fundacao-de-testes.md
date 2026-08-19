# Fase 1 — Fundação de Testes

**Objetivo:** transformar `flutter test` num sinal confiável e eliminar o ruído mecânico que esconde problemas reais.

**Critério de saída:**
- `flutter test` verde, 0 arquivos não-carregáveis
- `tool/coverage.sh` executa e reporta por camada
- `flutter analyze` < 160 issues
- 0 arquivos órfãos

---

## 1.1 — Reconstruir a estrutura de `test/` ✅

`test/` passa a espelhar `lib/` exatamente. O descolamento (`test/gameplay/` × `lib/game/`) foi o que matou a suíte anterior.

```
test/
├── helpers/
│   ├── manager_reset.dart        # reset determinístico de todos os singletons
│   ├── test_data_builders.dart   # builders de CropEntity, FarmObject, HandItem, …
│   ├── fake_managers.dart        # dobras manuais
│   └── mocks.dart                # mocktail + registerFallbackValue
├── core/utils/
└── game/{features,systems,database}/…
```

**Tarefas**

- [x] Criar `test/helpers/` com builders, fakes e reset de singletons
- [x] Criar `tool/coverage.sh` com gate por camada
- [x] Remover os 14 arquivos de teste 100% comentados (o git preserva o histórico)
- [x] Migrar `test/gameplay/**` e `test/core/**` para o novo layout
- [x] Corrigir `gameplay_map_manager_test.dart` — asserções sobre mapas que não existem mais

> **Sobre remover os testes comentados:** eles não são recuperáveis. Referenciam classes que não existem (`CropDatabase`, `CropStageModel`, `SoilStateModel`) e caminhos de 3 reorganizações atrás. Os *casos* que eles cobriam foram reescritos na Fase 2 contra a API atual.

---

## 1.2 — Higiene mecânica

Cada item vai em **commit próprio**, sem nenhuma mudança semântica junto.

- [ ] `dart fix --apply --code=unused_import` (22)
  `chore: remove unused imports`
- [ ] `dart fix --apply --code=directives_ordering` (180)
  `chore: sort import directives`
- [ ] `dart fix --apply --code=sort_constructors_first` (258)
  `chore: move constructors before members`
- [ ] `dart fix --apply` para o restante auto-fixável, revisando o diff
  `chore: apply remaining automated dart fixes`
- [ ] `dart format .`
  `chore: dart format .`

**Verificação obrigatória após cada um:** `flutter analyze && flutter test`.

⚠️ Revise manualmente `systems/save/save_repository.dart` após `directives_ordering` — o arquivo usa *conditional import*, e reordenação de diretivas nesse caso merece conferência.

---

## 1.3 — Remover código morto

- [ ] Remover a área de save morta (§4.1 do diagnóstico) — **~1.200 linhas**
  ```
  systems/save/models/save_data_model.dart
  systems/save/models/save_results.dart
  systems/save/interfaces/            (3 arquivos)
  systems/save/domain/               (5 arquivos)
  ```
  `refactor: remove unused save models, interfaces and domain layer`

- [ ] Remover órfãos confirmados
  ```
  shared/framework/save/player_save_manager.dart
  shared/framework/widgets/dd_sprite_widget.dart
  shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_view.dart
  shared/design_system/theme/responsive_widgets.dart
  game/modules/characters/player/demo/demo_player.dart
  game/features/farm/models/soil_state_model.dart
  game/features/farm/services/farm_tool_service.dart
  game/systems/save/utils/position_helper.dart
  ```
  `refactor: remove orphan files`

- [ ] `game/features/farm/constants/farm_constants.dart` — órfão, **mas** contém constantes que existem duplicadas em outros lugares. Consolidar antes de apagar, não apagar direto.
  `refactor: consolidate farm constants into farm defs`

**Como confirmar que um arquivo é órfão:**

```bash
f=lib/caminho/do/arquivo.dart
grep -rl "$(basename $f)" lib test --include='*.dart' | grep -v "^$f$"
# saída vazia = órfão
```

---

## 1.4 — Correções de risco real apontadas pelo linter

Estas **não** são cosméticas. Cada uma precisa de teste antes.

- [ ] `unrelated_type_equality_checks` (2) — comparação entre tipos não relacionados; quase certamente bug.
  Suspeito conhecido: `CropFactoryService.getCropsBySeason` compara `SeasonType` com `String`:
  ```dart
  return requiredSeason == 'any' || requiredSeason == season;  // sempre false
  ```
  `fix: compare season by type instead of string in crop factory`

- [ ] `dead_code` + `dead_null_aware_expression` (8) — inclui `character.dart:395` (`velocity ?? Vector2.zero()` onde `velocity` não é nullable).
  `fix: remove dead null-aware expressions`

- [ ] `overridden_fields` (9) — campo de subclasse sombreando o da superclasse. Fonte clássica de bug na cadeia `DD*Player`.
  `fix: remove shadowed overridden fields`

- [ ] **Match de behavior por string** (§4.3 do diagnóstico) — quebra em release Web.
  ```diff
  - .where((b) => b.runtimeType.toString().contains('Movement')).firstOrNull
  + .whereType<MovementBehavior>().firstOrNull
  ```
  `fix: resolve character behaviors by type instead of runtime string`

- [ ] `unnecessary_non_null_assertion` / `unnecessary_null_comparison` (6) — revisar caso a caso; `!` desnecessário costuma indicar que a nulidade real está em outro ponto.

---

## 1.5 — Substituir `print` por `GameLogger`

43 ocorrências. `GameLogger` já é no-op em release; `print` não, e vaza no console de produção Web.

- [ ] Substituir todas, então remover `avoid_print: false` do `analysis_options.yaml`
  `chore: replace print with GameLogger`

---

## Ordem sugerida

```
1.1 (feito)  →  1.2 (mecânico, rápido)  →  1.3 (remoção)  →  1.4 (com teste)  →  1.5
```

1.2 e 1.3 antes de 1.4 porque reduzem drasticamente o ruído e tornam os problemas reais visíveis.
