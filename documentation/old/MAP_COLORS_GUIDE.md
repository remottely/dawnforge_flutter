# Configuração de Cores de Mapa

## Visão Geral

O sistema de cores do Darkness Dungeon permite configurar cores específicas para cada mapa usando propriedades no editor Tiled. Essas cores são automaticamente aplicadas quando o jogador transita entre diferentes mapas.

## Propriedades Suportadas

### 1. `lightingColor`

- **Tipo**: String (cor hexadecimal)
- **Formato**: `#RRGGBB` ou `RRGGBB`
- **Descrição**: Define a cor de iluminação ambiente do mapa
- **Exemplo**: `#000080` (azul escuro), `FF4500` (vermelho laranja)

### 2. `backgroundColor`

- **Tipo**: String (cor hexadecimal)
- **Formato**: `#RRGGBB` ou `RRGGBB`
- **Descrição**: Define a cor de fundo do mapa
- **Exemplo**: `#1a1a1a` (cinza escuro), `2F4F4F` (cinza azulado)

## Configuração no Tiled Editor

### Passo a Passo

1. **Abra seu mapa no Tiled Editor**
2. **Crie um sensor de transição (objeto)**
3. **Nas propriedades do objeto, adicione:**
   - `nextMap`: Nome do mapa de destino
   - `playerPosition`: Posição onde o jogador aparecerá
   - `playerDirection`: Direção inicial do jogador
   - `lightingColor`: Cor de iluminação (opcional)
   - `backgroundColor`: Cor de fundo (opcional)
   - `backgroundMusic`: Música de fundo (opcional)

### Exemplo de Configuração

```
Propriedades do Sensor:
├── nextMap: "dungeon_1"
├── playerPosition: "10,15"
├── playerDirection: "down"
├── lightingColor: "#000066"
├── backgroundColor: "#1a1a2e"
└── backgroundMusic: "dungeon_ambient.ogg"
```

## Fluxo de Aplicação

### 1. **Detecção no Sensor**

```dart
// GameplayMapSensor detecta a transição
final lightingColor = ColorHelper.fromHexString(
  properties.others['lightingColor']?.toString(),
);
final backgroundColor = ColorHelper.fromHexString(
  properties.others['backgroundColor']?.toString(),
);
```

### 2. **Passagem via MapArguments**

```dart
// Cores são passadas para o próximo mapa
MapNavigator.of(context).toNamed(
  targetMap,
  arguments: MapArguments(
    playerPosition: playerPosition,
    playerDirection: playerDirection,
    backgroundMusic: backgroundMusic,
    lightingColor: lightingColor,
    backgroundColor: backgroundColor,
  ),
);
```

### 3. **Aplicação no Gameplay**

```dart
// Gameplay aplica as cores no BonfireWidget
final mapLightingColor = mapArguments?.lightingColor;
final mapBackgroundColor = mapArguments?.backgroundColor;
final effectiveLightingColor = mapLightingColor?.withValues(alpha: 0.6) ?? defaultLightingColor;
final effectiveBackgroundColor = mapBackgroundColor ?? defaultBackgroundColor;

BonfireWidget(
  lightingColorGame: effectiveLightingColor,
  backgroundColor: effectiveBackgroundColor,
  // ... outros parâmetros
)
```

## Cenários de Uso

### 🌙 **Dungeons Escuras**

```
lightingColor: "#000033"  // Azul muito escuro
backgroundColor: "#0a0a0a" // Preto quase total
```

**Efeito**: Ambiente sombrio e misterioso para dungeons subterrâneas.

### 🔥 **Cavernas de Lava**

```
lightingColor: "#330000"  // Vermelho escuro
backgroundColor: "#2a1a1a" // Marrom avermelhado
```

**Efeito**: Ambiente quente e perigoso para cavernas vulcânicas.

### 🌲 **Florestas**

```
lightingColor: "#003300"  // Verde escuro
backgroundColor: "#1a2a1a" // Verde musgo
```

**Efeito**: Ambiente natural e orgânico para áreas florestais.

### ❄️ **Regiões Geladas**

```
lightingColor: "#003366"  // Azul gelo
backgroundColor: "#e6f3ff" // Azul muito claro
```

**Efeito**: Ambiente frio e cristalino para regiões árticas.

## Implementação Técnica

### ColorHelper Integration

O sistema utiliza o `ColorHelper` para conversão segura:

```dart
// Conversão robusta com tratamento de erros
final color = ColorHelper.fromHexString("#FF0000");
// Retorna null se a string for inválida
```

### Fallback Padrão

Se as cores não forem especificadas, o sistema usa valores padrão:

```dart
// Valores padrão definidos no Gameplay
final defaultLightingColor = Colors.black.withValues(alpha: 0.6);
final defaultBackgroundColor = Colors.grey[900];
```

### Performance

- **Lazy Loading**: Cores são aplicadas apenas durante transições
- **Caching**: ColorHelper usa parsing eficiente
- **Memory Safe**: Tratamento robusto de valores nulos

## Debugging

### Logs Automáticos

O sistema registra automaticamente as aplicações de cor:

```
[INFO] Building BonfireWidget for map: dungeon_1,
       player position: Vector2(320.0, 480.0),
       music: dungeon_ambient.ogg,
       lighting: Color(0xff000066),
       background: Color(0xff1a1a2e)
```

### Validação

Use `ColorHelper.isValidHexString()` para validar cores:

```dart
if (!ColorHelper.isValidHexString(colorString)) {
  AppLogger.warning('Invalid color format: $colorString');
}
```

## Best Practices

### 🎨 **Design**

- Use cores que complementem o tema do mapa
- Mantenha contraste adequado para visibilidade
- Teste combinações em diferentes dispositivos

### 🔧 **Implementação**

- Sempre teste cores em hexadecimal antes de usar
- Use ferramentas de paleta de cores para consistência
- Documente as escolhas de cor para cada mapa

### 📱 **Experiência do Usuário**

- Evite mudanças muito bruscas entre mapas
- Use transições suaves quando possível
- Considere acessibilidade (daltonismo)

## Ferramentas Recomendadas

- **Adobe Color**: Criação de paletas harmoniosas
- **ColorZilla**: Extração de cores de imagens
- **Coolors.co**: Geração de esquemas de cores
- **Tiled Editor**: Configuração das propriedades do mapa
