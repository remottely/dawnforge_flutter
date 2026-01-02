# GDD — MVP

STATUS:
🔥 (Critical)
⭐ (Standard)
🔴 (TODO)
🟡 (WIP)
🟢 (DONE)

## Sumário
1. Visão e Metas do MVP
2. Pilares de Experiência
3. Escopo do MVP (Must-Have)
<!-- 4. Fora de Escopo (Nice-to-Have / Posterior) -->
5. Loop Principal de Jogo
6. Sistemas Centrais
   6.1 Mundo e Mapa
   6.2 Tempo, Dia/Noite, Estações e Clima
   6.3 Jogador e Progressão
   6.4 Inventário e Itens
   6.5 Ferramentas e Ações de Fazenda
   6.6 Cultivos (Plantio, Crescimento, Colheita)
   <!-- 6.7 Economia e Vendas -->
   6.8 HUD, Input e UX
   6.9 Salvamento/Carregamento
   6.10 Áudio (Música e SFX)
   6.11 Performance e Plataforma
7. Conteúdo Inicial do MVP
8. KPIs e Critérios de Pronto
9. Riscos e Mitigações
10. Roadmap Macro
<!-- 11. Refatorar -->
12. Resumo Executivo

## 1. Visão e Metas do MVP
Entregar um protótipo jogável que capture o loop central de farming:
    <!-- 🔥🟢 plantar → esperar → colher. -->
    <!-- ⭐🔴 → vender → reinvestir. -->
🔥🟡 Ser jogável em 20–30 minutos, demonstrando ciclo completo de 7 dias in-game.
🔥🟡 Priorizar clareza e responsividade de controles (keyboard/mouse e joystick, web/mobile/desktop).
🔥🟡 Estabilidade de save/load e ausência de softlocks no loop de fazenda.

## 2. Pilares de Experiência
🔥🔴 **Clareza**: feedback visual/sonoro imediato ao plantar, regar e colher.
🔥🟡 **Ritmo curto**: ciclos de cultivo rápidos para validar o loop (4-7 dias por cultivo no MVP).
<!-- ⭐🔴 **Progresso tangível**: vender colheita gera dinheiro que habilita novos seeds/slots. -->
🔥🟡 **Conforto de input**: HUD simples, botões essenciais sempre acessíveis e inputs que não quebram em resize/fullscreen.

## 3. Escopo do MVP (Must-Have)
🔥🟡 Mapa único de fazenda simples (grids aráveis + poucas decorações).
🔥🟡 Sistema de tempo: dia/noite, passagem acelerada, dormir para avançar o dia.
🔥🟡 Plantio, rega, crescimento em etapas e colheita de pelo menos 2 cultivos (strawberry, tomato).
🔥🟡 Inventário básico com stack e slots limitados; seeds, ferramentas e colheita como itens.
🔥🟡 Ferramentas: pá(cavar), enxada (arar), regador (regar), mão/foice (colher).
<!-- ⭐🔴 Economia: vender itens colhidos para obter dinheiro; loja simples de seeds. -->
🔥🟡 HUD: barras de vida/energia, relógio, estação/dia, hotbar/atalhos principais.
🔥🟡 Save/Load funcional cobrindo inventário, cultivos, tempo, dinheiro.
🔥🟡 Áudio mínimo: música de fundo e SFX de ações-chave (cavar, arar, regar, colher, UI).

## 4. Fora de Escopo (Nice-to-Have / Posterior)
<!-- ⭐🟡 NPCs, diálogos, quests e relacionamentos. -->
<!-- ⭐🟡 Combate e masmorras. -->
<!-- ⭐🔴 Pesca, mineração, crafting avançado. -->
<!-- ⭐🔴 Eventos de calendário, festivais, pets/animais de fazenda. -->
<!-- ⭐🔴 Sistema complexo de clima (chuva com irrigação automática) — pode ser protótipo simples depois. -->

## 5. Loop Principal de Jogo
🔥🟡 1. cavar solo grid_tile (consome energia).
🔥🟡 2. Arar solo arável (consome energia).
🔥🟡 3. Plantar semente (consome item seed).
<!-- 🔥🟢 4. Regar diariamente até crescer. -->
<!-- 🔥🟢 5. Colher quando maduro. -->
<!-- ⭐🔴 6. Vender colheita → receber dinheiro. -->
<!-- ⭐🔴 7. Comprar novas seeds/ferramentas → repetir com mais eficiência. -->

## 6. Sistemas Centrais
### 6.1 Mundo e Mapa
🔥🟡 Grid 16x16 tiles, área arável delimitada e clara.
<!-- 🔥🟢 Colisões mínimas (casas/rochas/decor) para guiar o jogador. -->
<!-- ⭐🔴 Ponto de venda (caixa/cofre) e ponto de compra (loja simples UI). -->

### 6.2 Tempo, Dia/Noite, Estações e Clima
🔥🔴 Relógio interno: 10min = 7s reais. 1 dia ≈ 12,6 minutos reais no MVP.
🔥🟡 Dormir avança para o próximo dia e regenera energia.
    ⭐🔴 Desmaiar as 2h da manhã joga player para cama e ele acorda com 70% da energia.
🔥🟡 Estação fixa (primavera) no MVP; sem variação climática obrigatória.

### 6.3 Jogador e Progressão
<!-- 🔥🟢 Atributos: vida, energia (stamina), posição. -->
🔥🟡 Energia é consumida ao cavar/arar/regar/colher; dormir restaura energia total.
<!-- ⭐🔴 Sem níveis/skills no MVP; progresso via economia e mais seeds. -->

### 6.4 Inventário e Itens
Slots: 
    <!-- 🔥🟢 limitados a 12 espaços -->
    🔥🟡 com stack para recursos. Falta melhorar.
Itens mínimos:
    <!-- 🔥🟢 seeds (2 tipos) -->
    🔥🟡 colheitas (2). Falta melhorar renderização dos crops no inventorio
    🔥🟡 ferramentas (pá, enxada, regador, foice/mão)
    <!-- ⭐🔴 dinheiro (saldo numérico) -->
    <!-- 🔥🟢 água (implícita no regador com uso ilimitado no MVP). -->

### 6.5 Ferramentas e Ações de Fazenda
🔥🟡 Pá: torna grama em terra.
🔥🟡 Enxada: torna tile arável.
<!-- 🔥🟢 Regador: marca tile como regado para o dia. -->
🔥🟡 Foice/Mão: colhe e coleta item.
🔥🟡 Interação contextual via botão de ação (keyboard/joystick). Entender esse tópico e verificar comportamento.

### 6.6 Cultivos (Plantio, Crescimento, Colheita)
<!-- 🔥🟢 Ao plantar, registra estágio 0 e dia de plantio. -->
<!-- 🔥🟢 Cada dia avança estágio se regado no dia anterior. -->
2 cultivos:
    🔥🟡 com durações de 4 e 7 dias.
    <!-- ⭐🔴 Preços diferentes para teste de balanceamento. -->
Colheita gera item:
    <!-- 🔥🟢 remove planta. -->
    <!-- ⭐🔴 reseta para estágio colhido. -->

### 6.7 Economia e Vendas
<!-- ⭐🔴 Caixa de venda: deposita itens e recebe dinheiro instantâneo (ou ao dormir, se quiser reforçar loop diário — opcional no MVP). -->
<!-- ⭐🔴 Loja simples: compra de seeds; preços fixos. -->

### 6.8 HUD, Input e UX
🔥🟡 HUD: barra de vida/energia, relógio/dia/estação, dinheiro, hotbar/slots rápidos.
🔥🔴 Overlays: inventory, ações contextuais; tutorial/hints básicos.
🔥🟡 Input: teclado/mouse e joystick; fullscreen opcional; overlays não devem quebrar com resize.

### 6.9 Salvamento/Carregamento
Persistir:
    <!-- ⭐🔴 dia/estação, hora. -->
    <!-- 🔥🟢 inventário -->
    🔥🟡 cultivos (tipo, estágio, regado, posição)
    <!-- ⭐🔴 dinheiro -->
    <!-- ⭐🔴 posição do jogador -->
    🔥🟢 energia/vida.
<!-- 🔥🟢 Auto-save ao dormir. -->
<!-- ⭐🔴 opção de save manual simples. -->

### 6.10 Áudio (Música e SFX)
🔥🟡 1–2 faixas de música de fundo (loop).
🔥🔴 SFX mínimos: cavar, arar, regar, colher, abrir/fechar UI, confirmação de compra/venda.
🔥🔴 Respeitar flag de mute/volume global.

### 6.11 Performance e Plataforma
🔥🔴 Alvo: 60 FPS em desktop/web; degrade aceitável em mobile web.
🔥🔴 Tile culling básico via engine (Bonfire) já usado.
🔥🔴 Atenção a alocação de sprites/atlases e batch de draw calls.

## 7. Conteúdo Inicial do MVP
🔥🟡 1 mapa de fazenda pequeno com "~10–20 tiles aráveis úteis."?
2 cultivos: 
  🔥🟡 Médio (4 dias, lucro baixo).
  🔥🟡 Lento (7 dias, lucro médio).
  <!-- ⭐🔴 Lento + recorrencia (7 dias com recorrencias, lucro alto). -->
<!-- ⭐🔴 Loja com 2 seeds; preços e retornos diferenciados para ensinar risco/recompensa. -->
<!-- ⭐🔴 Caixa de venda. -->

## 8. KPIs e Critérios de Pronto
🔥🔴 O jogador completa "2 ciclos de plantio-colheita-venda em ≤30 minutos"?
🔥🔴 Nenhum softlock ao dormir (sempre há seeds ou dinheiro suficiente inicial para recomeçar).
🔥🟡 Save/Load preserva cultivos, inventário, dinheiro e tempo de forma consistente.
🔥🟡 Inputs e overlays funcionam após resize/fullscreen no web/desktop.

## 9. Riscos e Mitigações
🔥🟡 **Resize/Fullscreen quebra HUD ou input** → Testes dedicados em web/desktop; evitar reconstruir player ao recalcular câmera; caches em overlays (como vital stats).
🔥🟡 **Balanceamento inadequado (loop lento)** → Durações curtas de cultivo no MVP; preços fáceis de ajustar por config.
🔥🟡 **Save corrompido** → Validação ao carregar; fallback para estado inicial se inválido.

## 10. Roadmap Macro
🔥🟡 Semana 1: Mundo, movimento, HUD básico, inventário e itens.
🔥🟡 Semana 2: Ferramentas (arar, regar), sistema de cultivos e estágios.
🔥🟡 Semana 3: Economia (loja + venda), dia/noite, dormir, energia.
🔥🟡 Semana 4: Polish de HUD, SFX/Música, save/load, testes de resize/fullscreen.

## 11. Refatorar
<!-- ⭐🔴 Mudar sistema de recuperação de vida. De potion para consumiveis. -->
<!-- ⭐🔴 Mudar o que hoje é stamina para energia. -->

## 12. Resumo Executivo
Um MVP focado no loop essencial de fazenda: plantar, regar, colher e vender. Conteúdo enxuto (um mapa, três cultivos, ferramentas básicas) com ênfase em clareza de feedback, estabilidade de save/load e UX robusta em diferentes modos de input e resize. Os pilares são ritmo curto, progressão tangível e controles estáveis; tudo o que for além (NPCs, combate, crafting avançado) fica para depois do MVP.
