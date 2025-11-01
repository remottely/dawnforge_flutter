import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_controller.dart';

class KidNpcView extends SimpleNpc {
  final KidNpcController _controller = KidNpcController();

  KidNpcView(Vector2 position)
    : super(
        animation: KidNpcConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: KidNpcConfig.fComponentSize,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }
}
