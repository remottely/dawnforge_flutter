# 🎨 Guia Completo - Finalização Visual do Sistema de Agricultura

> **Status Atual:** ✅ Sistema backend completo e testado
>
> **Faltando:** Renderização visual e assets
>
> **Tempo Estimado:** 2-3 horas

---

## 📋 Checklist Geral

- [ ] **Passo 1:** Preparar assets de sprites
- [ ] **Passo 2:** Organizar estrutura de pastas
- [ ] **Passo 3:** Criar FarmTileComponent (renderização)
- [ ] **Passo 4:** Criar FarmInteractionComponent (input)
- [ ] **Passo 5:** Integrar com TimeManager
- [ ] **Passo 6:** Adicionar ao mapa do jogo
- [ ] **Passo 7:** Testar e ajustar

---

## 🎯 PASSO 1: Preparar Assets de Sprites

### 1.1 Estrutura de Pastas

Crie a seguinte estrutura em `assets/images/`:

```
assets/images/gameplay/farm/
├── soil/
│   ├── untilled.png          (terra normal, não preparada)
│   ├── tilled.png             (terra arada, linhas visíveis)
│   ├── watered.png            (terra molhada, mais escura)
│   └── fertilized.png         (terra com brilho especial)
├── crops/
│   ├── carrot/
│   │   ├── seed.png           (semente no solo)
│   │   ├── sprout.png         (broto inicial)
│   │   ├── growing.png        (planta crescendo)
│   │   └── mature.png         (cenoura madura)
│   ├── potato/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── growing.png
│   │   └── mature.png
│   ├── wheat/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── growing.png
│   │   └── mature.png
│   ├── pumpkin/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── growing.png
│   │   └── mature.png
│   ├── turnip/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── growing.png
│   │   └── mature.png
│   ├── tomato/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── growing.png
│   │   └── mature.png
│   └── corn/
│       ├── seed.png
│       ├── sprout.png
│       ├── growing.png
│       └── mature.png
└── effects/
    ├── water_particle.png     (partícula de água ao regar)
    ├── harvest_particle.png   (partícula ao colher)
    └── till_particle.png      (partícula ao arar)
```

### 1.2 Especificações dos Sprites

**Tamanho Padrão:** 16x16 pixels (ou múltiplo de 16 para compatibilidade com tile size)

**Solo (4 sprites):**

- `untilled.png`: Terra marrom normal
- `tilled.png`: Terra com linhas horizontais indicando que foi arada
- `watered.png`: Terra mais escura, úmida
- `fertilized.png`: Terra com tom esverdeado ou brilho dourado

**Crops (7 crops × 4 estágios = 28 sprites):**
Cada crop precisa de 4 sprites mostrando evolução visual:

- **Seed:** Pequeno ponto marrom/semente no solo
- **Sprout:** Broto verde pequeno saindo do solo
- **Growing:** Planta média, visível mas não madura
- **Mature:** Planta completa com fruto/vegetal visível

**Efeitos (opcional, mas recomendado):**

- Partículas pequenas (4x4 ou 8x8 pixels)
- Podem ser sprites simples ou spritesheets para animação

### 1.3 Onde Encontrar Assets

**Opção 1 - Pixel Art Gratuito:**

- [itch.io](https://itch.io/game-assets/free/tag-farming) - Buscar "farming pixel art"
- [OpenGameArt](https://opengameart.org/) - Buscar "farm" ou "crops"
- [Kenney Assets](https://kenney.nl/) - Tem pacotes de farm

**Opção 2 - Criar Próprio:**

- Use [Aseprite](https://www.aseprite.org/) ou [Piskel](https://www.piskelapp.com/)
- Tamanho 16x16 é rápido de fazer
- Cores simples e high contrast funcionam bem

**Opção 3 - Assets Existentes do Projeto:**
Você já tem `assets/images/SunnysideWorld/` que pode ter sprites de farm!

---

## 🎯 PASSO 2: Atualizar pubspec.yaml

Adicione os novos assets ao `pubspec.yaml`:

```yaml
flutter:
  assets:
    # ... assets existentes ...
    - assets/crops/
    - assets/images/gameplay/farm/
    - assets/images/gameplay/farm/soil/
    - assets/images/gameplay/farm/crops/
    - assets/images/gameplay/farm/crops/carrot/
    - assets/images/gameplay/farm/crops/potato/
    - assets/images/gameplay/farm/crops/wheat/
    - assets/images/gameplay/farm/crops/pumpkin/
    - assets/images/gameplay/farm/crops/turnip/
    - assets/images/gameplay/farm/crops/tomato/
    - assets/images/gameplay/farm/crops/corn/
    - assets/images/gameplay/farm/effects/
```

**⚠️ IMPORTANTE:** Após adicionar, execute `flutter pub get` para registrar os assets.

---

## 🎯 PASSO 3: Criar FarmTileComponent

### 3.1 Criar o Arquivo

Crie: `lib/gameplay/farm/components/farm_tile_component.dart`

### 3.2 Código Base

```dart
import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_stage.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_state.dart';

/// Componente visual de um tile de fazenda
class FarmTileComponent extends GameDecoration {
  final FarmTile farmTile;

  SpriteComponent? _soilSprite;
  SpriteComponent? _cropSprite;
  bool _isHighlighted = false;

  FarmTileComponent({
    required this.farmTile,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(16), // Tamanho do tile
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadSoilSprite();
    await _loadCropSprite();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Atualizar sprites se tile mudou
    _updateSprites();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Renderizar highlight se hover
    if (_isHighlighted) {
      _renderHighlight(canvas);
    }
  }

  Future<void> _loadSoilSprite() async {
    final spritePath = _getSoilSpritePath();
    final sprite = await Sprite.load(spritePath);

    _soilSprite = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
    );

    add(_soilSprite!);
  }

  Future<void> _loadCropSprite() async {
    if (farmTile.crop == null) return;

    final spritePath = _getCropSpritePath();
    final sprite = await Sprite.load(spritePath);

    _cropSprite = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.center,
      priority: 1, // Acima do solo
    );

    add(_cropSprite!);
  }

  String _getSoilSpritePath() {
    switch (farmTile.soilState) {
      case SoilState.untilled:
        return 'gameplay/farm/soil/untilled.png';
      case SoilState.tilled:
        return 'gameplay/farm/soil/tilled.png';
      case SoilState.watered:
        return 'gameplay/farm/soil/watered.png';
      case SoilState.fertilized:
        return 'gameplay/farm/soil/fertilized.png';
    }
  }

  String _getCropSpritePath() {
    if (farmTile.crop == null) return '';

    final crop = farmTile.crop!;
    final stageName = _getStageFileName(crop.stage);

    return 'gameplay/farm/crops/${crop.cropId}/$stageName.png';
  }

  String _getStageFileName(CropStage stage) {
    switch (stage) {
      case CropStage.seed:
        return 'seed';
      case CropStage.sprout:
        return 'sprout';
      case CropStage.growing:
        return 'growing';
      case CropStage.mature:
        return 'mature';
      case CropStage.withered:
        return 'mature'; // Reusar sprite mature com opacity menor
    }
  }

  void _updateSprites() {
    // TODO: Recarregar sprites se farmTile mudou
    // Você pode adicionar lógica para detectar mudanças
  }

  void _renderHighlight(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x4400FF00) // Verde transparente
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);
  }

  void setHighlighted(bool highlighted) {
    _isHighlighted = highlighted;
  }

  /// Atualizar tile (chamado pelo FarmManager)
  void updateTile(FarmTile newTile) {
    // Recarregar sprites se necessário
    _loadSoilSprite();
    _loadCropSprite();
  }
}
```

---

## 🎯 PASSO 4: Criar FarmInteractionComponent

### 4.1 Criar o Arquivo

Crie: `lib/gameplay/farm/components/farm_interaction_component.dart`

### 4.2 Código Base

```dart
import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia interação do player com farm tiles
class FarmInteractionComponent extends GameComponent with KeyboardEventListener {
  final SimplePlayer player;

  FarmInteractionComponent({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    // Obter tile na frente do player
    final tileCoords = _getTileInFrontOfPlayer();
    if (tileCoords == null) return false;

    final x = tileCoords.$1;
    final y = tileCoords.$2;

    // H = Arar (Hoe)
    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      final success = FarmManager.instance.tillSoil(x, y);
      if (success) {
        developer.log('[FarmInteraction] Tilled soil at ($x, $y)');
        _showFloatingText('Terra Arada!');
      }
      return true;
    }

    // J = Regar (Water)
    if (event.logicalKey == LogicalKeyboardKey.keyJ) {
      final success = FarmManager.instance.waterTile(x, y);
      if (success) {
        developer.log('[FarmInteraction] Watered tile at ($x, $y)');
        _showFloatingText('Regado!');
      }
      return true;
    }

    // K = Plantar (Seed) - Exemplo com carrot
    if (event.logicalKey == LogicalKeyboardKey.keyK) {
      final success = FarmManager.instance.plantSeed(x, y, 'carrot');
      if (success) {
        developer.log('[FarmInteraction] Planted seed at ($x, $y)');
        _showFloatingText('Plantado!');
      }
      return true;
    }

    // R = Colher (Reap/Harvest)
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      final crop = FarmManager.instance.harvestCrop(x, y);
      if (crop != null) {
        developer.log('[FarmInteraction] Harvested ${crop.name} at ($x, $y)');
        _showFloatingText('Colhido ${crop.yieldAmount}x ${crop.name}!');
      }
      return true;
    }

    return false;
  }

  (int, int)? _getTileInFrontOfPlayer() {
    final direction = player.lastDirection;
    final playerPos = player.position;

    // Calcular tile baseado na direção
    final tileSize = 16.0;
    int x = (playerPos.x / tileSize).floor();
    int y = (playerPos.y / tileSize).floor();

    // Ajustar baseado na direção que player está olhando
    switch (direction) {
      case Direction.up:
        y -= 1;
        break;
      case Direction.down:
        y += 1;
        break;
      case Direction.left:
        x -= 1;
        break;
      case Direction.right:
        x += 1;
        break;
      case Direction.upLeft:
        x -= 1;
        y -= 1;
        break;
      case Direction.upRight:
        x += 1;
        y -= 1;
        break;
      case Direction.downLeft:
        x -= 1;
        y += 1;
        break;
      case Direction.downRight:
        x += 1;
        y += 1;
        break;
    }

    return (x, y);
  }

  void _showFloatingText(String text) {
    // TODO: Implementar floating text visual
    // Por enquanto só loga
    developer.log('[FarmInteraction] $text');
  }
}
```

---

## 🎯 PASSO 5: Integrar com TimeManager

### 5.1 Adicionar Listener de Novo Dia

No seu `TimeManager`, adicione integração com FarmManager:

```dart
// Em TimeManager, quando um novo dia começa:
void _onNewDay() {
  // ... código existente ...

  // Avançar crops da fazenda
  FarmManager.instance.advanceDay();

  developer.log('[TimeManager] New day - crops advanced');
}
```

Se você ainda não tem TimeManager, crie um método manual para testar:

```dart
// Em algum lugar no jogo (debug key)
if (event.logicalKey == LogicalKeyboardKey.keyN) {
  FarmManager.instance.advanceDay();
  developer.log('[DEBUG] Advanced 1 day manually');
}
```

---

## 🎯 PASSO 6: Adicionar Farm Tiles ao Mapa

### 6.1 Criar Área de Farm no Mapa

No seu mapa (provavelmente feito com Tiled), crie uma camada ou área designada para fazenda.

### 6.2 Gerar FarmTileComponents

No arquivo que carrega o mapa (ex: `gameplay_screen.dart` ou similar):

```dart
class GameplayScreen extends StatefulWidget {
  // ... código existente ...

  List<GameComponent> _createFarmTiles() {
    final farmTiles = <GameComponent>[];

    // Criar uma área 5x5 de farm tiles (exemplo)
    const farmStartX = 10; // Tile X inicial
    const farmStartY = 15; // Tile Y inicial
    const farmWidth = 5;
    const farmHeight = 5;

    for (var x = 0; x < farmWidth; x++) {
      for (var y = 0; y < farmHeight; y++) {
        final tileX = farmStartX + x;
        final tileY = farmStartY + y;

        // Obter ou criar tile do FarmManager
        var tile = FarmManager.instance.getTile(tileX, tileY);
        if (tile == null) {
          tile = FarmTile(x: tileX, y: tileY);
          FarmManager.instance.setTile(tile);
        }

        // Criar componente visual
        final component = FarmTileComponent(
          farmTile: tile,
          position: Vector2(
            tileX * 16.0, // 16 = tile size
            tileY * 16.0,
          ),
        );

        farmTiles.add(component);
      }
    }

    return farmTiles;
  }
}
```

### 6.3 Adicionar ao Jogo

No método que constrói o `BonfireWidget`:

```dart
@override
Widget build(BuildContext context) {
  return BonfireWidget(
    // ... parâmetros existentes ...

    components: [
      // ... componentes existentes ...
      ..._createFarmTiles(),
      FarmInteractionComponent(player: player),
    ],

    // ... resto do código ...
  );
}
```

---

## 🎯 PASSO 7: Testar e Ajustar

### 7.1 Checklist de Testes

Execute o jogo e teste:

- [ ] Farm tiles aparecem no mapa
- [ ] Sprites de solo corretos
- [ ] **Pressione H** perto de um tile → Solo deve ficar arado
- [ ] **Pressione W** em tile arado → Solo deve ficar molhado
- [ ] **Pressione P** em tile arado → Deve plantar semente (aparece sprite seed)
- [ ] **Pressione N** (debug) várias vezes → Crop deve crescer visualmente
- [ ] **Pressione R** em crop madura → Deve colher e tile volta ao normal
- [ ] Logs no console confirmando ações

### 7.2 Debug Common Issues

**Problema:** Sprites não aparecem

- ✅ Verificar que assets foram adicionados ao `pubspec.yaml`
- ✅ Executar `flutter pub get`
- ✅ Verificar paths dos sprites (case-sensitive!)
- ✅ Verificar se arquivos existem no diretório correto

**Problema:** Input não funciona

- ✅ Verificar que `FarmInteractionComponent` foi adicionado aos components
- ✅ Verificar que player está próximo do tile
- ✅ Verificar logs no console

**Problema:** Crops não crescem

- ✅ Verificar que `FarmManager.advanceDay()` está sendo chamado
- ✅ Verificar que tile tem soilState != untilled
- ✅ Verificar logs de crescimento

---

## 📊 Resultado Esperado

Após completar todos os passos, você terá:

✅ Farm tiles visíveis no mapa
✅ Sistema de input funcional (H/W/P/R)
✅ Crescimento visual de crops
✅ Animação de estágios (seed → sprout → growing → mature)
✅ Colheita funcional
✅ Logs detalhados para debug

---

## 🚀 Melhorias Futuras (Opcionais)

### Animações

- Adicionar partículas ao arar/regar/colher
- Transição suave entre estágios
- Efeito de água ao regar
- Sprite animation para crops maduras (balançando)

### UI/UX

- Tooltip mostrando info da crop ao passar mouse
- Barra de progresso de crescimento
- Indicador visual de "precisa regar"
- Menu de seleção de seed ao pressionar P

### Gameplay

- Integrar com inventário (verificar se tem ferramenta)
- Integrar com sistema de estações
- Adicionar fertilizantes
- Sistema de qualidade de crops

### Save/Load

- Salvar estado da fazenda no SaveManager
- Carregar farm ao iniciar jogo

---

## 📝 Notas Importantes

1. **Tile Size:** O código assume tiles de 16x16. Se seu jogo usa tamanho diferente, ajuste a constante `tileSize` nos cálculos.

2. **Performance:** Se criar muitos tiles (>100), considere usar um sistema de pooling ou renderizar apenas tiles visíveis na câmera.

3. **Camadas:** Farm tiles devem estar em camada abaixo do player para não sobrepor.

4. **Collision:** Se quiser que player não possa andar sobre crops plantadas, adicione collision boxes aos FarmTileComponents.

---

## ✅ Conclusão

Siga os passos na ordem e teste após cada etapa. Comece com assets simples (placeholders) e melhore depois. O sistema backend já está pronto, então você só precisa focar no visual!

**Boa sorte! 🌾✨**
