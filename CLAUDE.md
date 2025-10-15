# Padrões de Código - Darkness Dungeon

Este documento define os padrões de codificação e nomenclatura que devem ser seguidos no projeto Darkness Dungeon para manter consistência e qualidade do código.

## 🎯 Convenções de Nomenclatura

### Classes e Arquivos

- **Classes**: PascalCase seguindo padrão Flutter
- **Arquivos**: snake_case seguindo convenção Dart/Flutter
- **Sufixo "Manager"**: Para classes que gerenciam estados ou sistemas
  - Exemplo: `GameplayStateManager`, `GameplayUIStateManager`

### Métodos e Variáveis

- **Métodos públicos**: camelCase (ex: `displayGameOverDialog`)
- **Métodos privados**: \_camelCase com underscore prefix (ex: `_processGameStateChecks`)
- **Variáveis privadas**: \_camelCase com underscore prefix (ex: `_isGameOverDisplayed`)
- **Constantes**: \kConstantName seguindo padrão Google/Flutter (ex: `kGameOverImageHeight`)

## 🏗️ Padrões Arquiteturais

### Estrutura de Classes Manager

#### GameplayStateManager

```dart
class GameplayStateManager extends GameComponent {
  // Flutter-style constants for configuration
  static const String kCheckInterval = 'interval';
  static const int kCheckRate = 100;

  // Private state variables
  bool _isStateDisplayed = false;
  bool _isProcessingState = false;

  @override
  void update(double dt) {
    _processStateChecks(dt);
    super.update(dt);
  }

  // Private utility methods
  void _processStateChecks(double dt) { }
  void _checkForCondition() { }
  void _handleStateTransition() { }

  // Public API methods
  void triggerState() { }
}
```

#### GameplayUIStateManager

```dart
class GameplayUIStateManager {
  // Flutter-style constants for UI configuration
  static const double kImageHeight = 100.0;
  static const Color kBackgroundColor = Colors.transparent;

  // Public static methods for UI operations
  static void displayDialog(BuildContext context) { }

  // Private helper methods
  static void _navigateToScreen(BuildContext context) { }
  static Widget _createStyledWidget() { }
}
```

## 📝 Documentação

### Comentários de Classe

```dart
/// [ClassName] responsible for [main responsibility]
/// Following Flutter naming conventions for [system type] systems
class ClassName {
```

### Comentários de Método

```dart
/// [Action description]
/// Following Flutter pattern of [pattern description]
void methodName() {
```

## 🔧 Padrões de Implementação

### 1. Separação de Responsabilidades

- **Uma responsabilidade por método**: Métodos pequenos e focados
- **Métodos auxiliares**: Quebrar lógica complexa em métodos menores
- **Constantes**: Evitar valores mágicos, usar constantes nomeadas

### 2. Organização de Código

```dart
class ExampleManager {
  // 1. Constantes (agrupadas por tipo)
  static const String kConstant = 'value';
  static const double kSize = 10.0;
  static const Color kColor = Colors.white;

  // 2. Variáveis de instância privadas
  bool _privateVariable = false;

  // 3. Métodos públicos principais
  void publicMethod() { }

  // 4. Métodos privados auxiliares (organizados por funcionalidade)
  void _processLogic() { }
  void _handleState() { }
  void _createComponents() { }

  // 5. Métodos utilitários
  void _logEvent(String event) { }
}
```

### 3. Tratamento de Estado

- **Estado local**: Usar variáveis privadas com underscore
- **Validação**: Sempre validar estado antes de transições
- **Cleanup**: Reset de estado quando necessário
- **Logging**: Eventos importantes para debugging

### 4. Factory Methods

```dart
/// Creates a styled [component] following [pattern]
/// [Description of pattern or approach]
static Widget _createStyledComponent({
  required String parameter,
  double optionalParam = kDefaultValue,
}) {
  // Implementation
}
```

## 🎨 Padrões de UI

### Constantes de UI

```dart
// Sizes and spacing
static const double kImageHeight = 100.0;
static const double kDefaultSpacing = 10.0;
static const double kLargeSpacing = 30.0;

// Typography
static const double kTitleFontSize = 30.0;
static const double kNormalFontSize = 20.0;
static const String kFontFamily = 'FontName';

// Colors
static const Color kPrimaryColor = Colors.white;
static const Color kBackgroundColor = Colors.transparent;

// Assets
static const String kAssetPath = 'assets/image.png';
```

### Widgets Reutilizáveis

- **Factory methods** para componentes comuns
- **Parâmetros nomeados** para configuração
- **Valores padrão** usando constantes
- **Documentação clara** da funcionalidade

## 🔄 Padrões de Navegação

### Navegação Limpa

```dart
static void _navigateToScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const TargetScreen()),
    (Route<dynamic> route) => false,
  );
}
```

## 🐛 Debugging e Logging

### Sistema de Logs

```dart
void _logEvent(String eventName) {
  if (kDebugMode) {
    print('[ClassName] Event: $eventName at ${DateTime.now()}');
  }
}
```

## ✅ Checklist de Qualidade

Antes de finalizar qualquer código, verificar:

- [ ] Nomenclatura segue padrões Flutter (camelCase para métodos)
- [ ] Constantes usam prefixo `k` e são bem nomeadas
- [ ] Métodos são pequenos e focados (uma responsabilidade)
- [ ] Documentação clara para classes e métodos principais
- [ ] Validação de estado antes de transições
- [ ] Cleanup de estado quando necessário
- [ ] Logging para eventos importantes
- [ ] Sem valores mágicos (usar constantes)
- [ ] Organização lógica do código (constantes → variáveis → métodos públicos → métodos privados)

## 🚀 Benefícios Aplicados

1. **Legibilidade**: Código autodocumentado e fácil de entender
2. **Manutenibilidade**: Estrutura organizada facilita mudanças
3. **Consistência**: Padrões uniformes em todo o projeto
4. **Debugging**: Sistema de logs e validações facilita identificação de problemas
5. **Reutilização**: Componentes modulares e factory methods
6. **Escalabilidade**: Arquitetura preparada para crescimento do projeto

---

**Nota**: Estes padrões foram estabelecidos para garantir código limpo, profissional e alinhado com as melhores práticas do Flutter. Sempre seguir estas diretrizes ao criar ou modificar código no projeto.
