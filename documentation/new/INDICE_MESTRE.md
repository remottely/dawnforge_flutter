# 📚 Índice Mestre - Documentação Técnica MVP

> **Última atualização:** 14/11/2025
>
> **Status:** Documentação completa para MVP
>
> **Total de fases:** 4 fases principais, 9 sub-fases, 42 prompts

---

## 🎯 Visão Geral

Este índice organiza toda a documentação técnica para implementação do MVP do **Darkness Dungeon**. Cada documento segue o padrão estabelecido em `FASE_1_1_SAVE_LOAD_SYSTEM.md` e contém prompts detalhados, checklists e critérios de aceitação.

---

## 📋 Estrutura da Documentação

### 🔵 FASE 1: Fundação e Persistência (CRÍTICO)

#### 1.1 - Sistema de Save/Load Base

**Arquivo:** `FASE_1_1_SAVE_LOAD_SYSTEM.md`
**Status:** ✅ Completo (3/5 prompts executados)
**Tempo estimado:** 2-3 dias
**Dependências:** Nenhuma

**Conteúdo:**

- PROMPT 1: SaveRepository (Interface + Implementações) ✅
- PROMPT 2: SaveData Model (Serialização + Versionamento) ✅
- PROMPT 3: SaveManager (Singleton + Orquestração) ✅
- PROMPT 4: Criar Testes Unitários
- PROMPT 5: Integração e Validação End-to-End

**O que foi implementado:**

- SaveRepository com factory multiplataforma (Web/Native)
- SaveData model com versionamento e migração
- SaveManager singleton com auto-save e metadata
- Zero erros de compilação

---

#### 1.2 - Managers de Estado Global

**Arquivo:** `FASE_1_2_MANAGERS_ESTADO_GLOBAL.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 2-3 dias
**Dependências:** Save/Load (1.1)

**Conteúdo:**

- PROMPT 1: Criar WorldStateManager + Enums
- PROMPT 2: Criar TimeManager + Callbacks
- PROMPT 3: Criar PlayerProgressManager
- PROMPT 4: Criar Testes Unitários dos Managers
- PROMPT 5: Integração com SaveManager

**Componentes:**

- WorldStateManager: Estado do mundo (dia, estação, mapas)
- TimeManager: Ciclo temporal (dia/noite)
- PlayerProgressManager: Conquistas e flags

---

#### 1.3 - Integração Save ↔ Player

**Arquivo:** `FASE_1_3_INTEGRACAO_SAVE_PLAYER.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 1-2 dias
**Dependências:** Save/Load (1.1), Managers (1.2), PlayerModel existente

**Conteúdo:**

- PROMPT 1: Adicionar Serialização ao PlayerModel
- PROMPT 2: Criar PlayerSaveAdapter
- PROMPT 3: Criar Testes de Integração Player ↔ Save
- PROMPT 4: Integrar Auto-Save no Game Loop
- PROMPT 5: Documentação e Exemplos de Uso

**Componentes:**

- Serialização de PlayerModel/Attributes/Stats/Equipment
- PlayerSaveAdapter (conversão Player ↔ SaveData)
- Auto-save periódico integrado

---

### 🟢 FASE 2: Sistemas de Gameplay (CRÍTICO)

#### 2.1 - Sistema de Inventário

**Arquivo:** `FASE_2_1_SISTEMA_INVENTARIO.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 3-4 dias
**Dependências:** Save/Load (1.1-1.3)

**Conteúdo:**

- PROMPT 1: Criar Modelos Base do Inventário
- PROMPT 2: Criar Tipos Concretos de Itens
- PROMPT 3: Criar ItemFactory e Database
- PROMPT 4: Criar InventoryManager
- PROMPT 5: Criar EquipmentManager
- PROMPT 6: Criar Testes e Integração

**Componentes:**

- Item (abstract base), ItemType, ItemRarity
- WeaponItem, ToolItem, ConsumableItem, MaterialItem, SeedItem
- InventoryManager (30 slots, empilhamento)
- EquipmentManager (slots de equipamento)
- ItemFactory + items_database.json

---

#### 2.2 - Sistema de Agricultura

**Arquivo:** `FASE_2_2_SISTEMA_AGRICULTURA.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 3-4 dias
**Dependências:** Inventário (2.1), WorldState (1.2), TimeManager (1.2)

**Conteúdo:**

- PROMPT 1: Criar Modelos Base da Fazenda
- PROMPT 2: Criar CropDatabase
- PROMPT 3: Criar FarmManager
- PROMPT 4: Criar Testes e Integração
- PROMPT 5: Criar Renderização Visual

**Componentes:**

- Crop, FarmTile, SoilState, CropStage
- CropDatabase + crops_database.json
- FarmManager (plantar, regar, colher)
- FarmRenderer (visualização com Bonfire)

---

### 🔴 FASE 3: Combate e IA (CRÍTICO)

#### 3.1 - Sistema de Combate Base

**Arquivo:** `FASE_3_1_SISTEMA_COMBATE_BASE.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 4-5 dias
**Dependências:** Inventário (2.1), EquipmentManager (2.1)

**Conteúdo:**

- PROMPT 1: Criar Modelos Base de Combate
- PROMPT 2: Criar DamageCalculator
- PROMPT 3: Criar Modelos de Inimigos
- PROMPT 4: Criar EnemyFactory e Database
- PROMPT 5: Criar CombatManager
- PROMPT 6: Criar Testes

**Componentes:**

- CombatStats, HitResult, DamageType
- DamageCalculator (fórmulas de dano)
- Enemy, EnemyType, EnemyAIState
- EnemyFactory + enemies_database.json
- CombatManager (player vs enemy)

---

#### 3.2 - IA de Inimigos

**Arquivo:** `FASE_3_2_IA_INIMIGOS.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 2-3 dias
**Dependências:** Combate Base (3.1)

**Conteúdo:**

- PROMPT 1: Criar EnemyAIController
- PROMPT 2: Criar Behavior Classes
- PROMPT 3: Criar Pathfinding Simples (opcional)
- PROMPT 4: Integrar IA com Bonfire Components
- PROMPT 5: Criar Testes de IA

**Componentes:**

- EnemyAIController (gerenciamento de estados)
- IdleBehavior, PatrolBehavior, ChaseBehavior, AttackBehavior, FleeBehavior
- SimplePathfinding (opcional)
- EnemyComponent (integração Bonfire)

---

### 🟡 FASE 4: Interface e Polimento (CRÍTICO)

#### 4.1 - Sistema de UI e HUD

**Arquivo:** `FASE_4_1_SISTEMA_UI_HUD.md`
**Status:** 📄 Pronto para execução
**Tempo estimado:** 4-5 dias
**Dependências:** Todas as fases anteriores (1.1-3.2)

**Conteúdo:**

- PROMPT 1: Criar HUD Overlay Principal
- PROMPT 2: Criar Componentes de Barras
- PROMPT 3: Criar Hotbar
- PROMPT 4: Criar Tela de Inventário
- PROMPT 5: Criar Menus (Main, Pause, Settings)
- PROMPT 6: Criar Widgets Reutilizáveis

**Componentes:**

- HUDOverlay (HP, stamina, hotbar, minimapa)
- HealthBar, StaminaBar, ProgressBar
- Hotbar (8 slots com atalhos)
- InventoryScreen (grid 6x5, equipment panel)
- MainMenu, PauseMenu, SettingsMenu
- CustomButton, DialogBox, ItemTooltip

---

## 📊 Estatísticas do Projeto

### Por Fase

| Fase         | Sub-fases | Prompts | Dias Est. | Status  | Prioridade |
| ------------ | --------- | ------- | --------- | ------- | ---------- |
| 1 - Fundação | 3         | 15      | 5-8       | 60% ✅  | 🔴 CRÍTICO |
| 2 - Gameplay | 2         | 11      | 6-8       | 0% 📄   | 🔴 CRÍTICO |
| 3 - Combate  | 2         | 11      | 6-8       | 0% 📄   | 🔴 CRÍTICO |
| 4 - UI       | 1         | 6       | 4-5       | 0% 📄   | 🔴 CRÍTICO |
| **TOTAL**    | **8**     | **43**  | **21-29** | **18%** | -          |

### Progresso Detalhado

**Concluído:**

- ✅ FASE 1.1 PROMPT 1: SaveRepository
- ✅ FASE 1.1 PROMPT 2: SaveData Model
- ✅ FASE 1.1 PROMPT 3: SaveManager

**Em Progresso:**

- 🔄 FASE 1.1 PROMPT 4: Testes Unitários (Próximo)

**Aguardando:**

- ⏭️ FASE 1.1 PROMPT 5: Integração E2E
- ⏭️ FASE 1.2 (5 prompts)
- ⏭️ FASE 1.3 (5 prompts)
- ⏭️ FASE 2.1 (6 prompts)
- ⏭️ FASE 2.2 (5 prompts)
- ⏭️ FASE 3.1 (6 prompts)
- ⏭️ FASE 3.2 (5 prompts)
- ⏭️ FASE 4.1 (6 prompts)

---

## 🔄 Ordem de Execução Recomendada

### Sequência Linear (Recomendada)

1. **FASE 1.1** → Save/Load Base (fundação de tudo)
2. **FASE 1.2** → Managers Globais (estado compartilhado)
3. **FASE 1.3** → Integração Save ↔ Player (persistência do player)
4. **FASE 2.1** → Sistema de Inventário (itens e equipamentos)
5. **FASE 2.2** → Sistema de Agricultura (gameplay loop)
6. **FASE 3.1** → Sistema de Combate Base (mecânicas de luta)
7. **FASE 3.2** → IA de Inimigos (comportamento de NPCs)
8. **FASE 4.1** → Sistema de UI e HUD (interface)

### Dependências Críticas

```
1.1 (Save) ──┬──> 1.2 (Managers) ──> 1.3 (Player) ──┬──> 2.1 (Inventário)
             │                                       │
             └──────────────────────────────────────┘

2.1 (Inventário) ──┬──> 2.2 (Farm) ──> 3.1 (Combate) ──> 3.2 (IA) ──> 4.1 (UI)
                   │
                   └──> 3.1 (Combate)

1.2 (TimeManager) ──> 2.2 (Farm)
1.2 (WorldState) ──> 2.2 (Farm)
```

---

## 🛠️ Como Usar Esta Documentação

### 1. Executar um Prompt

```markdown
Copie o prompt do documento relevante e envie para o Claude:

"Crie o SaveRepository completo com factory multiplataforma:

REQUISITOS:
[...copiar requisitos...]"
```

### 2. Validar Implementação

Após cada prompt, use o checklist:

```markdown
CHECKLIST DE VALIDAÇÃO:
[ ] Código compila sem erros
[ ] Testes passam (se aplicável)
[ ] Documentação completa
[ ] Zero warnings
```

### 3. Avançar para Próximo Prompt

Só avance quando:

- ✅ Checklist 100% completo
- ✅ Testes passando
- ✅ Código validado manualmente

---

## 📝 Convenções dos Documentos

### Estrutura Padrão

Todos os documentos seguem:

1. **Cabeçalho:** Objetivo, prioridade, tempo, dependências
2. **Estrutura Final:** Árvore de arquivos
3. **Prompts:** 5-6 prompts detalhados
4. **Checklist:** Validação de conclusão
5. **Troubleshooting:** Problemas comuns

### Símbolos

- ✅ Concluído
- 🔄 Em progresso
- ⏭️ Aguardando
- 📄 Pronto para execução
- 🔴 CRÍTICO (não pode faltar no MVP)
- 🟡 IMPORTANTE (core gameplay)
- 🟢 OPCIONAL (pode ser adiado)

### Prompts

Cada prompt contém:

- **Contexto:** Por que precisamos disso
- **Requisitos:** Lista detalhada do que implementar
- **Padrão de Código:** Exemplo completo
- **Checklist:** Validação específica
- **Critérios de Aceitação:** Como saber que está pronto

---

## 🎯 Metas de MVP

### Sistemas Essenciais (Devem estar 100%)

- [x] Save/Load multiplataforma ✅ (60%)
- [ ] Managers de estado global
- [ ] Serialização de player
- [ ] Sistema de inventário
- [ ] Sistema de agricultura
- [ ] Sistema de combate
- [ ] IA de inimigos
- [ ] UI/HUD completa

### Funcionalidades MVP

- [ ] Salvar/carregar jogo
- [ ] Inventário com 30 slots
- [ ] Equipar armas/ferramentas
- [ ] Plantar e colher crops
- [ ] Combater inimigos
- [ ] Ciclo dia/noite
- [ ] Mudança de estações
- [ ] HUD com HP/Stamina
- [ ] Menu principal funcional

### Critérios de Qualidade

- [ ] Zero crashes
- [ ] 60 FPS constante
- [ ] Saves não corrompem
- [ ] Cobertura de testes >= 80%
- [ ] Documentação completa

---

## 📞 Referências Rápidas

### Arquivos Principais

- `MVP_ACTION_PLAN.md` - Plano mestre original
- `FASE_1_1_SAVE_LOAD_SYSTEM.md` - Template padrão

### Estrutura de Pastas

```
documentation/
├── MVP_ACTION_PLAN.md           (Plano mestre)
├── INDICE_MESTRE.md             (Este arquivo)
├── FASE_1_1_SAVE_LOAD_SYSTEM.md
├── FASE_1_2_MANAGERS_ESTADO_GLOBAL.md
├── FASE_1_3_INTEGRACAO_SAVE_PLAYER.md
├── FASE_2_1_SISTEMA_INVENTARIO.md
├── FASE_2_2_SISTEMA_AGRICULTURA.md
├── FASE_3_1_SISTEMA_COMBATE_BASE.md
├── FASE_3_2_IA_INIMIGOS.md
└── FASE_4_1_SISTEMA_UI_HUD.md
```

### Comandos Úteis

```bash
# Validar testes
flutter test

# Analisar código
flutter analyze

# Rodar jogo
flutter run

# Cobertura de testes
flutter test --coverage
```

---

## 🎉 Conclusão

Esta documentação fornece um roadmap completo para implementação do MVP. Seguindo os prompts sequencialmente e validando cada etapa, você construirá um jogo funcional e robusto.

**Próximo passo:** Execute `FASE_1_1_SAVE_LOAD_SYSTEM.md` PROMPT 4 (Testes Unitários).

---

**Última revisão:** 14/11/2025
**Versão:** 1.0.0
**Autor:** Planejamento técnico para Darkness Dungeon MVP
