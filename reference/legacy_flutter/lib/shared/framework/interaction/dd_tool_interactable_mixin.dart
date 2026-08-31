import 'package:bonfire/bonfire.dart';

enum ToolType { shovel, hoe, axe }

mixin DDToolInteractableMixin on GameComponent {
  void onToolUsed(
    ToolType tool,
    GameComponent user, {
    required Vector2 position,
  });
}
