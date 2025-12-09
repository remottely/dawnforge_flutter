import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/tool_type.dart';

class GamePlayer extends SimplePlayer with BlockMovementCollision {
  ToolType currentTool = ToolType.pickaxe;
  bool isUsingTool = false;

  // Guarda o último input direcional (se precisar usar em outra lógica)
  JoystickDirectionalEvent? _bufferedDirectionalInput;

  // Cache de animações por ferramenta
  final Map<ToolType, SimpleDirectionAnimation> _toolAnimations = {};

  GamePlayer({
    required Vector2 position,
    required SimpleDirectionAnimation initialAnimation,
  }) : super(
         position: position,
         size: Vector2.all(48), // cada frame é 48x48
         animation: initialAnimation,
         speed: 100,
       ) {
    setupBlockMovementCollision(enabled: true, bodyType: BodyType.dynamic);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: Vector2(20, 20), position: Vector2(14, 20)));
  }

  static Future<GamePlayer> create({
    required Vector2 position,
    ToolType initialTool = ToolType.pickaxe,
  }) async {
    final pickaxeAnim = await AnimationHelper.getPickaxeAnimation();
    final axeAnim = await AnimationHelper.getAxeAnimation();
    final shovelAnim = await AnimationHelper.getShovelAnimation();
    final wateringCanAnim = await AnimationHelper.getWateringCanAnimation();

    final player = GamePlayer(
      position: position,
      initialAnimation: pickaxeAnim,
    );

    player._toolAnimations[ToolType.pickaxe] = pickaxeAnim;
    player._toolAnimations[ToolType.axe] = axeAnim;
    player._toolAnimations[ToolType.shovel] = shovelAnim;
    player._toolAnimations[ToolType.wateringCan] = wateringCanAnim;

    player.currentTool = initialTool;
    player.animation = player._toolAnimations[initialTool];

    // Estado inicial
    player.animation?.play(SimpleAnimationEnum.idleDown);

    return player;
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    // Bufferiza o último input direcional (útil para outras lógicas)
    _bufferedDirectionalInput = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );

    // Atualiza visual conforme o direcional
    switch (event.directional) {
      case JoystickMoveDirectional.IDLE:
        // Usa a última direção para escolher o idle correspondente
        switch (lastDirection) {
          case Direction.left:
            animation?.play(SimpleAnimationEnum.idleLeft);
            break;
          case Direction.right:
            animation?.play(SimpleAnimationEnum.idleRight);
            break;
          case Direction.up:
            animation?.play(SimpleAnimationEnum.idleUp);
            break;
          case Direction.down:
          default:
            animation?.play(SimpleAnimationEnum.idleDown);
            break;
        }
        break;

      case JoystickMoveDirectional.MOVE_LEFT:
        animation?.play(SimpleAnimationEnum.runLeft);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        animation?.play(SimpleAnimationEnum.runRight);
        break;
      case JoystickMoveDirectional.MOVE_UP:
        animation?.play(SimpleAnimationEnum.runUp);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        animation?.play(SimpleAnimationEnum.runDown);
        break;

      // Diagonais (se suas animações suportarem eightDirection)
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        animation?.play(SimpleAnimationEnum.runUpLeft);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        animation?.play(SimpleAnimationEnum.runUpRight);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        animation?.play(SimpleAnimationEnum.runDownLeft);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        animation?.play(SimpleAnimationEnum.runDownRight);
        break;
    }

    // Importante: chame o super para que o SimplePlayer processe o movimento
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;

    // Mapeamento dos botões (ajuste conforme IDs do seu Joystick)
    if (event.event == ActionEvent.DOWN) {
      if (event.id == 0) {
        useTool();
      } else if (event.id == 1) {
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void switchTool(ToolType newTool) {
    if (currentTool == newTool || isUsingTool) return;

    final a = _toolAnimations[newTool];
    if (a == null) return;

    currentTool = newTool;
    animation = a;

    // Reaplica estado atual imediatamente usando play()
    if (isIdle) {
      switch (lastDirection) {
        case Direction.left:
          animation?.play(SimpleAnimationEnum.idleLeft);
          break;
        case Direction.right:
          animation?.play(SimpleAnimationEnum.idleRight);
          break;
        case Direction.up:
          animation?.play(SimpleAnimationEnum.idleUp);
          break;
        case Direction.down:
        default:
          animation?.play(SimpleAnimationEnum.idleDown);
          break;
      }
    } else {
      switch (lastDirection) {
        case Direction.left:
          animation?.play(SimpleAnimationEnum.runLeft);
          break;
        case Direction.right:
          animation?.play(SimpleAnimationEnum.runRight);
          break;
        case Direction.up:
          animation?.play(SimpleAnimationEnum.runUp);
          break;
        case Direction.down:
        default:
          animation?.play(SimpleAnimationEnum.runDown);
          break;
      }
    }
  }

  void useTool() {
    if (isUsingTool) return;
    isUsingTool = true;

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

    // Após a ação, restaura estado visual com play()
    Future.delayed(const Duration(milliseconds: 300), () {
      isUsingTool = false;

      if (isIdle) {
        switch (lastDirection) {
          case Direction.left:
            animation?.play(SimpleAnimationEnum.idleLeft);
            break;
          case Direction.right:
            animation?.play(SimpleAnimationEnum.idleRight);
            break;
          case Direction.up:
            animation?.play(SimpleAnimationEnum.idleUp);
            break;
          case Direction.down:
          default:
            animation?.play(SimpleAnimationEnum.idleDown);
            break;
        }
      } else {
        switch (lastDirection) {
          case Direction.left:
            animation?.play(SimpleAnimationEnum.runLeft);
            break;
          case Direction.right:
            animation?.play(SimpleAnimationEnum.runRight);
            break;
          case Direction.up:
            animation?.play(SimpleAnimationEnum.runUp);
            break;
          case Direction.down:
          default:
            animation?.play(SimpleAnimationEnum.runDown);
            break;
        }
      }
    });
  }

  void _usePickaxe() {
    final attackArea = _getAttackArea();
    gameRef.query<Rock>().forEach((component) {
      if (attackArea.overlaps(component.toRect())) {
        component.removeFromParent();
      }
    });
  }

  void _useAxe() {
    final attackArea = _getAttackArea();
    gameRef.query<Tree>().forEach((component) {
      if (attackArea.overlaps(component.toRect())) {
        component.removeFromParent();
      }
    });
  }

  void _useShovel() {
    final digArea = _getAttackArea();
    // implementar sua lógica
    digArea; // evita warning
  }

  void _useWateringCan() {
    final waterArea = _getAttackArea();
    gameRef.query<Plant>().forEach((component) {
      if (waterArea.overlaps(component.toRect())) {
        // implementar método de regar
        // component.water();
      }
    });
  }

  Rect _getAttackArea() {
    const attackRange = 48.0;

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
}

// Exemplos simples (se for usar)
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
