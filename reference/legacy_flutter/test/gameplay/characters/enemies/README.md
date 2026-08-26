# Testes Unitários - Enemies Base Classes

Este diretório contém os testes unitários para as classes abstratas base do sistema de inimigos.

## Estrutura de Testes

### 📋 dd_base_enemy_model_test.dart

Testes para a classe abstrata `DDBaseEnemyModel`.

**Cobertura (115 linhas):**

- ✅ Initialization (2 testes)
- ✅ Attack State Management (5 testes)
- ✅ Property Mutations (3 testes)
- ✅ Edge Cases (3 testes)

**Cenários testados:**

- Inicialização correta dos valores
- Gerenciamento de estado de ataque (canAttack, startAttack, finishAttack)
- Múltiplos ciclos de ataque
- Mutação de propriedades (attackDamage, visionRadius, attackInterval)
- Casos extremos (zero damage, large vision, fast attacks)

### 🎮 dd_base_enemy_controller_test.dart

Testes para a classe abstrata `DDBaseEnemyController`.

**Cobertura (224 linhas):**

- ✅ Initialization (3 testes)
- ✅ Primary Attack (5 testes)
- ✅ Ranged Attack (4 testes)
- ✅ Dispose (2 testes)
- ✅ Attack Sequencing (3 testes)
- ✅ Callback Integration (2 testes)
- ✅ Edge Cases (3 testes)

**Cenários testados:**

- Inicialização com callbacks (obrigatórios e opcionais)
- Execução de ataques primários e à distância
- Validação de estado antes/depois dos ataques
- Sequenciamento correto de ataques
- Integração com callbacks
- Dispose e reset de estado
- Ataques rápidos e mudanças de estado

### 🔗 dd_base_enemy_integration_test.dart

Testes de integração entre Model e Controller.

**Cobertura (232 linhas):**

- ✅ Model-Controller Communication (3 testes)
- ✅ Attack Workflow (3 testes)
- ✅ Lifecycle Management (3 testes)
- ✅ State Consistency (3 testes)
- ✅ Error Recovery (2 testes)
- ✅ Complex Scenarios (3 testes)
- ✅ Performance Characteristics (2 testes)

**Cenários testados:**

- Comunicação bidirecional entre Model e Controller
- Ciclos completos de ataque
- Gerenciamento de lifecycle (update, dispose)
- Consistência de estado
- Recuperação de estados inconsistentes
- Cenários complexos (múltiplos tipos de ataque, modificação dinâmica)
- Características de performance (1000+ ataques)

## Executando os Testes

### Todos os testes de enemies:

```bash
flutter test test/gameplay/characters/enemies/
```

### Teste específico:

```bash
flutter test test/gameplay/characters/enemies/dd_base_enemy_model_test.dart
flutter test test/gameplay/characters/enemies/dd_base_enemy_controller_test.dart
flutter test test/gameplay/characters/enemies/dd_base_enemy_integration_test.dart
```

### Com cobertura:

```bash
flutter test --coverage test/gameplay/characters/enemies/
```

## Resultados

✅ **54 testes passando**

- 13 testes de Model
- 22 testes de Controller
- 19 testes de Integração

## Padrões de Teste

### Test Doubles

Todos os testes utilizam implementações concretas simples das classes abstratas:

```dart
class TestEnemyModel extends DDBaseEnemyModel { ... }
class TestEnemyController extends DDBaseEnemyController<TestEnemyModel> { ... }
```

### Estrutura AAA (Arrange-Act-Assert)

```dart
test('should do something', () {
  // Arrange
  final model = TestEnemyModel(...);

  // Act
  model.startAttack();

  // Assert
  expect(model.isAttacking, isTrue);
});
```

### Logs para Validação

Uso de listas para rastrear chamadas de callbacks:

```dart
final callLog = <Map<String, dynamic>>[];
onPrimaryAttack: (damage) {
  callLog.add({'type': 'primary', 'damage': damage});
}
```

## Manutenção

Ao adicionar novas funcionalidades às classes base:

1. Adicione testes correspondentes
2. Mantenha a cobertura acima de 90%
3. Teste casos extremos e edge cases
4. Valide integração entre componentes

## Próximos Passos

- [ ] Testes para implementações específicas (Goblin, Imp, MiniBoss, Boss)
- [ ] Testes para DDBaseEnemy (View) com mock do Bonfire
- [ ] Testes de performance mais detalhados
- [ ] Testes de concorrência (se aplicável)
