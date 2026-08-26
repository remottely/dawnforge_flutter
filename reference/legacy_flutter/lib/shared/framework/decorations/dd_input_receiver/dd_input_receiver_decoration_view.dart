import 'package:bonfire/bonfire.dart';

abstract class DDInputReceiverDecorationView extends GameDecoration
    with Vision, PlayerControllerListener {
  PlayerController? _registeredController;

  DDInputReceiverDecorationView({required super.position, required super.size});

  DDInputReceiverDecorationView.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();

  /// Register this component to receive input events from the player controller
  void registerToPlayerController(PlayerController controller) {
    if (_registeredController == controller) return;
    unregisterFromPlayerController();
    _registeredController = controller;
    controller.addObserver(this);
  }

  /// Unregister this component from the player controller
  void unregisterFromPlayerController() {
    if (_registeredController != null) {
      _registeredController!.removeObserver(this);
      _registeredController = null;
    }
  }

  @override
  void onRemove() {
    unregisterFromPlayerController();
    super.onRemove();
  }
}
