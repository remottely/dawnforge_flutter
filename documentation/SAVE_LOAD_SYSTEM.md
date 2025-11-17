# Sistema de Save/Load

## Visão Geral

O sistema de save/load foi implementado para persistir todo o estado do jogo entre sessões, incluindo:

- Estado do player (vida, stamina, energy)
- Inventário completo (items, stacks)
- Estado da fazenda (tiles, crops, estágios de crescimento)
- Estado do mundo (dia atual, season, hora)

## Como Funciona

### 1. Save Automático ao Avançar Dia

Quando o jogador pressiona **N** para avançar um dia:

```dart
// farm_interaction_component.dart
if (event.logicalKey == LogicalKeyboardKey.keyN) {
  // 1. Avançar dia no mundo
  WorldStateManager.instance.advanceDay();

  // 2. Avançar dia nos crops
  FarmManager.instance.advanceDay();

  // 3. Salvar jogo automaticamente
  GameSaveController.instance.saveGame();
}
```

O save inclui:

- **Player**: Vida, stamina, energy, hasKey (via PlayerStateManager)
- **Inventory**: Todos os slots e items (via InventoryManager)
- **Farm**: Todos os tiles, crops e estágios (via FarmManager)
- **World**: Dia, season, tempo, estados de mapas (via WorldStateManager)

### 2. Load Automático ao Iniciar Jogo

No `initState()` do `GameplayScreenViewmodel`:

```dart
void _loadGameOrResetLife() {
  GameSaveController.instance.loadGame().then((success) {
    if (success) {
      // ✅ Save encontrado e carregado
      developer.log('Game loaded from save');
    } else {
      // ℹ️ Sem save, novo jogo
      _resetPlayerLifeOnNewGame();
    }
  });
}
```

### 3. Hot Restart

Após implementação, ao fazer **hot restart** (R no terminal):

1. O jogo é reiniciado
2. `initState()` é chamado
3. `loadGame()` busca o último save
4. Todo o estado é restaurado:
   - Player reaparece com vida/stamina/energy salvas
   - Inventário mantém todos os items
   - Farm tiles mantém estado (tilled, watered, crops)
   - Dia atual é preservado

## Arquitetura

### GameSaveController

Orquestra o save/load de todos os managers:

```dart
// Salvar
final playerData = PlayerStateManager.instance.toJson();
final inventoryData = InventoryManager.instance.toJson();
final farmData = FarmManager.instance.toJson();
final worldData = WorldStateManager.instance.toJson();

final saveData = SaveData(
  version: SaveData.kCurrentVersion,
  timestamp: DateTime.now(),
  playerData: playerData,
  worldData: worldData + farmData,
  inventoryData: inventoryData,
);

await SaveManager.instance.save(saveData);

// Carregar
final saveData = await SaveManager.instance.load();
PlayerStateManager.instance.fromJson(saveData.playerData);
InventoryManager.instance.fromJson(saveData.inventoryData);
FarmManager.instance.fromJson(saveData.worldData['farmData']);
WorldStateManager.instance.fromJson(saveData.worldData);
```

### SaveManager

Gerencia persistência usando `SaveRepository`:

- **Native**: SharedPreferences (Android/iOS/Desktop)
- **Web**: LocalStorage (Browser)

### SaveData

Modelo versionado para suportar migrações futuras:

```dart
final class SaveData {
  static const int kCurrentVersion = 1;

  final int version;
  final DateTime timestamp;
  final Map<String, dynamic> playerData;
  final Map<String, dynamic> worldData;
  final Map<String, dynamic> inventoryData;
}
```

## Fluxo Completo

### Primeira Execução (Sem Save)

```
1. App inicia
2. initState() → loadGame()
3. Nenhum save encontrado
4. _resetPlayerLifeOnNewGame() reseta vida
5. Jogo começa com estado padrão
```

### Com Save Existente

```
1. App inicia
2. initState() → loadGame()
3. Save encontrado no disco
4. PlayerStateManager.fromJson() → Vida/stamina restauradas
5. InventoryManager.fromJson() → Items restaurados
6. FarmManager.fromJson() → Tiles/crops restaurados
7. WorldStateManager.fromJson() → Dia/season restaurados
8. Jogo continua do ponto salvo
```

### Durante Gameplay

```
1. Player planta crops, colhe items
2. Player pressiona N (avançar dia)
3. WorldStateManager.advanceDay()
4. FarmManager.advanceDay() → Crops crescem
5. GameSaveController.saveGame()
6. Tudo é serializado e salvo no disco
```

### Hot Restart

```
1. Developer pressiona R (hot restart)
2. App reinicia completamente
3. initState() → loadGame()
4. Último save é carregado
5. Player, inventory, farm, world restaurados
6. Gameplay continua exatamente onde parou
```

## Managers com Serialização

Todos os managers implementam `toJson()` / `fromJson()`:

### ✅ PlayerStateManager

- Knight model (vida, stamina, energy, hasKey)
- Sunny model (vida, stamina, energy, hasKey, isRunning)

### ✅ InventoryManager

- Slots completos
- Items com stacks
- Metadata de cada item

### ✅ FarmManager

- Todos os farm tiles
- Soil states (untilled, tilled, watered)
- Crops com estágios de crescimento
- Dias até harvest

### ✅ WorldStateManager

- Dia atual
- Season (spring, summer, fall, winter)
- TimeOfDay (morning, afternoon, evening, night)
- Estados de mapas visitados

## Testando o Sistema

1. **Iniciar jogo novo**:

   ```bash
   flutter run
   ```

2. **Fazer algumas ações**:

   - Arar terra (H)
   - Regar (J)
   - Plantar (K)
   - Avançar dia (N) → **SAVE AUTOMÁTICO**

3. **Hot restart**:

   ```bash
   # No terminal onde flutter run está rodando
   # Pressionar: R
   ```

4. **Verificar**:
   - Farm tiles devem estar no mesmo estado
   - Crops devem ter crescido (se passou dias)
   - Inventário mantém items
   - Dia atual é o último salvo

## Logs Úteis

```dart
[GameSaveController] Starting game save...
[GameSaveController] ✅ Game saved successfully!

[GameSaveController] Starting game load...
[GameSaveController] Player state restored
[GameSaveController] World state restored
[GameSaveController] Inventory restored
[GameSaveController] Farm state restored
[GameSaveController] ✅ Game loaded successfully!
```

## Próximas Melhorias

- [ ] UI de "Continue" vs "New Game" na tela inicial
- [ ] Múltiplos slots de save
- [ ] Auto-save periódico (a cada X minutos)
- [ ] Indicador visual de "Salvando..." no HUD
- [ ] Backup de saves corrompidos
- [ ] Cloud sync (Firebase/supabase)
