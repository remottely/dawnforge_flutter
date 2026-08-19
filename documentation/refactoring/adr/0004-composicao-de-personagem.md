# ADR-0004 — Composição por behaviors em vez de herança de player

- **Status:** aceito
- **Data:** 2026-08-19

## Contexto

Existem hoje **duas** arquiteturas de personagem no projeto, em paralelo.

**Herança** (`shared/framework/player/`), 6 níveis:

```
DDFarmPlayer → DDConsumablePlayer → DDDefensePlayer → DDCombatPlayer
             → DDMobilePlayer → DDBasePlayer
```

Cada nível com `_view` / `_model` / `_controller` / `_config` — ~24 arquivos só para a cadeia. Efeitos medidos:

- Path de import de 180+ caracteres.
- Adicionar capacidade obriga a escolher uma posição na hierarquia; escolher errado espalha a mudança por todos os descendentes.
- Combinação não-linear é impossível sem duplicar: "player que minera mas não combate" não cabe numa cadeia linear.
- 9 avisos `overridden_fields` — campos de subclasse sombreando os da superclasse, fonte clássica de bug.

**Composição** (`shared/framework/character/`), já implementada e funcionando:

`Character extends SimplePlayer` + `List<CharacterBehavior>`, com 9 behaviors prontos: `Movement`, `Combat`, `Farming`, `Mining`, `Defense`, `Consumable`, `EquipmentSync`, `EnemyDetection`.

A herança sobreviveu por um rollback (`1.104.34+1 rollback: put back old player architecture across all codebase`) — foi mantida por urgência, não por decisão.

## Decisão

**Composição por `CharacterBehavior` é a arquitetura de personagem do projeto.** A cadeia `DD*Player` é legado a ser removido.

Player concreto declara suas capacidades:

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

Regras:

1. Behavior novo não conhece outros behaviors. Coordena via `Character`.
2. Behavior é testável isoladamente — sem game loop no construtor.
3. Resolução de behavior por **tipo**, nunca por string:
   ```dart
   _behaviors.whereType<MovementBehavior>().firstOrNull   // ✅
   _behaviors.where((b) => b.runtimeType.toString().contains('Movement'))  // ❌
   ```
   A segunda forma existe hoje em `character.dart:136-148` e **quebra em release Web** (minificação). Corrigir é pré-requisito bloqueante da migração.
4. Inimigos e NPCs mantêm o trio Model/Controller/View — a decisão vale para *player*, onde a explosão combinatória de capacidades acontece.

## Consequências

**Positivas.**
- Capacidade vira item de lista. Combinar é trivial.
- Behavior isolado é testável de verdade.
- Remove ~24 arquivos e a fonte dos `overridden_fields`.
- Elimina os paths de import gigantes.

**Negativas — aceitas.**
- Migração toca comportamento visível de jogo. Mitigação: **um player por commit**, validando em execução real entre cada um.
- Ordem de execução dos behaviors passa a importar. Hoje `Character` já define a prioridade explicitamente (Combat > Farming > Movement > resto) — mantenha explícita, nunca implícita pela ordem de inserção.
- Behaviors compartilham o `Character`; comunicação indireta é mais difícil de rastrear que uma chamada `super`. Mitigação: nada de behavior chamando behavior.

**Proibições decorrentes.**
- ❌ Estender a cadeia `DD*Player` com um novo nível.
- ❌ Criar player concreto herdando de `DD*Player`.
- ❌ Resolver behavior por nome de tipo em string.

## Alternativas consideradas

- **Manter a herança e só achatar a cadeia** (2–3 níveis). Reduz o sintoma, não a causa: continua impossível combinar capacidades livremente.
- **ECS completo** (entity-component-system). Descartada: Bonfire já impõe seu próprio modelo de componentes; um ECS por cima seria uma segunda arquitetura brigando com a do framework.
- **Mixins do Dart em vez de behaviors.** Tentador — mas mixin é resolvido em compile-time: não dá para adicionar/remover capacidade em runtime (equipar item que habilita ação), e continua sem estado próprio bem definido.
- **Composição por behaviors.** ✅ Escolhida — já existe, já funciona, e é o que o `Character` foi desenhado para suportar.
