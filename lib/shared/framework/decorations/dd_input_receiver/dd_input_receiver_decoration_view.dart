import 'package:bonfire/bonfire.dart';

abstract class DDInputReceiverDecorationView extends GameDecoration
    with Vision, KeyboardEventListener {
  DDInputReceiverDecorationView({required super.position, required super.size});

  DDInputReceiverDecorationView.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
