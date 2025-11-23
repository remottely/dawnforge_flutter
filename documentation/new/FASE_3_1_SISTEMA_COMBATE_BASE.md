# 🎯 FASE 3.1 - Sistema de Combate Base

> **Objetivo:** Implementar mecânicas fundamentais de combate
>
> **Prioridade:** 🔴 CRÍTICO (Core gameplay)
>
> **Tempo Estimado:** 4-5 dias
>
> **Dependências:** Inventário (2.1), EquipmentManager (2.1)

---

## 📋 Estrutura Final

```
lib/gameplay/combat/
├── models/
│   ├── damage_type.dart              ✅ Tipos de dano
│   ├── combat_stats.dart             ✅ Stats de combate
│   └── hit_result.dart               ✅ Resultado de ataque
├── combat_manager.dart               ✅ Singleton, gerencia combate
├── damage_calculator.dart            ✅ Cálculos de dano
└── combat_effects.dart               ✅ Efeitos visuais

lib/gameplay/enemies/
├── models/
│   ├── enemy.dart                    ✅ Modelo base de inimigo
│   ├── enemy_type.dart               ✅ Tipos de inimigos
│   └── enemy_ai_state.dart           ✅ Estados da IA
├── enemy_factory.dart                ✅ Factory de inimigos
└── enemy_database.dart               ✅ Database de inimigos

assets/enemies/
└── enemies_database.json             ✅ Database JSON

test/gameplay/combat/
├── combat_manager_test.dart          ✅ Testes de combate
├── damage_calculator_test.dart       ✅ Testes de dano
└── enemy_ai_test.dart                ✅ Testes de IA
```

---

## 🚀 PROMPT 1: Criar Modelos Base de Combate

### Contexto

Precisamos de modelos robustos para representar stats de combate, tipos de dano e resultados de ataques.

### Prompt para o Claude

````
Crie os modelos fundamentais do sistema de combate:

ARQUIVO 1: lib/gameplay/combat/models/damage_type.dart
```dart
/// Tipos de dano no jogo
enum DamageType {
  physical,   // Dano físico (armas corpo-a-corpo)
  magical,    // Dano mágico
  fire,       // Dano de fogo
  ice,        // Dano de gelo
  poison,     // Dano de veneno
  true_;      // Dano verdadeiro (ignora defesa)

  String toJson() => name;
  static DamageType fromJson(String json) => values.byName(json);
}
````

ARQUIVO 2: lib/gameplay/combat/models/combat_stats.dart

```dart
/// Stats relacionados a combate
final class CombatStats {
  final int maxHealth;        // HP máximo
  final int currentHealth;    // HP atual
  final int attack;           // Dano base
  final int defense;          // Defesa
  final double critChance;    // Chance de crítico (0.0-1.0)
  final double critMultiplier;// Multiplicador de crítico
  final double attackSpeed;   // Velocidade de ataque
  final int attackRange;      // Alcance de ataque (tiles)

  const CombatStats({
    required this.maxHealth,
    required this.currentHealth,
    required this.attack,
    this.defense = 0,
    this.critChance = 0.05,
    this.critMultiplier = 1.5,
    this.attackSpeed = 1.0,
    this.attackRange = 1,
  });

  /// HP está cheio?
  bool get isFullHealth => currentHealth >= maxHealth;

  /// HP está vazio?
  bool get isDead => currentHealth <= 0;

  /// Porcentagem de HP (0.0-1.0)
  double get healthPercent => currentHealth / maxHealth;

  /// Receber dano
  CombatStats takeDamage(int damage) {
    final newHealth = (currentHealth - damage).clamp(0, maxHealth);
    return copyWith(currentHealth: newHealth);
  }

  /// Curar HP
  CombatStats heal(int amount) {
    final newHealth = (currentHealth + amount).clamp(0, maxHealth);
    return copyWith(currentHealth: newHealth);
  }

  /// Restaurar HP completo
  CombatStats fullHeal() {
    return copyWith(currentHealth: maxHealth);
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'maxHealth': maxHealth,
      'currentHealth': currentHealth,
      'attack': attack,
      'defense': defense,
      'critChance': critChance,
      'critMultiplier': critMultiplier,
      'attackSpeed': attackSpeed,
      'attackRange': attackRange,
    };
  }

  factory CombatStats.fromJson(Map<String, dynamic> json) {
    return CombatStats(
      maxHealth: json['maxHealth'] as int,
      currentHealth: json['currentHealth'] as int,
      attack: json['attack'] as int,
      defense: json['defense'] as int? ?? 0,
      critChance: json['critChance'] as double? ?? 0.05,
      critMultiplier: json['critMultiplier'] as double? ?? 1.5,
      attackSpeed: json['attackSpeed'] as double? ?? 1.0,
      attackRange: json['attackRange'] as int? ?? 1,
    );
  }

  CombatStats copyWith({/* campos opcionais */}) {
    // Implementar...
  }

  @override
  String toString() => 'CombatStats(HP: $currentHealth/$maxHealth, ATK: $attack, DEF: $defense)';
}
```

ARQUIVO 3: lib/gameplay/combat/models/hit_result.dart

```dart
/// Resultado de um ataque
final class HitResult {
  final int damageDealt;     // Dano causado
  final bool isCritical;     // Foi crítico?
  final bool isDodged;       // Foi esquivado?
  final bool isBlocked;      // Foi bloqueado?
  final DamageType damageType; // Tipo de dano
  final bool killedTarget;   // Matou o alvo?

  const HitResult({
    required this.damageDealt,
    this.isCritical = false,
    this.isDodged = false,
    this.isBlocked = false,
    required this.damageType,
    this.killedTarget = false,
  });

  /// Foi um hit efetivo?
  bool get isHit => !isDodged && !isBlocked;

  /// Mensagem descritiva
  String get description {
    if (isDodged) return 'Dodged!';
    if (isBlocked) return 'Blocked!';
    if (isCritical) return 'Critical Hit! -$damageDealt HP';
    return '-$damageDealt HP';
  }

  @override
  String toString() => description;
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Enums compilam
[ ] CombatStats tem todos os campos necessários
[ ] takeDamage/heal funcionam corretamente
[ ] HitResult tem informações completas
[ ] Serialização funciona
[ ] Documentação completa

### Critérios de Aceitação

- [ ] Modelos compilam sem erros
- [ ] Imutáveis (copyWith pattern)
- [ ] Cálculos de HP corretos
- [ ] Serialização completa
- [ ] Documentação clara

```

---

## 🚀 PROMPT 2: Criar DamageCalculator

### Contexto
O DamageCalculator é responsável por calcular dano considerando ataque, defesa, críticos, tipos de dano e resistências.

### Prompt para o Claude

```

Crie o sistema de cálculo de dano:

ARQUIVO: lib/gameplay/combat/damage_calculator.dart

REQUISITOS:

1. Fórmula de Dano Base:

   - damage = (attack - defense \* 0.5)
   - Mínimo 1 de dano

2. Críticos:

   - Rolar random para determinar crítico
   - Multiplicar dano por critMultiplier

3. Tipos de Dano:

   - Physical: afetado por defesa
   - Magical: ignora 50% da defesa
   - Fire/Ice/Poison: elemental (futuro: resistências)
   - True: ignora defesa completamente

4. Esquiva/Bloqueio:
   - Chance de esquiva (futuro)
   - Chance de bloqueio (futuro)

PADRÃO DE CÓDIGO:

```dart
final class DamageCalculator {
  DamageCalculator._(); // Utility class

  static final Random _random = Random();

  /// Calcular dano de um ataque
  static HitResult calculateDamage({
    required CombatStats attacker,
    required CombatStats defender,
    DamageType damageType = DamageType.physical,
    double damageMultiplier = 1.0,
  }) {
    developer.log('[DamageCalculator] Calculating damage: '
      '${attacker.attack} ATK vs ${defender.defense} DEF');

    // 1. Verificar esquiva (futuro)
    // if (_rollDodge(defender)) {
    //   return HitResult(damageDealt: 0, isDodged: true, damageType: damageType);
    // }

    // 2. Calcular dano base
    int baseDamage = _calculateBaseDamage(
      attacker.attack,
      defender.defense,
      damageType,
    );

    // 3. Aplicar multiplicador
    baseDamage = (baseDamage * damageMultiplier).round();

    // 4. Verificar crítico
    final isCritical = _rollCritical(attacker.critChance);
    if (isCritical) {
      baseDamage = (baseDamage * attacker.critMultiplier).round();
      developer.log('[DamageCalculator] CRITICAL HIT!');
    }

    // 5. Garantir dano mínimo
    final finalDamage = max(1, baseDamage);

    // 6. Verificar se mata
    final killedTarget = defender.currentHealth <= finalDamage;

    developer.log('[DamageCalculator] Final damage: $finalDamage');

    return HitResult(
      damageDealt: finalDamage,
      isCritical: isCritical,
      damageType: damageType,
      killedTarget: killedTarget,
    );
  }

  /// Calcular dano base considerando tipo
  static int _calculateBaseDamage(int attack, int defense, DamageType damageType) {
    switch (damageType) {
      case DamageType.physical:
        // Dano físico: afetado por defesa
        return attack - (defense * 0.5).round();

      case DamageType.magical:
        // Dano mágico: ignora 50% da defesa
        return attack - (defense * 0.25).round();

      case DamageType.true_:
        // Dano verdadeiro: ignora defesa
        return attack;

      case DamageType.fire:
      case DamageType.ice:
      case DamageType.poison:
        // Dano elemental: implementar resistências no futuro
        return attack - (defense * 0.3).round();
    }
  }

  /// Rolar crítico
  static bool _rollCritical(double critChance) {
    return _random.nextDouble() < critChance;
  }

  /// Calcular dano de arma
  static int calculateWeaponDamage(WeaponItem weapon) {
    return weapon.damage;
  }

  /// Calcular defesa total (equipamentos + stats base)
  static int calculateTotalDefense(CombatStats baseStats, List<Item> equipment) {
    int totalDefense = baseStats.defense;

    // Adicionar defesa de armaduras (implementar no futuro)
    // for (var item in equipment) {
    //   if (item is ArmorItem) {
    //     totalDefense += item.defense;
    //   }
    // }

    return totalDefense;
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] calculateDamage() retorna HitResult correto
[ ] Críticos funcionam aleatoriamente
[ ] Tipos de dano aplicam fórmulas corretas
[ ] Dano mínimo é 1
[ ] killedTarget detectado corretamente

### Critérios de Aceitação

- [ ] Cálculos matemáticos corretos
- [ ] Críticos aleatórios funcionam
- [ ] Tipos de dano diferenciados
- [ ] Logs detalhados
- [ ] Código documentado

```

---

## 🚀 PROMPT 3: Criar Modelos de Inimigos

### Contexto
Precisamos de modelos para representar inimigos com stats, comportamento de IA e loot.

### Prompt para o Claude

```

Crie os modelos de inimigos:

ARQUIVO 1: lib/gameplay/enemies/models/enemy_type.dart

```dart
/// Tipos de inimigos
enum EnemyType {
  slime,       // Gosma básico
  goblin,      // Goblin guerreiro
  skeleton,    // Esqueleto
  bat,         // Morcego (voa)
  wolf,        // Lobo (rápido)
  orc,         // Orc (forte)
  boss;        // Boss

  String toJson() => name;
  static EnemyType fromJson(String json) => values.byName(json);
}
```

ARQUIVO 2: lib/gameplay/enemies/models/enemy_ai_state.dart

```dart
/// Estados da IA do inimigo
enum EnemyAIState {
  idle,        // Parado
  patrol,      // Patrulhando
  chase,       // Perseguindo player
  attack,      // Atacando
  flee,        // Fugindo
  dead;        // Morto

  String toJson() => name;
  static EnemyAIState fromJson(String json) => values.byName(json);
}
```

ARQUIVO 3: lib/gameplay/enemies/models/enemy.dart

```dart
/// Modelo de inimigo
final class Enemy {
  final String id;              // ID único da instância
  final String enemyTypeId;     // ID do tipo (para factory)
  final String name;            // Nome exibido
  final EnemyType type;         // Tipo do inimigo
  final CombatStats stats;      // Stats de combate
  final EnemyAIState aiState;   // Estado atual da IA
  final double aggroRange;      // Distância para agredir player
  final double moveSpeed;       // Velocidade de movimento
  final List<String> lootTable; // IDs de itens que pode dropar
  final int expReward;          // XP ao derrotar
  final String spritePath;      // Sprite do inimigo

  const Enemy({
    required this.id,
    required this.enemyTypeId,
    required this.name,
    required this.type,
    required this.stats,
    this.aiState = EnemyAIState.idle,
    this.aggroRange = 5.0,
    this.moveSpeed = 1.0,
    this.lootTable = const [],
    this.expReward = 10,
    required this.spritePath,
  });

  /// Inimigo está vivo?
  bool get isAlive => !stats.isDead;

  /// Inimigo está morto?
  bool get isDead => stats.isDead;

  /// Pode atacar?
  bool get canAttack => isAlive && aiState == EnemyAIState.attack;

  /// Receber dano
  Enemy takeDamage(int damage) {
    final newStats = stats.takeDamage(damage);
    final newAiState = newStats.isDead ? EnemyAIState.dead : aiState;
    return copyWith(stats: newStats, aiState: newAiState);
  }

  /// Mudar estado da IA
  Enemy changeAIState(EnemyAIState newState) {
    return copyWith(aiState: newState);
  }

  /// Gerar loot aleatório
  List<String> generateLoot() {
    if (lootTable.isEmpty) return [];

    final random = Random();
    final loot = <String>[];

    for (var itemId in lootTable) {
      // 50% de chance para cada item
      if (random.nextBool()) {
        loot.add(itemId);
      }
    }

    return loot;
  }

  /// Serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enemyTypeId': enemyTypeId,
      'name': name,
      'type': type.toJson(),
      'stats': stats.toJson(),
      'aiState': aiState.toJson(),
      'aggroRange': aggroRange,
      'moveSpeed': moveSpeed,
      'lootTable': lootTable,
      'expReward': expReward,
      'spritePath': spritePath,
    };
  }

  factory Enemy.fromJson(Map<String, dynamic> json) {
    return Enemy(
      id: json['id'],
      enemyTypeId: json['enemyTypeId'],
      name: json['name'],
      type: EnemyType.fromJson(json['type']),
      stats: CombatStats.fromJson(json['stats']),
      aiState: EnemyAIState.fromJson(json['aiState']),
      aggroRange: json['aggroRange'] ?? 5.0,
      moveSpeed: json['moveSpeed'] ?? 1.0,
      lootTable: List<String>.from(json['lootTable'] ?? []),
      expReward: json['expReward'] ?? 10,
      spritePath: json['spritePath'],
    );
  }

  Enemy copyWith({/* campos opcionais */}) {
    // Implementar...
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Enums compilam
[ ] Enemy tem todos os campos necessários
[ ] takeDamage atualiza stats corretamente
[ ] generateLoot funciona aleatoriamente
[ ] Serialização funciona
[ ] IA states fazem sentido

### Critérios de Aceitação

- [ ] Modelos compilam
- [ ] IA states cobrem comportamentos
- [ ] Loot system funcional
- [ ] Serialização completa

```

---

## 🚀 PROMPT 4: Criar EnemyFactory e Database

### Contexto
Criar factory para spawnar inimigos e database JSON com tipos de inimigos.

### Prompt para o Claude

```

Crie o EnemyFactory e database:

ARQUIVO 1: lib/gameplay/enemies/enemy_factory.dart

```dart
final class EnemyFactory {
  EnemyFactory._();

  static final Map<String, Map<String, dynamic>> _enemyDatabase = {};
  static bool _isInitialized = false;
  static int _nextId = 0;

  /// Inicializar database
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final jsonString = await rootBundle.loadString('assets/enemies/enemies_database.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    for (var entry in jsonData.entries) {
      _enemyDatabase[entry.key] = entry.value;
    }

    _isInitialized = true;
    developer.log('[EnemyFactory] Loaded ${_enemyDatabase.length} enemy types');
  }

  /// Criar inimigo por tipo
  static Enemy? createEnemy(String enemyTypeId) {
    if (!_isInitialized) {
      developer.log('[EnemyFactory] ERROR: Not initialized!');
      return null;
    }

    final enemyData = _enemyDatabase[enemyTypeId];
    if (enemyData == null) {
      developer.log('[EnemyFactory] Enemy type not found: $enemyTypeId');
      return null;
    }

    // Gerar ID único
    final id = 'enemy_${_nextId++}';

    return Enemy(
      id: id,
      enemyTypeId: enemyTypeId,
      name: enemyData['name'],
      type: EnemyType.fromJson(enemyData['type']),
      stats: CombatStats.fromJson(enemyData['stats']),
      aggroRange: enemyData['aggroRange'] ?? 5.0,
      moveSpeed: enemyData['moveSpeed'] ?? 1.0,
      lootTable: List<String>.from(enemyData['lootTable'] ?? []),
      expReward: enemyData['expReward'] ?? 10,
      spritePath: enemyData['spritePath'],
    );
  }

  /// Criar múltiplos inimigos
  static List<Enemy> createEnemies(String enemyTypeId, int count) {
    return List.generate(count, (_) => createEnemy(enemyTypeId))
      .whereType<Enemy>()
      .toList();
  }
}
```

ARQUIVO 2: assets/enemies/enemies_database.json

```json
{
  "slime": {
    "name": "Slime",
    "type": "slime",
    "stats": {
      "maxHealth": 20,
      "currentHealth": 20,
      "attack": 5,
      "defense": 0,
      "critChance": 0.0,
      "critMultiplier": 1.0,
      "attackSpeed": 0.8,
      "attackRange": 1
    },
    "aggroRange": 3.0,
    "moveSpeed": 0.5,
    "lootTable": ["slime_gel"],
    "expReward": 5,
    "spritePath": "assets/images/enemies/slime.png"
  },
  "goblin": {
    "name": "Goblin",
    "type": "goblin",
    "stats": {
      "maxHealth": 40,
      "currentHealth": 40,
      "attack": 10,
      "defense": 5,
      "critChance": 0.1,
      "critMultiplier": 1.5,
      "attackSpeed": 1.0,
      "attackRange": 1
    },
    "aggroRange": 5.0,
    "moveSpeed": 1.0,
    "lootTable": ["wood", "iron_sword"],
    "expReward": 15,
    "spritePath": "assets/images/enemies/goblin.png"
  },
  "skeleton": {
    "name": "Skeleton",
    "type": "skeleton",
    "stats": {
      "maxHealth": 30,
      "currentHealth": 30,
      "attack": 12,
      "defense": 3,
      "critChance": 0.15,
      "critMultiplier": 1.8,
      "attackSpeed": 1.2,
      "attackRange": 1
    },
    "aggroRange": 6.0,
    "moveSpeed": 0.8,
    "lootTable": ["bone", "iron_sword"],
    "expReward": 20,
    "spritePath": "assets/images/enemies/skeleton.png"
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] EnemyFactory.initialize() carrega JSON
[ ] createEnemy() retorna inimigo válido
[ ] IDs únicos gerados
[ ] Database tem pelo menos 3 tipos

### Critérios de Aceitação

- [ ] Factory funcional
- [ ] Database carrega corretamente
- [ ] IDs únicos garantidos
- [ ] Pelo menos 3 tipos de inimigos

```

---

## 🚀 PROMPT 5: Criar CombatManager

### Contexto
O CombatManager gerencia combates entre player e inimigos, aplicando dano, dropando loot, etc.

### Prompt para o Claude

```

Crie o CombatManager completo:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: CombatManager.\_()
   - Instance estática: static final instance = CombatManager.\_()

2. Gerenciamento de Combate:

   - HitResult playerAttackEnemy(Enemy enemy)
   - HitResult enemyAttackPlayer(Enemy enemy)
   - Calcular dano usando DamageCalculator
   - Aplicar dano aos stats

3. Sistema de Loot:

   - List<Item> onEnemyDefeated(Enemy enemy)
   - Gerar loot do inimigo
   - Adicionar ao inventário
   - Dar XP ao player

4. Cooldown de Ataque:

   - Controlar cooldown baseado em attackSpeed
   - bool canAttack(double lastAttackTime)

5. Callbacks de Eventos:
   - onEnemyHit(Enemy enemy, HitResult result)
   - onPlayerHit(HitResult result)
   - onEnemyDefeated(Enemy enemy)

PADRÃO DE CÓDIGO:

```dart
final class CombatManager {
  CombatManager._();
  static final instance = CombatManager._();

  /// Player ataca inimigo
  HitResult playerAttackEnemy(Enemy enemy, {WeaponItem? weapon}) {
    developer.log('[CombatManager] Player attacking ${enemy.name}');

    // 1. Obter stats do player
    final playerStats = _getPlayerCombatStats(weapon);

    // 2. Calcular dano
    final hitResult = DamageCalculator.calculateDamage(
      attacker: playerStats,
      defender: enemy.stats,
      damageType: weapon is WeaponItem ? DamageType.physical : DamageType.physical,
    );

    // 3. Aplicar dano ao inimigo
    if (hitResult.isHit) {
      // Atualizar enemy (será feito no component)
      developer.log('[CombatManager] Dealt ${hitResult.damageDealt} damage');

      if (hitResult.killedTarget) {
        _onEnemyDefeated(enemy);
      }
    }

    return hitResult;
  }

  /// Inimigo ataca player
  HitResult enemyAttackPlayer(Enemy enemy) {
    developer.log('[CombatManager] ${enemy.name} attacking player');

    // 1. Obter stats do player
    final playerStats = _getPlayerCombatStats(null);

    // 2. Calcular dano
    final hitResult = DamageCalculator.calculateDamage(
      attacker: enemy.stats,
      defender: playerStats,
    );

    // 3. Aplicar dano ao player
    if (hitResult.isHit) {
      // Atualizar player (será feito no component)
      developer.log('[CombatManager] Player took ${hitResult.damageDealt} damage');

      if (hitResult.killedTarget) {
        _onPlayerDefeated();
      }
    }

    return hitResult;
  }

  /// Processar derrota de inimigo
  void _onEnemyDefeated(Enemy enemy) {
    developer.log('[CombatManager] Enemy defeated: ${enemy.name}');

    // 1. Gerar loot
    final loot = enemy.generateLoot();

    // 2. Adicionar loot ao inventário
    for (var itemId in loot) {
      final item = ItemFactory.createItem(itemId);
      if (item != null) {
        InventoryManager.instance.addItem(item);
        developer.log('[CombatManager] Dropped: ${item.name}');
      }
    }

    // 3. Dar XP ao player
    _giveExperienceToPlayer(enemy.expReward);
  }

  /// Processar derrota do player
  void _onPlayerDefeated() {
    developer.log('[CombatManager] Player defeated!');
    // Implementar game over...
  }

  /// Obter stats de combate do player
  CombatStats _getPlayerCombatStats(WeaponItem? weapon) {
    // Buscar stats base do player
    // Adicionar bônus de equipamentos
    // Implementar...

    int attack = 10; // Base
    if (weapon != null) {
      attack += weapon.damage;
    }

    return CombatStats(
      maxHealth: 100,
      currentHealth: 100,
      attack: attack,
      defense: 5,
    );
  }

  void _giveExperienceToPlayer(int exp) {
    // Implementar...
  }

  /// Verificar se pode atacar (cooldown)
  bool canAttack(double lastAttackTime, double attackSpeed) {
    final cooldown = 1.0 / attackSpeed;
    final timeSinceAttack = DateTime.now().millisecondsSinceEpoch / 1000.0 - lastAttackTime;
    return timeSinceAttack >= cooldown;
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] playerAttackEnemy() calcula dano
[ ] enemyAttackPlayer() calcula dano
[ ] Loot gerado e adicionado
[ ] XP dado ao player
[ ] Cooldown funciona

### Critérios de Aceitação

- [ ] Combate funcional
- [ ] Loot system funciona
- [ ] XP rewards funcionam
- [ ] Logs detalhados

```

---

## 🚀 PROMPT 6: Criar Testes

### Contexto
Criar testes completos para validar lógica de combate.

### Prompt para o Claude

```

Crie testes completos:

ARQUIVO 1: test/gameplay/combat/damage_calculator_test.dart
TESTES:

1. test_physical_damage_affected_by_defense
2. test_magical_damage_ignores_half_defense
3. test_true_damage_ignores_all_defense
4. test_critical_hit_multiplies_damage
5. test_minimum_damage_is_one

ARQUIVO 2: test/gameplay/combat/combat_manager_test.dart
TESTES:

1. test_player_attack_enemy_deals_damage
2. test_enemy_attack_player_deals_damage
3. test_defeated_enemy_drops_loot
4. test_defeated_enemy_gives_exp
5. test_attack_cooldown_works

ARQUIVO 3: test/gameplay/enemies/enemy_ai_test.dart
TESTES:

1. test_enemy_idle_by_default
2. test_enemy_chases_when_player_in_range
3. test_enemy_attacks_when_in_attack_range
4. test_enemy_stops_chasing_when_far

CHECKLIST:
[ ] Todos os testes passam
[ ] Cobertura >= 80%

### Critérios de Aceitação

- [ ] Testes completos
- [ ] Lógica de combate validada

```

---

## 📊 Checklist de Conclusão da Fase 3.1

### Arquivos Criados
- [ ] Modelos de combate (CombatStats, HitResult, DamageType)
- [ ] DamageCalculator
- [ ] Modelos de inimigos (Enemy, EnemyAIState)
- [ ] EnemyFactory + Database
- [ ] CombatManager
- [ ] Testes completos

### Funcionalidades Validadas
- [ ] Cálculo de dano funciona
- [ ] Combate player vs enemy funciona
- [ ] Loot system funciona
- [ ] XP rewards funcionam

### Próximos Passos
⏭️ Avançar para **FASE 3.2** - IA de Inimigos

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
