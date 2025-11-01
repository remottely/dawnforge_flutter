# Padrão de Componentes (Config + Model + Controller + View)

## Objetivo

Criar uma arquitetura simples, testável e replicável seguindo o princípio KISS, com separação clara de responsabilidades.

---

## Estrutura de Diretórios

```
lib/gameplay/characters/[tipo]/[nome]/
├── [nome]_config.dart
├── [nome]_model.dart
├── [nome]_controller.dart
└── [nome]_view.dart
```

**Exemplo:**

```
lib/gameplay/characters/player/knight/
├── knight_player_config.dart
├── knight_player_model.dart
├── knight_player_controller.dart
└── knight_player_view.dart
```

---

## 1. Config (Configuração)

**Responsabilidade:** Constantes, valores fixos e fábricas de objetos complexos.

### Características:

- Classe `final` com construtor privado (`._()`)
- Apenas membros `static`
- Constantes (`const`) quando possível
- Métodos de factory para objetos complexos
- **Zero lógica de negócio**

### Template:

```dart
import 'package:bonfire/bonfire.dart';

final class MyComponentConfig {
  MyComponentConfig._();

  // Constantes de gameplay
  static const double kStandardLife = 200.0;
  static const double kSpeed = 100.0;
  static const int kMaxEnergy = 100;

  // Objetos imutáveis
  static final Vector2 fComponentSize = Vector2(16, 16);
  static final RectangleHitbox fHitbox = RectangleHitbox(
    position: Vector2(4, 9),
    size: Vector2(8, 6),
  );

  // Factories complexas
  static SimpleDirectionAnimation loadAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load('path/idle_left.png', /*...*/),
    idleRight: SpriteAnimation.load('path/idle_right.png', /*...*/),
  );
}
```

---

## 2. Model (Modelo de Dados)

**Responsabilidade:** Estado e validações simples.

### Características:

- Contém apenas **dados** e **getters**
- Validações simples e diretas (sem side effects)
- Métodos de mutação de estado (pure functions quando possível)
- **Sem referências** a View ou Controller
- **Sem timers** ou lógica assíncrona

### Template:

```dart
import 'package:my_app/path/to/config.dart';

/// Model: Contém apenas dados e validações simples
class MyComponentModel {
  // Estado privado
  double _stamina;
  int _energy;
  bool isActive;

  MyComponentModel({
    double? initialStamina,
    int? initialEnergy,
    bool? initialIsActive,
  })  : _stamina = initialStamina ?? MyComponentConfig.kMaxStamina,
        _energy = initialEnergy ?? MyComponentConfig.kMaxEnergy,
        isActive = initialIsActive ?? false;

  // Getters
  double get stamina => _stamina;
  int get energy => _energy;
  double get maxStamina => MyComponentConfig.kMaxStamina;

  // Validações simples (pure functions)
  bool get hasStamina => _stamina > 0;
  bool get canPerformAction => _stamina >= 10 && isActive;

  // Mutações de estado
  void consumeStamina(int amount) {
    _stamina = (_stamina - amount).clamp(0, MyComponentConfig.kMaxStamina);
  }

  void regenerateStamina() {
    _stamina = (_stamina + 2).clamp(0, MyComponentConfig.kMaxStamina);
  }

  void activate() => isActive = true;
  void deactivate() => isActive = false;
}
```

---

## 3. Controller (Controlador)

**Responsabilidade:** Lógica de negócio e orquestração.

### Características:

- Recebe o `Model` via construtor
- Recebe **callbacks** da View via construtor (inversão de dependência)
- **Não conhece detalhes de implementação** da View
- Contém lógica de timers, debouncing, state machines
- Orquestra ações e atualiza o Model
- Possui métodos de lifecycle (`update`, `dispose`)

### Template:

```dart
import 'package:bonfire/bonfire.dart';
import 'package:my_app/path/to/config.dart';
import 'package:my_app/path/to/model.dart';

/// Controller: Lógica de negócio e orquestração
/// Não conhece detalhes de implementação da View
class MyComponentController {
  final MyComponentModel model;

  // Callbacks para comunicação com View
  final void Function(double damage) onAttack;
  final void Function() onShowEffect;
  final void Function() onPlaySound;

  // Estado interno do controller
  bool _hasRegenScheduled = false;
  bool _isPerformingAction = false;

  MyComponentController({
    required this.model,
    required this.onAttack,
    required this.onShowEffect,
    required this.onPlaySound,
  });

  // Lifecycle
  void update(double dt) {
    _handleStaminaRegeneration();
    _handleOtherLogic();
  }

  void dispose() {
    _hasRegenScheduled = false;
  }

  // Input handling
  void handleInputAction(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return;

    if (event.id == SomeConfig.kAttackActionId) {
      executeAttack();
    }
  }

  // Actions (públicas - chamadas externamente)
  void executeAttack() {
    if (!model.canPerformAction) return;
    model.consumeStamina(10);
    onAttack(25.0);
    onPlaySound();
  }

  void activate() => model.activate();

  // Private helpers
  void _handleStaminaRegeneration() {
    if (_hasRegenScheduled) return;
    _hasRegenScheduled = true;
    Future.delayed(Duration(milliseconds: 150), () {
      _hasRegenScheduled = false;
      model.regenerateStamina();
    });
  }

  void _handleOtherLogic() {
    // Outras lógicas de negócio
  }
}
```

---

## 4. View (Visualização)

**Responsabilidade:** Renderização e integração com framework (Bonfire).

### Características:

- Estende componente do Bonfire (`SimplePlayer`, `SimpleEnemy`, etc.)
- Cria o `Controller` passando callbacks
- **Delega toda lógica** para o Controller
- Implementa callbacks privados (prefixo `_`)
- Expõe API pública mínima
- Chama `controller.dispose()` em `onRemove()`

### Template:

```dart
import 'package:bonfire/bonfire.dart';
import 'package:my_app/path/to/config.dart';
import 'package:my_app/path/to/controller.dart';
import 'package:my_app/path/to/model.dart';

/// View: Renderização e integração com o Bonfire
/// Delega lógica para o Controller via callbacks
class MyComponentView extends SimplePlayer with Lighting {
  late final MyComponentController _controller;

  MyComponentView(Vector2 position, {MyComponentModel? model})
      : super(
          animation: MyComponentConfig.loadAnimation(),
          size: MyComponentConfig.fComponentSize,
          position: position,
          life: MyComponentConfig.kStandardLife,
          speed: MyComponentConfig.kSpeed,
        ) {
    setupLighting(MyComponentConfig.fLightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
    _initializeController(model ?? MyComponentModel());
  }

  void _initializeController(MyComponentModel model) {
    _controller = MyComponentController(
      model: model,
      onAttack: _performAttack,
      onShowEffect: _showEffect,
      onPlaySound: _playSound,
    );
  }

  @override
  Future<void> onLoad() {
    add(MyComponentConfig.fHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    super.update(dt);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;
    _controller.handleInputAction(event);
    super.onJoystickAction(event);
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  // Public API para interação externa
  void activate() => _controller.activate();
  MyComponentModel get model => _controller.model;

  // Private callback implementations
  void _performAttack(double damage) {
    simpleAttackMelee(
      damage: damage,
      animationRight: SomeConfig.createAttackAnimation(),
      size: MyComponentConfig.fComponentSize,
    );
  }

  void _showEffect() {
    addParticle(
      SomeConfig.createParticles(),
      position: size,
    );
  }

  void _playSound() {
    AudioManager.instance.playAttackSound();
  }
}
```

---

## Princípios Aplicados

### 1. **KISS (Keep It Simple, Stupid)**

- Cada classe tem uma responsabilidade clara
- Sem abstrações desnecessárias
- Código direto e fácil de entender

### 2. **Separation of Concerns**

- **Config:** Configuração
- **Model:** Dados e estado
- **Controller:** Lógica de negócio
- **View:** Apresentação

### 3. **Dependency Inversion**

- Controller não depende de View concretamente
- Usa callbacks para comunicação
- View injeta comportamentos no Controller

### 4. **Single Responsibility**

- Cada classe tem apenas um motivo para mudar
- Validações no Model
- Lógica de negócio no Controller
- Renderização na View

---

## Fluxo de Dados

```
┌─────────────────────────────────────────────┐
│                   VIEW                      │
│  (Renderização + Framework Integration)    │
└────────┬──────────────────────┬─────────────┘
         │                      │
         │ Callbacks            │ Eventos (input)
         │                      │
         ▼                      ▼
┌─────────────────────────────────────────────┐
│                CONTROLLER                    │
│         (Lógica de Negócio)                 │
└────────┬────────────────────────────────────┘
         │
         │ Lê/Atualiza
         │
         ▼
┌─────────────────────────────────────────────┐
│                  MODEL                      │
│         (Estado + Validações)               │
└────────┬────────────────────────────────────┘
         │
         │ Lê constantes
         │
         ▼
┌─────────────────────────────────────────────┐
│                 CONFIG                      │
│    (Constantes + Factories)                 │
└─────────────────────────────────────────────┘
```

---

## Checklist de Implementação

### Config ✓

- [ ] Classe `final` com construtor privado
- [ ] Apenas membros `static`
- [ ] Constantes com prefixo `k` (ex: `kMaxLife`)
- [ ] Objetos finais com prefixo `f` (ex: `fHitbox`)
- [ ] Zero lógica de negócio

### Model ✓

- [ ] Contém apenas dados
- [ ] Getters para estado privado
- [ ] Validações simples e puras
- [ ] Mutações de estado claras
- [ ] Sem referências externas

### Controller ✓

- [ ] Recebe Model no construtor
- [ ] Recebe callbacks no construtor
- [ ] Não conhece implementação da View
- [ ] Tem métodos `update()` e `dispose()`
- [ ] Toda lógica de negócio centralizada

### View ✓

- [ ] Cria Controller com callbacks
- [ ] Callbacks privados (prefixo `_`)
- [ ] Delega lógica para Controller
- [ ] Chama `dispose()` em `onRemove()`
- [ ] API pública mínima

---

## Exemplos no Projeto

- **Player:** `lib/gameplay/characters/player/knight/`
- **Enemy (futuro):** `lib/gameplay/characters/enemies/[nome]/`
- **NPC (futuro):** `lib/gameplay/characters/npcs/[nome]/`

---

## Anti-Patterns a Evitar

❌ **View criando sua própria instância do Controller sem injetar callbacks**

```dart
// ERRADO
final controller = MyController(model: MyModel());
```

❌ **Controller conhecendo detalhes da View**

```dart
// ERRADO
class MyController {
  late MyView _view;
  void attachView(MyView view) => _view = view;
  void doSomething() => _view.specificMethod();
}
```

❌ **Model com lógica de negócio complexa**

```dart
// ERRADO
class MyModel {
  void complexBusinessLogic() {
    // Isso deveria estar no Controller
  }
}
```

❌ **Config com estado mutável**

```dart
// ERRADO
class MyConfig {
  static int currentValue = 0; // Estado mutável em Config!
}
```

---

## Benefícios

✅ **Testabilidade:** Controller e Model testáveis isoladamente
✅ **Reusabilidade:** Mesmo Controller/Model com Views diferentes
✅ **Manutenibilidade:** Mudanças localizadas em uma única classe
✅ **Clareza:** Responsabilidades explícitas
✅ **Escalabilidade:** Fácil adicionar novos componentes seguindo o padrão
