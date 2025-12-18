# Guia Rápido: Migração para Sistema de Animação

## 🚀 Quick Start

### Passo 1: Verifique seu Item Atual

```dart
// Se você tem isso hoje:
final myWeapon = KnightPickaxeHandPreset.create(
  id: 'my_weapon',
  spritePath: 'weapons/sword.png',  // Sprite único
  ...
);
```

**Perguntas:**

- ✅ É uma arma de combate? (Sword, Axe, Mace)
- ✅ Você quer visual mais profissional?
- ✅ Você tem ou pode criar um sprite sheet?

**Se respondeu SIM:** Continue para o Passo 2
**Se respondeu NÃO:** Mantenha como está! 👍

---

### Passo 2: Crie o Sprite Sheet

#### Opção A: Usar Asset Existente

Se você já tem frames de animação separados:

```
sword_1.png  →  Combine em uma tira horizontal  →  sword_slash_strip6.png
sword_2.png
sword_3.png
sword_4.png
sword_5.png
sword_6.png
```

#### Opção B: Criar no Editor Gráfico

1. Crie um canvas horizontal: `frameCount × frameSize`
2. Desenhe cada frame do ataque
3. Identifique o frame onde o dano deve ocorrer
4. Salve como `{weapon}_{action}_strip{N}.png`

**Exemplo:**

```
sword_slash_strip6.png
- Tamanho: 384×64 (6 frames de 64×64)
- Frame 3: Frame de ataque (meio do swing)
```

---

### Passo 3: Atualize o Código

#### Antes (Sprite):

```dart
final swordData = KnightPickaxeHandPreset.create(
  id: 'iron_sword',
  spritePath: 'weapons/sword.png',
  spriteSize: Vector2(32, 32),
  attachmentOffset: Vector2(0, -28),
  directionalOffset: Vector2(20, 0),
  mirroredDirectionalOffset: Vector2(-20, 0),
);
```

#### Depois (Animação):

```dart
final swordData = KnightAnimatedWeaponPreset.create(
  id: 'iron_sword',
  animationPath: 'weapons/sword_slash_strip6.png',  // ✅ Sprite sheet
  frameCount: 6,                                     // ✅ Número de frames
  attackFrameIndex: 3,                               // ✅ Frame do dano (0-based)
  animationDuration: Duration(milliseconds: 400),    // ✅ Duração total
  textureSize: Vector2(64, 64),                      // ✅ Tamanho de cada frame
  size: Vector2(64, 64),
  attachmentOffset: Vector2(0, -32),
  directionalOffset: Vector2(20, 0),
  mirroredDirectionalOffset: Vector2(-20, 0),
);
```

---

### Passo 4: Atualize o Attack Spec

#### Antes:

```dart
attack: KnightHandAttackSpec(
  execute: (context, damage) {
    // Dano aplicado imediatamente
    context.player.simpleAttackMelee(damage: damage);
    CameraFx.primaryAttackShake(context.player.gameRef);
  },
),
```

#### Depois:

```dart
attack: KnightHandAttackSpec(
  execute: (context, damage) {
    // ✅ Configurar callback ANTES do ataque
    context.handController.setAttackFrameCallback(() {
      // ✅ Executado no frame de ataque (frame 3)
      context.player.simpleAttackMelee(damage: damage);
      CameraFx.primaryAttackShake(context.player.gameRef);
    });
  },
),
```

**Importante:** O callback deve ser configurado DENTRO do `execute`, não fora!

---

## 📋 Checklist de Migração

### ✅ Assets

- [ ] Sprite sheet criado
- [ ] Nomenclatura correta: `{weapon}_{action}_strip{N}.png`
- [ ] Frames horizontais em sequência
- [ ] Todos os frames do mesmo tamanho
- [ ] Frame de ataque identificado

### ✅ Código

- [ ] Trocado `KnightPickaxeHandPreset` por `KnightAnimatedWeaponPreset`
- [ ] `spritePath` → `animationPath`
- [ ] `spriteSize` → `textureSize`
- [ ] Adicionado `frameCount`
- [ ] Adicionado `attackFrameIndex`
- [ ] Adicionado `animationDuration`
- [ ] Callback configurado com `setAttackFrameCallback()`

### ✅ Testes

- [ ] Compilação sem erros
- [ ] Animação toca durante ataque
- [ ] Dano aplicado no frame correto
- [ ] Animação para quando não está atacando
- [ ] Visual satisfatório

---

## 🎯 Exemplos Rápidos

### Espada Rápida (Light Sword)

```dart
final lightSword = KnightAnimatedWeaponPreset.create(
  id: 'light_sword',
  animationPath: 'weapons/light_sword_slash_strip4.png',
  frameCount: 4,
  attackFrameIndex: 2,  // Ataque rápido no meio
  animationDuration: Duration(milliseconds: 300),
  textureSize: Vector2(48, 48),
  size: Vector2(48, 48),
  attachmentOffset: Vector2(0, -28),
  directionalOffset: Vector2(18, 0),
  mirroredDirectionalOffset: Vector2(-18, 0),
);
```

### Machado Pesado (Heavy Axe)

```dart
final heavyAxe = KnightAnimatedWeaponPreset.create(
  id: 'heavy_axe',
  animationPath: 'weapons/heavy_axe_slam_strip8.png',
  frameCount: 8,
  attackFrameIndex: 6,  // Ataque pesado no final
  animationDuration: Duration(milliseconds: 700),
  textureSize: Vector2(80, 80),
  size: Vector2(80, 80),
  attachmentOffset: Vector2(0, -36),
  directionalOffset: Vector2(28, 0),
  mirroredDirectionalOffset: Vector2(-28, 0),
);
```

### Adaga Rápida (Quick Dagger)

```dart
final quickDagger = KnightAnimatedWeaponPreset.create(
  id: 'quick_dagger',
  animationPath: 'weapons/dagger_stab_strip3.png',
  frameCount: 3,
  attackFrameIndex: 1,  // Ataque super rápido no início
  animationDuration: Duration(milliseconds: 200),
  textureSize: Vector2(32, 32),
  size: Vector2(32, 32),
  attachmentOffset: Vector2(0, -24),
  directionalOffset: Vector2(12, 0),
  mirroredDirectionalOffset: Vector2(-12, 0),
);
```

---

## 🔧 Troubleshooting

### Problema: Animação não toca

**Causa:** Callback não configurado corretamente

**Solução:**

```dart
// ❌ ERRADO: Callback fora do execute
context.handController.setAttackFrameCallback(...);

// ✅ CERTO: Callback dentro do execute
execute: (context, damage) {
  context.handController.setAttackFrameCallback(() {
    // Aplica dano aqui
  });
},
```

---

### Problema: Dano aplicado no frame errado

**Causa:** `attackFrameIndex` incorreto

**Solução:**

```dart
// Contar frames começando do 0
// Frame 0, 1, 2, [3], 4, 5
//                 ↑ attackFrameIndex = 3

// Se visual mostra dano no 4º frame:
attackFrameIndex: 3,  // 0-based indexing
```

---

### Problema: Animação parece travada

**Causa:** `animationDuration` muito longa ou `frameCount` errado

**Solução:**

```dart
// Verifique o sprite sheet
// Se tem 6 frames, use frameCount: 6
// Ajuste duração para velocidade desejada
animationDuration: Duration(milliseconds: 400),  // ~67ms por frame
```

---

### Problema: Sprite sheet cortado errado

**Causa:** `textureSize` incorreto

**Solução:**

```dart
// Se sprite sheet é 384×64 com 6 frames:
// 384 / 6 = 64 (largura de cada frame)
textureSize: Vector2(64, 64),  // ✅ Correto

// Se sprite sheet é 480×80 com 6 frames:
// 480 / 6 = 80
textureSize: Vector2(80, 80),  // ✅ Correto
```

---

## 💡 Dicas

### Timing de Animação

```dart
// Ataque Rápido (Dagger, Rapier)
animationDuration: Duration(milliseconds: 200-300)

// Ataque Médio (Sword, Spear)
animationDuration: Duration(milliseconds: 400-500)

// Ataque Pesado (Axe, Hammer)
animationDuration: Duration(milliseconds: 600-800)
```

### Frame de Ataque

```dart
// Ataque Rápido: Logo no início
attackFrameIndex: 1  // 2º frame

// Ataque Normal: No meio
attackFrameIndex: frameCount ~/ 2  // Meio da animação

// Ataque Pesado: Mais pro final
attackFrameIndex: frameCount - 2  // Penúltimo frame
```

### Organização de Assets

```
assets/weapons/
├── swords/
│   ├── iron_sword_slash_strip6.png
│   ├── steel_sword_slash_strip6.png
│   └── diamond_sword_slash_strip8.png
├── axes/
│   ├── iron_axe_slam_strip8.png
│   └── steel_axe_slam_strip10.png
└── daggers/
    └── dagger_stab_strip4.png
```

---

## 🎯 Migração Gradual

Você **NÃO precisa** migrar tudo de uma vez!

```dart
// ✅ Mix and match no mesmo loadout
final loadout = KnightHandLoadoutSetup(
  entries: [
    // Mão direita: Animação (novo)
    KnightHandLoadoutEntry(
      slot: KnightHandSlot.right,
      itemData: KnightAnimatedWeaponPreset.createExampleSword(),
      attack: ...,
    ),

    // Mão esquerda: Sprite (legado)
    KnightHandLoadoutEntry(
      slot: KnightHandSlot.left,
      itemData: KnightPickaxeHandPreset.create(...),
      attack: ...,
    ),
  ],
);
```

**Migre apenas:**

- ✅ Armas de combate importantes
- ✅ Items que você quer melhorar visualmente
- ✅ Quando tiver os sprite sheets prontos

**Mantenha sprite para:**

- ✅ Ferramentas (pickaxe, hoe)
- ✅ Items defensivos (shields)
- ✅ Placeholders

---

## 📚 Recursos

### Documentação Completa

- `KNIGHT_HANDS_ANIMATION_SYSTEM.md` - Documentação técnica completa
- `KNIGHT_HANDS_ANIMATION_EXAMPLES.dart` - 6 exemplos práticos
- `KNIGHT_HANDS_VISUAL_COMPARISON.md` - Comparação visual detalhada

### Código de Exemplo

```dart
// Veja exemplos prontos em:
KnightAnimatedWeaponPreset.createExampleSword();
KnightAnimatedWeaponPreset.createExampleAxe();
KnightAnimatedWeaponPreset.createExampleDagger();
```

---

## ✅ Pronto!

Agora você pode:

- ✅ Usar sprites simples (sistema legado)
- ✅ Usar animações completas (novo sistema)
- ✅ Misturar ambos no mesmo loadout
- ✅ Migrar gradualmente quando quiser

**Sistema 100% compatível e funcionando!** 🎮⚔️
