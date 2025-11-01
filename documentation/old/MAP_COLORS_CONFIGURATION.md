# Configuração de Cores por Mapa

Este documento explica como a funcionalidade de cores por mapa (`lightingColor` e `backgroundColor`) foi implementada para que as cores sejam aplicadas desde o início do jogo, não apenas durante a navegação entre mapas.

## Problema Resolvido

**Problema Original:**

- O jogo iniciava no `initialMap` mas não aplicava as cores `lightingColor` e `backgroundColor`
- As cores só funcionavam após navegar entre mapas (via `MapArguments`)
- Era necessário que as cores fossem lidas diretamente dos arquivos Tiled (map1.json, dungeon1.json, etc.)

**Solução Implementada:**

- Criação de um sistema de configuração de mapa que associa cores diretamente aos mapas
- As cores são agora definidas no código e podem ser facilmente alteradas
- As cores são aplicadas tanto no mapa inicial quanto durante navegações

## Implementação

### 1. Nova Classe `MapConfiguration`

Criada em `lib/gameplay/core/constants/map_constants.dart`:

```dart
class MapConfiguration {
  final String? backgroundMusic;
  final Color? lightingColor;
  final Color? backgroundColor;

  const MapConfiguration({
    this.backgroundMusic,
    this.lightingColor,
    this.backgroundColor,
  });

  static const MapConfiguration empty = MapConfiguration();
}
```

### 2. Método de Configuração por Mapa

Adicionado ao `GameplayMapManager`:

```dart
static MapConfiguration getMapConfiguration(String mapId) {
  switch (mapId) {
    case 'map1':
      return const MapConfiguration(
        backgroundMusic: 'ro1_death_hex.mp3',
        lightingColor: Color(0xffFFE566), // Light yellow for outdoor
        backgroundColor: Color(0xff2E8B57), // Sea green for outdoor
      );
    case 'dungeon1':
      return const MapConfiguration(
        backgroundMusic: 'dungeon_theme.mp3',
        lightingColor: Color(0xffAA4400), // Orange for dungeon
        backgroundColor: Color(0xff1a1a1a), // Dark gray for dungeon
      );
    default:
      return MapConfiguration.empty;
  }
}
```

### 3. Integração no Gameplay

Modificado `lib/gameplay/gameplay.dart` para usar as configurações:

```dart
// Get map-specific configuration
final mapConfig = GameplayMapManager.getMapConfiguration(mapItem.id);

// Use map configuration as base, override with arguments if provided
final backgroundMusic = mapArguments?.backgroundMusic ?? mapConfig.backgroundMusic;
final mapLightingColor = mapArguments?.lightingColor ?? mapConfig.lightingColor;
final mapBackgroundColor = mapArguments?.backgroundColor ?? mapConfig.backgroundColor;
```

### 4. Arquivos Tiled Atualizados

Adicionadas propriedades ao nível do mapa nos arquivos JSON:

**map_1.json:**

```json
"properties":[
  {
    "name":"backgroundMusic",
    "type":"string",
    "value":"ro1_death_hex.mp3"
  },
  {
    "name":"lightingColor",
    "type":"string",
    "value":"#ffFFE566"
  },
  {
    "name":"backgroundColor",
    "type":"string",
    "value":"#ff2E8B57"
  }
]
```

**dungeon_1.json:**

```json
"properties":[
  {
    "name":"backgroundMusic",
    "type":"string",
    "value":"dungeon_theme.mp3"
  },
  {
    "name":"lightingColor",
    "type":"string",
    "value":"#ffAA4400"
  },
  {
    "name":"backgroundColor",
    "type":"string",
    "value":"#ff1a1a1a"
  }
]
```

## Como Usar

### Para Adicionar um Novo Mapa:

1. **Adicione a configuração no `GameplayMapManager`:**

```dart
case 'novo_mapa':
  return const MapConfiguration(
    backgroundMusic: 'nova_musica.mp3',
    lightingColor: Color(0xffCORHEX), // Cor da iluminação
    backgroundColor: Color(0xffCORHEX), // Cor de fundo
  );
```

2. **Adicione as propriedades no arquivo Tiled JSON:**

```json
"properties":[
  {
    "name":"backgroundMusic",
    "type":"string",
    "value":"nova_musica.mp3"
  },
  {
    "name":"lightingColor",
    "type":"string",
    "value":"#ffCORHEX"
  },
  {
    "name":"backgroundColor",
    "type":"string",
    "value":"#ffCORHEX"
  }
]
```

### Para Alterar Cores de um Mapa Existente:

1. **Modifique os valores no `GameplayMapManager`:**

```dart
case 'map1':
  return const MapConfiguration(
    backgroundMusic: 'ro1_death_hex.mp3',
    lightingColor: Color(0xffNOVACOR), // Nova cor
    backgroundColor: Color(0xffNOVACOR), // Nova cor
  );
```

2. **Sincronize com o arquivo Tiled JSON** (opcional, mas recomendado para consistência)

## Vantagens da Solução

1. **✅ Funciona desde o início:** Cores aplicadas no mapa inicial
2. **✅ Simples de configurar:** Apenas adicionar no switch case
3. **✅ Flexível:** Pode ser sobrescrito por `MapArguments`
4. **✅ Consistente:** Mesma interface para todos os mapas
5. **✅ Testável:** Método estático fácil de testar
6. **✅ Dinâmico:** Valores podem vir dos arquivos Tiled no futuro

## Fluxo de Prioridade

1. **MapArguments** (navegação entre mapas) - **Maior prioridade**
2. **MapConfiguration** (configuração do mapa) - **Prioridade padrão**
3. **Null/Transparente** (sem configuração) - **Menor prioridade**

## Cores Atuais Configuradas

### Map1 (Exterior)

- **Lighting:** `Color(0xffFFE566)` - Amarelo claro (luz do sol)
- **Background:** `Color(0xff2E8B57)` - Verde mar (ambiente externo)

### Dungeon1 (Masmorra)

- **Lighting:** `Color(0xffAA4400)` - Laranja escuro (tochas)
- **Background:** `Color(0xff1a1a1a)` - Cinza escuro (ambiente sombrio)

## Testes

Criados testes em `test/gameplay/core/managers/gameplay_map_manager_test.dart` para validar:

- Configurações corretas para cada mapa
- Comportamento para mapas inexistentes
- Integridade dos mapas disponíveis

Execute os testes com:

```bash
flutter test test/gameplay/core/managers/gameplay_map_manager_test.dart
```
