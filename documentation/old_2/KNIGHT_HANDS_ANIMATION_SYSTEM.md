# Knight Hands - Sistema Híbrido: Sprites + Animações

## Visão Geral

O sistema de **Knight Hands** agora suporta **dois modos de renderização**:

1. **Sprite Mode (Legado)** - Sprite estático que rotaciona via código
2. **Animation Mode (Novo)** - Animação completa com frame de ataque específico

## Motivação

Anteriormente, os equipamentos eram apenas sprites estáticos que rotacionavam programaticamente durante ataques. O novo sistema permite usar **animações pré-fabricadas** onde:

- A animação contém todos os frames do movimento do ataque
- O dano é aplicado em um frame específico (como no Sunny Player)
- O corpo do Knight permanece com sua animação normal
- **Apenas o equipamento** é renderizado com a animação isolada

## Arquitetura

### Novos Componentes

```
hands/
├── knight_hand_animation_data.dart        ✅ NOVO
├── knight_hand_item_data.dart             ♻️ Atualizado
├── knight_hand_item_view.dart             ♻️ Atualizado
├── knight_hand_item_controller.dart       ♻️ Atualizado
├── knight_hand_item_model.dart            ♻️ Atualizado
└── presets/
    ├── knight_pickaxe_hand_preset.dart    ✅ Compatível
    └── knight_animated_weapon_preset.dart ✅ NOVO
```

## Como Funciona

### 1. KnightHandAnimationData

Define os dados da animação do equipamento:

```dart
final swordAnimation = KnightHandAnimationData(
  spritePath: 'weapons/sword_slash_strip6.png',
  frameCount: 6,
  attackFrameIndex: 3,  // Frame onde o dano é aplicado
  animationDuration: Duration(milliseconds: 400),
  textureSize: Vector2(64, 64),
);
```

**Propriedades:**

- `spritePath`: Caminho do sprite sheet
- `frameCount`: Número de frames na animação
- `attackFrameIndex`: Frame onde o callback de ataque é executado (0-based)
- `animationDuration`: Duração total da animação
- `textureSize`: Tamanho de cada frame no sprite sheet

### 2. KnightHandItemData (Atualizado)

Agora aceita **ou** sprite **ou** animação:

```dart
// Modo Sprite (legado)
final pickaxe = KnightHandItemData(
  id: 'pickaxe',
  spritePath: 'tools/pickaxe.png',  // ✅ Sprite estático
  size: Vector2(32, 32),
  slotSpecs: {...},
);

// Modo Animação (novo)
final sword = KnightHandItemData(
  id: 'sword',
  animationData: swordAnimation,    // ✅ Animação
  size: Vector2(64, 64),
  slotSpecs: {...},
);
```

**Validação:**

- ❌ Não pode fornecer ambos `spritePath` e `animationData`
- ✅ Deve fornecer um dos dois

### 3. KnightHandItemView (Atualizado)

Renderiza sprite ou animação:

```dart
class KnightHandItemView extends GameDecoration {
  bool get isAnimated;              // Indica modo de renderização
  bool get isAnimationPlaying;       // Se a animação está tocando
  double get animationProgress;      // Progresso 0.0 a 1.0

  void playAnimation();              // Inicia animação
  void stopAnimation();              // Para animação
  Future<void> loadHandAnimation();  // Carrega animação
}
```

**Comportamento:**

- **Sprite Mode**: Rotaciona via código (sistema legado)
- **Animation Mode**: Toca animação completa, sem rotação manual

### 4. KnightHandItemController (Atualizado)

Gerencia execução e callback de frame de ataque:

```dart
controller.setAttackFrameCallback(() {
  // Executado quando atingir attackFrameIndex
  print('Aplicar dano agora!');
});

controller.startAttack();  // Inicia animação ou rotação
```

**Lógica:**

- Detecta quando `animationProgress >= attackFrameIndex / frameCount`
- Executa callback **uma única vez** por ataque
- Flag `attackFrameExecuted` evita execução duplicada

### 5. KnightHandItemModel (Atualizado)

Adiciona flag de controle:

```dart
class KnightHandItemModel {
  bool attackFrameExecuted = false;  // ✅ NOVO

  void resetAnimationState() {
    attackFrameExecuted = false;     // Reseta para próximo ataque
  }
}
```

## Exemplos de Uso

### Exemplo 1: Sprite Estático (Sistema Legado)

```dart
// Continua funcionando como antes
final pickaxe = KnightPickaxeHandPreset.create(
  id: 'iron_pickaxe',
  spritePath: 'tools/pickaxe.png',
  spriteSize: Vector2(32, 32),
  attachmentOffset: Vector2(0, -28),
  directionalOffset: Vector2(20, 0),
  mirroredDirectionalOffset: Vector2(-20, 0),
);
```

### Exemplo 2: Animação Completa (Novo Sistema)

```dart
final sword = KnightAnimatedWeaponPreset.create(
  id: 'iron_sword',
  animationPath: 'weapons/sword_slash_strip6.png',
  frameCount: 6,
  attackFrameIndex: 3,  // Dano no frame 3 (meio da animação)
  animationDuration: Duration(milliseconds: 400),
  textureSize: Vector2(64, 64),
  size: Vector2(64, 64),
  attachmentOffset: Vector2(0, -32),
  directionalOffset: Vector2(20, 0),
  mirroredDirectionalOffset: Vector2(-20, 0),
);
```

### Exemplo 3: Com Callback de Ataque

```dart
final entry = KnightHandLoadoutEntry(
  slot: KnightHandSlot.right,
  itemData: swordData,
  attack: KnightHandAttackSpec(
    trigger: KnightAttackTrigger.primary,
    attackType: AttackType.melee,
    syncSpec: SynchronizedAttackSpecConfig.standard,
    execute: (context, damage) {
      // Configurar callback de frame
      context.handController.setAttackFrameCallback(() {
        // Executado no frame 3 da animação
        print('💥 Aplicando dano: $damage');

        // Aplicar hitbox, efeitos, etc.
        context.player.simpleAttackMelee(
          damage: damage,
          size: Vector2(32, 32),
        );
      });
    },
  ),
);
```

## Comparação: Sprite vs Animação

| Característica       | Sprite Mode            | Animation Mode                |
| -------------------- | ---------------------- | ----------------------------- |
| **Renderização**     | Sprite estático        | SpriteAnimation               |
| **Movimento**        | Rotação via código     | Frames pré-animados           |
| **Callback de Dano** | Manual (via fractions) | Automático (attackFrameIndex) |
| **Player Animation** | Não afeta              | Não afeta                     |
| **Complexidade**     | Simples                | Requer sprite sheet           |
| **Flexibilidade**    | Limitada               | Alta                          |

## Preset Exemplos

### KnightAnimatedWeaponPreset

Fornece 3 exemplos prontos:

```dart
// 1. Espada - Ataque médio
final sword = KnightAnimatedWeaponPreset.createExampleSword();
// - 6 frames, 400ms
// - Dano no frame 3 (meio)

// 2. Machado - Ataque pesado
final axe = KnightAnimatedWeaponPreset.createExampleAxe();
// - 8 frames, 600ms
// - Dano no frame 5 (mais tarde)

// 3. Adaga - Ataque rápido
final dagger = KnightAnimatedWeaponPreset.createExampleDagger();
// - 4 frames, 250ms
// - Dano no frame 1 (início)
```

## Fluxo de Execução

### Sprite Mode (Legado)

```
1. startAttack()
2. update(dt) -> _advanceAnimation()
   - Calcula ângulo baseado em fractions
   - Aplica rotação ao sprite
3. Callback manual via SynchronizedAttackController
4. stopAttack() -> reseta ângulo
```

### Animation Mode (Novo)

```
1. startAttack()
2. update(dt)
   - playAnimation() se não está tocando
   - Calcula animationProgress
   - Se progress >= attackFrameProgress:
     ✅ Executa _onAttackFrameExecute()
     ✅ Marca attackFrameExecuted = true
3. Animação termina naturalmente
4. stopAttack() -> stopAnimation() -> reseta flags
```

## Benefícios

### 1. **Flexibilidade**

- Suporta sprites simples (ferramentas, escudos)
- Suporta animações complexas (espadas, machados)

### 2. **Isolamento**

- Animação do equipamento **não afeta** o player
- Player mantém sua animação de idle/walk
- Equipamento renderizado de forma **isolada**

### 3. **Compatibilidade**

- Sistema legado **continua funcionando**
- Migração gradual para animações
- Nenhum código quebrado

### 4. **Precisão**

- Dano aplicado no **frame exato**
- Similar ao Sunny Player (comprovado)
- Efeitos sincronizados com visual

## Migração

### Converter Sprite para Animação

**Antes:**

```dart
KnightHandItemData(
  id: 'sword',
  spritePath: 'weapons/sword.png',
  ...
)
```

**Depois:**

```dart
KnightHandItemData(
  id: 'sword',
  animationData: KnightHandAnimationData(
    spritePath: 'weapons/sword_slash_strip6.png',
    frameCount: 6,
    attackFrameIndex: 3,
    animationDuration: Duration(milliseconds: 400),
    textureSize: Vector2(64, 64),
  ),
  ...
)
```

## Requisitos de Assets

### Sprite Sheet Format

```
sword_slash_strip6.png
[Frame0][Frame1][Frame2][Frame3][Frame4][Frame5]
   ↑       ↑       ↑       💥      ↑       ↑
 Start   Wind    Wind   ATTACK  Follow  End
          Up      Up              Through
```

**Características:**

- Frames horizontais em sequência
- Todos os frames do mesmo tamanho
- Nomenclatura: `{weapon}_{action}_strip{N}.png`
- Frame de ataque: onde o equipamento "conecta"

## Debugging

### Verificar Modo

```dart
if (itemData.isAnimated) {
  print('🎬 Animation Mode');
  print('Frames: ${itemData.animationData!.frameCount}');
  print('Attack Frame: ${itemData.animationData!.attackFrameIndex}');
} else {
  print('🖼️ Sprite Mode');
  print('Path: ${itemData.spritePath}');
}
```

### Verificar Progresso

```dart
void update(double dt) {
  final view = controller.view;
  if (view != null && view.isAnimated) {
    print('Progress: ${(view.animationProgress * 100).toStringAsFixed(1)}%');
  }
}
```

### Verificar Callback

```dart
controller.setAttackFrameCallback(() {
  print('⚔️ Attack frame reached!');
  print('Time: ${DateTime.now()}');
});
```

## Limitações

### Animation Mode

1. **Sem rotação manual**: A animação define o movimento
2. **Frames fixos**: Não pode alterar frames dinamicamente
3. **Sprite sheet required**: Precisa do asset preparado

### Sprite Mode

1. **Movimento limitado**: Apenas rotação
2. **Sem frames intermediários**: Interpolação linear
3. **Visual simplificado**: Menos impacto visual

## Testes

### Teste 1: Sprite Legado Continua Funcionando

```dart
final pickaxe = KnightPickaxeHandPreset.create(...);
assert(!pickaxe.isAnimated);
// ✅ Deve rotacionar normalmente
```

### Teste 2: Animação Carrega Corretamente

```dart
final sword = KnightAnimatedWeaponPreset.createExampleSword();
assert(sword.isAnimated);
assert(sword.animationData!.frameCount == 6);
assert(sword.animationData!.attackFrameIndex == 3);
```

### Teste 3: Callback Executa no Frame Correto

```dart
bool callbackExecuted = false;
controller.setAttackFrameCallback(() {
  callbackExecuted = true;
});

controller.startAttack();
// Simular updates até atingir frame 3
while (!callbackExecuted) {
  controller.update(0.016); // ~60 FPS
}
assert(callbackExecuted); // ✅
```

## Conclusão

O sistema agora oferece **o melhor dos dois mundos**:

✅ **Sprites simples** para ferramentas e itens básicos
✅ **Animações completas** para armas com ataques complexos
✅ **Compatibilidade total** com código existente
✅ **Frame-precise execution** como Sunny Player
✅ **Isolamento visual** - equipamento animado independente do player

O knight hand agora **recebe tanto sprites quanto animações**, mantendo tudo funcionando! 🎮⚔️
