import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

abstract class DDInputReceiverDecoration extends DDDecoration
    with Vision, KeyboardEventListener {
  DDInputReceiverDecoration({required super.position, required super.size})
    : super();

  DDInputReceiverDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
