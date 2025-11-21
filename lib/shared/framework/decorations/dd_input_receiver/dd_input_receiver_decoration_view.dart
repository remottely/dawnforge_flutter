import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

abstract class DDInputReceiverDecorationView extends DDDecoration
    with Vision, KeyboardEventListener {
  DDInputReceiverDecorationView({required super.position, required super.size});

  DDInputReceiverDecorationView.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
