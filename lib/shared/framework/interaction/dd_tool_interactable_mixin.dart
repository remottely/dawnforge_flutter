import 'package:bonfire/bonfire.dart';

/// Tipos de ferramentas suportadas.
enum ToolType { shovel, hoe, axe }

/// Mixin para componentes que podem reagir ao uso de ferramentas.
mixin DDToolInteractableMixin on GameComponent {
  void onToolUsed(
    ToolType tool,
    GameComponent user, {
    required Vector2 position,
  });
}
