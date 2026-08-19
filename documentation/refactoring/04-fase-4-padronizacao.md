# Fase 4 — Padronização

**Objetivo:** zerar o linter e uniformizar nomenclatura. É a fase mais chata e a que mais depende das anteriores.

**Critério de saída:** `flutter analyze` = 0; `analysis_options.yaml` reduzido ao `include`.

---

## 4.1 🔴 Migrar enums para `lowerCamelCase`

**Problema.** 99 ocorrências de `constant_identifier_names`. Duas famílias:

| Família | Exemplo | Serializado em save? |
|---|---|:---:|
| `snake_case` | `HandItemId.empty_seed_bag`, `ToolType.watering_can` | ✅ **sim** |
| `UPPER` | `InterfaceType.HUD`, `InterfaceType.GUI` | ❌ não |

`HandItemId` é serializado por `name` em `InventorySlot.toJson` e `CropEntity.toJson`. **Renomear sem migração corrompe todo save existente.**

### Passo 1 — o que não toca save (barato, faça primeiro)

`InterfaceType` e outras enums puramente de runtime.

```
chore: rename InterfaceType values to lowerCamelCase
```

### Passo 2 — `HandItemId` e afins (caro, com migração)

1. Adicionar `SaveData.kCurrentVersion = 2`.
2. Escrever a tabela de tradução legado → novo:
   ```dart
   const _kLegacyItemIds = <String, String>{
     'empty_seed_bag': 'emptySeedBag',
     'carrot_seed_bag': 'carrotSeedBag',
     // …
   };
   ```
3. `HandItemId.fromJson` consulta a tabela antes de falhar:
   ```dart
   static HandItemId fromJson(String json) =>
       fromString(_kLegacyItemIds[json] ?? json);
   ```
4. **Teste obrigatório:** carregar um JSON de save versão 1 completo e verificar que todo item é resolvido. Guarde o fixture em `test/fixtures/save_v1.json` — ele é a prova de que ninguém perde progresso.
5. Só então renomear os valores da enum.
6. Remover `constant_identifier_names: false` do `analysis_options.yaml`.

```
feat: migrate item ids to lowerCamelCase with save v1 compatibility
```

> ⚠️ Passo 4 antes do 5. Sempre. Um save de jogador é o único dado do projeto que não dá para regenerar.

---

## 4.2 🟡 Zerar os lints restantes

Depois de `dart fix` (Fase 1.2) e das correções de risco (Fase 1.4), o que sobra precisa de julgamento:

| Regra | Ação |
|---|---|
| `avoid_renaming_method_parameters` (8) | renomear para casar com a superclasse — evita confusão real ao ler override |
| `unused_field` (10) | remover, ou usar se era intenção esquecida — verifique o git blame antes |
| `unnecessary_getters_setters` (3) | remover a indireção |
| `deprecated_member_use` (4) | migrar para a API atual do Flutter/Bonfire |
| `use_key_in_widget_constructors` (2) | adicionar `super.key` |
| `unnecessary_overrides` (4) | remover — override que só chama `super` é ruído |

Um commit por regra, `chore: fix <regra>`.

Ao chegar em zero, `analysis_options.yaml` deve ficar assim:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude: [ "**/*.g.dart", "build/**" ]

linter:
  rules:
    # extras que reforçam as convenções do CLAUDE.md
    always_declare_return_types: true
    # …
```

Sem nenhum `false`. É esse o marco.

---

## 4.3 🟡 Limpar código comentado

`00-diagnostico.md §4.9`. Regra: **o git é o arquivo morto do projeto.** Bloco comentado sem data e sem dono é lixo informacional — o próximo leitor não sabe se é planejado, removido ou quebrado.

| Arquivo | Situação |
|---|---|
| `inventory_def.dart` | 39 de 44 linhas comentadas |
| `market_models.dart` | catálogo majoritariamente comentado |
| `loot_category.dart` | metade dos valores comentados |
| `equipment_manager.dart` | método `equip()` inteiro comentado |
| `pubspec.yaml` | dezenas de assets comentados |

Para cada um, decida explicitamente: **restaurar**, **apagar** ou **virar TODO com dono**.

```
chore: remove commented-out code from <arquivo>
```

Balanceamento comentado (multiplicadores de qualidade, restauração de energia) provavelmente **deve ser restaurado** — é design de jogo, não código morto. Trate como feature, não como limpeza.

---

## 4.4 🟢 Padronizar sufixos de arquivo

`CLAUDE.md §3.2` fixa o significado de cada sufixo. Divergências atuais:

| Arquivo | Problema | Correção |
|---|---|---|
| `torch_decoration_config.dart` | é `*_def` na prática (constantes + factories estáticas) | renomear para `torch_decoration_def.dart` |
| `bed_decoration_config.dart`, `door_decoration_config.dart`, … | idem | idem |
| `farm_tool_action_config.dart` | verificar se é def ou config injetável | conforme o caso |
| `save_data_model.dart` | não é model de entidade Bonfire | → `save_data.dart` (Fase 3.1) |
| `soil_state_model.dart` | órfão | remover (Fase 1.3) |

**Commit de rename puro**, sem mudar conteúdo, para o git preservar o histórico.

```
chore: rename decoration config files to def suffix
```

---

## 4.5 🟢 Uniformizar estilo de import

Hoje há mistura de relativo e absoluto **no mesmo arquivo**:

```dart
import 'package:dawnforge/core/utils/game_logger.dart';   // absoluto
import '../managers/farm_manager.dart';                   // relativo
```

**Regra a adotar:** `package:dawnforge/...` sempre. Um único estilo elimina a pergunta e facilita mover arquivo.

`directives_ordering` (Fase 1.2) já agrupa; esta tarefa uniformiza a forma.

```
chore: use package imports consistently
```

---

## 4.6 🟢 Documentação pública

`public_member_api_docs` está desligada e assim fica — documentar 100% da API pública num projeto solo é custo sem retorno.

Mas o mínimo do `CLAUDE.md §3.4` vale:
- toda classe pública tem `///` de uma linha dizendo **por que existe**
- método com intenção não óbvia pelo nome tem `///`

Faça oportunisticamente, ao tocar cada arquivo. Não abra uma tarefa só para isso.

---

## Marco final

Ao terminar a Fase 4:

```bash
flutter analyze   # 0 issues
flutter test      # verde
./tool/coverage.sh # ≥ 80%
```

E o `00-diagnostico.md` §7 preenchido com os números finais ao lado do baseline.
