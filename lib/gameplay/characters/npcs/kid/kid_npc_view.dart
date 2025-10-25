import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_controller.dart';

/// KidNpcView
/// ---------------------------------------------------------------------------
/// Visual and interaction layer for Kid NPC. Handles rendering, collision, and delegates logic to the controller.
class KidNpcView extends SimpleNpc {
  /// Controller orchestrates logic and communication
  final KidNpcController _controller = KidNpcController();

  KidNpcView(Vector2 position)
    : super(
        animation: KidNpcConfig.buildDirectionalAnimation,
        position: position,
        size: KidNpcConfig.spriteSize,
      );

  /// Called when the component is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
  }

  /// Called every game tick
  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }
}
