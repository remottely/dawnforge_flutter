# 🎯 FASE 1.2 - Managers de Estado Global

> **Objetivo:** Implementar managers singleton para estado compartilhado do jogo
>
> **Prioridade:** 🔴 CRÍTICO (Fundação de tudo)
>
> **Tempo Estimado:** 2-3 dias
>
> **Dependências:** Sistema de Save/Load (1.1)

---

## 📋 Estrutura Final

```
lib/gameplay/core/modules/world/
├── world_state_manager.dart          ✅ Singleton, estado do mundo
├── map_state_model.dart              ✅ Estado de mapas individuais
└── season.dart                       ✅ Enum de estações

lib/gameplay/core/modules/time/
├── time_manager.dart                 ✅ Singleton, ciclo temporal
├── time_of_day.dart                  ✅ Enum de períodos
└── time_config.dart                  ✅ Constantes de duração

lib/gameplay/core/modules/player/
└── player_progress_manager.dart      ✅ Singleton, conquistas/flags

test/gameplay/core/modules/world/
└── world_state_manager_test.dart     ✅ Testes do manager

test/gameplay/core/modules/time/
└── time_manager_test.dart            ✅ Testes do manager

test/gameplay/core/modules/player/
└── player_progress_manager_test.dart ✅ Testes do manager
```

---

## 🚀 PROMPT 1: Criar WorldStateManager + Enums

### Contexto

O WorldStateManager é responsável por gerenciar o estado compartilhado do mundo do jogo: dia atual, estação, tempo, e estados de mapas ativos. Ele deve ser serializado via SaveManager.

### Prompt para o Claude

Crie o WorldStateManager completo com gerenciamento de mapas e estado do mundo:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: WorldStateManager.\_()
   - Instance estática: static final instance = WorldStateManager.\_()

2. Estado do Mundo:

   - int currentDay (dia atual do jogo, começa em 1)
   - Season currentSeason (enum: Spring, Summer, Fall, Winter)
   - TimeOfDay timeOfDay (enum: Morning, Noon, Evening, Night)
   - String? currentMapId (ID do mapa ativo)

3. Gerenciamento de Mapas:

   - Map<String, MapState> \_activeMapStates (cache de mapas ativos)
   - MapState? getMapState(String mapId)
   - void setMapState(String mapId, MapState state)
   - void unloadInactiveMaps() (remove mapas inativos da memória)

4. Serialização:

   - Map<String, dynamic> toJson()
   - void fromJson(Map<String, dynamic> json)
   - Integrar com SaveManager

5. Métodos auxiliares:
   - void advanceDay() (avança 1 dia, atualiza estação)
   - void setTimeOfDay(TimeOfDay time)
   - Season getSeasonForDay(int day) (cálculo automático: cada estação = 28 dias)

ESTRUTURA DE ARQUIVOS:
lib/gameplay/core/modules/world/
├── world_state_manager.dart
├── map_state_model.dart
└── season.dart

PADRÃO DE CÓDIGO:

- Usar 'final class' para singleton
- Documentação Dartdoc completa
- Logs com prefixo [WorldStateManager]

EXEMPLO DE JSON ESPERADO:

```json
{
  "currentDay": 15,
  "currentSeason": "spring",
  "timeOfDay": "morning",
  "currentMapId": "village_01",
  "mapStates": {
    "village_01": {
      "decorationsModified": [],
      "farmTiles": [],
      "enemiesDefeated": []
    }
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona (mesma instância)
[ ] advanceDay() atualiza dia e estação corretamente
[ ] getSeasonForDay() calcula estação (Spring: dias 1-28, Summer: 29-56, etc)
[ ] Serialização toJson/fromJson funciona
[ ] Cache de mapas funciona (get/set/unload)
[ ] Logs detalhados

### Critérios de Aceitação

- [ ] Código compila sem erros
- [ ] Singleton funcional
- [ ] Serialização completa
- [ ] Cálculo automático de estações
- [ ] Gerenciamento de mapas eficiente
- [ ] Documentação completa

---

## 🚀 PROMPT 2: Criar TimeManager + Callbacks

### Contexto

O TimeManager gerencia o ciclo de tempo do jogo (dia/noite) e dispara eventos quando o período muda. Outros sistemas podem se registrar para receber notificações.

### Prompt para o Claude

Crie o TimeManager completo com sistema de callbacks e ciclo temporal:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: TimeManager.\_()
   - Instance estática: static final instance = TimeManager.\_()

2. Ciclo Temporal:

   - double \_currentTime (tempo em segundos dentro do dia, 0-86400)
   - double \_timeScale (velocidade do tempo, default 1.0)
   - bool \_isPaused (pausa o tempo)
   - TimeOfDay currentTimeOfDay (calculado a partir de \_currentTime)

3. Callbacks:

   - List<Function(TimeOfDay)> \_onTimeOfDayChanged
   - void addTimeOfDayListener(Function(TimeOfDay) callback)
   - void removeTimeOfDayListener(Function(TimeOfDay) callback)
   - Disparar callbacks quando TimeOfDay muda

4. Métodos Públicos:

   - void update(double dt) (atualizar tempo, chamar de game loop)
   - void setTimeScale(double scale) (acelerar/desacelerar tempo)
   - void pause() / void resume()
   - void setTime(double timeInSeconds) (pular para horário específico)
   - double getProgress() (retorna 0.0-1.0 do progresso do dia)

5. Integração com WorldStateManager:

   - Quando novo dia começa (0h), chamar WorldStateManager.advanceDay()
   - Atualizar WorldStateManager.timeOfDay quando muda

6. Constantes (TimeConfig):
   - Duração de cada período (Morning: 6h-12h, Noon: 12h-18h, Evening: 18h-21h, Night: 21h-6h)
   - Segundos reais para 1 dia in-game (ex: 20 minutos reais = 1 dia)

ESTRUTURA DE ARQUIVOS:
lib/gameplay/core/modules/time/
├── time_manager.dart
├── time_of_day.dart (enum)
└── time_config.dart (constantes)

PADRÃO DE CÓDIGO:

- Usar 'final class' para singleton
- Callbacks type-safe
- Documentação Dartdoc completa
- Logs com prefixo [TimeManager]

EXEMPLO DE USO ESPERADO:

```dart
// Setup
TimeManager.instance.addTimeOfDayListener((timeOfDay) {
  print('Time changed to: $timeOfDay');
  // Update lighting, spawn enemies, etc
});

// Game loop
void update(double dt) {
  TimeManager.instance.update(dt);
}

// Fast forward to night
TimeManager.instance.setTime(TimeConfig.nightStartTime);
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona
[ ] update() avança o tempo corretamente
[ ] Callbacks disparam quando TimeOfDay muda
[ ] setTimeScale() afeta velocidade do tempo
[ ] pause/resume funcionam
[ ] Integração com WorldStateManager funciona
[ ] Avança para novo dia à meia-noite

### Critérios de Aceitação

- [ ] Código compila sem erros
- [ ] Ciclo temporal funciona
- [ ] Callbacks disparam corretamente
- [ ] Integração com WorldStateManager
- [ ] Time scale e pause funcionam
- [ ] Documentação completa

---

## 🚀 PROMPT 3: Criar PlayerProgressManager

### Contexto

O PlayerProgressManager gerencia conquistas, flags de progresso e eventos completados. É usado para controlar quests, NPCs conhecidos, áreas desbloqueadas, etc.

### Prompt para o Claude

Crie o PlayerProgressManager para gerenciar progresso persistente do jogador:

REQUISITOS DO MANAGER:

1. Padrão Singleton:

   - Construtor privado: PlayerProgressManager.\_()
   - Instance estática: static final instance = PlayerProgressManager.\_()

2. Sistema de Flags:

   - Set<String> \_flags (flags booleanas: "quest_1_completed", "npc_met_blacksmith")
   - void setFlag(String flag)
   - bool hasFlag(String flag)
   - void removeFlag(String flag)
   - Set<String> getAllFlags()

3. Sistema de Conquistas:

   - Map<String, int> \_achievements (conquistas com progresso numérico)
   - void incrementAchievement(String achievementId, [int amount = 1])
   - int getAchievementProgress(String achievementId)
   - bool isAchievementCompleted(String achievementId, int requiredAmount)

4. Estatísticas do Jogador:

   - int totalPlayTimeSeconds
   - int enemiesDefeated
   - int itemsCrafted
   - int distanceTraveled
   - void updateStats(Map<String, int> updates)

5. Serialização:

   - Map<String, dynamic> toJson()
   - void fromJson(Map<String, dynamic> json)
   - Integrar com SaveManager

6. Métodos auxiliares:
   - void reset() (limpar todo o progresso)
   - List<String> getCompletedQuests()
   - List<String> getMetNPCs()

ESTRUTURA DO ARQUIVO:
lib/gameplay/core/modules/player/player_progress_manager.dart

PADRÃO DE CÓDIGO:

- Usar 'final class' para singleton
- Documentação Dartdoc completa
- Logs com prefixo [PlayerProgressManager]

EXEMPLO DE JSON ESPERADO:

```json
{
  "flags": ["quest_1_completed", "npc_met_blacksmith", "area_forest_unlocked"],
  "achievements": {
    "enemies_defeated": 50,
    "items_crafted": 10,
    "distance_traveled": 5000
  },
  "totalPlayTimeSeconds": 3600,
  "enemiesDefeated": 50,
  "itemsCrafted": 10,
  "distanceTraveled": 5000
}
```

EXEMPLO DE USO ESPERADO:

```dart
// Completar quest
PlayerProgressManager.instance.setFlag('quest_1_completed');

// Checar progresso
if (PlayerProgressManager.instance.hasFlag('quest_1_completed')) {
  // Desbloquear conteúdo
}

// Atualizar conquista
PlayerProgressManager.instance.incrementAchievement('enemies_defeated');

// Checar conquista
if (PlayerProgressManager.instance.isAchievementCompleted('enemies_defeated', 100)) {
  // Dar recompensa
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona
[ ] setFlag/hasFlag/removeFlag funcionam
[ ] incrementAchievement/getAchievementProgress funcionam
[ ] Serialização toJson/fromJson funciona
[ ] updateStats funciona
[ ] reset() limpa tudo

### Critérios de Aceitação

- [ ] Código compila sem erros
- [ ] Sistema de flags funcional
- [ ] Sistema de conquistas funcional
- [ ] Estatísticas persistentes
- [ ] Serialização completa
- [ ] Documentação completa

---

## 🚀 PROMPT 4: Criar Testes Unitários dos Managers

### Contexto

Precisamos garantir que os managers funcionam corretamente com testes automatizados, especialmente a lógica de estado e serialização.

### Prompt para o Claude

Crie suíte completa de testes unitários para os Managers de Estado Global:

ARQUIVO 1: test/gameplay/core/modules/world/world_state_manager_test.dart
TESTES:

1. test_singleton_returns_same_instance

   - WorldStateManager.instance == WorldStateManager.instance

2. test_advance_day_increments_correctly

   - currentDay = 1, advanceDay(), currentDay == 2

3. test_season_changes_every_28_days

   - Dia 1-28: Spring
   - Dia 29-56: Summer
   - Dia 57-84: Fall
   - Dia 85-112: Winter
   - Dia 113: Spring novamente

4. test_map_state_cache_works

   - setMapState('map1', state)
   - getMapState('map1') retorna state

5. test_unload_inactive_maps_removes_old_maps

   - Adicionar 3 mapas
   - Marcar 1 como ativo
   - unloadInactiveMaps()
   - Apenas 1 mapa permanece

6. test_serialization_roundtrip
   - toJson() → fromJson()
   - Validar igualdade

ARQUIVO 2: test/gameplay/core/modules/time/time_manager_test.dart
TESTES:

1. test_singleton_returns_same_instance

2. test_update_advances_time

   - \_currentTime = 0
   - update(1.0) → \_currentTime == 1.0

3. test_time_of_day_changes_correctly

   - Simular update até Morning → Noon → Evening → Night

4. test_callbacks_fire_on_time_change

   - Adicionar listener
   - Forçar mudança de período
   - Verificar callback foi chamado

5. test_pause_stops_time

   - pause(), update(1.0), tempo não avança

6. test_time_scale_affects_speed

   - setTimeScale(2.0)
   - update(1.0) → tempo avança 2.0

7. test_new_day_triggers_world_manager
   - Mockar WorldStateManager
   - Simular virada de dia
   - Verificar advanceDay() foi chamado

ARQUIVO 3: test/gameplay/core/modules/player/player_progress_manager_test.dart
TESTES:

1. test_singleton_returns_same_instance

2. test_flags_set_and_check

   - setFlag('test')
   - hasFlag('test') == true

3. test_flags_remove

   - setFlag('test')
   - removeFlag('test')
   - hasFlag('test') == false

4. test_achievements_increment

   - incrementAchievement('test', 5)
   - getAchievementProgress('test') == 5

5. test_achievement_completion_check

   - incrementAchievement('test', 10)
   - isAchievementCompleted('test', 10) == true
   - isAchievementCompleted('test', 11) == false

6. test_serialization_roundtrip

   - toJson() → fromJson()
   - Validar igualdade

7. test_reset_clears_all_data
   - Adicionar flags e achievements
   - reset()
   - Tudo vazio

SETUP DOS TESTES:

- setUp() reseta managers antes de cada teste
- Use package:test
- Matchers: expect(actual, equals(expected))

CHECKLIST DE VALIDAÇÃO:
[ ] Todos os testes passam (flutter test)
[ ] Cobertura >= 80%
[ ] Testes isolados (não dependem de ordem)
[ ] Mocks configurados corretamente

### Critérios de Aceitação

- [ ] Todos os testes passam
- [ ] Cobertura >= 80%
- [ ] Testes rápidos (< 5 segundos total)
- [ ] Edge cases cobertos

---

## 🚀 PROMPT 5: Integração com SaveManager

### Contexto

Agora que todos os managers estão criados, precisamos integrá-los ao SaveManager para que o estado do jogo seja persistido corretamente.

### Prompt para o Claude

Integre os Managers de Estado Global ao SaveManager:

TAREFAS:

1. Atualizar SaveData model:

   - Adicionar campo worldData ao playerData existente
   - Incluir dados do WorldStateManager
   - Incluir dados do TimeManager
   - Incluir dados do PlayerProgressManager

2. Criar método de coleta de dados:

   - SaveData collectCurrentGameState()
   - Coletar de todos os managers
   - Retornar SaveData completo

3. Criar método de restauração:

   - void restoreGameState(SaveData saveData)
   - Restaurar todos os managers
   - Validar dados antes de restaurar

4. Atualizar SaveManager:

   - saveGame() agora coleta de managers
   - loadGame() agora restaura managers

5. Criar exemplo completo:
   - save_integration_example.dart
   - Demonstrar save/load de jogo completo

ESTRUTURA DE ARQUIVOS:
lib/gameplay/core/modules/save/
├── game_state_collector.dart (novo)
└── save_integration_example.dart (novo)

EXEMPLO DE USO ESPERADO:

```dart
// Salvar jogo completo
final gameState = GameStateCollector.collectCurrentGameState();
await SaveManager.instance.save(gameState);

// Carregar jogo completo
final loadedState = await SaveManager.instance.load();
if (loadedState != null) {
  GameStateCollector.restoreGameState(loadedState);
  // Jogo restaurado!
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] SaveData inclui todos os managers
[ ] collectCurrentGameState() funciona
[ ] restoreGameState() funciona
[ ] Save/load de jogo completo funciona
[ ] Exemplo demonstra uso completo

### Critérios de Aceitação

- [ ] Integração completa funciona
- [ ] Save/load restaura todo o estado
- [ ] Exemplo funcional
- [ ] Documentação completa

---

## 📊 Checklist de Conclusão da Fase 1.2

### Arquivos Criados

- [ ] `lib/gameplay/core/modules/world/world_state_manager.dart`
- [ ] `lib/gameplay/core/modules/world/map_state_model.dart`
- [ ] `lib/gameplay/core/modules/world/season.dart`
- [ ] `lib/gameplay/core/modules/time/time_manager.dart`
- [ ] `lib/gameplay/core/modules/time/time_of_day.dart`
- [ ] `lib/gameplay/core/modules/time/time_config.dart`
- [ ] `lib/gameplay/core/modules/player/player_progress_manager.dart`
- [ ] `lib/gameplay/core/modules/save/game_state_collector.dart`
- [ ] `test/gameplay/core/modules/world/world_state_manager_test.dart`
- [ ] `test/gameplay/core/modules/time/time_manager_test.dart`
- [ ] `test/gameplay/core/modules/player/player_progress_manager_test.dart`

### Funcionalidades Validadas

- [ ] WorldStateManager gerencia estado do mundo
- [ ] TimeManager gerencia ciclo temporal
- [ ] PlayerProgressManager gerencia progresso
- [ ] Integração com SaveManager funciona
- [ ] Testes >= 80% cobertura
- [ ] Documentação completa

### Próximos Passos

1. ✅ Revisar código gerado
2. ✅ Rodar `flutter test` e validar tudo passa
3. ✅ Testar integração manual
4. ⏭️ Avançar para **FASE 1.3** - Integração Save ↔ Player

---

## 🔧 Troubleshooting

### Problema: Callbacks não disparam

**Solução:** Verificar que listener foi adicionado antes de mudança de estado

### Problema: Estações não mudam corretamente

**Solução:** Validar cálculo de módulo: `(currentDay - 1) ~/ 28 % 4`

### Problema: Tempo avança muito rápido

**Solução:** Ajustar TimeConfig.realSecondsPerGameDay (ex: 1200 = 20 minutos reais)

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025

```

```
