# GDD — MVP Stardew Valley Clone

**Legenda de Status:**
- 🔥 Critical | ⭐ Standard
- 🔴 TODO | 🟡 WIP | 🟢 DONE

---

## 1. Visão e Metas do MVP

Protótipo jogável do loop central de farming (🔥🟢 **plantar → regar → colher → vender → reinvestir**).

**Objetivos Principais:**
- 🔥🟡 Sessão completa de 20-30 min demonstrando 7 dias in-game
- 🔥🟡 Controles responsivos (keyboard/mouse, joystick, multi-plataforma)
- 🔥🟡 Save/load estável sem softlocks
- 🔥🟢 Loop funcional: cavar → plantar → regar → colher → vender

---

## 2. Pilares de Experiência

- 🔥🔴 **Clareza**: Feedback visual/sonoro imediato em todas as ações
- 🔥🟢 **Ritmo curto**: Ciclos de 4-7 dias por cultivo
- 🔥🟡 **Conforto de input**: HUD simples, funcional em resize/fullscreen/mobile

---

## 3. Loop Principal de Gameplay

1. 🔥🟢 Cavar solo com pá (consome energia)
2. ⭐🔴 Arar solo arável com enxada (consome energia)
3. 🔥🟢 Plantar semente (consome item do inventário)
4. 🔥🟢 Regar diariamente com regador
5. 🔥🟢 Colher quando maduro
6. ⭐🟢 Vender colheita → receber dinheiro
7. ⭐🟢 Comprar novas seeds na loja → repetir ciclo

---

## 4. Sistemas Centrais

### 4.1 Mundo & Mapas

**Estrutura:**
- 🔥🟢 Grid 16×16 tiles
- 🔥🟢 Colisões básicas (casas, rochas, decorações)
- 🔥🟡 Mapa fazenda + mapa cidade
- 🔥🔴 Casa do jogador + cama (respawn point)

**Localizações:**
- 🔥🟡 Fazenda (10-20 tiles aráveis)
- 🔥🟡 Cidade (2 NPCs, decorações)
- ⭐🟢 Loja (compra de seeds)
- ⭐🔴 Caixa de venda (deposita itens, recebe dinheiro)

**Pendências:**
- 🔥🔴 Configurar hitbox de todos os assets (Tiled) e decorações
- 🔥🔴 Refatorar nomenclaturas de decorações do Tiled
- 🔥🔴 Corrigir comportamento de colisão em forest_1.json
- 🔥🔴 Setar cor de fundo dos mapas igual aos tiles do chão
- 🔥🔴 Refatorar assets para eliminar tiles repetidos

---

### 4.2 Sistema de Tempo & Calendário

**Mecânicas:**
- 🔥🔴 **Relógio**: 10 min in-game = 7s reais (1 dia ≈ 12,6 min)
- 🔥🟢 Estação fixa (primavera) no MVP
- 🔥🟡 **Dormir**: avança dia, regenera energia, spawn na cama
- 🔥🟡 **Desmaio (2h da manhã)**: acorda com 70% energia
- 🔥🔴 Spawn do player na posição da cama ao amanhecer

**HUD:**
- 🔥🟡 Display relógio/dia/estação

**Persistência:**
- ⭐🔴 Salvar dia/estação/hora atual

**Features Futuras:**
- ⭐🔴 Sistema dia/noite visual (filtros, camadas de luz)
- ⭐🟡 Eventos de calendário e festivais
- ⭐🔴 Sistema complexo de clima

---

### 4.3 Jogador (Player)

**Atributos:**
- 🔥🟢 Vida, energia, posição
- 🔥🟢 Energia consumida em ações (cavar, regar, colher)
- ⭐🔴 Energia consumida ao arar
- ⭐🟢 Dinheiro (começa com 500 de ouro)
- ⭐🔴 Sem níveis/skills no MVP; progresso via economia

**Morte & Respawn:**
- 🔥🟡 Morrer retorna ao último save
- 🔥🔴 Corrigir bug: ao morrer, player respawna morto
- 🔥🔴 Corrigir bug: morrer múltiplas vezes no mesmo segundo quebra o jogo

**Animações & Visual:**
- 🔥🔴 Refatorar animações do player (cabelo dark/marrom)
- 🔥🔴 Trocar animação de cavar (criar buraco)
- 🔥🟢 Renderizar sprite dinâmico do player em conversas
- 🔥🟢 Corrigir spawn: player centro do componente, não top-left
- 🔥🟢 Corrigir: animação de walk/run permanece após ataque
- 🔥🔴 Corrigir direção inicial do player ao teleportar entre mapas

**Nomenclaturas:**
- ⭐🔴 Renomear stamina → energy (alinhado ao Stardew Valley)
- 🔥🔴 Renomear ações: "isPrimaryAction" → "isActionPrimary", etc.

---

### 4.4 Inventário & Equipamentos

**Estrutura:**
- 🔥🟢 12 slots com stack
- 🔥🟢 Items: seeds (2 tipos), colheitas (2), ferramentas (pá, regador, foice/mão)
- ⭐🟢 Dinheiro (saldo numérico exibido)
- 🔥🟢 Água ilimitada no regador

**Items & Tipos:**
- 🔥🟢 `EquippedHandType` → `HandItemType`
- 🔥🟢 `Item` → `HandItem`
- 🔥🔴 `cropId` deve ser do tipo `HandItemId`
- 🔥🔴 Mudar nomenclaturas de snake_case ("strawberry_seed_bag") → camelCase ("strawberrySeedBag")
- 🔥🔴 Configurar seeds em `items_icons_database`
- 🔥🔴 Refatorar `crops_database` para estrutura de `items_icons_database`

**Ferramentas:**
- 🔥🟢 **Pá**: Grama → terra (consome energia)
- ⭐🔴 **Enxada**: Torna tile arável (consome energia)
- 🔥🟢 **Regador**: Marca tile regado
- 🔥🟢 **Foice/Mão** ou **harvestBasket**: Colhe e coleta
- 🔥🔴 **Picareta**: Quebra pedras (módulo Mine)
- 🔥🔴 Criar sprites para harvestBasket
- 🔥🔴 Criar sprite e animação para ironSword
- 🔥🔴 Impossibilitar player destruir tudo acidentalmente com picareta

**Interação Contextual:**
- 🔥🟡 Ações contextuais por botão de interação
- 🔥🔴 Resolver conflito: "X" para defesa vs interação (priorizar defesa?)
- 🔥🔴 No SV não existe equipamento para colheita; avaliar manter harvestBasket ou remover

**Persistência:**
- 🔥🟢 Salvar/carregar inventário e equipamento
- 🔥🔴 Carregar último item equipado ao iniciar jogo
- 🔥🔴 Melhorar reatividade do inventário (refletir mudanças em tempo real)
- 🔥🔴 Corrigir: "G" não limpa inventário em tempo real

**Keys & Consumíveis:**
- 🔥🔴 Chave deve ser item de inventário (não vinculado ao player)
- 🔥🔴 Consumir chave na porta exige slot selecionado (comportamento SV)

**UI:**
- 🔥🔴 Melhorar UI de `InventoryOverlay`
- 🔥🔴 Permitir selecionar slots vazios (como no SV)
- 🔥🔴 Melhorar renderização de crops no inventário

---

### 4.5 Sistema de Farming

**Mecânicas de Plantio:**
- 🔥🟢 Cavar tile com pá (grama → terra)
- ⭐🔴 Arar tile com enxada (terra → solo arável)
- 🔥🟢 Plantar semente em solo arável
- 🔥🟢 Regar diariamente (necessário para crescimento)
- 🔥🟢 Colher quando maduro

**Cultivos (3 tipos):**
1. 🔥🟢 **Médio** (4 dias, lucro baixo)
2. 🔥🟢 **Lento** (7 dias, lucro médio)
3. ⭐🔴 **Lento recorrente** (7 dias, lucro alto, colheitas múltiplas)

**Sistema de Crescimento:**
- 🔥🟢 Ao plantar: registra estágio 0 e dia de plantio
- 🔥🟢 Cada dia avança estágio se regado no dia anterior
- 🔥🟢 Estágios visuais (sprites diferentes por estágio)
- 🔥🔴 **Colheita recorrente**: Após colher, volta 2 estágios; crescimento subsequente = 2 dias por estágio
- 🔥🔴 **Árvores**: Mesma lógica de colheita recorrente; após crescimento oferecem colheitas periódicas
- 🔥🔴 Melhorar lógica de `requireWaterForRegrowth`

**Rendering & Visual:**
- 🔥🟢 Farm crops precisam de comportamento 3D (Y-sorting)
- 🔥🟢 Seeds plantadas NÃO devem ter comportamento 3D
- 🔥🔴 Melhorar render de crops (base do render = base do sprite para evitar bug no fake 3D)
- 🔥🔴 Configurar `ySortingFromStage` de todos os crops
- 🔥🔴 Adicionar ícones dinâmicos de crops ao colher

**Grid & Tiles:**
- 🔥🟢 Farm tiles com prioridade e render corretos
- 🔥🔴 Mudar "farm_tile" → "grid_tile"
- ⭐🔴 Adicionar "arar" como ação separada

---

### 4.6 Sistema de Economia

**Loja (Compra):**
- ⭐🟢 Compra de seeds (preços fixos)
- ⭐🟢 2 tipos de seeds disponíveis
- 🔥🟢 Interação via `MarketDecoration`

**Caixa de Venda:**
- ⭐🔴 Deposita itens e recebe dinheiro

**Balanceamento:**
- ⭐🟢 Preços ajustados para manter loop interessante
- 🔥🔴 Seeds/dinheiro inicial suficientes para evitar softlocks
- 🔥🔴 Começar novo jogo com 500 de ouro

**Compra/Venda em Massa:**
- ⭐🔴 Feature de compra e venda em grandes quantidades

---

### 4.7 Sistema de Mineração (Novo Módulo)

**Estrutura:**
- 🔥🔴 Criar módulo "mine" (separado do módulo "farm")
- 🔥🔴 Criar `MineToolActionDef` (similar ao `FarmToolActionDef`)
- 🔥🔴 Implementar `_handleMine` (lógica de mineração)

**Mecânicas:**
- 🔥🔴 **Picareta**: Quebra pedras
- 🔥🔴 Ao quebrar, recursos adquiridos automaticamente (sem drop no chão)
- 🔥🔴 Lógica mais simples que farm (sem estágios, apenas quebrar e colher)

**Pendências:**
- 🔥🔴 Criar documento com 10 passos (prompts) para completar feature

---

### 4.8 HUD & Interface

**Elementos Principais:**
- 🔥🟢 Barra vida/energia
- 🔥🟡 Relógio/dia/estação
- ⭐🟢 Dinheiro
- 🔥🟢 Hotbar/slots rápidos

**Overlays:**
- 🔥🔴 Inventário (`InventoryOverlay`)
- 🔥🔴 Ações contextuais
- 🔥🔴 Tutorial/hints (`TutorialInputsOverlay`)
- 🔥🔴 Stats do player (`PlayerVitalStatsOverlay`)
- 🔥🔴 Debug (`DebugOverlay`)
- 🔥🔴 Gameplay diário (missões) — overlay de tela cheia
- 🔥🔴 Menu de configuração — overlay de tela cheia

**Melhorias de UI:**
- 🔥🔴 Melhorar UI de `TutorialInputsOverlay`
- 🔥🔴 Melhorar UI de `InventoryOverlay`
- 🔥🔴 Melhorar UI de `PlayerVitalStatsOverlay`
- 🔥🔴 Melhorar UI de `DebugOverlay`

**Responsividade:**
- 🔥🟡 Funcional em resize/fullscreen
- 🔥🔴 Testes dedicados para evitar quebra de HUD em resize/fullscreen
- 🔥🔴 Finalizar comportamento landscape/portrait em mobile/web
- 🔥🔴 Decidir: bloquear orientação pós-início ou permitir mudança?

---

### 4.9 Sistema de Input

**Suporte Multi-Plataforma:**
- 🔥🟡 Teclado/mouse
- 🔥🟡 Joystick (mobile)
- 🔥🔴 Suporte a controle de PS5

**Configurações:**
- ⭐🔴 Mudar todos os inputs para alinhar com Stardew Valley
- 🔥🔴 Adicionar "X" ao display de configuração de teclado
- 🔥🔴 Atualizar layout de display de teclado
- ⭐🔴 Adicionar input de mouse completo
- ⭐🔴 Adicionar ponteiro customizado 16×16 (comportamento SV)

**Ações de Input:**
- 🔥🔴 Implementar `onJoystickAction` em `FarmInputHandler` (funcionar em mobile/joystick)
- ⭐🔴 Ataque contínuo ao manter pressionado (space bar)
- 🔥🔴 Adicionar pausa completa do jogo (LogicalKeyboardKey.space + equivalente joystick)

**Market & Navegação:**
- 🔥🟢 Corrigir: contato com `MarketDecoration` requer input "isInteractionAction"
- 🔥🟡 Andar fecha `MarketPanel` automaticamente
- 🔥🔴 Navegação no Market com teclas direcionais (não controla player)
- 🔥🔴 `kSlotNavNextKey`/`kSlotNavPrevKey`: navegar inventário
- 🔥🔴 `kInteractionKey`: compra 1x | `kPrimaryActionKey`: vende 1x
- 🔥🔴 ESC fecha Market (não sai de tela cheia)
- 🔥🔴 Corrigir bug: keyX no Market (criar state machine central para panels/dialogs)

**Fullscreen:**
- 🔥🔴 Botão fullscreen visível em web (keyboard/joystick)
- 🔥🔴 Criar botão de tela cheia (cmd + shift + f para web)

---

### 4.10 Sistema de Save/Load

**Dados Persistidos:**
- 🔥🟢 Inventário e equipamentos
- 🔥🟢 Cultivos (tipo, estágio, regado, posição)
- 🔥🟢 Vida/energia
- ⭐🟢 Dinheiro
- ⭐🔴 Dia/estação/hora
- ⭐🔴 Posição do jogador
- ⭐🔴 Estado da tocha (ON/OFF)

**Regras de Salvamento:**
- 🔥🟢 Auto-save ao dormir
- ⭐🔴 Save manual opcional
- 🔥🟢 Jamais salvar com coins negativos
- 🔥🟢 Jamais salvar com vida/energia/stamina ≤ 0
- 🔥🔴 No SV mobile: save ao sair do jogo (avaliar implementar)

**Validação & Robustez:**
- 🔥🟡 Validação + fallback para estado inicial
- 🔥🔴 Criar tratamento de exceções para evitar crashes (especialmente assets não encontrados)
- 🔥🔴 Melhorar carregamento: carregar último estado salvo do player

---

### 4.11 Áudio

**Música de Fundo:**
- 🔥🟢 1 faixa de música por mapa (loop)
- 🔥🔴 Adicionar músicas finais
- 🔥🔴 Adicionar camada de som de natureza (pássaros, etc.) por mapa
- 🔥🔴 Trocar todas as músicas do jogo (incluir música Keyn?)
- 🔥🔴 Trocar música de batalha

**SFX (Efeitos Sonoros):**
- 🔥🔴 Cavar
- 🔥🔴 Regar
- 🔥🔴 Colher
- 🔥🔴 UI
- 🔥🔴 Compra/venda
- ⭐🔴 Arar
- 🔥🔴 Mudar SFX de ataques (primary e fireball)

**Controles:**
- 🔥🔴 Mute/volume global

---

### 4.12 Performance & Otimização

**Metas:**
- 🔥🔴 60 FPS (desktop/web)
- 🔥🔴 Degradê aceitável em mobile
- 🔥🔴 Tile culling via engine (Bonfire)
- 🔥🔴 Otimização de sprites/atlases
- 🔥🔴 Batch de draw calls

**Logger & Debug:**
- 🔥🔴 Implementar `GameLogger` condicional (ativo apenas em debug)
- 🔥🔴 Remover logs de loops/updates
- 🔥🔴 Manter logs em pontos críticos (save, eventos)
- 🔥🔴 Organizar logs por níveis (debug, info, warning, error)

**Assets:**
- 🔥🔴 Criar lógica para não declarar cada crop asset individualmente no `pubspec.yaml`
- 🔥🔴 Remover sombras de todos os tiles

---

## 5. Sistemas de Combate (Escondidos no MVP)

**Inimigos (Ocultos):**
- 🔥🔴 Esconder enemies antigos (imp, goblin, mini_boss, boss)
- 🔥🔴 Corrigir hitbox de Skeleton (proporcional ao sprite, não ao componentSize)
- 🔥🔴 Ajustar comportamento de render do Market (hitbox e eixo Y como Door)
- 🔥🟢 Corrigir: Boss die explosion proporcional ao sprite
- 🔥🟢 Mini boss collision size
- 🔥🟢 Helper para cálculo de hitbox baseado em spriteSize/textureSize/componentSize
- ⭐🔴 Melhorar execução de primary attack do enemy (executar em frame específico, não no primeiro)
- 🔥🔴 Corrigir: inimigo corre na direção do player ao receber ataque ranged
- 🔥🟢 Corrigir: enemy primary attack buga após primeiro ataque (não causa dano subsequente)

**Player Combat:**
- 🔥🟢 Fireball attack collision size e posição
- 🔥🔴 Esconder fireball no MVP
- 🔥🔴 Mudar SFX de primary e fireball
- 🔥🔴 Esconder escudo para MVP
- 🔥🔴 Corrigir: player ataca e empurra enemy na direção errada (deve ser direção do ataque, não posição do enemy)
- 🔥🔴 Mudar design dos action buttons (não usar ícones de fireball e sword)
- 🔥🔴 Refatorar: remover `EquipmentToCustomPlayerAdapter` do codebase?
- 🔥🔴 Verificar necessidade de `_activeAnimationLockCount` logic

**Defesa:**
- ⭐🔴 Adicionar camadas de `DDDefensePlayer`
- ⭐🔴 Eliminar `ShieldDefenseComponent` e `ShieldDefenseInputHandler`
- 🔥🔴 Defesa deve durar tempo específico (não infinito ao pressionar "X")

**Consumíveis:**
- ⭐🔴 Adicionar camadas de `DDConsumablePlayer`
- ⭐🔴 Mudar recuperação de vida (potion → consumíveis)
- 🔥🔴 Mudar lógica de regeneração de vida (tocha → cama)

**Pós-MVP:**
- ⭐🔴 Sistema de stamina para primary attack e correr
- ⭐🔴 Sistema de mana para fireball attack
- ⭐🔴 Botar fireball de volta (sprite azul/roxo)
- ⭐🔴 Pausar inimigos durante diálogos (manter animações rodando)
- ⭐🔴 Mostrar escudo/defesa de volta

---

## 6. Interações & NPCs

**MVP:**
- 🔥🟡 2 NPCs na cidade (decorações)
- 🔥🟢 Tocha ON/OFF interaction
- 🔥🟢 Forçar player.idle em todas as conversas
- 🔥🔴 Garantir que `conversation` seja display padrão para mensagens (incluir alertas como "sem stamina")
- 🔥🔴 Pausar jogo em todos os displays de UI
- 🔥🔴 Executar player.idle em vitória e game over
- 🔥🔴 Corrigir bug: emote exibindo fora da área de `gameplayscreen`
- 🔥🔴 Corrigir: win e die não devem exibir simultaneamente (executar `enemy.idle`?)

**Fora de Escopo (Pós-MVP):**
- ⭐🟡 NPCs, diálogos, quests, relacionamentos
- ⭐🔴 Eventos de calendário, festivais
- ⭐🔴 Pets/animais

**Falas & Diálogos:**
- 🔥🔴 Mudar todas as falas do MVP do jogo

---

## 7. Conteúdo Inicial do MVP

- 🔥🟢 1 mapa fazenda (~10-20 tiles aráveis)
- 🔥🟡 1 mapa cidade (2 NPCs, decorações)
- **3 cultivos:**
  - 🔥🟢 Médio (4 dias)
  - 🔥🟢 Lento (7 dias)
  - ⭐🔴 Lento recorrente (7 dias)
- ⭐🟢 Loja com 2 tipos de seeds
- ⭐🔴 Caixa de venda
- 🔥🔴 Casa + cama com respawn

---

## 8. Critérios de Pronto (Definition of Done)

### Gameplay:
- 🔥🔴 Completar 2 ciclos plantio-colheita-venda em ≤ 30 min
- 🔥🔴 Sem softlocks (seeds/dinheiro inicial suficientes)

### Save/Load:
- 🔥🟢 Cultivos e inventário salvos corretamente
- ⭐🟢 Dinheiro salvo
- ⭐🔴 Tempo (dia/estação/hora) salvo
- 🔥🔴 Validação: jamais salvar com valores negativos/inválidos

### HUD & Input:
- 🔥🟡 HUD/input estáveis após resize/fullscreen
- 🔥🔴 Controles funcionais em teclado, mouse e joystick

### Performance:
- 🔥🔴 60 FPS em desktop/web
- 🔥🔴 Logger condicional (sem logs em produção)

---

## 9. Riscos e Mitigações

| Risco | Status | Mitigação |
|-------|--------|-----------|
| HUD quebra em resize/fullscreen | 🔥🟡 | Testes dedicados, cache em overlays |
| Loop lento (balanceamento) | 🔥🟡 | Durações curtas, preços ajustáveis |
| Save corrompido | 🔥🟡 | Validação rigorosa + fallback |
| Performance baixa | 🔥🔴 | Logger condicional, otimização de sprites |
| Softlock por falta de recursos | 🔥🔴 | Balanceamento inicial (500 gold, seeds suficientes) |

---

## 10. Roadmap (4 Semanas)

### Semana 1: Mundo, Movimento, HUD, Inventário
- 🔥🟡 Mundo e colisões
- 🔥🟡 Movimento multi-plataforma
- 🔥🟢 HUD básico
- 🔥🟢 Inventário funcional

### Semana 2: Ferramentas, Cultivos, Estágios
- 🔥🟢 Ferramentas (pá, regador, foice/mão)
- ⭐🔴 Enxada (arar)
- 🔥🟢 Cultivos e estágios de crescimento
- ⭐🔴 Colheita recorrente

### Semana 3: Economia, Tempo, Energia, Dormir
- ⭐🟢 Loja funcional
- ⭐🔴 Caixa de venda
- 🔥🔴 Sistema de tempo completo
- 🔥🟡 Dormir e respawn

### Semana 4: Polish (SFX/Música, Save/Load, Testes)
- 🔥🔴 Adicionar todos os SFX
- 🔥🔴 Adicionar músicas finais
- 🔥🟡 Save/load robusto
- 🔥🔴 Testes de performance
- 🔥🔴 Refatoração final

---

## 11. Backlog Técnico & Refatorações

### Refatorações Críticas:
- 🔥🔴 Centralizar configuração de items (eliminar repetição)
- 🔥🔴 Refatorar estrutura de database (crops, items, icons)
- 🔥🔴 Mudar nomenclaturas (snake_case → camelCase)
- 🔥🔴 Organizar exports do projeto em um arquivo único
- 🔥🔴 Implementar `GameLogger` condicional
- 🔥🔴 Criar tratamento de exceções global

### Melhorias de Código:
- 🔥🔴 Documentar camada de config (constants, factories, builders)
- 🔥🔴 Refatorar `executionStartFrame` para ser injetado
- 🔥🔴 Criar estrutura modular clara (MVC + camada de config)
- ⭐🔴 Criar programa Dart para gerar JSON database a partir de configuração tipada

### Funcionalidades Futuras:
- ⭐🔴 Adicionar `iconPath` de weapons (crops)
- ⭐🟢 Combo attacks
- ⭐🟢 Market expandido
- ⭐🔴 Configuração dinâmica de game view size (small, medium, large)

---

## 12. Fora de Escopo (Pós-MVP)

**Conteúdo:**
- ⭐🟡 NPCs, diálogos, quests, relacionamentos
- ⭐🟡 Combate e masmorras
- ⭐🔴 Pesca
- ⭐🔴 Mineração avançada
- ⭐🔴 Crafting avançado
- ⭐🔴 Eventos de calendário, festivais
- ⭐🔴 Pets/animais de fazenda

**Sistemas:**
- ⭐🔴 Sistema complexo de clima
- ⭐🔴 Níveis e skills do jogador
- ⭐🔴 Sistema de relacionamento com NPCs

---

## 13. Prompts para IA

### Planejamento:
- **Farmable**: "Preciso que você finalize o planejamento da lógica inicial de meu farmable. Levando em conta que quero fazer o clone do SV..." *(TODO: finalizar prompt)*

### Refatoração:
- **Padronização**: "Preciso que você percorra todo o meu código fazendo melhorias onde necessário para deixar tudo bem implementado e padronizado. Use como referência o módulo de `lib/gameplay/characters/player/knight`, utilizando o MVC e camada de config."

### Features Específicas:
- 🔥🔴 **Colheita Recorrente**: Criar lógica de crops/trees que oferecem colheitas múltiplas
- 🔥🔴 **Módulo Mine**: Criar documento com 10 passos para implementar mineração completa
- 🔥🔴 **Reorganização de Items**: Centralizar configs, eliminar repetição

---

## 14. Resumo Executivo

MVP focado no **loop essencial de farming**: **plantar → regar → colher → vender**.

**Conteúdo mínimo:**
- 2 mapas (fazenda + cidade)
- 3 cultivos (4 dias, 7 dias, 7 dias recorrente)
- Ferramentas básicas (pá, regador, foice/mão, enxada)
- Loja de seeds + caixa de venda

**Prioridades:**
1. **Clareza de feedback** (visual + sonoro)
2. **Estabilidade** (save/load robusto, sem softlocks)
3. **UX multi-plataforma** (keyboard, mouse, joystick)

**Tudo além** (NPCs, combate, mineração avançada, crafting, relacionamentos) **fica para iterações futuras**.

---

**Nota Final:** Este GDD unificado mantém TODOS os itens dos documentos originais, reorganizados por sistema e priorizados por status. Use como referência única para desenvolvimento do MVP.

---

# Questões pré MVP:
- substituir spike animation

# Questões pós MVP:
- marketing
- reter usuario (mobile)
- mobile: microtransacoes?
- como a comunidade irá criar mods para flutter?
- fix: bug, quando o player morre e esta executando algo ele executa ao renascer
- toda vez q o player navega entre mapas a vida dele refaz a animacao de perdendo vida, corrigir ou eliminar essa animacao para o MVP e colocar de volta pós mvp?
- colocar o tamanha do campo de visao do final boss bem maior do q é hoje, ou pelo menos mudar quando ele iniciar a batalha
- melhorar todo o sistema de save do meu jogo:
    - unificar todos os sunny, cute, demo player save classes em uma unica, usar bem o MVC e todos os dados volateis ficar em model unico e dados de save em savedata unico tb, KISS.
    - jogar _PositionHelper para tilehelper?