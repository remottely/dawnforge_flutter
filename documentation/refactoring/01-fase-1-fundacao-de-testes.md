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

## 1.2 — Higiene mecânica ✅

Cada item foi em **commit próprio**, sem nenhuma mudança semântica junto.

- [x] `dart fix --apply --code=unused_import` — 22 fixes / 18 arquivos
- [x] `dart fix --apply --code=directives_ordering` — 106 fixes / 106 arquivos
- [x] ~~`sort_constructors_first`~~ — **revertido**, ver §1.2.1
- [x] `dart fix --apply` para o restante auto-fixável — 69 fixes / 50 arquivos, ver §1.2.2
- [x] `dart format .`

**Resultado: 594 → 66 avisos.** `flutter analyze test` em zero. Suíte verde após cada passo.

✅ `systems/save/save_repository.dart` verificado após `directives_ordering`: o *conditional import* (`if (dart.library.html)`) sobreviveu intacto.

### 1.2.1 `sort_constructors_first` conflita com a convenção do projeto

A regra reescreveu **140 arquivos** movendo o construtor para antes dos campos — exatamente o contrário do que o [CLAUDE.md §3.3](../../CLAUDE.md#33-ordem-dentro-de-uma-classe) documenta e do que todo o codebase pratica:

```
1. Constantes  →  2. Campos finais  →  3. Estado privado  →  4. Construtores
```

Foi revertida e desligada no `analysis_options.yaml`, com o motivo registrado ali. **Convenção do projeto vence a default do lint** (CLAUDE.md §6.8).

Se um dia se decidir adotar a ordem do *Effective Dart* (construtor primeiro), o caminho é: mudar o CLAUDE.md §3.3 **antes**, e só então reativar a regra.

### 1.2.2 ⚠️ `dart fix` corrompeu código com duas regras

`--code=always_declare_return_types` e `--code=strict_top_level_inference` produziram código que **não compila**, duplicando o tipo de retorno:

```dart
// gerado por dart fix — inválido
static DDAnimationDirectionalFactory DDAnimationDirectionalFactory dynamic dynamic
    dynamic dynamic dynamic dynamic animationAttack1DirectionalFactory() => …
double double getFontSizeByType(DFFontSizeType type) { … }
```

Detectado porque a suíte passou a não carregar. Revertido com `git checkout -- lib` e reaplicado sem essas duas regras.

**Lição:** `dart fix --apply` em massa **exige** `flutter analyze && flutter test` logo depois, sempre. Não confie na ferramenta em cima de um codebase grande com tipagem parcial.

Ambas as regras seguem ativas no `analysis_options.yaml` (as 0 ocorrências restantes de `always_declare_return_types` foram corrigidas à mão pelos outros fixes); apenas **não use o auto-fix delas**.

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

Estas **não** são cosméticas. Cada uma precisa de teste antes. Depois da higiene mecânica sobraram **66 avisos**, todos exigindo julgamento humano:

| Regra | Qtd | Natureza |
|---|---:|---|
| `unused_field` | 10 | limpeza — verificar `git blame` antes de remover |
| `overridden_fields` | 9 | **risco real** — sombreamento na cadeia `DD*Player` |
| `avoid_renaming_method_parameters` | 8 | legibilidade de override |
| `deprecated_member_use` | 4 | migrar API Flutter/Bonfire |
| `dead_code` + `dead_null_aware_expression` | 8 | **risco real** |
| `unnecessary_null_comparison` + `unnecessary_non_null_assertion` | 6 | **risco real** — nulidade mal modelada |
| `unnecessary_getters_setters` | 3 | remover indireção |
| `unawaited_futures` | 3 | **risco real** — future ignorado |
| `unrelated_type_equality_checks` | 2 | **bug provável** |
| `always_declare_return_types` + `strict_top_level_inference` | 4 | corrigir **à mão** — ver §1.2.2 |
| outros (11 regras) | 9 | caso a caso |

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
