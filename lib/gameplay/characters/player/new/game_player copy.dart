// import 'package:bonfire/bonfire.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/new/animation_helper.dart';
// import 'package:darkness_dungeon/gameplay/characters/player/new/tool_type.dart';

// class GamePlayer extends SimplePlayer with BlockMovementCollision {
//   ToolType currentTool = ToolType.pickaxe;
//   bool isUsingTool = false;

//   // Cache de animações
//   final Map<ToolType, SimpleDirectionAnimation> _toolAnimations = {};

//   GamePlayer({
//     required Vector2 position,
//     required SimpleDirectionAnimation initialAnimation,
//   }) : super(
//          position: position,
//          size: Vector2.all(48), // cada frame é 48x48
//          animation: initialAnimation,
//          speed: 100,
//        ) {
//     setupBlockMovementCollision(enabled: true, bodyType: BodyType.dynamic);
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     // Hitbox ajustada para sprite 48x48
//     add(RectangleHitbox(size: Vector2(20, 20), position: Vector2(14, 20)));
//   }

//   /// Factory para criar o player com animações carregadas
//   static Future<GamePlayer> create({
//     required Vector2 position,
//     ToolType initialTool = ToolType.pickaxe,
//   }) async {
//     // Pré-carregar todas as animações
//     final pickaxeAnim = await AnimationHelper.getPickaxeAnimation();
//     final axeAnim = await AnimationHelper.getAxeAnimation();
//     final shovelAnim = await AnimationHelper.getShovelAnimation();
//     final wateringCanAnim = await AnimationHelper.getWateringCanAnimation();

//     final player = GamePlayer(
//       position: position,
//       initialAnimation: pickaxeAnim,
//     );

//     // Armazenar animações em cache
//     player._toolAnimations[ToolType.pickaxe] = pickaxeAnim;
//     player._toolAnimations[ToolType.axe] = axeAnim;
//     player._toolAnimations[ToolType.shovel] = shovelAnim;
//     player._toolAnimations[ToolType.wateringCan] = wateringCanAnim;

//     player.currentTool = initialTool;
//     player.animation = player._toolAnimations[initialTool];

//     // Estado inicial
//     player.animation?.idle();

//     return player;
//   }

//   @override
//   void joystickChangeDirectional(JoystickDirectionalEvent event) {
//     // Deixa o SimplePlayer processar movimento
//     super.joystickChangeDirectional(event);

//     // Atualiza visual (idle/run)
//     if (event.direction == JoystickDirection.idle) {
//       animation?.idle();
//     } else {
//       animation?.run();
//     }
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//   }

//   /// Troca a ferramenta atual
//   void switchTool(ToolType newTool) {
//     if (currentTool == newTool || isUsingTool) return;

//     final a = _toolAnimations[newTool];
//     if (a == null) return;

//     currentTool = newTool;
//     animation = a;

//     // Reaplica estado atual imediatamente
//     if (isIdle) {
//       animation
//           ?.idle(); // error: The method 'idle' isn't defined for the type 'SimpleDirectionAnimation'.
//       // Try correcting the name to the name of an existing method, or defining a method named 'idle'.
//     } else {
//       animation
//           ?.run(); // error: The method 'run' isn't defined for the type 'SimpleDirectionAnimation'.
//       // Try correcting the name to the name of an existing method, or defining a method named 'run'.
//     }
//   }

//   /// Usa a ferramenta atual (lógica; animação básica já está em loop)
//   void useTool() {
//     if (isUsingTool) return;

//     isUsingTool = true;

//     // Lógica específica de cada ferramenta
//     switch (currentTool) {
//       case ToolType.pickaxe:
//         _usePickaxe();
//         break;
//       case ToolType.axe:
//         _useAxe();
//         break;
//       case ToolType.shovel:
//         _useShovel();
//         break;
//       case ToolType.wateringCan:
//         _useWateringCan();
//         break;
//     }

//     // Após a ação, restaura estado visual
//     Future.delayed(const Duration(milliseconds: 300), () {
//       isUsingTool = false;
//       if (isIdle) {
//         animation
//             ?.idle(); // error: The method 'idle' isn't defined for the type 'SimpleDirectionAnimation'.
//         // Try correcting the name to the name of an existing method, or defining a method named 'idle'.
//       } else {
//         animation
//             ?.run(); // error: The method 'run' isn't defined for the type 'SimpleDirectionAnimation'.
//         // Try correcting the name to the name of an existing method, or defining a method named 'run'.
//       }
//     });
//   }

//   void _usePickaxe() {
//     final attackArea = _getAttackArea();
//     gameRef.query<Rock>().forEach((component) {
//       if (attackArea.overlaps(component.toRect())) {
//         component.removeFromParent();
//       }
//     });
//   }

//   void _useAxe() {
//     final attackArea = _getAttackArea();
//     gameRef.query<Tree>().forEach((component) {
//       if (attackArea.overlaps(component.toRect())) {
//         component.removeFromParent();
//       }
//     });
//   }

//   void _useShovel() {
//     final digArea = _getAttackArea();
//     // implementar sua lógica
//     digArea; // evita warning
//   }

//   void _useWateringCan() {
//     final waterArea = _getAttackArea();
//     gameRef.query<Plant>().forEach((component) {
//       if (waterArea.overlaps(component.toRect())) {
//         // implementar método de regar
//         // component.water();
//       }
//     });
//   }

//   /// Retorna a área de ataque baseada na direção
//   Rect _getAttackArea() {
//     const attackRange = 48.0;

//     switch (lastDirection) {
//       case Direction.up:
//         return Rect.fromLTWH(
//           position.x,
//           position.y - attackRange,
//           size.x,
//           attackRange,
//         );
//       case Direction.down:
//         return Rect.fromLTWH(
//           position.x,
//           position.y + size.y,
//           size.x,
//           attackRange,
//         );
//       case Direction.left:
//         return Rect.fromLTWH(
//           position.x - attackRange,
//           position.y,
//           attackRange,
//           size.y,
//         );
//       case Direction.right:
//         return Rect.fromLTWH(
//           position.x + size.x,
//           position.y,
//           attackRange,
//           size.y,
//         );
//       default:
//         return Rect.fromLTWH(position.x, position.y, size.x, size.y);
//     }
//   }

//   @override
//   void onJoystickAction(JoystickActionEvent event) {
//     if (event.event == ActionEvent.DOWN) {
//       if (event.id == 0) {
//         useTool();
//       } else if (event.id == 1) {
//         switchTool(ToolType.pickaxe);
//       } else if (event.id == 2) {
//         switchTool(ToolType.axe);
//       } else if (event.id == 3) {
//         switchTool(ToolType.shovel);
//       } else if (event.id == 4) {
//         switchTool(ToolType.wateringCan);
//       }
//     }
//     super.onJoystickAction(event);
//   }
// }

// // Exemplos simples (se for usar)
// class Rock extends GameDecoration with Sensor {
//   Rock(Vector2 position)
//     : super.withSprite(
//         sprite: Sprite.load('rock.png'),
//         position: position,
//         size: Vector2.all(32),
//       );
// }

// class Tree extends GameDecoration with Sensor {
//   Tree(Vector2 position)
//     : super.withSprite(
//         sprite: Sprite.load('tree.png'),
//         position: position,
//         size: Vector2.all(32),
//       );
// }

// class Plant extends GameDecoration with Sensor {
//   Plant(Vector2 position)
//     : super.withSprite(
//         sprite: Sprite.load('plant.png'),
//         position: position,
//         size: Vector2.all(32),
//       );
// }
