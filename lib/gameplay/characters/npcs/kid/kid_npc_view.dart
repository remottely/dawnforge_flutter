import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_controller.dart';

/// A View (Componente Bonfire)
/// Responsável apenas por exibir elementos visuais, animações, sons
/// e capturar entradas, delegando toda a lógica para o Controller.
class KidNpcView extends SimpleNpc {
  final KidNpcController _controller;

  KidNpcView(Vector2 position, {required KidNpcController controller})
    : _controller = controller,
      super(
        animation: KidNpcConfig.buildDirectionalAnimation,
        position: position,
        size: KidNpcConfig.spriteSize,
      ) {
    _controller.attachView(this);
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }
}
