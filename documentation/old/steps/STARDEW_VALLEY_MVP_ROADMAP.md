# 🌾 Stardew Valley Clone - MVP Roadmap

**Objetivo:** Transformar o Darkness Dungeon em um clone simplificado de Stardew Valley, mantendo a arquitetura existente e focando na sustentabilidade de longo prazo para um único desenvolvedor.

## 📋 Visão Geral do MVP

### 🎯 Filosofia do Projeto

- **Simplicidade First**: Cada feature deve ser a versão mais simples possível
- **Reutilização Máxima**: Aproveitar ao máximo o código e estrutura existente
- **Escalabilidade Gradual**: Permitir expansão incremental sem refatorações massivas
- **Single Developer Friendly**: Arquitetura compreensível e mantível por uma pessoa

### 🔄 Aproveitamento da Base Existente

Todas as funcionalidades atuais do Darkness Dungeon (combate, KnightCharacter, inimigos, mapas, etc.) serão mantidas integralmente. As novas funcionalidades de farming, social, economia e progressão serão adicionadas como extensões/modos ao jogo existente, sem remover ou alterar o funcionamento do sistema de combate ou qualquer funcionalidade já implementada. O objetivo é transformar o jogo em um Stardew Valley MVP, mas preservando o core dungeon/castle gameplay e combat system.
**Assets e Sistemas Reutilizáveis:**

**Transformações Necessárias:**

**Novas Funcionalidades Adicionadas:**

- 🔄 Sistema de farming (adicionado ao lado do combate)
- 🔄 Sistema de interação agrícola (ferramentas, tiles, crops)
- 🔄 NPCs sociais (adicionados além dos NPCs de combate)
- 🔄 Decorações agrícolas (adicionadas além das decorações de dungeon)

---

## 🗺️ Roadmap em Etapas

### 📦 **ETAPA 1: FUNDAÇÃO AGRÍCOLA (2-3 semanas)**

#### 1.1 Transformação do Core Player

- Remover sistema de combate e stamina
- Adaptar movimento para farming (velocidade, animações)
- Implementar sistema básico de tools (hand, watering can, hoe)
- Criar animações básicas de farming

#### 1.2 Sistema de Farm Tiles

- Converter sistema de tiles para grid de farming
- Implementar estados básicos: soil, watered, planted, grown
- Sistema de plantio simples (1 tipo de crop para MVP)
- Visual feedback para tiles interativos

#### 1.3 Game Loop Básico

- Remover sistema de vida/morte
- Implementar ciclo dia/noite básico
- Sistema de energia diária (replace stamina)
- Save/load de progresso básico

---

### 🌱 **ETAPA 2: SISTEMA DE FARMING (2 semanas)**

#### 2.1 Crops e Growth System

- 1-2 tipos de plantas básicas (potato, parsnip)
- Sistema de crescimento por dias
- Harvest system com items básicos
- Watering requirement system

#### 2.2 Tools e Inventory

- 3 tools básicas: hand, hoe, watering can
- Inventory system básico (grid 12 slots)
- Item stacking simples
- Tool durability opcional (pode ser infinita no MVP)

#### 2.3 Basic Economy

- Shipping box para vender items
- Sistema de gold básico
- Preços fixos para crops
- Shop simples para seeds

---

### 🏠 **ETAPA 3: ESTRUTURAS BÁSICAS (2 semanas)**

#### 3.1 Farm Buildings

- Casa do player (interior simples)
- Shipping container
- Well/water source
- Chest para storage básico

#### 3.2 Map Layout

- Farm area principal
- Town area básica
- Path connections
- Transition system entre areas

#### 3.3 Basic NPCs

- 2-3 NPCs essenciais: Shop keeper, Mayor, Friend
- Dialogue system básico (reutilizar TalkDialog)
- Friendship system ultra-simples (3 levels)
- Daily NPC routines básicas

---

### ⏰ **ETAPA 4: PROGRESSÃO E QUALIDADE DE VIDA (1-2 semanas)**

#### 4.1 Progression Systems

- Player level system básico
- Skill system simples (Farming skill apenas)
- Unlock system para tools/areas
- Achievement system básico

#### 4.2 Save System e Settings

- Persistent save data
- Settings menu básico
- Multiple save slots (3 slots)
- Backup/restore functionality

#### 4.3 Polish e UX

- Tutorial básico
- Help system in-game
- Performance optimization
- Bug fixing e stability

---

## 🎮 Gameplay Core Loop (MVP)

### 📅 Ciclo Diário Básico

1. **Manhã**: Player acorda, energia restaurada
2. **Atividades**: Farm → Water → Plant → Harvest → Sell
3. **Social**: Talk com NPCs (1-2 conversas por dia)
4. **Noite**: Auto-sleep quando energia acaba
5. **Progressão**: Gold → Buy seeds → Expand farm

### 🎯 Objetivos do Player (MVP)

- **Curto Prazo**: Plantar e colher primeiro crop
- **Médio Prazo**: Unlock all basic tools e NPCs
- **Longo Prazo**: Maximize daily income e friendship levels

---

## 🔧 Arquitetura e Design Decisions

### 📁 Estrutura de Pastas Sugerida

```
lib/
├── gameplay/
│   ├── characters/           # KnightCharacter
│   ├── farming/          # New: crops, soil, tools
│   ├── world/            # NPCs, buildings, areas
│   ├── economy/          # New: shop, inventory, money
│   ├── progression/      # New: levels, skills
│   └── core/            # Existing managers (adapted)
├── presentation/
│   ├── screens/         # Menu, Farm, Inventory screens
│   ├── design_system/   # Existing UI components
│   └── widgets/         # Farm-specific widgets
└── shared/              # Constants, utils, models
```

### 🎨 Visual Style Direction

- **Manter**: Pixel art style existente
- **Adaptar**: Color palette para farm theme (greens, browns, blues)
- **Adicionar**: Farm-specific sprites (crops, tools, animals)
- **Simplificar**: UI para farm-focused activities

### 📱 Platform e Performance

- **Target**: Mobile-first (reutilizar controles existentes)
- **Performance**: 60fps steady, smooth scrolling
- **Memory**: Efficient asset loading para farm areas
- **Storage**: Local save files, cloud backup opcional

---

## 🚀 Success Metrics para MVP

### 📊 Technical Metrics

- **Performance**: 60fps consistente
- **Memory**: <200MB usage típico
- **Load Times**: <3s para enter/exit areas
- **Save Size**: <10MB per save file

### 🎮 Gameplay Metrics

- **Learning Curve**: New player consegue plantar first crop em <5 min
- **Engagement**: Session length médio >15 min
- **Retention**: Player return rate >70% depois primeiro dia
- **Progression**: Player consegue unlock all basic content em <3 horas

### 🔧 Development Metrics

- **Code Quality**: Maintain current test coverage >90%
- **Documentation**: All new systems documented
- **Maintainability**: Single developer consegue add new feature em <1 week
- **Stability**: <1 crash per 10 hours gameplay

---

## ⚠️ Scope Limitations (MVP)

### ❌ Features EXCLUÍDAS do MVP

- **Seasonal System**: Apenas "perpetual spring"
- **Weather System**: Sempre sunny
- **Multiplayer**: Single player apenas
- **Advanced Crafting**: Apenas basic tool upgrades
- **Mining/Combat**: Focus 100% em farming
- **Marriage/Relationships**: Apenas friendship básica
- **Festivals/Events**: Excluded para simplicidade
- **Advanced Animals**: Apenas plantas no MVP

### 🔄 Features para Versões Futuras

- Seasonal changes e weather
- Mining areas (reutilizar combat system existente)
- Advanced NPCs e marriage system
- Animal farming
- Advanced crafting e building
- Festivals e special events
- Multiplayer co-op

---

## 📝 Documentation Strategy

### 📋 Documentos Necessários (próximos passos)

1. **Technical Architecture Document**: Detailed system designs
2. **Asset Requirements Document**: Sprites, audio, maps needed
3. **Game Design Document**: Detailed mechanics e balance
4. **Migration Guide**: Step-by-step transformation process
5. **Testing Strategy**: QA approach para cada etapa
6. **Release Plan**: Deployment e distribution strategy

### 🎯 Implementation Philosophy

- **Iterative Development**: Each etapa deve ser playable
- **Continuous Testing**: Automated tests para cada new system
- **User Feedback**: Early feedback loop desde primeira etapa
- **Documentation-Driven**: Document before implement
- **Refactor-Friendly**: Code structure que suporta future expansion

---

## 🏁 Conclusão

Este MVP roadmap transforma o Darkness Dungeon em um Stardew Valley clone mantendo a filosofia de **simplicidade e sustentabilidade**. O foco é criar uma base sólida que permita expansão gradual sem comprometer a maintainability para um único desenvolvedor.

**Próximo Passo**: Escolher uma etapa específica para detailed planning e implementation.

**Tempo Estimado Total**: 7-10 semanas para MVP completo funcional.

**Resultado Esperado**: Um farming game simples, polido e expandível que demonstra todas as mechanics core de Stardew Valley de forma acessível.
