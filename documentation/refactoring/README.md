# Plano de Refatoração — Dawnforge

Plano de evolução do projeto de "código de 6 anos que funciona" para "código de 6 anos que funciona **e** aguenta mais 6".

**Regra que governa tudo:** nenhuma refatoração acontece sem teste cobrindo o comportamento anterior. Por isso a Fase 1 e 2 são inteiramente sobre testes.

---

## Documentos

| # | Documento | Conteúdo |
|---|---|---|
| 00 | [00-diagnostico.md](00-diagnostico.md) | Estado atual medido, com evidências |
| 01 | [01-fase-1-fundacao-de-testes.md](01-fase-1-fundacao-de-testes.md) | Infra de teste + higiene mecânica |
| 02 | [02-fase-2-cobertura-de-dominio.md](02-fase-2-cobertura-de-dominio.md) | Cobrir domínio, use cases, managers |
| 03 | [03-fase-3-refatoracao-estrutural.md](03-fase-3-refatoracao-estrutural.md) | Dívidas estruturais grandes |
| 04 | [04-fase-4-padronizacao.md](04-fase-4-padronizacao.md) | Nomenclatura, lint zero, migração de save |
| — | [adr/](adr/) | Decisões arquiteturais registradas |
| — | [PROGRESS.md](PROGRESS.md) | Rastreamento vivo |

---

## Fases

```
Fase 1 ─ Fundação de testes        ┐
Fase 2 ─ Cobertura de domínio      ┘ rede de segurança
Fase 3 ─ Refatoração estrutural    ┐
Fase 4 ─ Padronização              ┘ pagar a dívida
```

| Fase | Objetivo | Critério de saída |
|---|---|---|
| **1** | Suíte executável e confiável; ruído mecânico eliminado | `flutter test` verde, `tool/coverage.sh` funcionando, `flutter analyze` < 160 |
| **2** | Domínio e orquestração cobertos | cobertura global ≥ 80%, entities ≥ 95% |
| **3** | Dívidas estruturais pagas | save unificado, herança de player substituída por behaviors, design system único |
| **4** | Convenções uniformes | `flutter analyze` = 0, `analysis_options.yaml` só com `include` |

Fases 1 e 2 podem correr em paralelo por módulo. Fase 3 **não começa** antes do módulo alvo estar coberto.

---

## Como trabalhar dentro do plano

1. Pegue uma tarefa do arquivo da fase atual.
2. Escreva o teste primeiro se ainda não existir.
3. Faça a mudança.
4. `dart format . && flutter analyze && flutter test`.
5. Commit no padrão `<version>; <type>: <description>`.
6. Marque a tarefa em [PROGRESS.md](PROGRESS.md).

**Uma tarefa por commit.** Refatoração mecânica em massa (`dart fix`) vai sozinha num commit, sem nenhuma mudança semântica junto — senão o diff fica irrevisável.

---

## Antipadrões a evitar durante a execução

- ❌ Refatorar e "aproveitar para corrigir esse bug" no mesmo commit.
- ❌ Criar abstração porque "vai que precisa" (YAGNI).
- ❌ Comentar teste que ficou vermelho.
- ❌ Renomear coisa que aparece em save serializado sem migração + teste de round-trip.
- ❌ Mover arquivo e mudar conteúdo no mesmo commit — o git perde o rastro do rename.
