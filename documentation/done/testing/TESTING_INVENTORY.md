# 🎮 Como Testar o Sistema de Inventário e Save/Load

## ✅ O que foi implementado

### Sistema de Inventário (100% funcional)

- ✅ 23 itens no database (armas, ferramentas, consumíveis, materiais, sementes)
- ✅ Sistema de 30 slots com stacking automático
- ✅ 8 slots de equipamento (arma, escudo, capacete, peitoral, calças, botas, 2 acessórios)
- ✅ InventoryManager e EquipmentManager (singletons)
- ✅ Serialização completa para save/load
- ✅ 65 testes unitários (100% passando)

### UI do Inventário

- ✅ HUD visual mostrando todos os slots
- ✅ Indicação de itens equipados
- ✅ Quantidade de itens empilhados

### Controles Implementados

- **Tecla I**: Abre/fecha o inventário
- **Tecla T**: Adiciona itens de teste (stone, iron_ore)
- **Tecla E**: Equipa a primeira arma do inventário
- **Tecla U**: Desequipa a arma

## 🎯 Como Testar

### 1. Executar o jogo

```bash
flutter run
```

### 2. No Menu Principal

- Clique em "PLAY" para iniciar o jogo
- O jogo irá carregar automaticamente os itens do database

### 3. Dentro do Jogo

1. **Pressione `I`** para abrir o inventário

   - Você verá 5 itens iniciais já adicionados:
     - Iron Sword (arma)
     - Steel Axe (ferramenta)
     - 5x Health Potion (consumível)
     - 50x Wood (material)
     - 10x Tomato Seeds (semente)

2. **Pressione `T`** para adicionar mais itens de teste

   - Adiciona 100x Stone
   - Adiciona 25x Iron Ore

3. **Pressione `E`** para equipar a espada

   - A espada será movida do inventário para o slot de arma
   - Você verá no HUD a arma equipada

4. **Pressione `U`** para desequipar
   - A arma volta para o inventário

### 4. Verificar no Console

Abra o console do Flutter para ver os logs:

```
[ItemFactory] Loaded 23 items
[InventoryInput] Inicializando itens de teste...
[InventoryInput] Itens de teste adicionados! 5 slots usados
[InventoryInput] Inventário aberto
[InventoryInput] Equipado: Iron Sword
```

## 📊 O que você vai ver no HUD

```
┌─────────────────────────────────────────┐
│ INVENTÁRIO (I para fechar)             │
├─────────────────────────────────────────┤
│ Inventário (5/30):                      │
│ ┌────┬────┬────┬────┬────┬────┐       │
│ │ Iron│Steel│Heal│Wood│Tom │    │       │
│ │    │ Axe│ x5 │ x50│ x10│    │       │
│ ├────┼────┼────┼────┼────┼────┤       │
│ │    │    │    │    │    │    │       │
│ └────┴────┴────┴────┴────┴────┘       │
│                                         │
│ Equipamento:                            │
│ WEAPON   [Iron Sword]                   │
│ OFFHAND  [     ]                        │
│ HELMET   [     ]                        │
│ CHEST    [     ]                        │
│ LEGS     [     ]                        │
│ BOOTS    [     ]                        │
└─────────────────────────────────────────┘
```

## 🧪 Funcionalidades Testáveis

### Stacking Automático

1. Pressione `T` múltiplas vezes
2. O sistema vai empilhar automaticamente stone e iron_ore
3. Máximo: materials (999), consumables (99), seeds (99)

### Sistema de Equipamento

1. Abra inventário (`I`)
2. Equipe arma (`E`)
3. Veja a arma desaparecer do inventário e aparecer em "WEAPON"
4. Desequipe (`U`)
5. Arma volta para o inventário

### Inventário Cheio

1. Continue adicionando itens (`T`)
2. Quando atingir 30 slots, o console mostrará:
   ```
   [InventoryManager] Inventory full!
   ```

## 🚀 Próximos Passos (Ainda não implementados)

### Save/Load no Menu

- [ ] Botão "Continue" (se há save)
- [ ] Botão "New Game"
- [ ] Botão "Save Game"
- [ ] Auto-save periódico

### Itens no Mundo

- [ ] Baús que dão itens
- [ ] Items dropados por inimigos
- [ ] NPCs que vendem/trocam itens

### UI Melhorada

- [ ] Clique em slots para usar/equipar
- [ ] Drag and drop de itens
- [ ] Tooltips com descrição completa
- [ ] Ícones dos itens (atualmente só texto)

## 🐛 Debug

### Se o inventário não abrir

- Verifique se pressionou `I` (i maiúsculo)
- Veja o console para logs de erro

### Se itens não aparecerem

- Verifique se ItemFactory foi inicializado:
  ```
  [ItemFactory] Loaded 23 items
  ```
- Se não aparecer, verifique se `assets/items/items_database.json` existe

### Se der erro ao compilar

```bash
flutter clean
flutter pub get
flutter run
```

## 📝 Arquivos Principais

### Managers (Singletons)

- `lib/gameplay/inventory/inventory_manager.dart`
- `lib/gameplay/inventory/equipment_manager.dart`
- `lib/gameplay/inventory/item_factory.dart`

### Models

- `lib/gameplay/inventory/models/item.dart`
- `lib/gameplay/inventory/models/inventory_slot.dart`
- `lib/gameplay/inventory/models/equipment_slot.dart`

### Items

- `lib/gameplay/inventory/items/weapon_item.dart`
- `lib/gameplay/inventory/items/tool_item.dart`
- `lib/gameplay/inventory/items/consumable_item.dart`
- `lib/gameplay/inventory/items/material_item.dart`
- `lib/gameplay/inventory/items/seed_item.dart`

### Database

- `assets/items/items_database.json` (23 itens)

### UI

- `lib/gameplay/core/modules/hud/inventory_hud.dart`
- `lib/gameplay/core/modules/game/inventory_input_handler.dart`

### Testes

- `test/gameplay/inventory/` (65 testes, 100% passando)

## ✅ Validation Checklist

- [x] ItemFactory carrega 23 itens do database
- [x] Inventário inicia com 5 itens de teste
- [x] Tecla I abre/fecha inventário
- [x] HUD mostra slots visuais
- [x] Stacking automático funciona
- [x] Equipar/desequipar funciona
- [x] Sistema suporta inventário cheio (30 slots)
- [x] 65 testes unitários passando
- [x] Save/load serialization implemented (tested)

---

**Status**: ✅ Sistema de Inventário 100% funcional e testável
**Próximo**: Integrar Save/Load no menu principal + Auto-save
