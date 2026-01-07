# GDD — MVP

**STATUS:**
- 🔥 Critical
- ⭐ Standard
- 🔴 TODO | 🟡 WIP | 🟢 DONE

---

## 1. Visão e Metas do MVP

Protótipo jogável do loop central de farming (🔥🟢 plantar → esperar → colher → ⭐🟢 vender → reinvestir).

**Objetivos:**
- 🔥🟡 Sessão completa de 20-30 min demonstrando 7 dias in-game
- 🔥🟡 Controles responsivos (keyboard/mouse, joystick, multi-plataforma)
- 🔥🟡 Save/load estável sem softlocks

---

## 2. Pilares de Experiência

- 🔥🔴 **Clareza**: Feedback visual/sonoro imediato
- 🔥🟢 **Ritmo curto**: Ciclos de 4-7 dias por cultivo
- 🔥🟡 **Conforto de input**: HUD simples, funcional em resize/fullscreen

---

## 3. Loop Principal

1. 🔥🟢 Cavar solo (energia)
2. ⭐🔴 Arar solo arável (energia)
3. 🔥🟢 Plantar semente (consome item)
4. 🔥🟢 Regar diariamente
5. 🔥🟢 Colher quando maduro
6. ⭐🟢 Vender colheita → dinheiro
7. ⭐🔴 Comprar novas seeds → repetir

---

## 4. Sistemas Centrais

### 4.1 Mundo
- 🔥🟢 Grid 16×16 tiles
- 🔥🟢 Colisões básicas (casas/rochas/decor)
- 🔥🟡 Mapa fazenda + mapa cidade (2 NPCs, decorações)
- ⭐🟢 Ponto de compra/venda (loja simples UI)
- ⭐🔴 Caixa de venda

### 4.2 Tempo
- 🔥🔴 **Relógio**: 10 min = 7s reais (1 dia ≈ 12,6 min)
- 🔥🟢 Estação fixa (primavera) no MVP
- 🔥🟡 **Dormir**: avança dia, regenera energia
- 🔥🟡 **Desmaio (2h)**: acorda com 70% energia

### 4.3 Jogador
- 🔥🟢 Atributos: vida, energia, posição
- 🔥🟢 Energia consumida em ações (cavar, regar, colher)
- ⭐🔴 Energia consumida ao arar
- ⭐🔴 Sem níveis/skills no MVP; progresso via economia
- 🔥🟡 Morrer retorna ao último save

### 4.4 Inventário
- 🔥🟢 12 slots com stack
- 🔥🟢 Seeds (2 tipos)
- 🔥🟢 Colheitas (2) — melhorar renderização no inventário
- 🔥🟢 Ferramentas (pá, regador, foice/mão)
- ⭐🟢 Dinheiro (saldo numérico)
- 🔥🟢 Água (implícita no regador, uso ilimitado)

### 4.5 Ferramentas
- 🔥🟢 **Pá**: Grama → terra
- ⭐🔴 **Enxada**: Torna tile arável
- 🔥🟢 **Regador**: Marca tile regado
- 🔥🟢 **Foice/Mão**: Colhe e coleta
- 🔥🟡 Interação contextual por botão de ação

### 4.6 Cultivos
- 🔥🟢 Ao plantar, registra estágio 0 e dia de plantio
- 🔥🟢 Cada dia avança estágio se regado no dia anterior
- **3 cultivos:**
  - 🔥🟢 Médio (4 dias, lucro baixo)
  - 🔥🟢 Lento (7 dias, lucro médio)
  - ⭐🔴 Lento recorrente (7 dias, lucro alto)
- ⭐🟢 Preços diferentes para balanceamento
- **Colheita:**
  - 🔥🟢 Remove planta
  - ⭐🔴 Opção: resetar para estágio colhido (recorrente)

### 4.7 Economia
- ⭐🟢 Loja: compra de seeds (preços fixos)
- ⭐🔴 Caixa de venda: deposita itens, recebe dinheiro

### 4.8 HUD e Input
- **HUD:**
  - 🔥🟢 Barra vida/energia
  - 🔥🟡 Relógio/dia/estação
  - ⭐🟢 Dinheiro
  - 🔥🟢 Hotbar/slots rápidos
- 🔥🔴 **Overlays**: inventário, ações contextuais, tutorial/hints
- 🔥🟡 **Input**: teclado/mouse, joystick; funcional em resize/fullscreen

### 4.9 Save/Load
- **Persistir:**
  - 🔥🟢 Inventário
  - 🔥🟢 Cultivos (tipo, estágio, regado, posição)
  - 🔥🟢 Vida/energia
  - ⭐🟢 Dinheiro
  - ⭐🔴 Dia/estação/hora
  - ⭐🔴 Posição do jogador
- 🔥🟢 Auto-save ao dormir
- ⭐🔴 Save manual opcional

### 4.10 Áudio
- 🔥🟢 1 faixa música de fundo (loop) por mapa
- ⭐🔴 1 faixa som natureza de fundo (loop) por mapa
- 🔥🔴 **SFX**: cavar, regar, colher, UI, compra/venda
- ⭐🔴 **SFX**: arar
- 🔥🔴 Controle de mute/volume global

### 4.11 Performance
- 🔥🔴 60 FPS (desktop/web), degradê aceitável (mobile)
- 🔥🔴 Tile culling via engine (Bonfire)
- 🔥🔴 Otimização de sprites/atlases e batch de draw calls

---

## 5. Conteúdo Inicial

- 🔥🟢 1 mapa fazenda (~10-20 tiles aráveis)
- **2-3 cultivos:**
  - 🔥🟢 Médio (4 dias)
  - 🔥🟢 Lento (7 dias)
  - ⭐🔴 Lento recorrente (7 dias)
- ⭐🟢 Loja com 2 seeds
- ⭐🔴 Caixa de venda

---

## 6. Critérios de Pronto

- 🔥🔴 Completar 2 ciclos plantio-colheita-venda em ≤30 min
- 🔥🔴 Sem softlocks (seeds/dinheiro inicial suficientes)
- **Save/load consistente:**
  - 🔥🟢 Cultivos, inventário
  - ⭐🟢 Dinheiro
  - ⭐🔴 Tempo
- 🔥🟡 HUD/input estáveis após resize/fullscreen

---

## 7. Riscos e Mitigações

| Risco | Status | Mitigação |
|-------|--------|-----------|
| HUD quebra em resize/fullscreen | 🔥🟡 | Testes dedicados, cache em overlays |
| Loop lento (balanceamento) | 🔥🟡 | Durações curtas, preços ajustáveis |
| Save corrompido | 🔥🟡 | Validação + fallback para estado inicial |

---

## 8. Roadmap (4 semanas)

1. **Semana 1**: Mundo, movimento, HUD, inventário
2. **Semana 2**: Ferramentas, cultivos, estágios
3. **Semana 3**: Economia, tempo, energia, dormir
4. **Semana 4**: Polish (SFX/música, save/load, testes)

---

## 9. Backlog (Pós-MVP)

**Melhorias/Refatorações:**
- ⭐🔴 Mudar recuperação de vida (potion → consumíveis)
- ⭐🔴 Renomear stamina → energia
- ⭐🔴 Sistema dia/noite visual (filtros, camadas de luz)
- ⭐🔴 Adicionar enxada (arar) + SFX

**Fora de Escopo:**
- ⭐🟡 NPCs, diálogos, quests, relacionamentos
- ⭐🟡 Combate e masmorras
- ⭐🔴 Pesca, mineração, crafting avançado
- ⭐🔴 Eventos de calendário, festivais, pets/animais
- ⭐🔴 Sistema complexo de clima

**Extras:**
- ⭐🟢 Combo attacks
- ⭐🟢 Market

---

## 10. Resumo Executivo

MVP focado no loop essencial: **plantar → regar → colher → vender**. Conteúdo mínimo (1 mapa, 3 cultivos, ferramentas básicas) priorizando **clareza de feedback**, **estabilidade** e **UX multi-plataforma**. Tudo além (NPCs, combate, crafting avançado) fica para iterações futuras.

# TODO: MUDAR
## No MVP:
- 🔥🔴 refactor: mudar todas as falas do MVP do jogo
- 🔥🔴 refactor: esconder antigos enemies, imp, goblin, mini_boss e boss
- 🔥🔴 refactor: ajustar tamanho da caixa de vida do skeleton pois hj é proporcional ao componentsize (bonfire?)
- 🔥🔴 refactor: ajustar comportamento do render do market, adicionar hitbox e comportamento no eixo Y assim como é hj com Door
- 🔥🔴 fix: corrigir a direcao para qual o player olha quando teleporta para um novo mapa, ele sempre olha para a direita. não é config no tiled, é a criacao da instancia do player no mapa, criar feature q controla a direcao para o qual ele inicia olhando, se nao criar instancia e fazer ele olhar para as 4 direcoes forcadamente
- 🔥🔴 fix: o ESC quando aberto a loja deveria fechar a loja e nao sair de tela cheia
- 🔥🔴 feat: melhorar hitbox behavior de todos os assets(tiled) e componentes(decoration) do jogo
- 🔥🔴 mudar SFX de primary e fireball ataque player/enemy
- 🔥🔴 esconder a utilização de fireball no MVP
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 
- 🔥🔴 

## Pós MVP:
- ⭐🔴 mudar stamina para energy
- ⭐🔴 criar sistema de smatina q consome em primary attack e correr
- ⭐🔴 criar sistema de mana para utilização de fireball attack
- ⭐🔴 botar de volta fireball no jogo e mudar sprite de fireball para azul? roxo? assets já encontrados antes
- ⭐🔴 adicionar toda a logica de input de mouse no jogo
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴
- ⭐🔴