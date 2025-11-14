# Prompt Melhorado

Preciso criar o **planejamento de arquitetura do sistema de gestão de dados** para meu jogo (clone de Stardew Valley em Flutter com Bonfire), considerando toda a complexidade necessária para manipular dados em memória e persistidos em disco.

## Contexto do Projeto

- **Stack**: Flutter + Bonfire
- **Plataformas-alvo**: Windows, Mac, Linux, Web, Android, iOS (single codebase)
- **Modo**: Single-player, offline
- **Estado atual**: Projeto em desenvolvimento inicial, faltando implementar: sistema de farm, inventário, ciclo dia/noite, estações do ano, pesca, inimigos, decorações, transição de mapas com persistência de estado

## Objetivos do Planejamento

### 1. Sistema de Gestão de Dados

Preciso de uma arquitetura que gerencie:

- **Dados em memória** (estado runtime do jogo)
- **Dados persistidos** (salvamento em disco)
- **Performance** (otimizado para gameplay fluido)
- **Compatibilidade multiplataforma** (especialmente Web, que pode ter limitações)

### 2. Princípios Arquiteturais

- **KISS** (Keep It Simple, Stupid)
- **DRY** (Don't Repeat Yourself)
- **Respeitar a arquitetura atual** do projeto
- **Facilidade de manutenção**
- **Profissionalismo** sem over-engineering

### 3. Escopo MVP

O planejamento deve focar em entregar **funcional, robusto e rápido** para MVP, com:

- 1 item de farm
- 1 player
- 1 decoração
- 2 mapas (com transição e persistência inteligente de estado)
- 1 inimigo
- Sistema de inventário básico
- Sistema de salvamento funcional

Porém, **a arquitetura deve suportar expansão futura** para o jogo completo.

## O Que Preciso Nesta Resposta

### Visão Geral e Decisões Estratégicas

Quero que você analise o contexto e forneça:

1. **Arquitetura de Gestão de Estado**

   - Como estruturar a separação entre estado em memória vs. persistido?
   - Qual pattern de gerenciamento de estado é mais adequado (Provider, Bloc, Riverpod, GetX, MobX)?
   - Como garantir performance sem sacrificar organização?

2. **Sistema de Salvamento**

   - Qual estratégia de serialização/desserialização (JSON, SQLite, Hive, SharedPreferences, outro)?
   - Como lidar com limitações do Web (LocalStorage, IndexedDB)?
   - Quando e como salvar (auto-save, manual, checkpoints)?
   - Estrutura de versionamento de saves (para expansões futuras)?

3. **Arquitetura de Dados do Jogo**

   - Como organizar entidades (Player, Items, Enemies, Map, Decorations, Farm)?
   - Separação de responsabilidades (Models, Services, Repositories, Controllers)?
   - Como persistir estados de múltiplos mapas sem carregar tudo em memória?

4. **Roadmap de Implementação**

   - Ordem lógica de desenvolvimento das funcionalidades faltantes
   - Priorização focada no MVP
   - Dependências entre sistemas (ex: inventory precisa vir antes de farm?)

5. **Estratégia para Funcionalidades Faltantes**
   - Farm system
   - Inventory system
   - Ciclo dia/noite
   - Estações do ano
   - Pesca
   - Sistema de combate (inimigos)
   - Decorações
   - Transição e persistência de mapas

## Formato da Resposta

Para cada decisão arquitetural, explique:

- **O quê**: Qual a solução proposta
- **Por quê**: Justificativa técnica (performance, manutenibilidade, compatibilidade)
- **Trade-offs**: Vantagens e limitações
- **Adequação ao MVP**: Como isso se encaixa na entrega rápida

## Entregável Final

Com sua resposta, vou criar um **documento de arquitetura** em `documentation/` que guiará todo o desenvolvimento do início ao fim, partindo do ponto atual do projeto.

---

**Importante**: Neste momento, **NÃO implemente código**. Quero apenas a **visão estratégica de alto nível** e as **justificativas das decisões arquiteturais**. Os detalhes de implementação virão depois, no documento de arquitetura.
