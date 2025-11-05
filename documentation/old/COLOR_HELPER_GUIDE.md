# ColorHelper

O `ColorHelper` é uma classe utilitária para manipulação e conversão de strings de cores para objetos `Color` do Flutter. Esta classe foi criada para centralizar e padronizar a conversão de cores em formato hexadecimal para objetos `Color`, melhorando a legibilidade e reutilização do código.

## Localização

```
lib/gameplay/core/utils/helpers/color_helper.dart
```

## Funcionalidades

### 1. `fromHexString(String? hexString)`

Converte uma string hexadecimal para um objeto `Color`.

**Características:**

- Suporta formatos `#RRGGBB` e `RRGGBB`
- Retorna `null` se a string for inválida ou nula
- Adiciona canal alpha automaticamente (totalmente opaco)

**Exemplos:**

```dart
final redColor = ColorHelper.fromHexString('#FF0000');     // Vermelho
final greenColor = ColorHelper.fromHexString('00FF00');    // Verde
final invalidColor = ColorHelper.fromHexString('invalid'); // null
```

### 2. `fromHexStringWithAlpha(String? hexString, double alpha)`

Converte uma string hexadecimal para um objeto `Color` com transparência personalizada.

**Características:**

- Mesmo comportamento do `fromHexString`
- Permite definir transparência (0.0 = transparente, 1.0 = opaco)
- Alpha é limitado entre 0.0 e 1.0

**Exemplos:**

```dart
final semiTransparentRed = ColorHelper.fromHexStringWithAlpha('#FF0000', 0.5);
final transparent = ColorHelper.fromHexStringWithAlpha('#FF0000', 0.0);
```

### 3. `toHexString(Color color)`

Converte um objeto `Color` para string hexadecimal.

**Exemplos:**

```dart
final hexString = ColorHelper.toHexString(Colors.red); // '#F44336'
```

### 4. `isValidHexString(String? hexString)`

Valida se uma string está em formato hexadecimal válido.

**Exemplos:**

```dart
final isValid1 = ColorHelper.isValidHexString('#FF0000'); // true
final isValid2 = ColorHelper.isValidHexString('00FF00');  // true
final isValid3 = ColorHelper.isValidHexString('invalid'); // false
```

### 5. `fromRGB(int red, int green, int blue)`

Cria um `Color` a partir de valores RGB individuais.

**Características:**

- Valores RGB são limitados entre 0 e 255
- Alpha é definido como 1.0 (totalmente opaco)

**Exemplos:**

```dart
final color = ColorHelper.fromRGB(255, 128, 64);
```

### 6. `fromRGBA(int red, int green, int blue, double alpha)`

Cria um `Color` a partir de valores RGBA individuais.

**Características:**

- Valores RGB são limitados entre 0 e 255
- Alpha é limitado entre 0.0 e 1.0

**Exemplos:**

```dart
final color = ColorHelper.fromRGBA(255, 128, 64, 0.8);
```

## Uso no Projeto

### Antes (no GameplayMapManager)

```dart
var lightingColorString = properties.others['lightingColor']?.toString();
lightingColorString = lightingColorString?.replaceAll('#', '');
final lightingColor = lightingColorString != null
    ? Color(int.parse(lightingColorString, radix: 16))
    : null;

var backgroundColorString = properties.others['backgroundColor']?.toString();
backgroundColorString = backgroundColorString?.replaceAll('#', '');
final backgroundColor = backgroundColorString != null
    ? Color(int.parse(backgroundColorString, radix: 16))
    : null;
```

### Depois (com ColorHelper)

```dart
final lightingColor = ColorHelper.fromHexString(
  properties.others['lightingColor']?.toString(),
);
final backgroundColor = ColorHelper.fromHexString(
  properties.others['backgroundColor']?.toString(),
);
```

## Vantagens

1. **Legibilidade**: Código mais claro e expressivo
2. **Reutilização**: Centraliza a lógica de conversão de cores
3. **Robustez**: Tratamento de erros integrado
4. **Flexibilidade**: Múltiplos formatos de entrada
5. **Testabilidade**: Funções puras com comportamento previsível
6. **Manutenibilidade**: Mudanças centralizadas em um local

## Testes

Os testes estão localizados em:

```
test/gameplay/core/utils/helpers/color_helper_test.dart
```

Para executar os testes:

```bash
flutter test test/gameplay/core/utils/helpers/color_helper_test.dart
```

## Padrões Seguidos

- **Flutter Naming Conventions**: Nomes de classes e métodos seguem as convenções do Flutter
- **Documentação**: Todos os métodos possuem documentação com exemplos
- **Null Safety**: Tratamento adequado de valores nulos
- **Immutabilidade**: Métodos são estáticos e não alteram estado
- **Error Handling**: Tratamento gracioso de erros com retornos nulos
