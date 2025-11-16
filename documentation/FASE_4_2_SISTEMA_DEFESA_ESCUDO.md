# Sistema de Defesa com Escudo

## Visão Geral

Sistema implementado que permite ao player defender-se de ataques enquanto mantém a tecla **Z** pressionada. Durante a defesa, o player fica completamente imune a dano e todos os inputs são bloqueados.

## Arquitetura

### 1. **Componentes Criados**

#### `ShieldDefenseComponent`

- **Localização**: `lib/gameplay/characters/player/knight/hands/shield_defense_component.dart`
- **Função**: Componente visual que mostra o sprite 16x16 do escudo na frente do player
- **Comportamento**:
  - Posiciona o escudo na direção que o player está olhando
  - Ativa/desativa opacidade baseado no estado de defesa
  - Suporta 8 direções (up, down, left, right, diagonais)

#### `ShieldDefenseInputHandler`

- **Localização**: `lib/gameplay/core/modules/game/shield_defense_input_handler.dart`
- **Função**: Gerencia input do teclado para defesa
- **Comportamento**:
  - Detecta **KeyDown** do Z → Inicia defesa
  - Detecta **KeyUp** do Z → Para defesa
  - Bloqueia TODOS os outros inputs enquanto está defendendo
  - Zera velocidade do player durante defesa

### 2. **Modificações em Arquivos Existentes**

#### `KnightAttackTrigger` (knight_hand_loadout.dart)

```dart
enum KnightAttackTrigger { primary, fireball, shieldDefense }
```

- Adicionado trigger `shieldDefense` para escudos

#### `KnightHandManager` (knight_hand_manager.dart)

**Novos campos**:

- `_defenseComponent: ShieldDefenseComponent?`
- `_isDefending: bool`
- `_currentShieldSpritePath: String?`

**Novos métodos**:

- `bool get isDefending` → Retorna se está defendendo
- `bool startDefense()` → Inicia modo de defesa, retorna true se sucesso
- `void stopDefense()` → Para modo de defesa
- `void _stopDefenseInternal()` → Limpeza interna ao parar defesa

#### `DDEquippablePlayerView` (dd_equippable_player_view.dart)

**Novos métodos públicos**:

- `bool startShieldDefense()` → Delega para hand manager
- `void stopShieldDefense()` → Delega para hand manager
- `bool get isDefending` → Getter para estado de defesa

**Override de método**:

- `onReceiveDamage()` → Bloqueia dano se `isDefending == true`, mostra "0" em ciano

#### `EquipmentToKnightAdapter` (equipment_to_knight_adapter.dart)

**Modificação no método `_createOffhandEntryFromItem()`**:

```dart
else if (weaponType.contains('shield')) {
  attackSpec = KnightHandAttackSpec(
    trigger: KnightAttackTrigger.shieldDefense,
    attackType: AttackType.melee,
    syncSpec: syncSpec,
    execute: (context, damage) {
      // Defesa gerenciada pelo input handler
    },
  );
}
```

#### `GameplayScreenViewmodel` (gameplay_screen_viewmodel.dart)

- Adicionado: `final shieldDefenseInputHandler = ShieldDefenseInputHandler();`

#### `GameplayScreen` (gameplay_screen.dart)

- Adicionado `shieldDefenseInputHandler` aos `components`

## Fluxo de Execução

### Iniciar Defesa (Z pressionado)

1. **ShieldDefenseInputHandler** detecta KeyDown(Z)
2. Chama `player.startShieldDefense()`
3. **DDEquippablePlayerView** delega para `_handEquipmentManager.startDefense()`
4. **KnightHandManager**:
   - Verifica se tem escudo equipado (trigger `shieldDefense`)
   - Cria `ShieldDefenseComponent` com sprite do escudo
   - Ativa o componente (opacity = 1)
   - Define `_isDefending = true`
5. **ShieldDefenseInputHandler**:
   - Define `_isDefending = true` localmente
   - Chama `player.idle()` para zerar velocidade
   - Bloqueia todos os inputs subsequentes retornando `true`

### Durante Defesa

- **ShieldDefenseComponent.update()**:

  - Atualiza posição do escudo baseado na direção do player
  - Escudo sempre fica na frente do player (20px de distância)

- **ShieldDefenseInputHandler.onKeyboard()**:

  - Intercepta TODOS os eventos de teclado
  - Retorna `true` para consumir e bloquear o evento

- **DDEquippablePlayerView.onReceiveDamage()**:
  - Verifica `if (isDefending)`
  - Se true: mostra "0" em ciano, retorna sem aplicar dano
  - Se false: processa dano normalmente

### Parar Defesa (Z solto)

1. **ShieldDefenseInputHandler** detecta KeyUp(Z)
2. Chama `player.stopShieldDefense()`
3. **DDEquippablePlayerView** delega para `_handEquipmentManager.stopDefense()`
4. **KnightHandManager**:
   - Desativa `ShieldDefenseComponent` (opacity = 0)
   - Remove componente do jogo
   - Define `_isDefending = false`
5. **ShieldDefenseInputHandler**:
   - Define `_isDefending = false` localmente
   - Inputs voltam a ser processados normalmente

## Sprite do Escudo

### Requisitos

- **Tamanho**: 16x16 pixels
- **Formato**: PNG com transparência
- **Localização sugerida**: `assets/images/gameplay/characters/player/knight/shield_defense.png`

### Como Adicionar

1. Criar/obter sprite 16x16 do escudo
2. Salvar em: `assets/images/gameplay/characters/player/knight/shield_defense.png`
3. O sprite path é obtido automaticamente do item equipado via `runtime.itemController.data.spritePath`

### Posicionamento

O escudo é posicionado baseado na última direção do player:

- **Up**: (0, -20)
- **Down**: (0, 20)
- **Left**: (-20, 0)
- **Right**: (20, 0)
- **Diagonais**: (±14, ±14)

## Configuração Atual

### Controles

- **Z (pressionado)**: Ativa defesa
- **Z (solto)**: Desativa defesa
- **Qualquer outra tecla durante defesa**: Bloqueada

### Slots de Equipamento

- **Weapon (Right Hand - Space)**: Sword, Axe → Primary Attack
- **Offhand (Left Hand - Z)**:
  - Staff, Wand → Fireball Attack
  - **Shield → Shield Defense** ✅

### Estado de Defesa

- **Movimento**: ❌ Bloqueado (idle forçado)
- **Primary Attack (Space)**: ❌ Bloqueado
- **Fireball Attack (Z)**: N/A (Z está sendo usado para defesa)
- **Outros inputs**: ❌ Bloqueados
- **Receber Dano**: ❌ Imune (mostra "0" em ciano)

## Testes Necessários

### Teste 1: Equipar Escudo

1. Pressionar **O** → Equipar wooden_shield no offhand
2. Verificar se escudo aparece na mão esquerda

### Teste 2: Iniciar Defesa

1. Com escudo equipado, pressionar e **segurar Z**
2. Verificar:
   - ✅ Player para de se mover
   - ✅ Sprite 16x16 do escudo aparece na frente
   - ✅ Outros inputs não funcionam

### Teste 3: Imunidade a Dano

1. Com defesa ativa (Z pressionado)
2. Deixar inimigo atacar
3. Verificar:
   - ✅ Nenhum dano aplicado
   - ✅ Texto "0" em ciano aparece
   - ✅ Barra de vida não diminui

### Teste 4: Desativar Defesa

1. Soltar tecla **Z**
2. Verificar:
   - ✅ Sprite do escudo desaparece
   - ✅ Movimento volta ao normal
   - ✅ Ataques voltam a funcionar
   - ✅ Dano volta a ser recebido normalmente

### Teste 5: Sem Escudo Equipado

1. Desequipar escudo (pressionar **P**)
2. Pressionar **Z**
3. Verificar:
   - ✅ Defesa não ativa
   - ✅ Fireball funciona normalmente (se staff equipado)

### Teste 6: Trocar de Staff para Shield

1. Equipar fire_staff (pressionar **O**)
2. Pressionar **Z** → Fireball deve funcionar
3. Desequipar (pressionar **P**)
4. Equipar wooden_shield (pressionar **O**)
5. Pressionar **Z** → Defesa deve ativar

## Melhorias Futuras

### Opcionais

1. **Efeito sonoro** ao ativar/desativar defesa
2. **Partículas visuais** ao bloquear ataques
3. **Stamina cost** por segundo defendendo
4. **Cooldown** após soltar defesa
5. **Ângulo de defesa** (apenas bloqueia ataques da frente)
6. **Dano refletido** para atacantes
7. **Shield durability** (escudo pode quebrar)
8. **Diferentes tipos de escudo** com diferentes propriedades

### Bugs Conhecidos

- Nenhum identificado ainda (aguardando testes)

## Logs de Debug

### Console Logs Esperados

**Ao equipar escudo:**

```
[InventoryInput] ✓ Equipado no offhand (Left Hand): Wooden Shield (shield)
[EquipmentAdapter] Created loadout with 1 items
[KnightHandManager] Applying entry for slot: left
```

**Ao pressionar Z (iniciar defesa):**

```
[ShieldDefenseInput] ✓ Defesa iniciada - inputs bloqueados
[KnightHandManager] Iniciando defesa com escudo
[KnightHandManager] ✓ Defesa ativada - player imune a dano
```

**Ao tentar se mover durante defesa:**

```
[ShieldDefenseInput] ✗ Input bloqueado durante defesa: LogicalKeyboardKey#xxxxx(keyName: "Key W")
```

**Ao receber ataque durante defesa:**

```
(Nenhum log, apenas texto "0" em ciano na tela)
```

**Ao soltar Z (parar defesa):**

```
[ShieldDefenseInput] ✓ Defesa finalizada - inputs liberados
[KnightHandManager] Parando defesa
```

## Versão

- **Implementado em**: v1.41.0+1
- **Data**: 16/11/2025
