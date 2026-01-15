import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/kid/kid_npc_def.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/kid/kid_npc_controller.dart';

class KidNpcView extends SimpleNpc {
  final KidNpcController _controller = KidNpcController();

  KidNpcView({required super.position})
    : super(
        animation: KidNpcDef.animationWalkDirectional,
        size: KidNpcDef.componentSize,
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
