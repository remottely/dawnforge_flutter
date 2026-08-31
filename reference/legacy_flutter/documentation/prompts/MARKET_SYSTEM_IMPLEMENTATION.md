# Market System Implementation - Prompts Guide

## Visão Geral

Este documento contém todos os prompts necessários para implementar o sistema de mercado (market) no Darkness Dungeon. O sistema inclui:

- Sistema de moedas (coins)
- Loja para compra de sementes
- Venda de itens de colheita (HarvestLootItem)
- Interface simples com GridView

---

## PROMPT 1: Análise da Arquitetura Atual

```
Preciso que você analise a arquitetura atual do jogo, especialmente:

1. Como o player é estruturado e onde ficam as propriedades como life e stamina
2. Como funciona o sistema de save/load do player
3. Como o inventário está implementado atualmente
4. Como os GameDecorations são criados e gerenciados
5. Como os dialogs/overlays são exibidos no jogo

Com base nessa análise, forneça um resumo da estrutura atual e recomendações de onde cada componente do novo sistema de market deve ser implementado.

Arquivos relevantes para análise:
- Player e suas propriedades
- Sistema de inventário
- Sistema de save/load
- GameDecorations existentes
- Sistema de UI/dialogs
```

---

## PROMPT 2: Implementar Sistema de Moedas (Coins)

```
Com base na análise anterior, implemente o sistema de moedas (coins) no jogo. Requisitos:

1. Adicionar propriedade 'coins' ao player (similar a life e stamina)
2. Valor inicial de 500 moedas para novos jogos
3. Métodos para adicionar e remover moedas:
   - addCoins(int amount)
   - removeCoins(int amount)
   - canAfford(int amount) - verifica se tem moedas suficientes

4. Adicionar coins ao sistema de save/load do player
5. Criar eventos/notifiers para atualizar a UI quando as moedas mudarem

Certifique-se de seguir o mesmo padrão arquitetural usado para life e stamina.
```

---

## PROMPT 3: Criar HUD de Moedas

```
Crie um componente de HUD para exibir as moedas do player na tela. Requisitos:

1. Componente visual mostrando:
   - Ícone de moeda
   - Quantidade atual de moedas

2. Deve atualizar em tempo real quando as moedas mudarem
3. Posicionar próximo aos outros indicadores do HUD (life, stamina)
4. Design simples e legível
5. Usar o sistema de notificação/stream do player para atualizar

Siga o padrão de design dos outros componentes de HUD existentes.
```

---

## PROMPT 4: Criar Modelo de Dados do Market

```
Crie a estrutura de dados para o sistema de market. Requisitos:

1. Criar classe MarketItem:
   - Referência ao HandItem correspondente
   - Preço de compra
   - Preço de venda (se aplicável)
   - Disponibilidade (sempre disponível para MVP)

2. Criar lista de itens do market (MarketCatalog):
   - Incluir todas as sementes disponíveis
   - Definir preços balanceados
   - Organizar por categoria/tipo

3. Criar enums/constantes necessários:
   - MarketTransactionType (buy/sell)
   - Códigos de erro para transações

Use como referência a estrutura de HandItem já existente.
```

---

## PROMPT 5: Implementar MarketManager

```
Crie o MarketManager para gerenciar toda a lógica de negócios do market. Requisitos:

1. Singleton ou service class para gerenciar o market
2. Métodos principais:
   - buyItem(HandItemId itemId, Player player, InventoryManager inventory)
   - sellItem(HandItemId itemId, int quantity, Player player, InventoryManager inventory)
   - getMarketCatalog() - retorna lista de itens disponíveis
   - canBuyItem(HandItemId itemId, Player player) - validação
   - canSellItem(HandItemId itemId, InventoryManager inventory) - validação

3. Validações:
   - Verificar se player tem moedas suficientes para comprar
   - Verificar se tem espaço no inventário
   - Verificar se item existe no inventário para vender
   - Verificar se item é vendável

4. Retornar resultados das transações (sucesso/erro com mensagem)

Integre com os sistemas existentes de player e inventário.
```

---

## PROMPT 6: Configuração de Preços e Balanceamento

```
Configure os preços dos itens do market e balanceie a economia do jogo. Requisitos:

1. Definir preços de compra para todas as sementes:
   - Considerar raridade e valor das colheitas
   - Manter valores simples e intuitivos
   - Exemplo: sementes comuns 10-50 moedas, raras 100-200 moedas

2. Definir preços de venda para HarvestLootItems:
   - Usar sistema de quality multiplier já existente
   - Venda geralmente 50-70% do valor de compra
   - Implementar método getSellPrice() baseado em HandItem.sellValue

3. Criar tabela de preços documentada:
   - Listar todos os itens com seus preços
   - Justificar balanceamento
   - Facilitar ajustes futuros

4. Validar economia:
   - Testar ciclo completo: comprar sementes → plantar → colher → vender
   - Garantir que é possível ter lucro
   - Verificar progressão com 500 moedas iniciais
```

---

## PROMPT 7: Criar Market Decoration (GameDecoration)

```
Crie o MarketDecoration como um GameDecoration do Bonfire. Requisitos:

1. Classe MarketDecoration extends GameDecoration:
   - Sprite/animação visual simples (pode ser uma sprite estática)
   - Collision detection para interação com player

2. Implementar detecção de interação:
   - Quando player entra em contato, detectar proximidade
   - Exibir indicador visual de interação (opcional: tecla/botão de ação)

3. Ao interagir, abrir o MarketDialog:
   - Passar referências necessárias (player, inventory, marketManager)
   - Usar sistema de overlay/dialog do jogo

4. Posicionar no mapa:
   - Adicionar em local acessível no mundo do jogo
   - Documentar como adicionar via Tiled ou código

Use como referência outros GameDecorations interativos já existentes no jogo.
```

---

## PROMPT 8: Criar MarketDialog UI (Widget Flutter)

```
Crie o widget Flutter para a interface do market (MarketDialog). Requisitos:

1. Dialog/Overlay fullscreen ou semi-fullscreen
2. Layout:
   - Header com título "Market" e botão fechar
   - Área mostrando moedas atuais do player
   - GridView scrollable com itens disponíveis para compra

3. GridView de itens:
   - Cada item mostra:
     * Ícone do item
     * Nome do item
     * Preço
     * Indicador se player pode comprar (moedas suficientes)
   - Ao clicar em um item, executa compra de 1 unidade
   - Feedback visual da transação (sucesso/erro)

4. Feedback em tempo real:
   - Atualizar moedas após cada transação
   - Atualizar estado dos botões (enabled/disabled)
   - Mensagens de erro/sucesso (toast ou snackbar)

5. Responsividade:
   - Adaptar para diferentes tamanhos de tela
   - Grid responsivo (2-4 colunas dependendo do tamanho)

Usar StreamBuilder ou ValueNotifier para atualizações em tempo real.
```

---

## PROMPT 9: Modificar Comportamento do Inventário para Venda

```
Modifique o sistema de inventário para suportar venda de itens quando o market está aberto. Requisitos:

1. Adicionar flag/state global indicando se market está aberto
2. Modificar o callback de clique nos slots do inventário:
   - Se market está fechado: comportamento normal (equipar/usar)
   - Se market está aberto E item é HarvestLootItem: vender 1 unidade

3. Lógica de venda:
   - Verificar se item é vendável (HarvestLootItem)
   - Chamar MarketManager.sellItem()
   - Atualizar inventário
   - Atualizar moedas
   - Feedback visual

4. Prevenir equipar/usar itens quando market está aberto
5. Adicionar indicador visual nos itens vendáveis quando market está aberto

Certifique-se de não quebrar o comportamento normal do inventário.
```

---

## PROMPT 10: Integração e Sistema de Feedback

```
Integre todos os componentes e adicione sistema de feedback ao usuário. Requisitos:

1. Sistema de notificações/mensagens:
   - Mensagem de compra bem-sucedida: "Comprou [Item] por [X] moedas"
   - Mensagem de venda bem-sucedida: "Vendeu [Item] por [X] moedas"
   - Mensagens de erro:
     * "Moedas insuficientes"
     * "Inventário cheio"
     * "Item não pode ser vendido"

2. Feedback visual:
   - Animação/highlight ao comprar/vender
   - Som de transação (se houver sistema de áudio)
   - Atualização suave das moedas (animação opcional)

3. Garantir sincronização:
   - Todas as transações são imediatas
   - UI atualiza em tempo real
   - Sem delays ou lags perceptíveis

4. Tratamento de edge cases:
   - Múltiplos cliques rápidos
   - Transações enquanto inventário está sendo atualizado
   - Fechar market durante transação
```

---

<!-- ## PROMPT 11: Adicionar Market ao Mundo do Jogo

```
Adicione o MarketDecoration ao mundo do jogo. Requisitos:

1. Escolher localização no mapa:
   - Área acessível próxima à farm ou spawn
   - Posição que faça sentido narrativamente

2. Adicionar sprite/visual para o market:
   - Pode ser uma banca, loja, NPC vendedor, etc.
   - Visual simples mas identificável
   - Usar assets existentes ou criar sprite placeholder

3. Configurar interação:
   - Definir área de collision
   - Configurar trigger de interação
   - Adicionar indicador visual (opcional)

4. Integrar no sistema de spawn/loading do mapa:
   - Adicionar via Tiled map ou código
   - Garantir que aparece sempre no jogo
   - Documentar como reposicionar se necessário

Fornecer coordenadas exatas e instruções de como adicionar.
``` -->

---

## PROMPT 12: Testes e Validação

```
Realize testes completos do sistema de market. Tarefas:

1. Testar fluxo de compra:
   - Comprar sementes com moedas suficientes
   - Tentar comprar sem moedas suficientes
   - Comprar com inventário cheio
   - Comprar múltiplos itens em sequência

2. Testar fluxo de venda:
   - Vender HarvestLootItems com market aberto
   - Verificar que não vende com market fechado
   - Vender itens de diferentes qualidades
   - Vender até esvaziar inventário

3. Testar persistência:
   - Salvar jogo após transações
   - Carregar jogo e verificar moedas
   - Verificar que inventário foi salvo corretamente

4. Testar edge cases:
   - Múltiplos cliques rápidos
   - Abrir e fechar market rapidamente
   - Interagir com outros sistemas enquanto market está aberto

5. Validar economia:
   - Ciclo completo de gameplay
   - Verificar progressão natural
   - Ajustar preços se necessário

Documentar todos os bugs encontrados e criar lista de melhorias futuras.
```

---

## PROMPT 13: Documentação e Refinamentos Finais

```
Finalize a implementação com documentação e refinamentos. Tarefas:

1. Criar documentação técnica:
   - Como o sistema de market funciona
   - Arquitetura e componentes
   - Como adicionar novos itens ao market
   - Como ajustar preços

2. Documentação para usuário/designer:
   - Como posicionar market no mapa
   - Como configurar preços
   - Como adicionar novos itens vendáveis

3. Refinamentos finais:
   - Melhorar feedback visual
   - Ajustar UI para melhor UX
   - Otimizar performance se necessário
   - Adicionar comentários no código

4. Checklist de conclusão:
   - [ ] Sistema de moedas implementado
   - [ ] HUD de moedas funcional
   - [ ] Market decoration no mundo
   - [ ] MarketDialog funcional
   - [ ] Compra de sementes funcionando
   - [ ] Venda de HarvestLootItems funcionando
   - [ ] Persistência de moedas
   - [ ] Feedback visual adequado
   - [ ] Testes realizados
   - [ ] Documentação criada

5. Criar lista de melhorias futuras (pós-MVP):
   - Sistema de quest do vendedor
   - Desconto/promoções
   - Itens limitados ou rotativos
   - Múltiplos vendedores
   - Upgrade da loja
```

---

## Ordem de Execução Recomendada

Execute os prompts na seguinte ordem para melhor resultado:

1. **PROMPT 1** - Análise da arquitetura (entender o código atual)
2. **PROMPT 2** - Sistema de moedas (base do sistema)
3. **PROMPT 3** - HUD de moedas (visualização)
4. **PROMPT 4** - Modelo de dados (estrutura)
5. **PROMPT 5** - MarketManager (lógica de negócio)
6. **PROMPT 6** - Preços e balanceamento (configuração)
7. **PROMPT 7** - Market decoration (mundo do jogo)
8. **PROMPT 8** - MarketDialog UI (interface de compra)
9. **PROMPT 9** - Modificar inventário (sistema de venda)
10. **PROMPT 10** - Integração e feedback (polimento)
<!-- 11. **PROMPT 11** - Adicionar ao mundo (posicionamento) -->
12. **PROMPT 12** - Testes (validação)
13. **PROMPT 13** - Documentação (finalização)

---

## Notas Importantes

### Considerações de Design

- Manter tudo simples para o MVP
- Priorizar funcionalidade sobre visual elaborado
- Garantir que sistema é extensível para futuras melhorias
- Seguir padrões arquiteturais já estabelecidos no projeto

### Pontos de Atenção

- Sincronização entre UI e game state
- Performance do GridView com muitos itens
- Tratamento de erros robusto
- Testes em dispositivos móveis (touch interactions)

### Assets Necessários

- Ícone de moeda (coin icon)
- Sprite do market/vendedor (pode ser placeholder)
- Ícones dos itens (já existem em HandItem.iconData)
- Sons opcionais (moeda, compra, venda)

### Integrações Necessárias

- Sistema de player (moedas)
- Sistema de inventário (compra/venda)
- Sistema de save/load (persistência de moedas)
- Sistema de UI/overlays (dialogs)
- GameDecorations (market no mundo)

---

## Próximos Passos

Após completar todos os prompts:

1. Realizar playtest completo
2. Coletar feedback
3. Ajustar balanceamento se necessário
4. Preparar para release do MVP
5. Planejar features adicionais pós-MVP

---

## Melhorias Futuras (Pós-MVP)

Ideias para expandir o sistema após o MVP:

- Sistema de quests/missões do vendedor
- Desconto por volume ou fidelidade
- Itens especiais ou raros rotativos
- Múltiplos vendedores/lojas
- Upgrade progressivo da loja
- Sistema de reputação
- Itens exclusivos desbloqueáveis
- Carrinho de compras (comprar múltiplos de uma vez)
- Comparação de preços com histórico
- Gráficos de economia/mercado

---

_Documento criado em: 6 de janeiro de 2026_
_Versão: 1.0_
_Status: Pronto para implementação_
