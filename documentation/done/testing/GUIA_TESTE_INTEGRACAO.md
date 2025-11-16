# Guia de Teste - Integração de Features

## 📋 Features Implementadas para Testar

### ✅ Sistema de Inventário

- **Status**: Integrado com HUD visual
- **Managers**: InventoryManager (30 slots)
- **Database**: 23 itens carregados do JSON
- **Testes Backend**: 65 testes passando

### ✅ Sistema de Equipamento

- **Status**: Integrado com InventoryManager
- **Slots**: weapon, offhand, helmet, chest, legs, boots
- **Testes Backend**: Incluídos nos 65 testes de inventário

### ✅ Sistema de Save/Load

- **Status**: Backend completo (não integrado em UI ainda)
- **Testes Backend**: 101 testes passando
- **Features**: SaveManager, SaveDataModel, SaveRepository

---

## 🎮 Controles de Teste

### Teclas Implementadas

| Tecla | Ação                  | Descrição                                       |
| ----- | --------------------- | ----------------------------------------------- |
| **I** | Toggle Inventário     | Abre/fecha a visualização do inventário         |
| **T** | Adicionar Itens Teste | Adiciona 100 pedras + 25 minério de ferro       |
| **E** | Equipar Arma          | Equipa a primeira arma encontrada no inventário |
| **U** | Desequipar Arma       | Remove a arma equipada e retorna ao inventário  |

---

## 🧪 Roteiro de Teste

### 1️⃣ Teste de Inicialização

**O que verificar:**

- [ ] Jogo inicia sem erros
- [ ] Console mostra: `[InventoryInput] Component mounted!`
- [ ] Console mostra: `[InventoryInput] Itens de teste adicionados! 5 slots usados`

**Itens iniciais esperados:**

- 1x Iron Sword
- 1x Steel Axe
- 5x Health Potion
- 50x Wood
- 10x Tomato Seeds

---

### 2️⃣ Teste do HUD de Inventário (Tecla **I**)

**Passo a passo:**

1. Pressione **I** para abrir o inventário
2. Verifique se o HUD aparece na tela
3. Verifique se os 5 itens iniciais estão visíveis nos slots
4. Pressione **I** novamente para fechar

**O que observar:**

- [ ] HUD renderiza em posição (10, 100)
- [ ] 30 slots de inventário visíveis (6 colunas × 5 linhas)
- [ ] 6 slots de equipamento visíveis (weapon, offhand, etc.)
- [ ] Nomes abreviados dos itens aparecem nos slots
- [ ] Quantidades aparecem (ex: "x50" para wood)
- [ ] Background semi-transparente com bordas

**Possíveis problemas:**

- Se HUD não aparecer: Verifique console para erros
- Se items não aparecerem: Verifique se ItemFactory inicializou

---

### 3️⃣ Teste de Adicionar Itens (Tecla **T**)

**Passo a passo:**

1. Com inventário aberto (tecla **I**)
2. Pressione **T** para adicionar itens de teste
3. Observe os novos itens aparecerem

**Resultado esperado:**

- [ ] Console: `[InventoryInput] Adicionado 100x stone`
- [ ] Console: `[InventoryInput] Adicionado 25x iron_ore`
- [ ] Slots 6 e 7 agora contêm os novos itens
- [ ] Total de 7 slots usados

**Teste múltiplas adições:**

- Pressione **T** várias vezes
- Verifique se as quantidades aumentam (200 pedras, 300 pedras...)
- Observe o comportamento ao atingir 30 slots (inventário cheio)

---

### 4️⃣ Teste de Equipar Arma (Tecla **E**)

**Passo a passo:**

1. Abra inventário (**I**)
2. Verifique que Iron Sword está no slot 1
3. Pressione **E** para equipar
4. Observe mudanças no HUD

**Resultado esperado:**

- [ ] Console: `[InventoryInput] Equipado: Iron Sword`
- [ ] Slot de weapon no equipamento mostra "IroS" (Iron Sword)
- [ ] Iron Sword removida do inventário (slot 1 vazio)
- [ ] Total de slots usados diminui para 4

**Teste equipar segunda arma:**

- Pressione **E** novamente
- Deve equipar Steel Axe (segunda arma encontrada)
- Iron Sword deve retornar ao inventário (desequipada automaticamente)

---

### 5️⃣ Teste de Desequipar Arma (Tecla **U**)

**Passo a passo:**

1. Com arma equipada (siga teste 4)
2. Pressione **U**
3. Observe o slot de weapon ficar vazio

**Resultado esperado:**

- [ ] Console: `[InventoryInput] Desequipado: [nome da arma]`
- [ ] Slot weapon no equipamento fica vazio
- [ ] Arma retorna ao inventário (primeiro slot disponível)
- [ ] Total de slots usados aumenta em 1

**Se nenhuma arma equipada:**

- Console: `[InventoryInput] Nenhuma arma equipada`

---

### 6️⃣ Teste de Persistência de Estado

**Durante gameplay:**

1. Adicione vários itens (**T** múltiplas vezes)
2. Equipe/desequipe armas (**E**/**U**)
3. Feche e abra o inventário (**I**)
4. Mova o personagem pelo mapa

**O que verificar:**

- [ ] Itens permanecem no inventário ao fechar/abrir
- [ ] Equipamento permanece equipado durante movimento
- [ ] Quantidades corretas são mantidas
- [ ] HUD atualiza corretamente ao adicionar/remover itens

---

## 🐛 Problemas Conhecidos e Soluções

### Problema: HUD não aparece ao pressionar I

**Sintomas:**

- Tecla I não faz nada
- Console mostra: `HUD não encontrado!`

**Solução:**

- Verifique se HUDView está registrado em `gameplay_screen.dart`
- Verifique se `inventoryInputHandler` está nos components do BonfireWidget

---

### Problema: Itens não aparecem nos slots

**Sintomas:**

- Slots aparecem vazios
- Console não mostra erros de inicialização

**Possíveis causas:**

1. ItemFactory não inicializado
   - Verifique `main.dart`: `await ItemFactory.initialize()`
2. Items database não carregado
   - Verifique `assets/items/items_database.json` existe
3. Nomes de itens incorretos
   - IDs devem corresponder ao database

---

### Problema: Equipar não funciona

**Sintomas:**

- Console: `Falha ao equipar: [item]`
- Arma não aparece no slot de equipment

**Verificações:**

1. Item é do tipo 'weapon'?
2. Slot weapon está disponível?
3. Item atende requisitos? (level, stats)

---

## 📊 Checklist Final de Validação

### Backend Systems

- [ ] InventoryManager: 30 slots funcionando
- [ ] EquipmentManager: Equip/unequip operando corretamente
- [ ] ItemFactory: 23 itens carregados do database
- [ ] SaveManager: Backend pronto (não testado visualmente ainda)

### Visual/UI Systems

- [ ] InventoryHUD renderiza corretamente
- [ ] Slots mostram itens e quantidades
- [ ] Equipment slots mostram items equipados
- [ ] Toggle inventário (abrir/fechar) funciona

### Input Systems

- [ ] Tecla I: Toggle inventário
- [ ] Tecla T: Adicionar test items
- [ ] Tecla E: Equipar arma
- [ ] Tecla U: Desequipar arma

### Integration

- [ ] Input handler recebe eventos de teclado
- [ ] Managers comunicam corretamente
- [ ] HUD atualiza em tempo real
- [ ] Estado persiste durante gameplay

---

## 🚀 Próximos Passos (Após Validação)

### Features Pendentes (Documentação em `documentation/`)

1. **Save/Load Menu Integration**

   - Arquivo: `INTEGRATION_SAVE_LOAD.md`
   - Adicionar botões Continue, New Game, Save Game no MenuScreen
   - Integrar SaveManager com UI

2. **Auto-Save System**

   - Integrar com GameStateManager
   - Auto-save a cada 5 minutos
   - Auto-save em eventos (level up, area change)

3. **Save Indicator Widget**

   - Widget visual mostrando "Salvando...", "Salvo!", "Erro"
   - Posicionar no canto superior direito

4. **World Item Pickups**
   - Decorations no mapa que dão itens
   - Chests com loot
   - Enemy drops após combate

---

## 💡 Dicas de Debug

### Logs Úteis

```dart
// Ver estado do inventário
developer.log('Slots usados: ${InventoryManager.instance.usedSlots}');
developer.log('Slots disponíveis: ${InventoryManager.instance.availableSlots}');

// Ver equipamento
developer.log('Arma equipada: ${EquipmentManager.instance.getEquippedItem(EquipmentSlotType.weapon)?.name}');

// Ver itens no inventário
for (int i = 0; i < 30; i++) {
  final slot = InventoryManager.instance.getSlotByIndex(i);
  if (slot?.item != null) {
    developer.log('Slot $i: ${slot!.item!.name} x${slot.quantity}');
  }
}
```

### Ferramentas

- **Flutter DevTools**: Para inspecionar widget tree
- **Console logs**: Todos os eventos logados com `[InventoryInput]`
- **Hot Reload**: R para recarregar após mudanças
- **Hot Restart**: Shift+R para reiniciar completamente

---

## 📝 Relatório de Teste

Após completar os testes, documente:

### O que funcionou ✅

- [ ] Item 1
- [ ] Item 2

### O que NÃO funcionou ❌

- [ ] Problema 1 - Descrição
- [ ] Problema 2 - Descrição

### Observações adicionais

- Notas sobre performance
- Sugestões de melhorias
- Bugs visuais encontrados
