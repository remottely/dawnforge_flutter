# 💾 Integração Save/Load - EXEMPLO DE IMPLEMENTAÇÃO

## O que está pronto e funcionando

### ✅ Sistema Base (100% implementado)

1. **SaveManager** - Gerencia save/load (singleton)
2. **SaveData** - Model com versionamento
3. **SaveRepository** - Persistência multiplataforma (Web + Native)
4. **GameStateCollector** - Coleta estado de todos os managers
5. **InventoryManager** - Serialização completa
6. **EquipmentManager** - Serialização completa
7. **WorldStateManager** - Gerencia estado do mundo
8. **TimeManager** - Ciclo temporal
9. **PlayerProgressManager** - Flags e conquistas

### ✅ Testes (100% passando)

- 28 testes de save/load system
- 65 testes de inventário
- 8 testes de integração inventory ↔ save

## 🎯 Como integrar no MenuScreen

### 1. Verificar se há save existente

```dart
// No MenuScreen
class _MenuScreenState extends MenuScreenViewModel {
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    _checkForSave();
  }

  Future<void> _checkForSave() async {
    final hasSave = await SaveManager.instance.hasSave();
    setState(() {
      _hasSave = hasSave;
    });
  }

  // ...
}
```

### 2. Adicionar botão "Continue" (se há save)

```dart
// No build() do MenuScreen
Column(
  children: [
    const _Title(),

    // Botão CONTINUE (só aparece se há save)
    if (_hasSave) ...[
      _ContinueButton(onPressed: _onContinuePressed),
      SizedBox(height: 10),
    ],

    // Botão NEW GAME
    _StartButton(onPressed: _onNewGamePressed),

    // ... resto dos widgets
  ],
)
```

### 3. Implementar Continue

```dart
Future<void> _onContinuePressed() async {
  // Carregar save
  final saveData = await SaveManager.instance.load();

  if (saveData == null || !saveData.isValid()) {
    // Erro: save corrompido
    _showErrorDialog('Save file is corrupted');
    return;
  }

  // Restaurar estado do jogo
  GameStateCollector.restoreGameState(saveData);

  // Navegar para gameplay
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const GameplayScreen()),
  );
}
```

### 4. Implementar New Game

```dart
Future<void> _onNewGamePressed() async {
  // Reset todos os managers
  GameStateCollector.resetAllManagers();

  // Navegar para gameplay
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const GameplayScreen()),
  );
}
```

### 5. Adicionar Auto-Save no GameStateManager

```dart
class GameStateManager extends GameComponent {
  static const Duration kAutoSaveInterval = Duration(minutes: 5);
  double _timeSinceLastSave = 0;

  @override
  void update(double dt) {
    _processGameState(dt);
    _processAutoSave(dt);
    super.update(dt);
  }

  void _processAutoSave(double dt) {
    _timeSinceLastSave += dt;

    if (_timeSinceLastSave >= kAutoSaveInterval.inSeconds) {
      _timeSinceLastSave = 0;
      _performAutoSave();
    }
  }

  Future<void> _performAutoSave() async {
    developer.log('[GameStateManager] Auto-saving...');

    final saveData = GameStateCollector.collectCurrentGameState();
    final success = await SaveManager.instance.save(saveData);

    if (success) {
      developer.log('[GameStateManager] Auto-save successful!');
      // Mostrar indicador de "Saved!"
      _showSaveIndicator();
    } else {
      developer.log('[GameStateManager] Auto-save failed!');
    }
  }

  void _showSaveIndicator() {
    // TODO: Implementar widget visual que aparece por 2 segundos
  }
}
```

### 6. Salvar em eventos importantes

```dart
// No GameStateManager
void _handleGameOver() {
  // Salvar antes de game over
  _performAutoSave();

  if (!_vIsGameOverDisplayed) {
    _displayGameOverDialog();
  }
}

// Ao trocar de mapa
void onMapChange() {
  _performAutoSave();
}

// Ao completar quest
void onQuestComplete() {
  _performAutoSave();
}
```

## 📝 Widget de Save Indicator

```dart
class SaveIndicatorWidget extends StatefulWidget {
  final SaveStatus status;

  const SaveIndicatorWidget({required this.status});

  @override
  State<SaveIndicatorWidget> createState() => _SaveIndicatorWidgetState();
}

enum SaveStatus { saving, saved, error }

class _SaveIndicatorWidgetState extends State<SaveIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.status == SaveStatus.saved) {
      Future.delayed(Duration(seconds: 1), () {
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getIcon(),
            SizedBox(width: 8),
            Text(
              _getMessage(),
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.status) {
      case SaveStatus.saving:
        return Colors.blue.withOpacity(0.8);
      case SaveStatus.saved:
        return Colors.green.withOpacity(0.8);
      case SaveStatus.error:
        return Colors.red.withOpacity(0.8);
    }
  }

  Icon _getIcon() {
    switch (widget.status) {
      case SaveStatus.saving:
        return Icon(Icons.save, color: Colors.white, size: 16);
      case SaveStatus.saved:
        return Icon(Icons.check_circle, color: Colors.white, size: 16);
      case SaveStatus.error:
        return Icon(Icons.error, color: Colors.white, size: 16);
    }
  }

  String _getMessage() {
    switch (widget.status) {
      case SaveStatus.saving:
        return 'Saving...';
      case SaveStatus.saved:
        return 'Saved!';
      case SaveStatus.error:
        return 'Save failed!';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 🎮 Adicionar no HUD

```dart
class HUDView extends GameInterface {
  SaveIndicatorWidget? _saveIndicator;

  void showSaveIndicator(SaveStatus status) {
    // Remove indicador anterior se existir
    _saveIndicator?.removeFromParent();

    // Cria novo indicador
    _saveIndicator = SaveIndicatorWidget(status: status);
    add(_saveIndicator!);
  }
}
```

## 🧪 Como testar

### Teste Manual 1: New Game

1. Abra o jogo
2. Clique "NEW GAME"
3. Jogue por alguns minutos
4. Pressione `I` para ver inventário
5. Pressione `T` para adicionar itens
6. Espere 5 minutos (auto-save)
7. Feche o jogo

### Teste Manual 2: Continue

1. Abra o jogo novamente
2. Deve aparecer botão "CONTINUE"
3. Clique "CONTINUE"
4. Inventário deve estar com os mesmos itens
5. Equipamentos devem estar mantidos

### Teste Manual 3: Múltiplos Saves

1. Jogue e adicione itens
2. Espere auto-save
3. Adicione mais itens
4. Espere auto-save
5. Feche e reabra
6. Deve carregar último estado

## 🐛 Debug

### Logs importantes

```
[SaveManager] Saving data...
[SaveManager] Save successful!
[SaveManager] Loading data...
[GameStateCollector] Restoring game state...
[InventoryManager] Restored 5 items from save
[EquipmentManager] Restored weapon: Iron Sword
```

### Verificar save file

```dart
// Ver conteúdo do save
final saveData = await SaveManager.instance.load();
if (saveData != null) {
  print(saveData.toJson());
}
```

### Ver metadata

```dart
final metadata = await SaveManager.instance.getSaveMetadata();
print('Last save: ${metadata['lastSaveTime']}');
print('Play time: ${metadata['playTime']}');
```

## ✅ Checklist de Implementação

- [ ] Adicionar botão "Continue" no MenuScreen
- [ ] Adicionar botão "New Game" no MenuScreen
- [ ] Implementar \_onContinuePressed()
- [ ] Implementar \_onNewGamePressed()
- [ ] Adicionar auto-save no GameStateManager (5 min)
- [ ] Salvar em eventos importantes (game over, map change)
- [ ] Criar SaveIndicatorWidget
- [ ] Adicionar indicador no HUD
- [ ] Testar save/load completo
- [ ] Testar save corrompido (recovery)

## 🚀 Código Completo (GameStateCollector já implementado)

O `GameStateCollector` JÁ ESTÁ PRONTO e faz tudo automaticamente:

```dart
// Salvar jogo completo
final saveData = GameStateCollector.collectCurrentGameState();
await SaveManager.instance.save(saveData);

// Carregar jogo completo
final saveData = await SaveManager.instance.load();
if (saveData != null) {
  GameStateCollector.restoreGameState(saveData);
}

// Reset completo
GameStateCollector.resetAllManagers();
```

**Isso salva automaticamente:**

- ✅ Inventário (30 slots)
- ✅ Equipamentos (8 slots)
- ✅ Estado do mundo (dia, estação, mapas)
- ✅ Tempo (hora do dia)
- ✅ Progresso (flags, conquistas, stats)

---

**Status**: 🟢 Sistema pronto para uso, só falta integrar na UI
**Arquivos**: Tudo em `lib/gameplay/core/modules/save/`
**Testes**: 101 testes passando (100% coverage)
