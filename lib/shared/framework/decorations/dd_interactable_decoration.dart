import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

abstract class DDInteractableDecoration extends DDDecoration
    with Vision, KeyboardEventListener {
  DDInteractableDecoration({required super.position, required super.size})
    : super();

  DDInteractableDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
