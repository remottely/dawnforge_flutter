# Prompts para implementar colheita recorrente (crops e árvores)

Use estes prompts em ordem para orientar a refatoração. Mantenha as respostas curtas, diretas e com referências aos arquivos citados.

---

1) **Mapear estados atuais**
- Prompt: "Leia a lógica de crops e farm: [lib/gameplay/world/entities/objects/farm/crop_entity.dart], [lib/gameplay/world/entities/objects/farm/crop_stage_type.dart], [lib/gameplay/world/entities/objects/farm/farm_object.dart], [lib/gameplay/farm/managers/farm_manager.dart], e resuma como o crescimento, colheita e avanço diário funcionam hoje. Liste onde o solo muda de estado na colheita e no avanço de dia."

2) **Definir configuração de regrowth por crop**
- Prompt: "No modelo `CropEntity`, adicione campos de config para recrescimento: `bool regrows`, `int regrowStageRollback = 2`, `int regrowStepDays = 2`, `bool requireWaterForRegrowth = true` (crops); para árvores, `requireWaterForRegrowth = false`. Ajuste serialização/deserialização e fábricas de crops para preencher esses campos."
- Prompt: "Garanta que crops que não recrescem mantenham o comportamento atual (removidos ao colher)."

3) **Regras de solo (não reseta na colheita)**
- Prompt: "Atualize `FarmObject.harvest()` em [lib/gameplay/world/entities/objects/farm/farm_object.dart] para não alterar `soilState` nem `lastWateredDay` ao colher. O solo permanece exatamente como estava. Somente atualize a crop (ou removê-la se não recresce)."

4) **Rollback de estágio na colheita**
- Prompt: "Implemente em `CropEntity` um método `regrowAfterHarvest()` que: (a) se `regrows` for falso, devolve null/indica remoção; (b) regride 2 estágios a partir do estágio atual, parando no mínimo em `CropStageType.sprout`; (c) zera contadores de dias para o estágio; (d) marca que está em modo de recrescimento (se precisar de flag)."

5) **Avanço diário com passos de 2 dias para recrescimento**
- Prompt: "Refatore `CropEntity.advanceDay()` para usar contadores por estágio: incremente `daysInCurrentStage`; se atingir o limite, avance para o próximo estágio. Durante recrescimento, use `regrowStepDays = 2` (crops) e ainda exigir água para crops (`requireWaterForRegrowth = true`), mas árvores não exigem água. No crescimento inicial, mantenha a regra atual de necessidade de água para crops."

6) **Integração em FarmObject.advanceDay()**
- Prompt: "Em `FarmObject.advanceDay(int dayEnded)`, use o novo `advanceDay` da crop. Para crops: só avançar se estiver watered no dia; após avanço, se estava watered, consumir a água (voltar para tilled). Para árvores: avançar diariamente sem depender de água. Não mexer no solo na colheita."

7) **Colheita recorrente**
- Prompt: "Em `FarmObject.harvest()`, se `crop.regrows` for true, aplique `regrowAfterHarvest()` e mantenha o crop no tile; se false, remova o crop. Solo e watered permanecem inalterados."

8) **Fábricas e bancos de dados**
- Prompt: "Atualize fábricas/DBs de crops para definir quais recrescem (`regrows=true`) e quais não (`regrows=false`). Ex.: berries, árvores frutíferas recrescem; grãos simples não."

9) **UI e estados derivados**
- Prompt: "Verifique onde `isReadyToHarvest`, `canHarvest`, `growthProgress` são usados; ajuste se necessário para considerar o recrescimento e rollback."

10) **Testes e validação manual**
- Prompt: "Liste cenários de teste: (a) colher crop que recresce e verificar que permanece no tile, volta 2 estágios e requer água nos próximos 2 dias por estágio; (b) colher crop que não recresce e verificar que some; (c) árvores: colher, permanecer no tile, regredir 2 estágios, avançar diariamente sem água; (d) confirmar que o solo não muda na colheita e água não é resetada."
