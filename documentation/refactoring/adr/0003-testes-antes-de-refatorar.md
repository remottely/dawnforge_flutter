# ADR-0003 — Testes antes de refatorar

- **Status:** aceito
- **Data:** 2026-08-19

## Contexto

Diagnóstico de 2026-08-19 (`00-diagnostico.md`):

- 14 dos 19 arquivos em `test/` estavam **100% comentados** e não carregavam.
- 2 dos 5 restantes falhavam com asserções desatualizadas.
- Cobertura efetiva do domínio: **~0%**.
- `analysis_options.yaml` estava inteiramente comentado — sem linter.

A causa é rastreável: a reorganização `1.106.3+1 refactor: reorganize all app structure` quebrou os imports dos testes, e eles foram **comentados em vez de corrigidos**. Sem sinal, as ~15 refatorações seguintes (incluindo um `rollback: put back old player architecture`) rodaram sem rede.

Ao mesmo tempo, há dívidas estruturais que precisam ser pagas: três modelos de save, cadeia de herança de 6 níveis, duas enums de estação, dois design systems.

O conflito é direto: **refatorar essas áreas sem cobertura é apostar o jogo.**

## Decisão

**Nenhuma refatoração estrutural acontece antes do módulo alvo ter cobertura de teste.**

Concretamente:

1. Fases 1 e 2 do plano são inteiramente sobre testes. A Fase 3 (estrutural) só começa por módulo depois que aquele módulo está coberto.
2. Testes cobrem o comportamento **atual**, mesmo quando ele parece errado. Comportamento suspeito recebe comentário apontando para a tarefa da Fase 3 que o corrige.
3. Correção de comportamento **muda o teste junto**, no mesmo commit — e a mudança do teste é a evidência da correção.
4. Bug corrigido = teste de regressão que falha sem o fix.
5. **Nunca comentar um teste para deixar a suíte verde.** Conserte ou delete com justificativa no commit.
6. `test/` espelha `lib/` exatamente. Divergência de path foi a causa raiz do colapso anterior.

## Consequências

**Positivas.**
- Refatoração vira mecânica em vez de aposta.
- Os testes documentam regras de jogo que hoje só existem espalhadas no código (crescimento de plantação, stacking de inventário, ciclo de estações).
- Suíte rápida (domínio puro, sem engine) roda a cada save.
- Testes de invariante do catálogo pegam erro de conteúdo em segundos.

**Negativas — aceitas.**
- Duas fases inteiras sem entregar feature de jogo. É o preço de seis anos sem rede.
- Testes que documentam comportamento errado precisarão mudar. Isso é **intencional** e visível no diff.

**Proibições decorrentes.**
- ❌ Comentar teste.
- ❌ `skip:` sem justificativa no commit.
- ❌ Iniciar tarefa da Fase 3 num módulo sem cobertura.
- ❌ Refatoração e correção de bug no mesmo commit.

## Alternativas consideradas

- **Refatorar primeiro, testar o resultado.** Descartada: sem oráculo do comportamento anterior, não há como distinguir "refatorei" de "quebrei". É exatamente o que aconteceu entre `1.106` e `1.110`.
- **Testes só no código novo.** Descartada: o código novo não é o que vai ser refatorado.
- **Testes de integração/e2e no lugar de unitários.** Descartada: num jogo, e2e exige game loop, é lento e frágil. A lógica que importa já está extraída em classes puras — teste onde é barato e determinístico.
- **Reescrever do zero.** Descartada: 30k linhas funcionando valem mais que uma reescrita que nunca termina.
