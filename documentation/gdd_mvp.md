# GDD — MVP

## Sumário
1. Visão e Metas do MVP
2. Pilares de Experiência
3. Escopo do MVP (Must-Have)
4. Fora de Escopo (Nice-to-Have / Posterior)
5. Loop Principal de Jogo
6. Sistemas Centrais
   6.1 Mundo e Mapa
   6.2 Tempo, Dia/Noite, Estações e Clima
   6.3 Jogador e Progressão
   6.4 Inventário e Itens
   6.5 Ferramentas e Ações de Fazenda
   6.6 Cultivos (Plantio, Crescimento, Colheita)
   6.7 Economia e Vendas
   6.8 HUD, Input e UX
   6.9 Salvamento/Carregamento
   6.10 Áudio (Música e SFX)
   6.11 Performance e Plataforma
7. Conteúdo Inicial do MVP
8. KPIs e Critérios de Pronto
9. Riscos e Mitigações
10. Roadmap Macro
11. Resumo Executivo

## 1. Visão e Metas do MVP
[TODO] - Entregar um protótipo jogável que capture o loop central de farming: plantar → esperar → colher → vender → reinvestir.
[TODO] - Ser jogável em 20–30 minutos, demonstrando ciclo completo de 2–3 dias in-game.
[ALMOST] - Priorizar clareza e responsividade de controles (keyboard/mouse e joystick, web/mobile/desktop).
[ALMOST] - Estabilidade de save/load e ausência de softlocks no loop de fazenda.

## 2. Pilares de Experiência
[TODO] - **Clareza**: feedback visual/sonoro imediato ao plantar, regar e colher.
[ALMOST] - **Ritmo curto**: ciclos de cultivo rápidos para validar o loop (1–3 dias por cultivo no MVP).
[TODO] - **Progresso tangível**: vender colheita gera dinheiro que habilita novos seeds/slots.
[ALMOST] - **Conforto de input**: HUD simples, botões essenciais sempre acessíveis e inputs que não quebram em resize/fullscreen.

## 3. Escopo do MVP (Must-Have)
[ALMOST] - Mapa único de fazenda simples (grids aráveis + poucas decorações).
[ALMOST] - Sistema de tempo: dia/noite, passagem acelerada, dormir para avançar o dia.
[ALMOST] - Plantio, rega, crescimento em etapas e colheita de pelo menos 3 cultivos (ex.: trigo, batata, cenoura).
[ALMOST] - Inventário básico com stack e slots limitados; seeds, ferramentas e colheita como itens.
[ALMOST] - Ferramentas: enxada (arar), regador (regar), mão/foice (colher).
[TODO] - Economia: vender itens colhidos para obter dinheiro; loja simples de seeds.
[ALMOST] - HUD: barras de vida/energia, relógio, estação/dia, hotbar/atalhos principais.
[ALMOST] - Save/Load funcional cobrindo inventário, cultivos, tempo, dinheiro.
[ALMOST] - Áudio mínimo: música de fundo e SFX de ações-chave (arar, regar, colher, UI).

## 4. Fora de Escopo (Nice-to-Have / Posterior)
[ALMOST] - NPCs, diálogos, quests e relacionamentos.
[ALMOST] - Combate e masmorras.
[TODO] - Pesca, mineração, crafting avançado.
[TODO] - Eventos de calendário, festivais, pets/animais de fazenda.
[TODO] - Sistema complexo de clima (chuva com irrigação automática) — pode ser protótipo simples depois.

## 5. Loop Principal de Jogo
[ALMOST] - 1. Arar solo arável (consome energia).
[ALMOST] - 2. Plantar semente (consome item seed).
[DONE] - 3. Regar diariamente até crescer.
[DONE] - 4. Colher quando maduro.
[TODO] - 5. Vender colheita → receber dinheiro.
[TODO] - 6. Comprar novas seeds/ferramentas → repetir com mais eficiência.

## 6. Sistemas Centrais
### 6.1 Mundo e Mapa
[ALMOST] - Grid 16x16 tiles, área arável delimitada e clara.
[ALMOST] - Colisões mínimas (casas/rochas/decor) para guiar o jogador.
[TODO] - Ponto de venda (caixa/cofre) e ponto de compra (loja simples UI).

### 6.2 Tempo, Dia/Noite, Estações e Clima
[TODO] - Relógio interno: 1 dia ≈ 3–5 minutos reais no MVP.
[ALMOST] - Dormir avança para o próximo dia e regenera energia.
[ALMOST] - Estação fixa (primavera) no MVP; sem variação climática obrigatória.

### 6.3 Jogador e Progressão
[ALMOST] - Atributos: vida, energia (stamina), posição.
[ALMOST] - Energia é consumida ao arar/regar/colher; dormir restaura energia total.
[TODO] - Sem níveis/skills no MVP; progresso via economia e mais seeds.

### 6.4 Inventário e Itens
[ALMOST] - Slots limitados (ex.: 12) com stack para recursos.
[ALMOST] - Itens mínimos: seeds (3 tipos), colheitas (3), ferramentas (enxada, regador, foice/mão), dinheiro (saldo numérico), água (implícita no regador com uso ilimitado no MVP).

### 6.5 Ferramentas e Ações de Fazenda
[ALMOST] - Enxada: torna tile arável.
[ALMOST] - Regador: marca tile como regado para o dia.
[ALMOST] - Foice/Mão: colhe e coleta item.
[ALMOST] - Interação contextual via botão de ação (keyboard/joystick).

### 6.6 Cultivos (Plantio, Crescimento, Colheita)
[ALMOST] - Ao plantar, registra estágio 0 e dia de plantio.
[ALMOST] - Cada dia avança estágio se regado no dia anterior.
[ALMOST] - 3 cultivos com durações curtas (ex.: 1, 2, 3 dias) e preços diferentes para teste de balanceamento.
[ALMOST] - Colheita gera item, remove planta ou reseta para estágio colhido (one-shot no MVP).

### 6.7 Economia e Vendas
[TODO] - Caixa de venda: deposita itens e recebe dinheiro instantâneo (ou ao dormir, se quiser reforçar loop diário — opcional no MVP).
[TODO] - Loja simples: compra de seeds; preços fixos.

### 6.8 HUD, Input e UX
[ALMOST] - HUD: barra de vida/energia, relógio/dia/estação, dinheiro, hotbar/slots rápidos.
[TODO] - Overlays: inventory, ações contextuais; tutorial/hints básicos.
[ALMOST] - Input: teclado/mouse e joystick; fullscreen opcional; overlays não devem quebrar com resize.

### 6.9 Salvamento/Carregamento
[ALMOST] - Persistir: dia/estação, hora, inventário, cultivos (tipo, estágio, regado, posição), dinheiro, posição do jogador, energia/vida.
[ALMOST] - Auto-save ao dormir; opção de save manual simples (opcional no MVP se o fluxo de dormir já salvar).

### 6.10 Áudio (Música e SFX)
[ALMOST] - 1–2 faixas de música de fundo (loop).
[TODO] - SFX mínimos: arar, regar, colher, abrir/fechar UI, confirmação de compra/venda.
[TODO] - Respeitar flag de mute/volume global.

### 6.11 Performance e Plataforma
[TODO] - Alvo: 60 FPS em desktop/web; degrade aceitável em mobile web.
[TODO] - Tile culling básico via engine (Bonfire) já usado.
[TODO] - Atenção a alocação de sprites/atlases e batch de draw calls.

## 7. Conteúdo Inicial do MVP
[ALMOST] - 1 mapa de fazenda pequeno com ~10–20 tiles aráveis úteis.
[ALMOST] - 3 cultivos: 
  [ALMOST] - Rápido (1 dia, lucro baixo),
  [ALMOST] - Médio (2 dias, lucro médio),
  [ALMOST] - Lento (3 dias, lucro alto).
[TODO] - Loja com 3 seeds; preços e retornos diferenciados para ensinar risco/recompensa.
[TODO] - Caixa de venda.

## 8. KPIs e Critérios de Pronto
[TODO] - O jogador completa 2 ciclos de plantio-colheita-venda em ≤30 minutos.
[TODO] - Nenhum softlock ao dormir (sempre há seeds ou dinheiro suficiente inicial para recomeçar).
[TODO] - Save/Load preserva cultivos, inventário, dinheiro e tempo de forma consistente.
[ALMOST] - Inputs e overlays funcionam após resize/fullscreen no web/desktop.

## 9. Riscos e Mitigações
[ALMOST] - **Resize/Fullscreen quebra HUD ou input** → Testes dedicados em web/desktop; evitar reconstruir player ao recalcular câmera; caches em overlays (como vital stats).
[ALMOST] - **Balanceamento inadequado (loop lento)** → Durações curtas de cultivo no MVP; preços fáceis de ajustar por config.
[ALMOST] - **Save corrompido** → Validação ao carregar; fallback para estado inicial se inválido.

## 10. Roadmap Macro
[ALMOST] - Semana 1: Mundo, movimento, HUD básico, inventário e itens.
[ALMOST] - Semana 2: Ferramentas (arar, regar), sistema de cultivos e estágios.
[ALMOST] - Semana 3: Economia (loja + venda), dia/noite, dormir, energia.
[ALMOST] - Semana 4: Polish de HUD, SFX/Música, save/load, testes de resize/fullscreen.

## 11. Resumo Executivo
Um MVP focado no loop essencial de fazenda: plantar, regar, colher e vender. Conteúdo enxuto (um mapa, três cultivos, ferramentas básicas) com ênfase em clareza de feedback, estabilidade de save/load e UX robusta em diferentes modos de input e resize. Os pilares são ritmo curto, progressão tangível e controles estáveis; tudo o que for além (NPCs, combate, crafting avançado) fica para depois do MVP.
