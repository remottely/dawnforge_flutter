# 📹 Limitação: Câmera e Mudança de Orientação

## 🔍 Problema Identificado

O `BonfireWidget` do Bonfire **não suporta atualização dinâmica de `CameraConfig`** após a construção inicial. Isso cria um dilema:

### Opção A: Usar Key para Forçar Rebuild
```dart
BonfireWidget(
  key: ValueKey(orientation), // ❌ Reseta player e quebra inputs
  cameraConfig: getCameraConfig(context),
  // ...
)
```
**Consequências:**
- ✅ Câmera se ajusta corretamente
- ❌ **Player volta para posição inicial**
- ❌ **Inputs param de funcionar** (joystick/keyboard)
- ❌ Estado do jogo é perdido

### Opção B: Sem Key (Implementação Atual)
```dart
BonfireWidget(
  // Sem key
  cameraConfig: getCameraConfig(context),
  // ...
)
```
**Consequências:**
- ❌ Câmera não se ajusta em mudanças de orientação/fullscreen
- ✅ **Player mantém posição**
- ✅ **Inputs continuam funcionando**
- ✅ Estado do jogo preservado

## ✅ Solução Adotada: Opção B (Sem Key)

**Justificativa:**
1. **Mobile**: `SettingsManager` força orientação landscape com joystick → mudanças de orientação são **raras**
2. **Web/Desktop**: Fullscreen mantém mesma orientação → câmera continua adequada
3. **Prioridade**: Funcionalidade dos inputs > Ajuste perfeito da câmera

## 🎮 Comportamento Esperado

### ✅ Funciona Perfeitamente:
- Fullscreen (web/desktop)
- Gameplay normal
- Inputs (joystick/keyboard)
- Save/Load do jogo
- Transições de mapas

### ⚠️ Limitação Conhecida:
- Se o usuário **manualmente** mudar a orientação do dispositivo (desabilitando o bloqueio de orientação do SO), a câmera **não se ajustará** automaticamente
- Solução: Reiniciar o jogo ou aceitar a visualização sub-ótima

## 🔮 Solução Futura (se Bonfire adicionar API)

Se o Bonfire adicionar um método como `updateCameraConfig()`:

```dart
abstract class GameplayScreenViewmodel extends State<GameplayScreen>
    with WidgetsBindingObserver {
  final GlobalKey<BonfireWidgetState> _bonfireKey = GlobalKey();
  
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // API hipotética
      _bonfireKey.currentState?.updateCameraConfig(
        getCameraConfig(context),
      );
    });
  }
}
```

## 📚 Referências

- [Bonfire GitHub Issues - Camera Update](https://github.com/RafaelBarbosatec/bonfire/issues)
- Código: `lib/gameplay/gameplay_screen_viewmodel.dart`
- Configuração: `lib/shared/managers/settings_manager.dart`
