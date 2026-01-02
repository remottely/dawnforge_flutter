# Sistema de Stamina - Refatoração para Modelo SV

## Objetivo
Transformar o sistema de stamina atual (regeneração automática contínua) para o modelo do SV:
- Stamina NÃO regenera automaticamente ao longo do tempo
- Regeneração completa ao avançar o dia
- Regeneração gradual ao interagir com Tochas
- Regeneração ao consumir frutas colhidas

---

## Passo 1: Remover Sistema de Regeneração Automática

### Prompt 1.1 - Identificar Sistema Atual
```
Analise o sistema de regeneração de stamina atual. Procure por:
1. Onde a regeneração automática é chamada (provavelmente em DDBasePlayerController ou DDMobilePlayerController)
2. Os métodos responsáveis: regenerateStamina(), _staminaRegenDebounce, etc.
3. Como a regeneração é controlada (timers, flags, etc.)

Mostre-me os arquivos e trechos de código relevantes.
```

### Prompt 1.2 - Desabilitar Regeneração Automática
```
Remova COMPLETAMENTE o sistema de regeneração automática de stamina. Especificamente:

1. Em DDBasePlayerController/DDMobilePlayerController:
   - Remova chamadas para regenerateStamina()
   - Remova o sistema de debounce de regeneração
   - Remova flags como _isStaminaRegenerationPaused
   - Mantenha APENAS os métodos consumeStamina() e restoreEnergy()

2. No DDBasePlayerModel:
   - Mantenha o método consumeStamina()
   - REMOVA o método regenerateStamina() 
   - Adicione um novo método: void restoreStamina(double amount)
   - Adicione um novo método: void restoreStaminaFully()

3. Não quebre nenhuma funcionalidade existente de consumo de stamina (ataques, defesa, ações de farm)
```

---

## Passo 2: Regeneração Completa ao Virar o Dia

### Prompt 2.1 - Integrar com Sistema de Dia
```
Implemente a regeneração completa de stamina ao avançar o dia:

1. Localize onde o dia é avançado (provavelmente em WorldStateManager.advanceDay())

2. No método que avança o dia, adicione:
   - Chamada para PlayerStateManager.instance.lastPlayerModel?.restoreStaminaFully()
   - Log: "[StaminaSystem] Stamina restaurada completamente (novo dia)"

3. Garanta que isso ocorra ANTES de salvar o jogo (se houver auto-save ao dormir)

4. Teste o fluxo: consumir stamina → avançar dia → verificar stamina = 100%
```

---

## Passo 3: Regeneração Gradual em Tochas

### Prompt 3.1 - Adicionar Sistema de Regeneração em Tocha
```
Implemente o sistema de regeneração de stamina ao ficar próximo a tochas acesas:

1. Em TorchDecorationController:
   - Adicione uma flag: bool _isPlayerInRange = false
   - Adicione um timer: double _staminaRegenTimer = 0.0
   - Adicione constantes:
     * static const double kStaminaRegenInterval = 2.0 (segundos)
     * static const double kStaminaRegenAmount = 5.0 (pontos por intervalo)

2. No método update() de TorchDecorationController:
   ```dart
   void update(double dt, DDBasePlayerView? player) {
     if (player != null && model.isOn) {
       _updateStaminaRegeneration(dt, player);
     }
     // ... código existente de detecção
   }
   ```

3. Adicione método privado:
   ```dart
   void _updateStaminaRegeneration(double dt, DDBasePlayerView player) {
     if (_isPlayerInRange && model.isOn) {
       _staminaRegenTimer += dt;
       
       if (_staminaRegenTimer >= kStaminaRegenInterval) {
         player.controller.model.restoreStamina(kStaminaRegenAmount);
         _staminaRegenTimer = 0.0;
         
         // Feedback visual opcional
         player.showDamage(
           '+${kStaminaRegenAmount.toInt()} stamina',
           config: const TextStyle(color: Color(0xFF00FF00), fontSize: 12),
         );
       }
     } else {
       _staminaRegenTimer = 0.0;
     }
   }
   ```

4. Atualize o callback observed/notObserved para setar _isPlayerInRange
```

### Prompt 3.2 - Adicionar Feedback Visual
```
Melhore o feedback de regeneração de stamina na tocha:

1. Adicione uma partícula/sprite de "energia" que sobe da tocha até o player a cada regeneração

2. Ou adicione um ícone flutuante perto do player mostrando "+5 stamina" em verde

3. Implemente isso no método _updateStaminaRegeneration quando a stamina for regenerada

4. Use o sistema existente de EmoteManager como referência
```

---

## Passo 4: Sistema de Frutas e Consumíveis

### Prompt 4.1 - Criar Sistema Base de Consumíveis
```
Crie a estrutura base para itens consumíveis que restauram stamina:

1. Crie uma nova interface/classe abstrata:
   ```dart
   // lib/gameplay/inventory/items/consumable_item.dart
   abstract class ConsumableItem extends ItemBase {
     double get staminaRestore;
     double get healthRestore;
     
     void consume(DDBasePlayerView player);
   }
   ```

2. Crie classe para frutas:
   ```dart
   // lib/gameplay/inventory/items/fruit_item.dart
   class FruitItem extends ConsumableItem {
     final String fruitType; // 'strawberry', 'tomato', etc.
     
     @override
     double get staminaRestore => _getStaminaRestoreForType();
     
     @override
     double get healthRestore => 0.0; // Frutas só restauram stamina
     
     @override
     void consume(DDBasePlayerView player) {
       player.controller.model.restoreStamina(staminaRestore);
       
       // Feedback visual
       player.showDamage(
         '+${staminaRestore.toInt()} stamina',
         config: const TextStyle(color: Color(0xFF00FF00), fontSize: 14),
       );
     }
     
     double _getStaminaRestoreForType() {
       switch (fruitType) {
         case 'strawberry': return 15.0;
         case 'tomato': return 10.0;
         case 'blueberry': return 20.0;
         default: return 5.0;
       }
     }
   }
   ```

3. Registre as frutas no ItemFactoryService
```

### Prompt 4.2 - Integrar Consumo com Inventário
```
Adicione a funcionalidade de consumir frutas do inventário:

1. Em InventoryInputHandler, adicione nova ação:
   - Tecla/botão: C (Consume)
   - Método: _consumeSelectedItem()

2. Implemente o método:
   ```dart
   void _consumeSelectedItem() {
     final selectedSlot = getIt<InventoryManager>().selectedSlotIndex;
     final item = getIt<InventoryManager>().getItemAt(selectedSlot);
     
     if (item is ConsumableItem) {
       final player = _getPlayer();
       if (player == null) return;
       
       item.consume(player);
       
       // Remove 1 unidade do item
       getIt<RemoveItemUseCase>()(item.key, 1);
       
       developer.log('[InventoryInput] Consumed ${item.name}');
     } else {
       developer.log('[InventoryInput] Selected item is not consumable');
     }
   }
   ```

3. Adicione a tecla C em KeyboardSetup e InputDef

4. Adicione botão de consumo no UI de inventário (opcional)
```

### Prompt 4.3 - Colheita de Frutas
```
Garanta que as frutas colhidas sejam adicionadas como FruitItem ao inventário:

1. Em FarmActionService ou no sistema de colheita existente:
   - Quando uma fruta for colhida (strawberry, tomato, etc.)
   - Adicione ao inventário como FruitItem ao invés de item genérico
   - Use o itemKey correto para mapear para FruitItem no factory

2. Atualize items_database.json:
   ```json
   {
     "strawberry": {
       "name": "Strawberry",
       "type": "consumable",
       "subtype": "fruit",
       "staminaRestore": 15,
       "sellPrice": 25
     },
     "tomato": {
       "name": "Tomato", 
       "type": "consumable",
       "subtype": "fruit",
       "staminaRestore": 10,
       "sellPrice": 20
     }
   }
   ```

3. Atualize ItemFactoryService para criar FruitItem baseado no type: "consumable"
```

---

## Passo 5: Ajustes e Balanceamento

### Prompt 5.1 - Balancear Valores
```
Revise e ajuste os valores de stamina do sistema:

1. Custo de stamina atual:
   - Ataque primário: 15
   - Defesa: 10/segundo
   - Cavar: 5
   - Regar: 5
   - Plantar: 5
   - Colher: 5

2. Regeneração:
   - Por dia: 100% (max stamina)
   - Por tocha: 5 stamina a cada 2 segundos (2.5/s)
   - Por frutas: 10-20 stamina por unidade

3. Perguntas para considerar:
   - Os custos estão balanceados com a regeneração?
   - Tochas devem regenerar mais rápido/devagar?
   - Frutas devem restaurar mais/menos?

Ajuste as constantes conforme necessário para gameplay equilibrado.
```

### Prompt 5.2 - Adicionar Indicadores Visuais
```
Melhore os indicadores visuais do sistema de stamina:

1. Na HUD, adicione:
   - Ícone de tocha quando player está regenerando perto de uma
   - Animação de "+stamina" mais visível
   - Mudança de cor da barra quando stamina está crítica (< 20%)

2. No player:
   - Efeito visual quando tenta usar habilidade sem stamina
   - Animação de "cansado" quando stamina está baixa

3. Nas frutas:
   - Tooltip mostrando "+X stamina" ao passar mouse
   - Partículas verdes ao consumir
```

---

## Passo 6: Testes e Validação

### Prompt 6.1 - Checklist de Testes
```
Execute os seguintes testes para validar o sistema:

1. **Regeneração Removida**:
   - [ ] Consumir stamina e esperar: stamina NÃO deve regenerar sozinha
   - [ ] Usar defesa até zerar: stamina deve permanecer em 0

2. **Regeneração por Dia**:
   - [ ] Zerar stamina
   - [ ] Avançar o dia (dormir/sistema de tempo)
   - [ ] Verificar stamina = 100%

3. **Regeneração por Tocha**:
   - [ ] Ficar próximo a tocha acesa
   - [ ] Verificar regeneração a cada 2 segundos
   - [ ] Afastar da tocha: regeneração deve parar
   - [ ] Tocha apagada: não deve regenerar

4. **Consumo de Frutas**:
   - [ ] Colher morango
   - [ ] Usar tecla C para consumir
   - [ ] Verificar +15 stamina
   - [ ] Item deve ser removido do inventário

5. **Limites**:
   - [ ] Stamina não deve ultrapassar o máximo (100)
   - [ ] Stamina não deve ficar negativa

Reporte quaisquer bugs encontrados.
```

---

## Passo 7: Documentação Final

### Prompt 7.1 - Atualizar Documentação
```
Atualize a documentação do projeto:

1. Crie/atualize: documentation/STAMINA_SYSTEM.md
   - Explicar como o sistema funciona
   - Listar todos os métodos de regeneração
   - Documentar valores de consumo e regeneração
   - Adicionar exemplos de uso

2. Atualize README.md se necessário

3. Adicione comentários nos códigos novos explicando a lógica

4. Crie diagrama de fluxo do sistema de stamina (opcional)
```

---

## Notas de Implementação

### Ordem Recomendada
1. Passo 1 (Remover regeneração) - CRÍTICO primeiro
2. Passo 2 (Regeneração por dia) - Base do novo sistema
3. Passo 4 (Frutas consumíveis) - Sistema independente
4. Passo 3 (Tochas) - Feature adicional
5. Passo 5 (Balanceamento) - Ajustes finais
6. Passo 6 (Testes) - Validação
7. Passo 7 (Documentação) - Registro

### Arquivos Principais a Modificar
- `dd_base_player_controller.dart` - Remover regen automática
- `dd_mobile_player_controller.dart` - Remover regen automática  
- `dd_base_player_model.dart` - Adicionar restoreStamina()
- `world_state_manager.dart` - Hook para virar o dia
- `torch_decoration_controller.dart` - Sistema de regen por tocha
- `consumable_item.dart` - Nova classe (criar)
- `fruit_item.dart` - Nova classe (criar)
- `inventory_input_handler.dart` - Adicionar consumo
- `items_database.json` - Adicionar frutas consumíveis

### Considerações Importantes
- Não quebrar sistema de consumo de stamina existente
- Manter compatibilidade com saves antigos
- Testar todas as ações que consomem stamina
- Considerar feedback visual/sonoro para cada regeneração
- Balancear para gameplay divertido (não muito fácil/difícil)

### Possíveis Extensões Futuras
- Comidas que restauram health + stamina
- Poções/elixires com efeitos especiais
- Fogueiras/acampamentos que regeneram mais rápido
- Habilidades que reduzem consumo de stamina
- Status effect de "energizado" que dobra stamina temporariamente

---

## Resumo Executivo

**Problema**: Sistema atual regenera stamina automaticamente, diferente do SV.

**Solução**: 
1. Remover regeneração automática contínua
2. Regenerar 100% ao virar o dia
3. Regenerar gradualmente perto de tochas acesas (5 stamina/2s)
4. Regenerar ao consumir frutas colhidas (10-20 stamina/fruta)

**Impacto**: Sistema mais estratégico, requer planejamento de recursos, aumenta valor de tochas e frutas.

**Tempo Estimado**: 4-6 horas de desenvolvimento + 2 horas de testes e balanceamento.
