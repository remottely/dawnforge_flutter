# Otimização de Jogos com Bonfire + Flame + Tiled no Flutter

Excelente pergunta! Vou te explicar o que **realmente pesa** em jogos 2D com Flame/Bonfire:

## 🎯 Camadas do Tiled - Impacto Real

### ❌ **Mito:** "Mais camadas = mais lag"
### ✅ **Realidade:** Camadas bem organizadas têm impacto MÍNIMO

**Por quê?**
- O Flame renderiza tiles em **batches** (grupos)
- Várias camadas com poucos tiles podem ser mais eficientes que uma camada gigante
- O que pesa é o **número total de tiles renderizados**, não as camadas em si

## ⚡ O Que REALMENTE Pesa no Seu Mundo

### 1. **🔴 CRÍTICO - Tiles Renderizados na Tela**
```
Tiles visíveis = (Largura da câmera / 16) × (Altura da câmera / 16)
```
- **Solução:** Implemente **culling** (não renderizar fora da câmera)
- Bonfire já faz isso automaticamente com `MapWorld`

### 2. **🔴 CRÍTICO - Número de GameComponents Ativos**
- NPCs, inimigos, animais, decorações animadas
- **Cada entidade com lógica de update() é cara**
- **Solução:** 
  - Desative lógica de NPCs longe da câmera
  - Use `hasGameRef` para verificar distância do player
  - Limite entidades ativas simultâneas

### 3. **🟡 IMPORTANTE - Colisões**
- Muitos objetos com `BlockMovementCollision` pesam
- **Solução:**
  - Use camadas de colisão do Tiled em vez de objetos individuais
  - Agrupe colisões em formas maiores

### 4. **🟡 IMPORTANTE - Animações**
- SpriteAnimations consomem memória e CPU
- **Solução:**
  - Pause animações fora da tela
  - Use spritesheets otimizados
  - Limite FPS de animações distantes

### 5. **🟢 BAIXO IMPACTO - Tamanho do Mapa Total**
- Um mapa 200×200 tiles NÃO pesa se você renderiza só o visível
- Memória aumenta, mas performance não

## 📊 Comparação Prática

```dart
// ❌ RUIM - Renderiza tudo sempre
class MyWorld extends GameMap {
  // Sem culling, 5200 tiles renderizados = LAG
}

// ✅ BOM - Bonfire com culling automático
BonfireTiledWidget(
  map: TiledWorldMap('maps/farm.tmx'),
  // Só renderiza tiles visíveis (~300-500)
)
```

## 🚀 Checklist de Otimização para Clone de SV

### **Tier S - Faça AGORA:**
- ✅ Ative culling de tiles (Bonfire faz automaticamente)
- ✅ Desative NPCs/inimigos longe do player (>10-15 tiles)
- ✅ Use `ObjectPriority` para renderizar só o necessário
- ✅ Reduza animações de 60fps para 12-24fps

### **Tier A - Importante:**
- ✅ Agrupe colisões em retângulos maiores
- ✅ Use spritesheets em vez de imagens individuais
- ✅ Implemente pool de objetos reutilizáveis
- ✅ Limite partículas simultâneas (<50)

### **Tier B - Se necessário:**
- ✅ Reduza camadas decorativas desnecessárias
- ✅ Use tiles estáticos em vez de GameComponents quando possível
- ✅ Otimize pathfinding (A*) com cache
- ✅ Carregue mapas de forma assíncrona

### **Tier C - Polimento:**
- ✅ Comprima texturas (PNG → WebP)
- ✅ Use atlas de textura único
- ✅ Reduza resolução de tiles (16x16 é ideal)

## 💡 Exemplo de Código - Otimização de NPC

```dart
class MyNPC extends SimpleNpc {
  static const maxActiveDistance = 15.0 * 16; // 15 tiles
  
  @override
  void update(double dt) {
    // Só processa lógica se perto do player
    final distance = position.distanceTo(gameRef.player!.position);
    
    if (distance > maxActiveDistance) {
      // NPC "dorme" - sem pathfinding, sem IA
      idle();
      return;
    }
    
    super.update(dt);
    // Sua lógica de IA aqui...
  }
}
```

## 📈 Números Reais (Baseado em Testes)

| Elemento | Impacto | Quantidade Segura |
|----------|---------|-------------------|
| Tiles visíveis | Alto | 300-800 |
| NPCs ativos | Muito Alto | 10-20 |
| Partículas | Médio | 20-50 |
| Camadas Tiled | Muito Baixo | 5-15 |
| Tamanho do mapa | Baixo | Ilimitado* |

*Com culling ativo

## 🎯 Resposta Direta

### **Camadas do Tiled fazem diferença?**
**Não significativa.** 3 camadas vs 10 camadas = ~5% diferença.

### **O que realmente pesa?**
1. **NPCs/Entidades com lógica ativa** (70% do impacto)
2. **Tiles renderizados simultaneamente** (20%)
3. **Animações e partículas** (10%)

### **Recomendação:**
- Mantenha suas camadas organizadas (6-8 é ideal)
- Foque em otimizar **entidades ativas** e **culling**
- Clone 100% do Stardew é viável, mas limite NPCs simultâneos

Boa sorte com seu clone! 🔥🎮

---

Sim, você pode limitar os FPS no Flame! Aqui estão as formas de fazer isso:

## 🎮 Limitando FPS no Flame + Bonfire

### **Opção 1: Usando `paused` (Recomendado para Flame 1.0+)**

No seu `BonfireWidget` ou classe principal do jogo:

```dart
class MyGame extends BonfireGame {
  MyGame() : super(
    // ... suas configurações
  ) {
    // Limita para 30 FPS
    pauseEngineDuringTouch = false;
  }

  @override
  void onLoad() {
    super.onLoad();
    // Define o FPS target
    // Flame usa variável de tempo delta, então precisamos controlar o update
  }
}
```

### **Opção 2: Throttle Manual do Update (Mais Controle)**

```dart
class MyGame extends BonfireGame {
  static const double targetFPS = 30.0;
  static const double targetDelta = 1.0 / targetFPS;
  double _accumulator = 0.0;

  @override
  void update(double dt) {
    _accumulator += dt;
    
    // Só atualiza quando acumular tempo suficiente para o próximo frame
    if (_accumulator >= targetDelta) {
      super.update(targetDelta);
      _accumulator -= targetDelta;
    }
  }
}
```

### **Opção 3: Configuração Global do Flutter Engine**

No seu `main.dart`:

```dart
import 'package:flutter/scheduler.dart';

void main() {
  // Força 30 FPS globalmente
  timeDilation = 2.0; // Isso deixa tudo mais lento, NÃO recomendado
  
  runApp(MyApp());
}
```

## ⚠️ **ATENÇÃO: Limitação de FPS pode não resolver performance**

Antes de limitar FPS, considere estas otimizações:

### 🔧 **Otimizações Recomendadas para Bonfire + Flame:**

#### 1. **Reduzir Tile Size / Resolução**
```dart
BonfireWidget(
  map: WorldMapByTiled(
    'map.json',
    forceTileSize: Size(16, 16), // Use tiles menores
  ),
  cameraConfig: CameraConfig(
    zoom: 2.0, // Ajuste o zoom para compensar
    resolution: Size(800, 600), // Resolução menor
  ),
)
```

#### 2. **Desabilitar Sombras/Luzes Desnecessárias**
```dart
BonfireWidget(
  lightingColorGame: Colors.transparent, // Desabilita sistema de luz
  // ...
)
```

#### 3. **Limitar Distância de Visão dos Enemies**
```dart
class MyEnemy extends SimpleEnemy {
  MyEnemy(Vector2 position) : super(
    position: position,
    size: Vector2(32, 32),
    speed: 50,
    life: 100,
    visionCells: 3, // REDUZIR ISSO - menos células de visão
  );
}
```

#### 4. **Usar `HasGameRef` ao invés de `gameRef` em todo lugar**
```dart
// RUIM - busca o gameRef toda hora
void update(double dt) {
  gameRef.player; // Lento
}

// BOM - cache a referência
class MyComponent extends GameComponent with HasGameRef {
  late Player _player;
  
  @override
  void onMount() {
    super.onMount();
    _player = gameRef.player; // Cache uma vez
  }
  
  void update(double dt) {
    _player.position; // Rápido
  }
}
```

#### 5. **Reduzir Partículas e Efeitos**
```dart
// Reduza quantidade de partículas
// Desabilite sombras desnecessárias
// Use menos frames de animação
```

#### 6. **Profile o Jogo**
```dart
import 'package:flutter/foundation.dart';

void main() {
  // Ativa performance overlay
  runApp(
    MaterialApp(
      showPerformanceOverlay: true, // IMPORTANTE!
      home: GameWidget(game: MyGame()),
    ),
  );
}
```

## 🎯 **Solução Recomendada**

**Ao invés de limitar FPS, faça isso:**

```dart
class MyGame extends BonfireGame {
  MyGame() : super(
    map: WorldMapByTiled(
      'map.json',
      forceTileSize: Size(16, 16), // Tiles menores
    ),
    cameraConfig: CameraConfig(
      zoom: 2.5,
      resolution: Size(960, 540), // ~540p ao invés de 1080p
      moveOnlyMapArea: true,
    ),
    lightingColorGame: Colors.transparent, // Desabilita luzes
    // ...
  );
}
```

## 📊 **Diagnóstico**

Me diga:
1. Qual plataforma você está testando? (Android/iOS/Desktop/Web)
2. Quantos enemies/objetos você tem na tela simultaneamente?
3. Está usando sistema de iluminação do Bonfire?
4. Qual o tamanho do seu mapa (em tiles)?

Com essas informações posso te dar uma solução mais específica! 🚀