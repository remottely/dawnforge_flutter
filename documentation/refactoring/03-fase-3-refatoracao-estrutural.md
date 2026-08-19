# Fase 3 — Refatoração Estrutural

**Pré-requisito absoluto:** o módulo alvo tem cobertura da Fase 2. Sem isso, não comece.

**Objetivo:** pagar as dívidas que travam novas features.

**Critério de saída:** um modelo de save; herança de player substituída por behaviors; um design system; validação sem duplicação.

---

## Como cada item está descrito

```
Problema  → o que dói hoje, com referência ao código
Alvo      → como fica
Passos    → sequência revisável, um commit cada
Rede      → quais testes precisam existir ANTES
Risco     → o que pode dar errado
```

---

## 3.1 🔴 Unificar o sistema de save

**Problema.** Três modelos coexistem (`00-diagnostico.md §4.1`); só `save_data_model.dart` está em uso. `SaveManager` depende de `SaveRepository` concreto com *conditional import*, o que impede injetar dobra e deixa a área crítica sem teste.

**Alvo.**

```
systems/save/
├── save_data.dart                # SaveData (renomeado de save_data_model.dart)
├── save_manager.dart             # recebe ISaveRepository no construtor
├── game_save_controller.dart
└── repository/
    ├── i_save_repository.dart    # interface (fronteira de teste — justificada)
    ├── save_repository.dart      # conditional import → native | web
    ├── save_repository_native.dart
    └── save_repository_web.dart
```

**Passos.**

1. Deletar código morto — já coberto pela Fase 1.3.
2. Extrair `ISaveRepository` das implementações existentes.
   `refactor: extract ISaveRepository interface`
3. `SaveManager` recebe o repositório por construtor, com default para produção:
   ```dart
   SaveManager._({ISaveRepository? repository})
       : _repository = repository ?? SaveRepository();
   ```
   `refactor: inject save repository into SaveManager`
4. Escrever os testes de `SaveManager` com repositório fake: save inválido rejeitado, save corrompido gera backup, debounce do auto-save, contador em metadata.
   `test: cover SaveManager with fake repository`
5. Renomear `save_data_model.dart` → `save_data.dart` (rename puro, sem mudar conteúdo).
   `chore: rename save_data_model to save_data`

**Rede.** Fase 2.5 (`SaveData`) + round-trip completo de `GameSaveController`.

**Risco.** 🔴 Alto — bug aqui apaga progresso do jogador. Mitigação: nenhuma mudança no **formato** serializado nesta fase. Só estrutura de código. Mudança de formato é Fase 4, com migração versionada.

---

## 3.2 🔴 Substituir a herança de player por behaviors

**Problema.** Cadeia de 6 níveis (`00-diagnostico.md §4.2`), cada um com 4 arquivos. `CharacterBehavior` já existe e resolve isso.

**Alvo.**

```dart
final class SmallburgPlayer extends Character {
  SmallburgPlayer({required super.position})
      : super(id: 'smallburg', data: …, config: SmallburgPlayerDef.config) {
    addBehavior(MovementBehavior());
    addBehavior(FarmingBehavior());
    addBehavior(CombatBehavior());
    addBehavior(EquipmentSyncBehavior());
  }
}
```

Capacidade vira item de lista, não posição em hierarquia.

**Passos.**

1. Corrigir `_cacheFrequentlyUsedBehaviors()` — Fase 1.4. **Bloqueante.**
2. Auditar o que cada nível da cadeia realmente adiciona e mapear para behaviors:

   | Nível | Adiciona | Behavior correspondente |
   |---|---|---|
   | `DDBasePlayer` | vida, movimento, sprite | `MovementBehavior` |
   | `DDMobilePlayer` | joystick/mobile | `MovementBehavior` (config) |
   | `DDCombatPlayer` | ataque | `CombatBehavior` |
   | `DDDefensePlayer` | escudo | `DefenseBehavior` |
   | `DDConsumablePlayer` | consumo de item | `ConsumableBehavior` |
   | `DDFarmPlayer` | ferramentas de farm | `FarmingBehavior` |

   `docs: map player inheritance chain to character behaviors`
3. Migrar **um** player concreto (sugestão: `SmallburgPlayer`, o mais usado) e validar em jogo.
   `refactor: migrate SmallburgPlayer to behavior composition`
4. Migrar os demais, um commit por player.
5. Remover a cadeia `DD*Player` quando nada mais referenciar.
   `refactor: remove DD player inheritance chain`

**Rede.** Behaviors testados isoladamente; `Character` testado quanto a: lock/unlock de ação com contador, restauração de input bufferizado, contador de ações de stamina.

**Risco.** 🟡 Médio — é comportamento de jogo, visível ao jogar. Mitigação: um player por commit, testando em execução real (`/run`) entre cada um.

---

## 3.3 🟡 Tirar regra de negócio do `FarmManager`

**Problema.** Validação duplicada entre `FarmManager` e os use cases (`00-diagnostico.md §4.4`). `TillSoilUseCase` chegou a copiar a lógica com o log `[FarmManager]` junto.

**Alvo.** `FarmManager` fica só com estado:

```dart
GridTile? getTile(int x, int y);
List<GridTile> getAllTiles();
void setTile(GridTile tile);
void notifyChange();
void clear();
void reset();
Map<String, dynamic> toJson();
void fromJson(Map<String, dynamic> json);
```

Toda decisão vai para o UseCase, que consulta as regras que **já existem** em `FarmObject` (`canPlantCrop`, `canPlantTree`, `canHarvest`).

**Passos.**

1. Mover a validação de `FarmManager.waterTile` para `WaterTileUseCase`; manager passa a só `setTile`.
   `refactor: move watering rules from FarmManager to WaterTileUseCase`
2. Idem `plantSeed` → `PlantSeedUseCase`.
3. Idem `harvestCrop` → `HarvestCropUseCase`.
4. `TillSoilUseCase._tillSoil` → inline no `call()`, corrigindo o prefixo de log.
5. `advanceDay` → `AdvanceFarmDayUseCase` (novo).
   `refactor: extract AdvanceFarmDayUseCase from FarmManager`
6. Remover os métodos de regra do manager.

**Rede.** Fase 2.3 completa. Os testes de use case não devem mudar — se mudarem, houve mudança de comportamento não intencional.

**Risco.** 🟢 Baixo, com a rede da Fase 2.

---

## 3.4 🟡 Unificar `Season` e `SeasonType`

**Problema.** Duas enums para o mesmo conceito, sem conversão (`00-diagnostico.md §4.5`). `WorldStateManager` e `TimeManager` podem divergir silenciosamente.

**Alvo.** Uma enum `Season` em `game/features/time/` (dono natural do calendário), com `any` e `unknown` — `CropEntity.requiredSeason` precisa de `any`.

**Passos.**

1. Mover `SeasonType` para `features/time/season.dart`, renomeando para `Season`.
2. `WorldStateManager` passa a usar a enum unificada.
3. Deletar `systems/world/season.dart`.
4. ⚠️ **Migração de save**: `WorldStateManager.toJson` serializa `currentSeason`. Os nomes dos valores coincidem (`spring`/`summer`/`fall`/`winter`), então o round-trip é compatível — **confirme com teste** antes de mergear.
5. Corrigir `SeasonType.next()`, que hoje percorre `any` e `unknown`:
   ```dart
   static const _cycle = [Season.spring, Season.summer, Season.fall, Season.winter];
   Season next() => _cycle[(_cycle.indexOf(this) + 1) % _cycle.length];
   ```
   `fix: skip non-calendar values in Season.next`

**Rede.** Testes de `DayState.nextDay` cobrindo o ciclo completo de 4 estações e a virada de ano; teste de round-trip de `WorldStateManager`.

**Risco.** 🟡 Médio — toca save. Mitigação: teste de round-trip com JSON da versão antiga.

---

## 3.5 🟡 Consolidar o design system

**Problema.** `design_system/` e `design_system_old/` coexistem.

**Passos.**

1. Listar o que ainda usa `design_system_old`:
   ```bash
   grep -rn "design_system_old" lib --include='*.dart'
   ```
2. Para cada widget legado (`DDButton`, `DDText`, `DDRadioButton`, `DDDialogWidget`): migrar chamadores para o equivalente novo ou promover o widget para `design_system/widgets/` usando os tokens atuais.
3. Deletar `design_system_old/`.
   `refactor: remove legacy design system`

**Risco.** 🟢 Baixo — só UI, visualmente verificável.

---

## 3.6 🟡 Tirar orquestração do service locator

**Problema.** `farm_service_locator.dart::_onDayChanged` orquestra 4 sistemas dentro de um arquivo de DI, com `TODO(Kevin): verify this method` (`00-diagnostico.md §4.7`).

**Alvo.** Um `DayChangeCoordinator` explícito em `game/systems/game/`, registrado no bootstrap:

```dart
final class DayChangeCoordinator {
  void onDayChanged(DayState previous, DayState current) {
    _worldState.advanceDay();
    _advanceFarmDay();
    _playerState.restoreStamina();
    unawaited(_saveGame());
  }
}
```

O service locator volta a só registrar dependências.

**Passos.**

1. Criar `DayChangeCoordinator` com deps injetadas.
2. Mover a lógica de `_onDayChanged` para ele, com teste.
3. Registrar em `main.dart`, remover do `farm_service_locator.dart`.
   `refactor: extract DayChangeCoordinator from farm service locator`

**Nota.** Isso também remove o flag global `_timeListenersRegistered`, que hoje é estado de módulo — outra coisa que vaza entre testes.

**Risco.** 🟢 Baixo.

---

## 3.7 🟡 Corrigir `copyWith` que não seta `null` — **defeito sistêmico**

**Problema.** Todo `copyWith` do projeto usa `campo ?? this.campo`, o que torna **impossível voltar um campo para `null`**. Passar `null` é silenciosamente ignorado e o valor antigo permanece.

Não é um caso isolado. A cobertura da Fase 2 encontrou **quatro** ocorrências, em entidades independentes:

| Local | Chamada que não funciona | Efeito observado |
|---|---|---|
| `GridTile.removeObject()` | `copyWith(object: null, metadata: null)` | **não remove nada** — o nome do método mente |
| `GridTile.removeMetadata()` | `copyWith(metadata: null)` ao remover a última chave | metadata vazio nunca colapsa para `null` |
| `FarmObject.advanceDay()` | `copyWith(lastWateredDay: null)` | campo fica com o dia antigo; o dado mente sobre a rega |
| `DayState.nextDay()` | `copyWith(festivalId: null)` | dia seguinte fica `isFestival: false` **com** `festivalId` preenchido |

`FarmObject` já havia esbarrado nisso e contornou com um parâmetro extra `setCrop`, criando inconsistência: uma entidade usa flag, as outras nem sabem que o problema existe.

Nenhuma quebra o jogo hoje — mas as quatro produzem estado inconsistente, e cada uma é uma armadilha para quem for mexer ali. Os testes da Fase 2 já documentam o comportamento atual e apontam para cá.

**Alvo.** Padrão único no projeto. Recomendado: sentinela, que não polui a assinatura.

```dart
const _unset = Object();

GridTile copyWith({int? x, int? y, Object? object = _unset, Object? metadata = _unset}) =>
    GridTile(
      x: x ?? this.x,
      y: y ?? this.y,
      object: identical(object, _unset) ? this.object : object as TileObject?,
      metadata: identical(metadata, _unset) ? this.metadata : metadata as Map<String, dynamic>?,
    );
```

Aplique nas quatro entidades **de uma vez** e remova o parâmetro `setCrop` de `FarmObject` — meia migração deixa dois padrões convivendo, que é pior que um padrão errado consistente.

**Rede.** Os testes da Fase 2 já documentam o comportamento quebrado nas quatro. Vire cada um para o comportamento correto no mesmo commit — a mudança do teste é a evidência da correção.

**Risco.** 🟡 Médio. `removeObject()` passa a de fato remover e `advanceDay` passa a limpar a rega. Antes de mergear, verifique quem depende do comportamento antigo:

```bash
grep -rn "removeObject\|removeMetadata\|lastWateredDay\|festivalId" lib --include='*.dart'
```

---

## 3.8 🟢 Compensação em `HarvestCropUseCase`

**Problema.** Se o inventário está cheio, o crop já foi removido do tile e o item é perdido. O próprio código admite:

```dart
// Nota: O crop já foi removido do tile, então não há como reverter completamente.
```

**Alvo.** Verificar espaço **antes** de colher.

```dart
if (!_inventoryManager.hasSpaceFor(harvestItemId, harvestQuantity)) {
  return false;   // crop continua no tile, jogador tenta de novo
}
```

Requer `InventoryManager.hasSpaceFor` — novo, com teste.

**Risco.** 🟢 Baixo. Melhoria clara de comportamento.

---

## Ordem sugerida

```
3.1 save        (risco maior, faça com a cabeça fresca)
3.3 farm rules  (rede de teste mais forte)
3.6 coordinator (destrava teste de virada de dia)
3.4 season      (depende de 3.6 estar estável)
3.7 copyWith
3.8 harvest
3.2 players     (o maior; faça por último, incremental)
3.5 design system (independente; encaixe quando quiser variar)
```
