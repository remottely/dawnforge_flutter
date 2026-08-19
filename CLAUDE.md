# CLAUDE.md — Dawnforge

Contexto canônico para agentes de IA e para o dev. **Este arquivo descreve o projeto como ele é hoje**, não como gostaríamos que fosse. Quando houver divergência entre este arquivo e o código, o código vence e este arquivo deve ser corrigido no mesmo commit.

> **Dev solo.** Toda decisão aqui é otimizada para *um* mantenedor: robusto onde erra caro (domínio, save, regras de jogo), simples onde erra barato (UI, glue de engine). DRY/KISS/YAGNI têm precedência sobre pureza arquitetural.

---

## 1. O que é o projeto

Jogo 2D top-down estilo *Stardew Valley / Forager*, em Flutter + [Bonfire](https://pub.dev/packages/bonfire) (que roda sobre Flame). Single-player, offline, persistência local.

| | |
|---|---|
| Package | `dawnforge` |
| Dart SDK | `^3.12.0-14.0.dev` (Dart 3.13 / Flutter 3.47) |
| Engine | `bonfire ^3.16.1`, `flame_audio`, `flame_splash_screen` |
| DI | `get_it ^9.2.0` (Service Locator) + singletons nativos |
| Persistência | `shared_preferences` (native) / `web` localStorage |
| Testes | `flutter_test` + `mocktail ^1.0.4` |
| Plataformas | Android, iOS, macOS, Linux, Windows, Web (Firebase Hosting) |
| Escala | ~30k linhas Dart, ~317 arquivos |

---

## 2. Arquitetura

Referência completa e mapa de pastas: **[documentation/ARCHITECTURE.md](documentation/ARCHITECTURE.md)**.
Resumo operacional abaixo — é o que você precisa para escrever código correto.

### 2.1 Camadas de topo (`lib/`)

```
lib/
├── main.dart          # Bootstrap: singletons → service locators → runApp
├── core/              # Utilitários sem dependência de jogo (logger, env, settings)
├── shared/            # Framework reutilizável: design system + base classes Bonfire
├── pre_game/          # Telas fora do gameplay (menu)
└── game/              # Todo o jogo
    ├── features/      # Domínio por funcionalidade (farm, inventory, time, market, world)
    ├── systems/       # Serviços transversais do jogo (save, audio, map, combat, overlay, ui, input)
    ├── modules/       # Entidades concretas de mundo (players, enemies, npcs, decorations)
    ├── database/      # Catálogos estáticos tipados (`*_database_def.dart`)
    ├── global/        # Estado/input globais do gameplay (state machine, input handler)
    └── utils/         # Helpers ligados ao gameplay
```

**Regra de dependência** (o que pode importar o quê):

```
modules ──▶ features ──▶ core
   │           │
   ├──▶ systems ──▶ core
   └──▶ shared ────▶ core
```

- `core/` **não importa nada** de `game/` ou `shared/`.
- `features/<x>/` pode importar `features/<y>/` **apenas** via UseCase ou `ValueNotifier` público — nunca detalhes internos.
- `shared/framework/` não conhece features específicas (exceto o acoplamento legado já existente com `inventory`, que está no backlog de refatoração).
- Nada importa `pre_game/` além de `main.dart`.

### 2.2 Anatomia de uma feature (`game/features/<feature>/`)

Estrutura **plana por responsabilidade** (não `domain/data/presentation`):

```
features/farm/
├── entities/    # (em world/entities) objetos puros, imutáveis, com toJson/fromJson
├── models/      # value objects de apoio / config visual
├── managers/    # ESTADO singleton + ValueNotifier. Sem regra de negócio complexa.
├── usecases/    # OPERAÇÕES. Uma classe, um `call()`. Recebe deps no construtor.
├── services/    # Stateless: factories, cálculos, integração externa
├── viewmodels/  # Adaptação Manager → UI
├── handlers/    # Ponte input do jogo → usecases
├── components/  # Componentes Bonfire da feature
├── constants/   # `k`-constantes locais à feature
└── <feature>_service_locator.dart  # registro GetIt da feature
```

### 2.3 Papéis — decore isto

| Papel | Guarda estado? | Responsabilidade | Como testar |
|---|---|---|---|
| **Entity** | não (imutável) | Regra de negócio pura + serialização | teste unitário direto, sem mock |
| **Manager** | **sim** (singleton) | Ser a fonte da verdade + notificar via `ValueNotifier` | `reset()` no `setUp`, asserta estado |
| **UseCase** | não | Orquestrar uma operação, validar, coordenar managers | injeta fakes/mocks das deps |
| **Service** | não (ou cache) | Factory, cálculo, IO | teste direto |
| **ViewModel** | derivado | Traduzir manager → UI | teste direto |
| **Def / Constants** | não | Constantes e catálogos estáticos | teste de invariantes do catálogo |
| **Controller/View/Model** | — | Trio MVC de entidades Bonfire (`modules/`) | teste apenas o Model/Controller |

> ⚠️ **Managers não devem crescer com lógica de negócio.** Se um método de manager começa a validar/decidir, isso pertence a um UseCase. `FarmManager.plantSeed` e `waterTile` hoje violam isso — está mapeado no backlog.

### 2.4 Decisões arquiteturais vigentes

Estas são as escolhas já feitas (referenciadas no código como "A2", "C1", "E2"...). Elas seguem valendo:

| Tópico | Escolha | Nota |
|---|---|---|
| Estrutura | Flat por responsabilidade | não criar `domain/data/presentation` |
| UseCases | Classes concretas, sem interface base | `call()` como método principal |
| Estado | Singleton + `ValueNotifier` | `Manager.instance` |
| Entidades | Entity com `toJson`/`fromJson` embutido | sem camada `Model` separada |
| Save/Load | UseCase dedicado (`SaveXUseCase` / `LoadXUseCase`) | versionado |
| UI | ViewModel intermediário quando há lógica; `ValueNotifier` direto quando é só exibir | |
| Testes | `mocktail` para dobras; integração real quando barato | |
| DI | GetIt para UseCases/ViewModels; `.instance` para Managers/Services | ver §2.5 |
| Nomenclatura | Manager = estado, UseCase = operação, Service = stateless | |
| Eventos cross-módulo | `ValueNotifier` público no manager de origem | |
| Constantes | Locais à feature, arquivo `*_def.dart` ou `*_constants.dart` | |
| Catálogo de conteúdo | Constantes Dart tipadas em `game/database/` | migrado de JSON — **não voltar para JSON** |

### 2.5 Regra de DI (importante — tem inconsistência histórica)

- **Managers e Services**: acesse por `XManager.instance`. Não registre no GetIt.
- **UseCases e ViewModels**: registre como `registerFactory` no `*_service_locator.dart` da feature e resolva com `getIt<X>()`.
- **Nunca** misture: `getIt<FarmManager>()` já quebrou o jogo em produção (commit `1.106.15+1`).
- Em teste, construa o UseCase manualmente (`TillSoilUseCase(fakeManager)`) em vez de mexer no GetIt global.

### 2.6 Bootstrap (`main.dart`)

Ordem obrigatória — quebrar isso causa `LateInitializationError`:

```
WidgetsFlutterBinding.ensureInitialized()
  → Flame.device.fullScreen() (não-web)
  → _initializeSingletons()      # Settings, Audio, CropFactory, ItemFactory,
                                 # FarmManager.initializeTiles, InventoryManager.initializeSlots,
                                 # EquipmentManager.initialize
  → setupInventoryDependencies() # inventory antes de farm: farm depende de Add/RemoveItemUseCase
  → setupFarmDependencies()
  → runApp(AppRoot)
```

---

## 3. Convenções de código

### 3.1 Nomenclatura

| Elemento | Padrão | Exemplo |
|---|---|---|
| Arquivo | `snake_case.dart` | `farm_manager.dart` |
| Classe | `PascalCase` | `TillSoilUseCase` |
| Método/variável | `camelCase` | `advanceDay()` |
| Privado | `_camelCase` | `_notifyChange()`, `_tiles` |
| Constante pública | `kPascalCase` após o `k` | `kTileSize`, `kDaysPerSeason` |
| Constante privada | `_kPascalCase` | `_kSaveKey` |
| Enum | `PascalCase`, valores `lowerCamelCase` | `SoilState.untilled` |
| Interface | `IPascalCase` | `ISaveable` |
| Base do framework | prefixo `DD` | `DDBasePlayerView` |

> Valores de enum em `snake_case` (`empty_seed_bag`) e em `UPPER` (`InterfaceType.HUD`) são **legado**. Não crie novos; a migração está no backlog (afeta ~99 avisos do linter).

### 3.2 Sufixos de arquivo — significado fixo

| Sufixo | Significa |
|---|---|
| `*_def.dart` | Constantes + factories estáticas de configuração de uma entidade |
| `*_config.dart` | Objeto de configuração injetável |
| `*_constants.dart` | Constantes puras de um módulo |
| `*_model.dart` | Estado mutável de uma entidade Bonfire (parte do MVC) |
| `*_view.dart` | Componente Bonfire renderizável |
| `*_controller.dart` | Lógica de uma entidade Bonfire, sem tocar em render |
| `*_manager.dart` | Singleton de estado |
| `*_use_case.dart` | Operação única |
| `*_service.dart` | Stateless |
| `*_database_def.dart` | Catálogo estático de conteúdo |

### 3.3 Ordem dentro de uma classe

```dart
class Example {
  // 1. Constantes (públicas, depois privadas)
  static const double kSize = 32.0;
  static const String _kKey = 'example';

  // 2. Campos finais / injetados
  final FarmManager _manager;

  // 3. Estado mutável privado
  bool _isReady = false;

  // 4. Construtores (principal, depois named/factory)
  Example(this._manager);

  // 5. Getters computados
  bool get isReady => _isReady;

  // 6. API pública (ordem de fluxo, não alfabética)
  void start() { }

  // 7. Privados, agrupados por funcionalidade
  void _process() { }

  // 8. Serialização
  Map<String, dynamic> toJson() => {};
}
```

### 3.4 Regras práticas

- **Sem valores mágicos.** Número ou string repetida vira constante `k` no `*_def.dart`/`*_constants.dart` da feature.
- **Um método, uma responsabilidade.** Se precisa de comentário explicando "agora fazemos X", extraia método.
- **Entidades são imutáveis.** Mutação retorna nova instância (`copyWith`, `till()`, `water()`). Use `Equatable` em entidades.
- **Logging** via `GameLogger` (`.info/.warning/.error`), nunca `print`. Formato: `'[NomeDaClasse] mensagem'`. `GameLogger` já é no-op em release.
- **Documentação**: `///` em toda classe pública e em métodos cuja intenção não é óbvia pelo nome. Escreva *por que*, não *o que*.
- **Idioma**: código, nomes e mensagens de log em **inglês**. Documentação (`.md`) e comentários explicativos podem ser em **português**.
- **TODOs**: sempre `// TODO(Kevin): descrição acionável`. TODO sem dono é proibido.
- **Código morto**: apague. Não comente blocos "para depois" — o git guarda. Existe muito código comentado no repo; ao tocar num arquivo, limpe o que estiver no caminho.
- **`ValueNotifier`**: quem cria, faz `dispose`. Managers singleton são exceção (vivem o app inteiro).

---

## 4. Testes

Estratégia completa: **[documentation/TESTING.md](documentation/TESTING.md)**.

### 4.1 Regras não-negociáveis

1. **Toda entidade, use case, manager e service novo nasce com teste.** Sem exceção.
2. **Bug corrigido = teste de regressão** que falha antes do fix.
3. **Refatoração acontece com a suíte verde antes e depois.** Nunca refatore código sem cobertura — escreva o teste primeiro (é literalmente o propósito da fase atual do projeto).
4. **Nunca comente um teste para fazer a suíte passar.** Conserte ou delete com justificativa no commit.

### 4.2 Layout

`test/` espelha `lib/` exatamente:

```
test/
├── helpers/                     # test doubles, builders, fixtures, reset helpers
├── core/…
└── game/
    ├── features/farm/usecases/till_soil_use_case_test.dart
    └── …
```

### 4.3 Convenções

- Nome do arquivo: `<arquivo_sob_teste>_test.dart`.
- `group()` = nome da classe; `test()` = comportamento em inglês, no formato `'<condição> → <resultado esperado>'`.
- Estrutura **Arrange / Act / Assert** com linha em branco entre blocos.
- Managers singleton: chame `reset()` no `setUp()`. Sempre.
- Prefira builders de `test/helpers/` a literais gigantes inline.
- `mocktail` para dobras; instância real quando construir é barato e determinístico.

### 4.4 Comandos

```bash
flutter test                       # suíte
flutter test --coverage            # gera coverage/lcov.info
./tool/coverage.sh                 # coverage + resumo por camada (falha abaixo da meta)
flutter test test/game/features/farm/   # subconjunto
flutter analyze                    # linter
dart format .                      # formatação (obrigatório antes do commit)
```

---

## 5. Padrão de commit — obrigatório

```
<version>; <type>: <description>
```

**Exemplo real:** `1.110.14+1; config: reorganize project layers`

### 5.1 Regras

- `<version>` é **exatamente** o valor de `version:` no `pubspec.yaml` **após o bump deste commit**. Bump o `pubspec.yaml` no mesmo commit.
- Bump: `feat` → **minor** (`1.110.14+1` → `1.111.0+1`). Todos os outros tipos → **patch** (`1.110.14+1` → `1.110.15+1`). Breaking change → major, com `BREAKING CHANGE:` no corpo.
- `<description>`: imperativo, minúsculo, em inglês, sem ponto final.
- Uma mudança lógica por commit.

### 5.2 Tipos permitidos

| Tipo | Uso |
|---|---|
| `feat` | nova funcionalidade de jogo ou sistema |
| `fix` | correção de bug |
| `refactor` | muda estrutura sem mudar comportamento |
| `chore` | limpeza, renomeações, ajustes menores, format |
| `config` | assets, pubspec, tooling, Tiled, build, CI |
| `test` | adiciona ou ajusta testes |
| `docs` | documentação |

### 5.3 Checklist antes de commitar

- [ ] `dart format .`
- [ ] `flutter analyze` sem *novos* avisos
- [ ] `flutter test` verde
- [ ] `pubspec.yaml` com versão bumpada
- [ ] mensagem no formato `<version>; <type>: <description>`
- [ ] versão da mensagem **igual** à do `pubspec.yaml`

### 5.4 Detectando divergência de versão

O item mais fácil de esquecer é o bump do `pubspec.yaml` — e quando ele é esquecido, a mensagem do commit passa a mentir. Já aconteceu: `b72f25c1` anuncia `1.110.14+1` mas deixou o `pubspec.yaml` em `1.110.13+1`.

Confira antes de commitar:

```bash
# devem ser iguais
grep '^version:' pubspec.yaml | cut -d' ' -f2
git log -1 --pretty=%s | cut -d';' -f1
```

Se divergirem, a mensagem do commit é o registro público — alinhe o `pubspec.yaml` a ela e siga a numeração a partir do maior valor.

---

## 6. Regras para o agente de IA

1. **Leia antes de escrever.** Este projeto tem convenções específicas e código legado com armadilhas conhecidas. Abra os arquivos vizinhos e siga o estilo local.
2. **Não invente arquitetura nova.** As decisões da §2.4 estão fechadas. Propor mudança = abrir um ADR em `documentation/refactoring/adr/`, não reescrever silenciosamente.
3. **Refatoração só com teste.** Se a área não tem cobertura, escreva o teste primeiro no mesmo trabalho.
4. **Não crie abstração especulativa.** YAGNI vale. Interface só quando existe segunda implementação real ou é fronteira de teste.
5. **Não mexa em assets nem em `pubspec.yaml`** (lista de assets) sem pedido explícito — a lista é manual e frágil por decisão.
6. **Não delete código legado em massa** sem antes checar referências e sem estar na fase correspondente do plano.
7. **Ao terminar**, rode `dart format . && flutter analyze && flutter test` e reporte o resultado real, incluindo falhas.
8. **Convenção > preferência pessoal.** Se o código local diverge deste doc, siga o código e sinalize a divergência.

---

## 7. Mapa de documentação

| Arquivo | Conteúdo |
|---|---|
| `CLAUDE.md` | **este** — contexto canônico, convenções, commits |
| `documentation/ARCHITECTURE.md` | arquitetura detalhada, mapa de pastas, fluxos |
| `documentation/TESTING.md` | estratégia de testes, helpers, metas de cobertura |
| `documentation/refactoring/` | plano de evolução em fases + ADRs + progresso |
| `documentation/gdd_mvp.md` | game design do MVP |
| `documentation/CONTROLS.md` | mapeamento de input |
| `documentation/WORLD_GRID_SYSTEM.md` | sistema de grid do mundo |

---

## 8. Débitos conhecidos (resumo)

Detalhamento e ordem de ataque em [documentation/refactoring/](documentation/refactoring/).

- Suíte de testes quase inexistente — a maior parte dos arquivos em `test/` estava 100% comentada.
- `lib/game/systems/save/` tem **três** modelos de save; só um está em uso (`save_data_model.dart`). `domain/`, `interfaces/` e `models/` são código morto.
- Duas enums de estação: `Season` (`systems/world`) e `SeasonType` (`features/inventory/entities/enums`).
- Cadeia de herança de player com 6 níveis (`DDFarmPlayer → … → DDBasePlayer`) — composição por `CharacterBehavior` já existe e deve substituí-la.
- `Character._cacheFrequentlyUsedBehaviors()` casa comportamento por `runtimeType.toString().contains('Movement')` — frágil.
- `design_system_old/` coexistindo com `design_system/`.
- ~288 avisos com `flutter_lints` ativo; `constant_identifier_names` e `avoid_print` dominam.
