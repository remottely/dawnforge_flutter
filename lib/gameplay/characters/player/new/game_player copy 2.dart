// Opções de Hitbox:
// Retângulo
// add(RectangleHitbox(
//   size: Vector2(16, 16),
//   position: Vector2(8, 16),
// ));

// // Círculo
// add(CircleHitbox(
//   radius: 8,
//   position: Vector2(16, 16),
// ));

// // Polígono customizado
// add(PolygonHitbox([
//   Vector2(8, 0),
//   Vector2(24, 0),
//   Vector2(32, 32),
//   Vector2(0, 32),
// ]));

// // Múltiplas hitboxes (exemplo: separar corpo e pés)
// add(RectangleHitbox(
//   size: Vector2(16, 8),  // Hitbox dos pés
//   position: Vector2(8, 24),
// ));
// add(RectangleHitbox(
//   size: Vector2(20, 16), // Hitbox do corpo
//   position: Vector2(6, 8),
// ));
// Para objetos do jogo com colisão:
// class Rock extends GameDecoration with BlockMovementCollision {
//   Rock(Vector2 position)
//       : super.withSprite(
//           sprite: Sprite.load('rock.png'),
//           position: position,
//           size: Vector2.all(32),
//         ) {
//     setupBlockMovementCollision(
//       enabled: true,
//       bodyType: BodyType.static, // Pedra não se move
//     );
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     add(RectangleHitbox(size: Vector2.all(28)));
//   }
// }
// Debug de colisão:
// @override
// Future<void> onLoad() async {
//   await super.onLoad();

//   final hitbox = RectangleHitbox(
//     size: Vector2(16, 16),
//     position: Vector2(8, 16),
//   );

//   // Ativar debug para ver a hitbox
//   hitbox.debugMode = true;

//   add(hitbox);
// }

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/tool_type.dart';

class GamePlayer extends SimplePlayer with BlockMovementCollision {
  ToolType currentTool = ToolType.pickaxe;
  bool isUsingTool = false;

  // Cache de animações
  final Map<ToolType, SimpleDirectionAnimation> _toolAnimations = {};

  GamePlayer({
    required Vector2 position,
    required SimpleDirectionAnimation initialAnimation,
  }) : super(
         position: position,
         size: Vector2.all(32), // Ajuste conforme seu sprite
         animation: initialAnimation,
         speed: 100,
       ) {
    // ✅ Configurar colisão com os parâmetros corretos
    setupBlockMovementCollision(enabled: true, bodyType: BodyType.dynamic);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ Adicionar hitbox para colisão
    add(
      RectangleHitbox(
        size: Vector2(16, 16), // Área de colisão menor que o sprite
        position: Vector2(8, 16), // Offset da hitbox
      ),
    );
  }

  /// Factory para criar o player com animações carregadas
  static Future<GamePlayer> create({
    required Vector2 position,
    ToolType initialTool = ToolType.pickaxe,
  }) async {
    // Pré-carregar todas as animações
    final pickaxeAnim = await AnimationHelper.getPickaxeAnimation();
    final axeAnim = await AnimationHelper.getAxeAnimation();
    final shovelAnim = await AnimationHelper.getShovelAnimation();
    final wateringCanAnim = await AnimationHelper.getWateringCanAnimation();

    final player = GamePlayer(
      position: position,
      initialAnimation: pickaxeAnim,
    );

    // Armazenar animações em cache
    player._toolAnimations[ToolType.pickaxe] = pickaxeAnim;
    player._toolAnimations[ToolType.axe] = axeAnim;
    player._toolAnimations[ToolType.shovel] = shovelAnim;
    player._toolAnimations[ToolType.wateringCan] = wateringCanAnim;

    player.currentTool = initialTool;
    player.animation = player._toolAnimations[initialTool];

    return player;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Aqui você pode adicionar lógica adicional
  }

  @override
  void render(Canvas canvas) {
    // O espelhamento agora é feito pela própria SimpleDirectionAnimation
    // através do enabledFlipX, então não precisa fazer manualmente
    super.render(canvas);
  }

  /// Troca a ferramenta atual
  void switchTool(ToolType newTool) {
    if (currentTool == newTool || isUsingTool) return;

    currentTool = newTool;

    // Trocar animação
    if (_toolAnimations.containsKey(newTool)) {
      animation = _toolAnimations[newTool];
    }
  }

  /// Usa a ferramenta atual
  void useTool() {
    if (isUsingTool) return;

    isUsingTool = true;

    // A animação já está tocando, apenas executar a lógica
    // Lógica específica de cada ferramenta
    switch (currentTool) {
      case ToolType.pickaxe:
        _usePickaxe();
        break;
      case ToolType.axe:
        _useAxe();
        break;
      case ToolType.shovel:
        _useShovel();
        break;
      case ToolType.wateringCan:
        _useWateringCan();
        break;
    }

    // Aguardar fim da animação
    Future.delayed(const Duration(milliseconds: 300), () {
      isUsingTool = false;
    });
  }

  void _usePickaxe() {
    // Lógica para quebrar pedras
    print('🪨 Usando picareta!');

    // Exemplo: verificar objetos na direção que está olhando
    final attackArea = _getAttackArea();

    gameRef.query<Rock>().forEach((component) {
      if (attackArea.overlaps(component.toRect())) {
        // Quebrar pedra
        component.removeFromParent();
      }
    });
  }

  void _useAxe() {
    // Lógica para cortar árvores
    print('🪓 Usando machado!');

    final attackArea = _getAttackArea();

    gameRef.query<Tree>().forEach((component) {
      if (attackArea.overlaps(component.toRect())) {
        // Cortar árvore
        component.removeFromParent();
      }
    });
  }

  void _useShovel() {
    // Lógica para cavar
    print('⛏️ Usando pá!');

    final digArea = _getAttackArea();
    // Implementar lógica de cavar
  }

  void _useWateringCan() {
    // Lógica para regar plantas
    print('💧 Usando regador!');

    final waterArea = _getAttackArea();

    gameRef.query<Plant>().forEach((component) {
      if (waterArea.overlaps(component.toRect())) {
        // Regar planta
        // component.water(); // Implemente seu método
      }
    });
  }

  /// Retorna a área de ataque baseada na direção
  Rect _getAttackArea() {
    const attackRange = 32.0;

    switch (lastDirection) {
      case Direction.up:
        return Rect.fromLTWH(
          position.x,
          position.y - attackRange,
          size.x,
          attackRange,
        );
      case Direction.down:
        return Rect.fromLTWH(
          position.x,
          position.y + size.y,
          size.x,
          attackRange,
        );
      case Direction.left:
        return Rect.fromLTWH(
          position.x - attackRange,
          position.y,
          attackRange,
          size.y,
        );
      case Direction.right:
        return Rect.fromLTWH(
          position.x + size.x,
          position.y,
          attackRange,
          size.y,
        );
      default:
        return Rect.fromLTWH(position.x, position.y, size.x, size.y);
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    // Verificar se o botão foi pressionado
    if (event.event == ActionEvent.DOWN) {
      // Botão de ação pressionado
      if (event.id == 0) {
        useTool();
      }
      // Trocar ferramenta com outros botões
      else if (event.id == 1) {
        switchTool(ToolType.pickaxe);
      } else if (event.id == 2) {
        switchTool(ToolType.axe);
      } else if (event.id == 3) {
        switchTool(ToolType.shovel);
      } else if (event.id == 4) {
        switchTool(ToolType.wateringCan);
      }
    }

    super.onJoystickAction(event);
  }
}

// Classes de exemplo para objetos do jogo
class Rock extends GameDecoration with Sensor {
  Rock(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('rock.png'),
        position: position,
        size: Vector2.all(32),
      );
}

class Tree extends GameDecoration with Sensor {
  Tree(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('tree.png'),
        position: position,
        size: Vector2.all(32),
      );
}

class Plant extends GameDecoration with Sensor {
  Plant(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('plant.png'),
        position: position,
        size: Vector2.all(32),
      );
}
