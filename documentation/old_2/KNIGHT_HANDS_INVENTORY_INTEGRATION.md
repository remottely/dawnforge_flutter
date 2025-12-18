# Knight Hands - Integração com Inventário

## Como Funciona

O sistema de knight hands agora está **totalmente integrado com o inventário**. Quando você equipa uma arma, ela automaticamente aparece nas mãos do knight player.

## Fluxo de Equipamento

```
Inventário → EquipmentManager → EquipmentToKnightAdapter → KnightHandManager → Mão Visível
```

### 1. Equipar Arma do Inventário

```dart
// Pressione 'E' no jogo para equipar primeira sword/axe encontrada
// Ou use o código:

final inventory = InventoryManager.instance;
final equipment = EquipmentManager.instance;

// Encontrar sword no inventário
final sword = inventory.items
    .whereType<WeaponItem>()
    .firstWhere((item) => item.equippedHandType == EquippedHandType.sword);

// Equipar no slot weapon (Right Hand)
equipment.equip(sword, EquipmentSlotType.weapon);
```

### 2. O Adapter Detecta e Converte

O `EquipmentToKnightAdapter` detecta automaticamente o tipo de equipamento:

```dart
// Configuração no adapter (já implementado):
static final Map<String, _EquipmentVisualConfig> _weaponConfigs = {
  'sword': _EquipmentVisualConfig(
    useAnimation: true,  // ✅ Usa animação!
    animationPath: 'SunnysideWorld/.../tools_attack_strip10.png',
    frameCount: 6,
    attackFrameIndex: 3,  // Dano aplicado no frame 3
    animationDuration: Duration(milliseconds: 400),
    ...
  ),
  'axe': _EquipmentVisualConfig(
    useAnimation: false,  // Usa sprite estático legado
    spritePathResolver: (item) => KnightPlayerConfig.axeNormal1SpritePath,
    ...
  ),
};
```

### 3. Mão Renderiza Corretamente

- **Sword**: Renderiza animação de 6 frames
- **Axe**: Renderiza sprite estático com rotação
- **Shield**: Renderiza sprite estático na mão esquerda
- **Staff**: Renderiza sprite estático na mão esquerda com fireball

## Como Adicionar Novas Animações

### Opção 1: Atualizar Configuração Existente

Edite `/lib/gameplay/inventory/equipment_to_knight_adapter.dart`:

```dart
static final Map<String, _EquipmentVisualConfig> _weaponConfigs = {
  'sword': _EquipmentVisualConfig(
    useAnimation: true,
    animationPath: 'caminho/para/sua/animacao.png',
    frameCount: 8,  // Número de frames
    attackFrameIndex: 4,  // Frame onde dano é aplicado (0-based)
    animationDuration: Duration(milliseconds: 500),
    spriteSize: Vector2(64, 64),
    attachmentOffset: Vector2(0, -32),
    directionalOffset: Vector2(20, 0),
    mirroredDirectionalOffset: Vector2(-20, 0),
  ),

  // Adicionar nova arma com animação
  'greatsword': _EquipmentVisualConfig(
    useAnimation: true,
    animationPath: 'weapons/greatsword_slash_strip12.png',
    frameCount: 12,
    attackFrameIndex: 6,
    animationDuration: Duration(milliseconds: 600),
    spriteSize: Vector2(96, 96),
    attachmentOffset: Vector2(0, -40),
    directionalOffset: Vector2(30, 0),
    mirroredDirectionalOffset: Vector2(-30, 0),
  ),
};
```

### Opção 2: Criar Item no Database

Adicione no `items_database.json`:

```json
{
  "iron_sword": {
    "id": "iron_sword",
    "name": "Iron Sword",
    "type": "weapon",
    "equippedHandType": "sword",
    "damage": 15,
    "baseValue": 100,
    "iconPath": "items/weapons/iron_sword_icon.png"
  }
}
```

Quando você equipar este item, o adapter automaticamente usa a configuração de `'sword'` que já tem animação!

## Testando no Jogo

### 1. Inicie o Jogo

```bash
flutter run
```

### 2. Adicione Sword ao Inventário

No console debug do jogo, ou use tecla de debug:

```dart
// O jogo já deve ter swords no inventário inicial
// Ou adicione via console:
final sword = ItemFactory.createItem('iron_sword');
InventoryManager.instance.addItem(sword);
```

### 3. Equipe a Sword

Pressione **E** no teclado ou use o botão de equipar no menu.

### 4. Ataque

Pressione **SPACE** (ou botão de ataque do joystick).

**Resultado esperado:**

- ✅ Animação de 6 frames executa na mão direita
- ✅ Dano é aplicado no frame 3 da animação
- ✅ Partículas de ataque aparecem
- ✅ Câmera vibra
- ✅ Som de ataque toca

## Estrutura de Animação

### Sprite Sheet Format

```
[Frame 0] [Frame 1] [Frame 2] [Frame 3] [Frame 4] [Frame 5]
   ⬆         ⬆         ⬆         ⬆💥        ⬆         ⬆
 Idle    Wind-up   Wind-up   ATTACK!  Follow   Return
```

- **Frame 0-2**: Wind-up (preparação)
- **Frame 3**: 💥 Attack Frame (dano aplicado aqui!)
- **Frame 4-5**: Recovery (finalização)

### Configuração do Attack Frame

```dart
attackFrameIndex: 3  // 0-based index

// Frame 0: 0ms
// Frame 1: 66ms
// Frame 2: 133ms
// Frame 3: 200ms  ← DANO APLICADO AQUI!
// Frame 4: 266ms
// Frame 5: 333ms
// Total: 400ms
```

## Debug e Troubleshooting

### Animação Não Aparece

**Verificar:**

1. `useAnimation: true` está configurado?
2. `animationPath` existe no assets?
3. `frameCount` está correto?
4. Item está equipado no slot weapon?

**Debug Log:**

```
[EquipmentAdapter] Created loadout with 2 items
[EquipmentAdapter] Primary attack with Iron Sword: 15.0 damage
```

### Dano Aplicado No Momento Errado

**Ajustar:**

```dart
attackFrameIndex: 3  // Frame onde dano é aplicado

// Se o dano está muito cedo: aumentar o índice
attackFrameIndex: 4

// Se o dano está muito tarde: diminuir o índice
attackFrameIndex: 2
```

### Animação Muito Rápida/Lenta

**Ajustar:**

```dart
animationDuration: Duration(milliseconds: 400)

// Mais lenta:
animationDuration: Duration(milliseconds: 600)

// Mais rápida:
animationDuration: Duration(milliseconds: 300)
```

## Comparação: Sprite vs Animação

### Modo Sprite (Legado - Axe)

```dart
'axe': _EquipmentVisualConfig(
  useAnimation: false,  // ❌ Sprite estático
  spritePathResolver: (item) => 'weapons/axe.png',
  ...
)
```

**Comportamento:**

- Sprite roda via código (sin/cos)
- Dano aplicado instantaneamente
- Menos autêntico

### Modo Animação (Novo - Sword)

```dart
'sword': _EquipmentVisualConfig(
  useAnimation: true,  // ✅ Animação frame-by-frame
  animationPath: 'weapons/sword_slash.png',
  frameCount: 6,
  attackFrameIndex: 3,
  ...
)
```

**Comportamento:**

- Animação pré-criada por artista
- Dano aplicado em frame específico
- Mais profissional e autêntico

## Próximos Passos

1. **Adicionar mais animações**: Greatsword, Dagger, Spear
2. **Combo system**: Múltiplas animações encadeadas
3. **Directional animations**: Animações diferentes por direção
4. **Heavy attacks**: Animações mais longas com mais dano

## Conclusão

O sistema está **100% funcional e integrado**!

Quando você equipa uma **sword** do inventário, ela automaticamente usa a **animação de 6 frames** com dano aplicado no **frame 3**.

Quando você equipa um **axe**, ele usa o sistema legado de **sprite rotacionando**.

Ambos funcionam perfeitamente! 🎮⚔️
