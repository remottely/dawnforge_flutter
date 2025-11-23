# 🎯 FASE 3.2 - IA de Inimigos

> **Objetivo:** Implementar comportamento de IA para inimigos
>
> **Prioridade:** 🟡 IMPORTANTE (Gameplay dinâmico)
>
> **Tempo Estimado:** 2-3 dias
>
> **Dependências:** Combate Base (3.1)

---

## 📋 Estrutura Final

```
lib/gameplay/enemies/ai/
├── enemy_ai_controller.dart          ✅ Controlador principal de IA
├── behaviors/
│   ├── idle_behavior.dart            ✅ Comportamento idle
│   ├── patrol_behavior.dart          ✅ Patrulha
│   ├── chase_behavior.dart           ✅ Perseguição
│   ├── attack_behavior.dart          ✅ Ataque
│   └── flee_behavior.dart            ✅ Fuga
└── pathfinding/
    └── simple_pathfinding.dart       ✅ Pathfinding simples

test/gameplay/enemies/ai/
├── enemy_ai_controller_test.dart     ✅ Testes de IA
└── pathfinding_test.dart             ✅ Testes de pathfinding
```

---

## 🚀 PROMPT 1: Criar EnemyAIController

### Contexto

O AIController gerencia o comportamento dos inimigos, alternando entre estados (idle, patrol, chase, attack) baseado em distância do player e condições.

### Prompt para o Claude

````
Crie o sistema de IA para inimigos:

ARQUIVO: lib/gameplay/enemies/ai/enemy_ai_controller.dart

REQUISITOS DO CONTROLLER:

1. Gerenciamento de Estado:
   - Manter estado atual (EnemyAIState)
   - Transições de estado baseadas em condições
   - Update loop para processar IA

2. Detecção do Player:
   - Calcular distância até player
   - Entrar em chase se player dentro de aggroRange
   - Voltar para idle/patrol se player longe

3. Integração com Behaviors:
   - Delegar ações para behavior classes
   - IdleBehavior, PatrolBehavior, ChaseBehavior, etc

4. Cooldowns e Timers:
   - Attack cooldown
   - State change cooldown (evitar flickering)

PADRÃO DE CÓDIGO:
```dart
final class EnemyAIController {
  final Enemy enemy;
  final Player player; // Referência ao player

  EnemyAIState _currentState;
  double _lastStateChangeTime = 0;
  double _lastAttackTime = 0;

  static const double _kStateChangeCooldown = 0.5; // segundos

  EnemyAIController({
    required this.enemy,
    required this.player,
  }) : _currentState = enemy.aiState;

  EnemyAIState get currentState => _currentState;

  /// Atualizar IA (chamar a cada frame)
  void update(double dt) {
    if (enemy.isDead) {
      _changeState(EnemyAIState.dead);
      return;
    }

    // Calcular distância até player
    final distanceToPlayer = _calculateDistanceToPlayer();

    // Determinar novo estado baseado em distância
    final targetState = _determineTargetState(distanceToPlayer);

    // Mudar estado se necessário
    if (targetState != _currentState) {
      _tryChangeState(targetState);
    }

    // Executar behavior do estado atual
    _executeBehavior(dt, distanceToPlayer);
  }

  /// Determinar estado alvo baseado em distância
  EnemyAIState _determineTargetState(double distanceToPlayer) {
    // Morto: permanecer morto
    if (_currentState == EnemyAIState.dead) {
      return EnemyAIState.dead;
    }

    // Atacar: se player dentro do attack range
    if (distanceToPlayer <= enemy.stats.attackRange) {
      return EnemyAIState.attack;
    }

    // Perseguir: se player dentro do aggro range
    if (distanceToPlayer <= enemy.aggroRange) {
      return EnemyAIState.chase;
    }

    // Fugir: se HP baixo (< 20%)
    if (enemy.stats.healthPercent < 0.2) {
      return EnemyAIState.flee;
    }

    // Patrulhar: por padrão quando longe do player
    return EnemyAIState.patrol;
  }

  /// Tentar mudar estado (com cooldown)
  void _tryChangeState(EnemyAIState newState) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Cooldown para evitar flickering
    if (now - _lastStateChangeTime < _kStateChangeCooldown) {
      return;
    }

    _changeState(newState);
  }

  /// Mudar estado imediatamente
  void _changeState(EnemyAIState newState) {
    if (_currentState == newState) return;

    developer.log('[EnemyAI] ${enemy.name} changing state: $_currentState -> $newState');

    _currentState = newState;
    _lastStateChangeTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Callback de mudança de estado
    _onStateChanged(newState);
  }

  /// Executar behavior do estado atual
  void _executeBehavior(double dt, double distanceToPlayer) {
    switch (_currentState) {
      case EnemyAIState.idle:
        IdleBehavior.execute(enemy, dt);
        break;

      case EnemyAIState.patrol:
        PatrolBehavior.execute(enemy, dt);
        break;

      case EnemyAIState.chase:
        ChaseBehavior.execute(enemy, player, dt);
        break;

      case EnemyAIState.attack:
        if (_canAttack()) {
          AttackBehavior.execute(enemy, player, dt);
          _lastAttackTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
        }
        break;

      case EnemyAIState.flee:
        FleeBehavior.execute(enemy, player, dt);
        break;

      case EnemyAIState.dead:
        // Não fazer nada
        break;
    }
  }

  /// Calcular distância até player
  double _calculateDistanceToPlayer() {
    // Implementar usando posições (Vector2)
    // return enemy.position.distanceTo(player.position);
    return 0.0; // Placeholder
  }

  /// Pode atacar? (cooldown)
  bool _canAttack() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final cooldown = 1.0 / enemy.stats.attackSpeed;
    return now - _lastAttackTime >= cooldown;
  }

  /// Callback de mudança de estado
  void _onStateChanged(EnemyAIState newState) {
    // Pode disparar animações, sons, etc
  }

  /// Forçar estado (para debugging/cutscenes)
  void forceState(EnemyAIState state) {
    _changeState(state);
  }
}
````

CHECKLIST DE VALIDAÇÃO:
[ ] Controller gerencia estados corretamente
[ ] Transições baseadas em distância funcionam
[ ] Cooldowns evitam flickering
[ ] Behaviors delegados corretamente
[ ] Logs detalhados

### Critérios de Aceitação

- [ ] IA funcional
- [ ] Transições suaves entre estados
- [ ] Cooldowns funcionam
- [ ] Código documentado

```

---

## 🚀 PROMPT 2: Criar Behavior Classes

### Contexto
Cada estado da IA tem uma classe de behavior que implementa a lógica específica (idle, patrol, chase, attack, flee).

### Prompt para o Claude

```

Crie as classes de behavior para cada estado:

ARQUIVO 1: lib/gameplay/enemies/ai/behaviors/idle_behavior.dart

```dart
/// Behavior: Idle (parado)
final class IdleBehavior {
  IdleBehavior._(); // Utility class

  /// Executar behavior idle
  static void execute(Enemy enemy, double dt) {
    // Apenas ficar parado
    // Pode adicionar animação idle
  }
}
```

ARQUIVO 2: lib/gameplay/enemies/ai/behaviors/patrol_behavior.dart

```dart
/// Behavior: Patrol (patrulha)
final class PatrolBehavior {
  PatrolBehavior._();

  static final Map<String, Vector2?> _patrolTargets = {};
  static final Map<String, double> _patrolTimers = {};

  /// Executar behavior patrol
  static void execute(Enemy enemy, double dt) {
    // 1. Obter ou criar patrol target
    var target = _patrolTargets[enemy.id];
    if (target == null) {
      target = _generateRandomPatrolTarget(enemy);
      _patrolTargets[enemy.id] = target;
    }

    // 2. Mover em direção ao target
    _moveTowards(enemy, target, dt);

    // 3. Se chegou no target, esperar e escolher novo
    if (_reachedTarget(enemy, target)) {
      _patrolTimers[enemy.id] = (_patrolTimers[enemy.id] ?? 0) + dt;

      if (_patrolTimers[enemy.id]! >= 2.0) { // Esperar 2 segundos
        _patrolTargets[enemy.id] = null;
        _patrolTimers[enemy.id] = 0;
      }
    }
  }

  static Vector2 _generateRandomPatrolTarget(Enemy enemy) {
    // Gerar posição aleatória próxima
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = 2.0 + random.nextDouble() * 3.0;

    // return enemy.position + Vector2(cos(angle), sin(angle)) * distance;
    return Vector2.zero(); // Placeholder
  }

  static void _moveTowards(Enemy enemy, Vector2 target, double dt) {
    // Mover enemy em direção ao target
    // final direction = (target - enemy.position).normalized();
    // enemy.position += direction * enemy.moveSpeed * dt;
  }

  static bool _reachedTarget(Enemy enemy, Vector2 target) {
    // return enemy.position.distanceTo(target) < 0.5;
    return false; // Placeholder
  }
}
```

ARQUIVO 3: lib/gameplay/enemies/ai/behaviors/chase_behavior.dart

```dart
/// Behavior: Chase (perseguir player)
final class ChaseBehavior {
  ChaseBehavior._();

  /// Executar behavior chase
  static void execute(Enemy enemy, Player player, double dt) {
    // 1. Calcular direção até player
    // final direction = (player.position - enemy.position).normalized();

    // 2. Mover em direção ao player
    // enemy.position += direction * enemy.moveSpeed * dt;

    // 3. Olhar para o player
    // enemy.facingDirection = direction;

    developer.log('[ChaseBehavior] ${enemy.name} chasing player');
  }
}
```

ARQUIVO 4: lib/gameplay/enemies/ai/behaviors/attack_behavior.dart

```dart
/// Behavior: Attack (atacar player)
final class AttackBehavior {
  AttackBehavior._();

  /// Executar behavior attack
  static void execute(Enemy enemy, Player player, double dt) {
    developer.log('[AttackBehavior] ${enemy.name} attacking player');

    // 1. Executar ataque via CombatManager
    final hitResult = CombatManager.instance.enemyAttackPlayer(enemy);

    // 2. Disparar animação de ataque
    // enemy.playAnimation('attack');

    // 3. Aplicar dano ao player
    if (hitResult.isHit) {
      developer.log('[AttackBehavior] Hit player for ${hitResult.damageDealt} damage');
      // player.takeDamage(hitResult.damageDealt);
    }
  }
}
```

ARQUIVO 5: lib/gameplay/enemies/ai/behaviors/flee_behavior.dart

```dart
/// Behavior: Flee (fugir do player)
final class FleeBehavior {
  FleeBehavior._();

  /// Executar behavior flee
  static void execute(Enemy enemy, Player player, double dt) {
    // 1. Calcular direção oposta ao player
    // final direction = (enemy.position - player.position).normalized();

    // 2. Mover para longe do player (mais rápido que normal)
    // final fleeSpeed = enemy.moveSpeed * 1.5;
    // enemy.position += direction * fleeSpeed * dt;

    developer.log('[FleeBehavior] ${enemy.name} fleeing from player');
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Idle behavior implementado
[ ] Patrol gera targets aleatórios
[ ] Chase persegue player
[ ] Attack chama CombatManager
[ ] Flee move para longe do player

### Critérios de Aceitação

- [ ] Todos os behaviors funcionais
- [ ] Movimentação suave
- [ ] Logs informativos
- [ ] Código limpo

```

---

## 🚀 PROMPT 3: Criar Pathfinding Simples

### Contexto
Implementar pathfinding básico para que inimigos possam navegar ao redor de obstáculos (opcional, pode ser implementado mais tarde).

### Prompt para o Claude

```

Crie pathfinding simples (opcional):

ARQUIVO: lib/gameplay/enemies/ai/pathfinding/simple_pathfinding.dart

REQUISITOS:

1. Algoritmo A\* Simplificado:

   - Grid-based pathfinding
   - Evitar obstáculos
   - Encontrar caminho mais curto

2. Integração com Behaviors:
   - Chase e Flee usam pathfinding
   - Fallback para movimento direto se path não encontrado

PADRÃO DE CÓDIGO:

```dart
final class SimplePathfinding {
  SimplePathfinding._();

  /// Encontrar caminho de start até end
  static List<Vector2>? findPath({
    required Vector2 start,
    required Vector2 end,
    required List<Vector2> obstacles,
  }) {
    // Implementar A* ou linha direta por enquanto
    // Por simplicidade, MVP pode usar movimento direto
    return [end]; // Placeholder
  }

  /// Verificar se há obstáculo entre dois pontos
  static bool hasObstacleBetween(Vector2 start, Vector2 end, List<Vector2> obstacles) {
    // Raycast simples
    return false; // Placeholder
  }
}
```

NOTA: Para o MVP, pathfinding pode ser simplificado ou pulado.
Inimigos podem se mover em linha reta até o player.

### Critérios de Aceitação

- [ ] Pathfinding básico funciona OU
- [ ] Movimento direto funciona como fallback

```

---

## 🚀 PROMPT 4: Integrar IA com Bonfire Components

### Contexto
Integrar o AIController com os componentes do Bonfire (Enemy components no jogo).

### Prompt para o Claude

```

Integre IA com componentes Bonfire:

TAREFAS:

1. Criar EnemyComponent:

   - Herdar de SimpleEnemy (Bonfire)
   - Adicionar EnemyAIController
   - Chamar controller.update() no update()

2. Spawnar Inimigos:

   - Adicionar inimigos no mapa via TiledMap
   - Instanciar EnemyComponent com IA

3. Feedback Visual:
   - Animações para cada estado (idle, walk, attack)
   - Barra de HP acima do inimigo
   - Efeitos de dano

PADRÃO DE CÓDIGO:

```dart
class EnemyComponent extends SimpleEnemy {
  final Enemy enemyModel;
  late EnemyAIController aiController;

  EnemyComponent({
    required this.enemyModel,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(32),
    life: enemyModel.stats.currentHealth.toDouble(),
    speed: enemyModel.moveSpeed * 50, // Ajustar velocidade
  );

  @override
  void onMount() {
    super.onMount();

    // Inicializar IA
    final player = gameRef.player; // Obter player
    aiController = EnemyAIController(
      enemy: enemyModel,
      player: player as Player,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Atualizar IA
    aiController.update(dt);

    // Sincronizar estado visual com IA
    _updateAnimation();
  }

  void _updateAnimation() {
    switch (aiController.currentState) {
      case EnemyAIState.idle:
        idle();
        break;
      case EnemyAIState.patrol:
      case EnemyAIState.chase:
      case EnemyAIState.flee:
        // Usar animação de walk
        // animation?.playOnce('walk');
        break;
      case EnemyAIState.attack:
        // animation?.playOnce('attack');
        break;
      case EnemyAIState.dead:
        // animation?.playOnce('death');
        break;
    }
  }

  @override
  void receiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    super.receiveDamage(attacker, damage, id);

    // Atualizar model
    // enemyModel = enemyModel.takeDamage(damage.toInt());

    // Mostrar dano visual
    _showDamageText(damage.toInt());
  }

  void _showDamageText(int damage) {
    // Spawnar texto de dano acima do enemy
    // gameRef.add(DamageTextComponent(damage: damage, position: position));
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] EnemyComponent integrado com Bonfire
[ ] IA atualiza a cada frame
[ ] Animações sincronizadas com estados
[ ] Dano visual funciona
[ ] HP bar renderizada

### Critérios de Aceitação

- [ ] Inimigos aparecem no mapa
- [ ] IA funciona in-game
- [ ] Animações corretas
- [ ] Feedback visual de dano

```

---

## 🚀 PROMPT 5: Criar Testes de IA

### Contexto
Validar comportamento da IA com testes automatizados.

### Prompt para o Claude

```

Crie testes de IA:

ARQUIVO 1: test/gameplay/enemies/ai/enemy_ai_controller_test.dart
TESTES:

1. test_idle_when_far_from_player
2. test_chase_when_player_in_aggro_range
3. test_attack_when_player_in_attack_range
4. test_flee_when_low_health
5. test_state_change_cooldown_prevents_flickering
6. test_dead_state_permanent

ARQUIVO 2: test/gameplay/enemies/ai/behaviors_test.dart
TESTES:

1. test_patrol_generates_random_targets
2. test_chase_moves_towards_player
3. test_attack_calls_combat_manager
4. test_flee_moves_away_from_player

SETUP:

```dart
void main() {
  late Enemy testEnemy;
  late Player testPlayer;
  late EnemyAIController aiController;

  setUp(() {
    testEnemy = Enemy(
      id: 'test_enemy',
      enemyTypeId: 'goblin',
      name: 'Test Goblin',
      type: EnemyType.goblin,
      stats: CombatStats(
        maxHealth: 50,
        currentHealth: 50,
        attack: 10,
      ),
      aggroRange: 5.0,
    );

    testPlayer = Player(/* ... */);

    aiController = EnemyAIController(
      enemy: testEnemy,
      player: testPlayer,
    );
  });

  test('idle_when_far_from_player', () {
    // Posicionar player longe
    // aiController.update(0.016);
    // expect(aiController.currentState, EnemyAIState.idle);
  });
}
```

CHECKLIST:
[ ] Todos os testes passam
[ ] Cobertura >= 80%
[ ] Edge cases cobertos

### Critérios de Aceitação

- [ ] Testes completos
- [ ] IA validada

```

---

## 📊 Checklist de Conclusão da Fase 3.2

### Arquivos Criados
- [ ] EnemyAIController
- [ ] 5 Behavior classes
- [ ] SimplePathfinding (opcional)
- [ ] Integração com Bonfire
- [ ] Testes completos

### Funcionalidades Validadas
- [ ] IA muda estados corretamente
- [ ] Behaviors executam ações
- [ ] Integração com combate funciona
- [ ] Animações sincronizadas

### Próximos Passos
⏭️ Avançar para **FASE 4.1** - UI de HUD

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
