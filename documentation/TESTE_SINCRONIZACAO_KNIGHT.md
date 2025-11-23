# 🎮 Teste de Sincronização Inventário ↔ Knight Player

## 📋 Sistema Implementado

### Novo Sistema: Equipment to Knight Adapter

Sincroniza automaticamente o `EquipmentManager` com o sistema visual de hands do Knight Player.

**Mapeamento:**

- `EquipmentSlotType.weapon` → Right Hand → **Primary Attack (Melee)**
- `EquipmentSlotType.offhand` → Left Hand → **Ranged Attack (Fireball)**

**Lógica de Armas:**

- **Sword/Axe/Mace** no `weapon` slot → Primary Attack (Space/Joystick Button)
- **Staff/Wand** no `offhand` slot → Fireball Attack (Shift/Joystick Button)
- **Shield** no `offhand` slot → Apenas visual, sem ataque

---

## 🎯 Novos Controles

| Tecla | Ação               | Descrição                                                        |
| ----- | ------------------ | ---------------------------------------------------------------- |
| **E** | Equipar Weapon     | Equipa primeira arma do inventário no slot `weapon` (Right Hand) |
| **U** | Desequipar Weapon  | Remove arma do `weapon` e retorna ao inventário                  |
| **O** | Equipar Offhand    | Equipa primeira arma do inventário no slot `offhand` (Left Hand) |
| **P** | Desequipar Offhand | Remove arma do `offhand` e retorna ao inventário                 |
| **I** | Toggle Inventário  | Abre/fecha visualização do inventário                            |
| **T** | Adicionar Teste    | Adiciona 100 pedras + 25 minério de ferro                        |

---

## 🧪 Roteiro de Teste Completo

### 1️⃣ Inicialização

**Executar:**

```bash
flutter run
```

**Verificar Console:**

```
[InventoryInput] Component mounted!
[InventoryInput] Itens de teste adicionados! 7 slots usados
[EquipmentAdapter] No equipment, using defaults
```

**Itens Iniciais no Inventário:**

- 1x Iron Sword (weaponType: sword)
- 1x Steel Axe (weaponType: axe)
- 1x Fire Staff (weaponType: staff)
- 1x Wooden Shield (weaponType: shield)
- 5x Health Potion
- 50x Wood
- 10x Tomato Seeds

**Estado Inicial do Player:**

- Right Hand: Default Sword (Primary Attack ativo)
- Left Hand: Default Shield (sem ataque)

---

### 2️⃣ Teste: Equipar Sword no Weapon Slot

**Passo a passo:**

1. Pressione **I** para abrir inventário
2. Verifique que Iron Sword está no slot 1
3. Pressione **E** para equipar

**Resultado Esperado:**

```
[InventoryInput] Procurando arma para equipar no slot weapon...
[InventoryInput] Equipado no weapon: Iron Sword
[InventoryInput] Equipamento mudou! Procurando player...
[InventoryInput] KnightPlayer encontrado! Recarregando loadout...
[EquipmentAdapter] Created loadout with 2 items
[InventoryInput] Loadout recarregado com sucesso!
```

**Verificar Visualmente:**

- ✅ Right Hand do player agora mostra Iron Sword
- ✅ Iron Sword removida do inventário
- ✅ Default sword não aparece mais

**Testar Combate:**

- Pressione **Space** (Primary Attack)
- ✅ Animação de ataque melee
- ✅ Dano: 15 (damage da Iron Sword)
- ✅ Console: `[EquipmentAdapter] Primary attack with Iron Sword: 15.0 damage`

---

### 3️⃣ Teste: Equipar Staff no Offhand Slot

**Passo a passo:**

1. Com Iron Sword equipada no weapon
2. Pressione **I** para abrir inventário
3. Verifique que Fire Staff está no inventário
4. Pressione **O** para equipar offhand

**Resultado Esperado:**

```
[InventoryInput] Procurando arma para equipar no slot offhand...
[InventoryInput] Equipado no offhand: Fire Staff
[InventoryInput] Equipamento mudou! Procurando player...
[EquipmentAdapter] Created loadout with 2 items
[InventoryInput] Loadout recarregado com sucesso!
```

**Verificar Visualmente:**

- ✅ Right Hand: Iron Sword (mantém)
- ✅ Left Hand: Fire Staff
- ✅ Fire Staff removida do inventário

**Testar Combate:**

- Pressione **Shift** (Fireball Attack)
- ✅ Animação de fireball
- ✅ Dano: 20 (damage do Fire Staff)
- ✅ Console: `[EquipmentAdapter] Fireball attack with Fire Staff: 20.0 damage`
- ✅ Partículas de fogo aparecem

---

### 4️⃣ Teste: Switch de Sword → Axe

**Passo a passo:**

1. Com Iron Sword equipada
2. Pressione **U** para desequipar weapon

**Resultado Esperado:**

```
[InventoryInput] Desequipado do weapon: Iron Sword
[EquipmentAdapter] No weapon equipped, using default sword
```

3. Pressione **E** para equipar próxima arma (Steel Axe)

**Resultado Esperado:**

```
[InventoryInput] Equipado no weapon: Steel Axe
[EquipmentAdapter] Primary attack with Steel Axe: 25.0 damage
```

**Verificar:**

- ✅ Right Hand agora mostra Steel Axe
- ✅ Iron Sword retornou ao inventário
- ✅ Primary Attack agora causa 25 de dano (dano do Steel Axe)

---

### 5️⃣ Teste: Shield no Offhand (Sem Ataque)

**Passo a passo:**

1. Pressione **P** para desequipar Fire Staff do offhand
2. Pressione **O** para equipar próxima arma (Wooden Shield)

**Resultado Esperado:**

```
[InventoryInput] Desequipado do offhand: Fire Staff
[InventoryInput] Equipado no offhand: Wooden Shield
```

**Verificar:**

- ✅ Left Hand mostra Wooden Shield
- ✅ Pressionar **Shift** não faz nada (shield não tem ataque fireball)
- ✅ Shield é apenas visual/defensivo

---

### 6️⃣ Teste: Multiple Swaps (Stress Test)

**Sequência rápida:**

1. **E** → Equipa arma 1
2. **U** → Desequipa arma 1
3. **E** → Equipa arma 2
4. **O** → Equipa offhand 1
5. **P** → Desequipa offhand 1
6. **O** → Equipa offhand 2

**Verificar:**

- ✅ Todas as trocas ocorrem sem erro
- ✅ Inventário atualiza corretamente
- ✅ Sprites visuais atualizam corretamente
- ✅ Ataques usam dano correto de cada arma

---

### 7️⃣ Teste: Combo Sword + Staff

**Setup:**

1. Equipar Iron Sword no weapon (**E**)
2. Equipar Fire Staff no offhand (**O**)

**Testar Combate Híbrido:**

1. Pressione **Space** → Melee attack (15 damage)
2. Pressione **Shift** → Fireball attack (20 damage)
3. Repita alternando

**Verificar:**

- ✅ Pode alternar entre melee e ranged livremente
- ✅ Cada ataque usa dano correto da arma equipada
- ✅ Animações corretas para cada tipo
- ✅ Stamina consome em ambos ataques

---

### 8️⃣ Teste: Inventário Cheio

**Setup:**

1. Usar **T** múltiplas vezes até inventário quase cheio
2. Equipar várias armas
3. Tentar desequipar com inventário cheio

**Verificar:**

```
[EquipmentManager] Inventory full, cannot unequip
[InventoryInput] Nenhuma arma equipada no weapon
```

- ✅ Sistema impede desequipar se inventário cheio
- ✅ Item permanece equipado
- ✅ Mensagem de erro clara no console

---

## 📊 Checklist de Validação

### Backend Integration

- [ ] EquipmentManager sincroniza com InventoryManager
- [ ] EquipmentToKnightAdapter converte slots corretamente
- [ ] Weapon slot → Right Hand (Primary Attack)
- [ ] Offhand slot → Left Hand (Ranged Attack)

### Visual Synchronization

- [ ] Equipar item atualiza sprite visual do player imediatamente
- [ ] Desequipar item retorna sprite ao default
- [ ] Múltiplas trocas não causam glitches visuais
- [ ] Sprites renderizam na posição correta (attachment offsets)

### Combat System

- [ ] Sword no weapon → Primary Attack melee funciona
- [ ] Staff no offhand → Fireball Attack funciona
- [ ] Shield no offhand → Não tem ataque (comportamento correto)
- [ ] Dano de cada arma é aplicado corretamente
- [ ] Ataques consomem stamina normalmente

### Weapon Type Mapping

- [ ] `weaponType: "sword"` → Primary Attack
- [ ] `weaponType: "axe"` → Primary Attack
- [ ] `weaponType: "mace"` → Primary Attack
- [ ] `weaponType: "staff"` → Fireball Attack
- [ ] `weaponType: "wand"` → Fireball Attack
- [ ] `weaponType: "shield"` → Sem ataque

### Edge Cases

- [ ] Equipar sem arma no inventário → Mensagem clara
- [ ] Desequipar com inventário cheio → Bloqueado
- [ ] Trocar arma equipada → Move antiga para inventário
- [ ] Reload loadout não causa memory leak

---

## 🐛 Problemas Conhecidos

### Possíveis Issues

**Issue 1: Sprite não atualiza após equipar**

- **Sintoma**: Item equipa mas sprite não muda
- **Causa**: Loadout não recarregou
- **Debug**: Verificar logs `[EquipmentAdapter]` e `[InventoryInput]`
- **Solução**: Garantir que `reloadEquipmentLoadout()` é chamado

**Issue 2: Dano incorreto após trocar arma**

- **Sintoma**: Ataque usa dano antigo
- **Causa**: `finalDamage` não usa weapon damage
- **Debug**: Ver log `[EquipmentAdapter] Primary/Fireball attack with X: Y damage`
- **Solução**: Verificar lógica de `weaponDamage` no adapter

**Issue 3: Staff não dispara fireball**

- **Sintoma**: Pressionar Shift não faz nada
- **Causa**: Staff equipado em weapon em vez de offhand
- **Solução**: Usar **O** para equipar staff no offhand, não **E**

---

## 💡 Arquivos Criados/Modificados

### Novos Arquivos

- `lib/gameplay/inventory/equipment_to_knight_adapter.dart` - Adaptador principal
- `documentation/TESTE_SINCRONIZACAO_KNIGHT.md` - Este arquivo

### Arquivos Modificados

- `lib/gameplay/inventory/equipment_manager.dart` - Sem mudanças (já funcional)
- `lib/gameplay/characters/player/knight/knight_player_view.dart` - Usa adapter
- `lib/shared/framework/players/dd_equippable_player/dd_equippable_player_view.dart` - Método `reloadEquipmentLoadout()`
- `lib/gameplay/core/modules/game/inventory_input_handler.dart` - Teclas O/P, notificação
- `assets/items/items_database.json` - Adicionados fire_staff, ice_wand, wooden_shield

---

## 🚀 Próximos Passos (Futuro)

### Features Planejadas

1. **Sprite Mapping Dinâmico**

   - Mapear `item.iconPath` para sprite paths reais
   - Suportar custom sprites por item

2. **Equipment Stats Bonus**

   - Aplicar buffs de equipamento ao player
   - Defense do shield reduz dano recebido

3. **Dual Wield**

   - Equipar duas espadas (weapon + offhand)
   - Primary Attack usa ambas armas

4. **Offhand Attacks Variados**

   - Shield bash (ataque corpo-a-corpo com shield)
   - Wand com projectiles diferentes de staff

5. **UI Visual para Equipment**

   - Mostrar equipamento na HUD
   - Tooltip com stats ao passar mouse

6. **Hotkeys para Quick Swap**
   - Teclas 1-4 para slots de equipamento rápido
   - Trocar armas sem abrir inventário

---

## 📝 Relatório de Teste

### Funcionalidades Testadas ✅

- [ ] Equipar sword no weapon
- [ ] Equipar staff no offhand
- [ ] Desequipar weapon
- [ ] Desequipar offhand
- [ ] Trocar sword por axe
- [ ] Equipar shield (sem ataque)
- [ ] Primary Attack com diferentes armas
- [ ] Fireball Attack com staff
- [ ] Múltiplas trocas consecutivas

### Bugs Encontrados ❌

- Lista de bugs encontrados durante teste

### Observações Adicionais

- Performance
- Sugestões de melhoria
- UX feedback
