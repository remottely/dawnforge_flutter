# Prompts para IA implementar colheita recorrente (crops e árvores)

Use estes prompts para a IA executar a implementação completa, sem intervenção humana. Respostas devem incluir os diffs nos arquivos citados.

---

1) **Entender estado atual**
- Leia [lib/gameplay/world/entities/objects/farm/crop_entity.dart], [lib/gameplay/world/entities/objects/farm/crop_stage_type.dart], [lib/gameplay/world/entities/objects/farm/farm_object.dart], [lib/gameplay/farm/managers/farm_manager.dart] e descreva o fluxo atual de crescimento/colheita/avanço diário e onde o solo muda de estado.

2) **Adicionar config de regrowth no modelo**
- Em `CropEntity`, adicione `bool regrows`, `int regrowStageRollback = 2`, `int regrowStepDays = 2`, `bool requireWaterForRegrowth` (crops usam true; árvores usam false). Atualize `toJson()`/`fromJson()` com defaults.

3) **Preservar solo na colheita**
- Em `FarmObject.harvest()` ([lib/gameplay/world/entities/objects/farm/farm_object.dart]), não altere `soilState` nem `lastWateredDay`. Se `!crop.regrows`, remova a crop. Se `regrows`, aplique rollback e mantenha a crop no tile.

4) **Rollback de estágio**
- Em `CropEntity`, implemente `regrowAfterHarvest()`: se `!regrows`, retorne null; caso contrário, regrida 2 estágios (mínimo `CropStageType.sprout`), zere contadores de dias de estágio e marque modo de recrescimento se necessário.

5) **Avanço diário com passo 2d no recrescimento**
- Refatore `CropEntity.advanceDay()` para contar dias no estágio. No recrescimento use `regrowStepDays = 2`. Crops exigem água (`requireWaterForRegrowth = true`), árvores não. Crescimento inicial mantém a necessidade de água atual para crops.

6) **Integração em FarmObject.advanceDay()**
- Use o novo `advanceDay` da crop. Crops só avançam se watered no dia; depois de avançar, consumir a água (voltar para tilled). Árvores avançam diariamente sem água. Não mude solo na colheita.

7) **Aplicar colheita recorrente**
- Em `FarmObject.harvest()`, se `regrows`, mantenha a crop com rollback; se não, remova. Solo e estado de água intactos.

8) **Configurar DB/fábricas**
- Atualize definições/fábricas de crops para marcar quais recrescem (`regrows=true`) e quais não. Ex.: berries e árvores frutíferas recrescem; grãos simples não.

9) **UI/derivados**
- Verifique usos de `isReadyToHarvest`, `canHarvest`, `growthProgress` e ajuste se necessário para refletir recrescimento.

10) **Testes**
- Liste e execute cenários: (a) crop que recresce permanece no tile, volta 2 estágios e exige água a cada estágio de 2 dias; (b) crop que não recresce some; (c) árvores recrescem sem água, com rollback de 2 estágios; (d) solo e água não mudam na colheita.
