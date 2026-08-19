# Estratégia de Testes — Dawnforge

Complementa o [CLAUDE.md §4](../CLAUDE.md#4-testes). Aqui está o *como* e o *porquê*.

---

## 1. Por que testes vêm antes da refatoração

O projeto tem ~30k linhas, seis anos de acúmulo e dívidas estruturais reais (cadeia de herança de 6 níveis, três modelos de save, dois design systems). Refatorar isso sem rede é apostar. A ordem é:

```
1. Testes cobrindo o comportamento ATUAL (mesmo o que parece errado)
2. Refatorar com a suíte verde como oráculo
3. Corrigir comportamento errado — aí sim mudando o teste, deliberadamente
```

Se um teste documenta um comportamento que você acha errado, **marque-o** e não conserte junto:

```dart
// COMPORTAMENTO ATUAL, provavelmente incorreto — ver documentation/refactoring/03-fase-3.md
test('harvest fails after crop removed → item is lost (no compensation)', () { … });
```

---

## 2. Pirâmide (adaptada para gamedev)

```
        ╱ e2e ╲            ~0%   não vale o custo num jogo single-player
      ╱ widget  ╲          ~5%   só overlays com lógica de verdade
    ╱ integração ╲        ~20%   fluxos entre features (plantar→colher→inventário)
  ╱   unitário    ╲       ~75%   entidades, use cases, managers, services
```

Componentes Bonfire (`*View`, `FarmTileView`) exigem game loop e não são cobertos. Isso é intencional: a lógica que importa já foi extraída para Model/Controller/UseCase. **Se uma View tem lógica que você quer testar, o bug é o design — extraia.**

---

## 3. Metas de cobertura

Coberturas são um sintoma, não o objetivo. Mas servem de guarda-corpo.

| Camada | Meta | Estado (2026-08-19) | Motivo da meta |
|---|---:|---:|---|
| `features/world/entities` | 95% | **95.4%** ✅ | regra de jogo pura; é o coração |
| `features/inventory/usecases` | 90% | **95.0%** ✅ | orquestração; onde bugs de fluxo aparecem |
| `features/farm/usecases` | 90% | **90.9%** ✅ | idem, e serão reescritos na Fase 3 |
| `systems/world` | 85% | **92.8%** ✅ | calendário e estado de mapa |
| `features/inventory/*` (resto) | 85% | 70.8% | inclui itens e widgets de item |
| `features/farm/*` (resto) | 85% | 40.1% | falta o `FarmViewModel` e os handlers |
| `features/time/**` | 90% | 51.5% | falta `TimeManager` — ver §5.6 |
| `systems/save/**` (ativo) | 90% | 21.2% | **bloqueado**: `SaveManager` precisa do seam da Fase 3.1 |
| `features/market` | 80% | 6.3% | `MarketManager` ainda não coberto |
| `core/**` | 80% | 23.1% | |
| `database/**` | invariantes | ✅ | não se mede em %; ver §3.1 |
| `modules/**/*_model.dart`, `*_controller.dart` | 70% | 0% | próxima frente |
| `*_view.dart`, `components/`, overlays, `design_system` | excluído | — | exigem game loop |
| **Global (linhas testáveis)** | **80%** | **22.2%** | |

### 3.1 Sobre o número global

22% parece pouco e é honesto que pareça. Das ~6.700 linhas contabilizadas, cerca de 4.300 são entidades Bonfire (`modules/`, `shared/framework/`), handlers de input e sistemas de combate — código que hoje não tem teste nenhum.

O que já está coberto é o que decide o jogo: **entidades de domínio a 95%, use cases a 91–95%**. Essa é a rede que a Fase 3 exige.

**Não infle o número aumentando exclusões.** A lista de exclusões cobre só o que exige game loop ou árvore de widgets. Esconder código testável para a métrica subir troca um problema real por um número bonito.

### 3.2 A catraca

`tool/coverage.sh` aplica um gate que é **catraca, não meta**: ele trava a regressão no nível já conquistado (`GLOBAL_THRESHOLD`, hoje `20`).

Um gate fixado em 80% num projeto que está em 22% falha em todo commit e vira o primeiro candidato a ser desligado — aí não protege mais nada. Ao subir a cobertura, **suba `GLOBAL_THRESHOLD` no mesmo commit**. A meta de 80% continua valendo; a catraca é como se chega lá sem quebrar o fluxo.

`database/` aparece com 0% e está correto: os testes de invariante exercitam constantes, que não geram linhas executáveis. O valor deles não está na porcentagem.

---

## 4. Layout

`test/` espelha `lib/`. Nada de `test/gameplay/` quando o código está em `lib/game/` — divergência de path foi exatamente o que matou a suíte antiga.

```
test/
├── helpers/
│   ├── test_data_builders.dart     # builders fluentes de entidades
│   ├── fake_managers.dart          # dobras manuais leves
│   ├── mocks.dart                  # mocktail mocks + registerFallbackValue
│   └── manager_reset.dart          # reset de todos os singletons
├── core/
│   └── utils/
└── game/
    ├── features/
    │   ├── farm/{usecases,managers,services}/
    │   ├── inventory/{entities,usecases,managers,services}/
    │   ├── time/
    │   ├── world/entities/
    │   └── market/
    ├── systems/{save,world}/
    └── database/
```

---

## 5. Convenções

### 5.1 Nomes

```dart
group('FarmObject', () {
  group('advanceDay', () {
    test('crop watered on the ending day → advances growth', () { … });
    test('crop not watered → state unchanged', () { … });
    test('tree → advances regardless of water', () { … });
  });
});
```

Formato: `'<condição> → <resultado esperado>'`. Em inglês, como o código.

### 5.2 Estrutura

```dart
test('adding beyond stack size → overflows into the next slot', () {
  // arrange
  final item = anItem(maxStackSize: 10);

  // act
  final ok = useCase.addItemEntity(item, 15);

  // assert
  expect(ok, isTrue);
  expect(manager.getSlotByIndex(0)!.quantity, 10);
  expect(manager.getSlotByIndex(1)!.quantity, 5);
});
```

Uma asserção conceitual por teste. Várias linhas `expect` que descrevem *o mesmo fato* são aceitáveis.

### 5.3 Singletons

Managers são singletons de processo — o estado vaza entre testes. **Sempre**:

```dart
setUp(() {
  resetAllManagers();   // test/helpers/manager_reset.dart
});
```

`InventoryManager.slotsNotifier` e `FarmManager.tilesNotifier` são `late final` inicializados por `initializeSlots()` / `initializeTiles()`. `resetAllManagers()` cuida da ordem — não chame `initialize*` duas vezes no mesmo processo.

### 5.4 Builders

Prefira builders a literais. `CropEntity` tem 19 campos; inline mata a legibilidade.

```dart
final crop = aCrop(stage: CropStageType.harvestable, daysToMature: 4);
final tile = aFarmTile(x: 1, y: 2, soilState: SoilState.watered);
```

### 5.5 Dobras

- **Fake manual** (`test/helpers/fake_managers.dart`) quando você precisa de estado real e simples.
- **`mocktail`** quando precisa verificar interação ou simular falha.
- **Instância real** quando construir é barato e determinístico — o melhor teste é o que não mente.

```dart
class MockAddItemUseCase extends Mock implements AddItemUseCase {}

setUpAll(() {
  registerFallbackValue(HandItemId.unknown);
});
```

### 5.6 Determinismo

- `DayState.defaultWeatherRng` usa `Random()` global. Sempre injete `weatherRng` nos testes de calendário.
- `SaveData.timestamp` usa `DateTime.now()`. Passe timestamps explícitos.
- `TimeManager` usa `Timer.periodic`. Não teste o timer — teste `GameTime`, `DayState` e `TimeScheduler`, que são puros; para `TimeManager`, dirija o relógio pelos métodos manuais.

---

## 6. Comandos

```bash
flutter test                                   # suíte completa
flutter test --coverage                        # gera coverage/lcov.info
./tool/coverage.sh                             # coverage + resumo por camada + gate
./tool/coverage.sh --html                      # + relatório HTML (requer lcov)
flutter test test/game/features/farm/          # subconjunto
flutter test --name "advanceDay"               # por nome
flutter test --reporter expanded               # saída detalhada (debug de falha)
```

---

## 7. Checklist de PR

- [ ] Todo código novo de domínio/use case/manager tem teste
- [ ] Bug corrigido tem teste de regressão que falha sem o fix
- [ ] `flutter test` verde
- [ ] Cobertura global não regrediu
- [ ] Nenhum teste comentado ou `skip:` sem justificativa no commit
