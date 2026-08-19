# ADR-0001 — Arquitetura base: flat por responsabilidade, singleton + ValueNotifier

- **Status:** aceito
- **Data:** 2025 (retroativo — formalizado em 2026-08-19)

## Contexto

O projeto é um jogo estilo Stardew Valley mantido por **um** desenvolvedor, com horizonte de anos. Foram avaliadas 12 dimensões arquiteturais (estrutura, use cases, estado, dados, persistência, UI, testes, DI, nomenclatura, eventos, constantes, factories), cada uma com 3 opções — o estudo completo, com prós e contras de cada alternativa, está preservado em [0000-estudo-de-opcoes-arquiteturais.md](0000-estudo-de-opcoes-arquiteturais.md).

É de lá que vêm os códigos `A2`, `B1`, `C1`, `D2`, `E2`, `F2`, `G2`, `H1`, `I2`, `J3`, `K1`, `L2` que aparecem em comentários por todo o código.

Restrições que pesaram:

- Um mantenedor. Boilerplate cobra juros todo dia.
- Single-player offline. Sem concorrência, sem sincronização de rede, sem múltiplas fontes de verdade.
- Flutter/Bonfire já são a base — brigar com o framework custa caro.
- Estado do jogo é global por natureza: inventário, fazenda e calendário são acessados de dezenas de pontos.

## Decisão

| Dimensão | Escolha |
|---|---|
| Estrutura | Flat por responsabilidade dentro da feature (`entities/`, `usecases/`, `managers/`, `services/`) — **não** `domain/data/presentation` |
| UseCases | Classes concretas com `call()`, sem interface base |
| Estado | Manager singleton (`X.instance`) + `ValueNotifier` |
| Entidades | Entity imutável com `toJson`/`fromJson` embutido, sem camada `Model` separada |
| Save/Load | UseCase dedicado e versionado (`SaveXUseCase` / `LoadXUseCase`) |
| UI | ViewModel quando há lógica; `ValueNotifier` direto quando é só exibir |
| Testes | `mocktail`; instância real quando barato |
| DI | GetIt para UseCases/ViewModels; `.instance` para Managers/Services |
| Nomenclatura | Manager = estado, UseCase = operação, Service = stateless |
| Eventos cross-módulo | `ValueNotifier` público no manager de origem |
| Constantes | Locais à feature |

## Consequências

**Positivas.**
- Poucos arquivos por operação. Adicionar uma ação de jogo = 1 use case + 1 teste.
- `ValueNotifier` é nativo do Flutter — sem dependência extra, sem lifecycle de stream para gerenciar.
- Managers acessíveis de qualquer lugar, que é o que um jogo single-player realmente precisa.
- Entities puras e imutáveis são triviais de testar.

**Negativas — aceitas conscientemente.**
- Singleton dificulta isolamento em teste. **Mitigação obrigatória:** todo manager expõe `reset()`, chamado no `setUp()`.
- Estado global permite acoplamento acidental. **Mitigação:** regra de dependência do `CLAUDE.md §2.1`; feature só fala com feature via UseCase ou notifier público.
- Entity com serialização mistura domínio e persistência. Aceito: a alternativa (Entity + Model + mapper) triplica arquivos sem benefício real aqui.

**Proibições decorrentes.**
- ❌ Criar `domain/`, `data/`, `presentation/` dentro de feature.
- ❌ `getIt<XManager>()` — managers são `.instance`. Já quebrou produção (`1.106.15+1`).
- ❌ Event bus global.
- ❌ Interface para use case com uma implementação só.

## Alternativas consideradas

- **Clean Architecture completa** (`domain`/`data`/`presentation` + repositories + mappers). Descartada: número de arquivos por feature inviável para dev solo, e as fronteiras que ela protege (troca de fonte de dados, múltiplos frontends) não existem aqui.
- **Bloc/Cubit.** Descartado: boilerplate de eventos/estados não paga num jogo onde a UI é fina e o estado vive no game loop.
- **Streams em vez de `ValueNotifier`.** Descartado: mais poderoso, mas exige gerenciar lifecycle; `ValueNotifier` cobre o caso real (último valor + notificação).
- **Repository + Manager de orquestração.** Descartado: sem backend, `Repository` viraria um wrapper de `Map`.
