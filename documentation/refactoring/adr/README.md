# ADRs — Architecture Decision Records

Registro de decisões arquiteturais. Uma decisão que muda como o código é escrito vira ADR **antes** de virar código.

## Formato

Arquivo `NNNN-titulo-em-kebab-case.md`:

```markdown
# ADR-NNNN — Título

- **Status:** proposto | aceito | substituído por ADR-XXXX | revogado
- **Data:** YYYY-MM-DD

## Contexto
O que forçou a decisão. Fatos, não opinião.

## Decisão
O que foi decidido, no imperativo.

## Consequências
O que fica melhor, o que fica pior, o que passa a ser proibido.

## Alternativas consideradas
O que foi descartado e por quê.
```

## Regras

- ADR **não se edita** depois de aceito. Mudou? Novo ADR com `Substitui ADR-NNNN`, e o antigo passa a `substituído por`.
- Só vira ADR o que é caro de reverter: estrutura, estado, persistência, fronteiras de módulo.
- Escolha de nome de variável não é ADR. Está no `CLAUDE.md`.

## Índice

| # | Título | Status |
|---|---|---|
| [0000](0000-estudo-de-opcoes-arquiteturais.md) | Estudo de opções arquiteturais (12 tópicos × 3 alternativas) | histórico — insumo do ADR-0001 |
| [0001](0001-arquitetura-base.md) | Arquitetura base: flat por responsabilidade, singleton + ValueNotifier | aceito |
| [0002](0002-catalogo-em-constantes-dart.md) | Catálogo de conteúdo em constantes Dart em vez de JSON | aceito |
| [0003](0003-testes-antes-de-refatorar.md) | Testes antes de refatorar | aceito |
| [0004](0004-composicao-de-personagem.md) | Composição por behaviors em vez de herança de player | aceito |
