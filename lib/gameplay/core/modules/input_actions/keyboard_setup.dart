import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class KeyboardSetup {
  KeyboardSetup._();

  /// Keyboard
  static const LogicalKeyboardKey kPrimaryAttackKey = LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kFireballAttackKey = LogicalKeyboardKey.keyZ;
  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyX;

  static final List<KeyboardDirectionalKeys> keyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> keyboardAcceptedKeys = [
    kPrimaryAttackKey,
    kFireballAttackKey,
  ];

  static PlayerController createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: keyboardDirectionalKeys,
        acceptedKeys: keyboardAcceptedKeys,
      ),
    );
  }
}
