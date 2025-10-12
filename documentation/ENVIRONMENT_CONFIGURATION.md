# Configuração de Ambiente (AppEnvironment)

Este documento explica como usar e configurar diferentes ambientes no jogo Darkness Dungeon usando variáveis de ambiente.

## Problema Resolvido

**Problema Original:**

- Mesmo definindo `--dart-define=GAME_ENVIRONMENT=STAGING`, o código estava sendo executado como development/testing
- A lógica de ambiente estava misturada com o modo de build do Flutter

**Solução Implementada:**

- Separação clara entre variáveis de ambiente customizadas e modos de build do Flutter
- Prioridade da variável `GAME_ENVIRONMENT` sobre o modo de build
- Configurações específicas para cada ambiente

## Ambientes Disponíveis

### 1. **DEVELOPMENT** (Padrão)

- **Uso:** Desenvolvimento local
- **Características:**
  - Debug info habilitado
  - Cheat codes habilitados
  - Health multiplier: 2.0x
  - Enemy damage: 0.5x
  - Volume master: 30%
  - Logs verbosos

### 2. **TESTING**

- **Uso:** Testes automatizados
- **Características:**
  - Logs habilitados (nível info)
  - Health multiplier: 1.5x
  - Enemy damage: 0.7x
  - Volume master: 10%
  - Timeout API: 60s

### 3. **STAGING**

- **Uso:** Testes antes da produção
- **Características:**
  - Logs habilitados (nível warning)
  - Health multiplier: 1.2x
  - Enemy damage: 0.9x
  - Volume master: 50%
  - AutoSave habilitado
  - Shadows e Bloom habilitados

### 4. **PRODUCTION**

- **Uso:** Ambiente de produção
- **Características:**
  - Apenas logs de erro
  - Health multiplier: 1.0x
  - Enemy damage: 1.0x
  - Volume master: 70%
  - AutoSave habilitado
  - Todas otimizações ativas

## Como Usar

### Definir Ambiente via Command Line

```bash
# Desenvolvimento (padrão)
flutter run

# Testing
flutter run --dart-define=GAME_ENVIRONMENT=TESTING

# Staging
flutter run --dart-define=GAME_ENVIRONMENT=STAGING

# Produção
flutter run --dart-define=GAME_ENVIRONMENT=PRODUCTION
```

### Definir Ambiente para Testes

```bash
# Testar com ambiente específico
flutter test --dart-define=GAME_ENVIRONMENT=STAGING

# Testar com múltiplas variáveis
flutter test --dart-define=GAME_ENVIRONMENT=STAGING --dart-define=APP_VERSION=1.2.0
```

### Definir Ambiente para Build

```bash
# Build para staging
flutter build apk --dart-define=GAME_ENVIRONMENT=STAGING

# Build para produção
flutter build apk --dart-define=GAME_ENVIRONMENT=PRODUCTION
```

## Verificar Ambiente em Runtime

### No Código

```dart
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';

// Verificar ambiente atual
print('Ambiente: ${AppEnvironment.currentEnvironment}');

// Verificar flags específicas
if (AppEnvironment.isStaging) {
  print('Rodando em staging!');
}

// Usar configurações específicas
final volume = AppEnvironment.masterVolume; // 0.5 em staging
final health = AppEnvironment.playerHealthMultiplier; // 1.2 em staging

// Executar código por ambiente
AppEnvironment.debugOnly(() {
  print('Só executa em development');
});

// Valor baseado no ambiente
final apiUrl = AppEnvironment.byEnvironment<String>(
  development: 'dev-api.com',
  testing: 'test-api.com',
  staging: 'staging-api.com',
  production: 'api.com',
);
```

### Imprimir Informações do Ambiente

```dart
// Imprime todas as configurações atuais
AppEnvironment.printEnvironmentInfo();
```

## Configurações por Ambiente

| Configuração             | Development | Testing | Staging | Production |
| ------------------------ | ----------- | ------- | ------- | ---------- |
| **Master Volume**        | 30%         | 10%     | 50%     | 70%        |
| **Player Health**        | 2.0x        | 1.5x    | 1.2x    | 1.0x       |
| **Enemy Damage**         | 0.5x        | 0.7x    | 0.9x    | 1.0x       |
| **Starting Lives**       | 5           | 4       | 3       | 3          |
| **API Timeout**          | 30s         | 60s     | 15s     | 10s        |
| **Show Debug Info**      | ✅          | ❌      | ❌      | ❌         |
| **Enable Cheat Codes**   | ✅          | ❌      | ❌      | ❌         |
| **Show Collision Boxes** | ✅          | ✅      | ❌      | ❌         |
| **Enable Logging**       | ✅          | ✅      | ✅      | ❌         |
| **Log Level**            | debug       | info    | warning | error      |
| **AutoSave**             | ❌          | ❌      | ✅      | ✅         |
| **Log to File**          | ❌          | ❌      | ✅      | ✅         |
| **Show Tooltips**        | ✅          | ❌      | ✅      | ❌         |

## APIs por Ambiente

- **Development:** `https://dev-api.darknessdungeon.com`
- **Testing:** `https://test-api.darknessdungeon.com`
- **Staging:** `https://staging-api.darknessdungeon.com`
- **Production:** `https://api.darknessdungeon.com`

## Separação de Build Mode vs Environment

### Build Modes (Flutter)

- **kDebugMode:** Modo debug do Flutter
- **kReleaseMode:** Modo release do Flutter
- **kProfileMode:** Modo profile do Flutter

### Custom Environments (Nosso)

- **isDevelopment:** GAME_ENVIRONMENT=DEVELOPMENT
- **isTesting:** GAME_ENVIRONMENT=TESTING
- **isStaging:** GAME_ENVIRONMENT=STAGING
- **isProduction:** GAME_ENVIRONMENT=PRODUCTION

### Propriedades Combinadas (Para compatibilidade)

- **isDevelopmentOrDebug:** DEVELOPMENT OR kDebugMode
- **isProductionOrRelease:** PRODUCTION OR kReleaseMode

## Exemplo Prático

```bash
# Cenário: Testar em staging mas em debug mode
flutter run --dart-define=GAME_ENVIRONMENT=STAGING --debug

# Resultado:
# - AppEnvironment.isStaging = true
# - AppEnvironment.isDebugMode = true
# - AppEnvironment.masterVolume = 0.5 (staging)
# - AppEnvironment.enableLogging = true (staging)
# - AppEnvironment.showDebugInfo = false (não é development)
```

## Troubleshooting

### Ambiente não está sendo reconhecido

1. Verifique se está usando `--dart-define=GAME_ENVIRONMENT=STAGING`
2. Verifique se não há espaços extras: `GAME_ENVIRONMENT = STAGING` ❌
3. Use o método `printEnvironmentInfo()` para verificar o valor atual

### Hot Reload não aplica mudança de ambiente

- Variáveis `--dart-define` são compiladas em build time
- Necessário fazer `flutter run` novamente, não apenas hot reload

### Testes não reconhecem ambiente

- Certifique-se de usar `--dart-define` nos comandos de teste
- Exemplo: `flutter test --dart-define=GAME_ENVIRONMENT=STAGING test_file.dart`

## Adicionando Novas Configurações

Para adicionar uma nova configuração por ambiente:

```dart
static bool get minhaNovaProp {
  if (isDevelopment) return true;
  if (isTesting) return false;
  if (isStaging) return true;
  return false; // Production
}
```
