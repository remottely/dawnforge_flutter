import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:flutter/services.dart';

/// The single source of truth for player input (rules 11 and 12): gameplay
/// code asks THIS for the movement vector and, later, the unified cursor —
/// never a raw event or keyboard query. Keyboard is the first mode; gamepad
/// and touch land here too, so parity is structural.
///
/// Registered at boot and never null after (rule 28). The render layer feeds
/// key events in; the sim reads a normalized vector out.
final class InputHelper {
  final Set<LogicalKeyboardKey> _pressed = <LogicalKeyboardKey>{};

  /// The render layer forwards every key event here (rule 24: handlers read
  /// the event they were handed; per-frame polling happens in update, off the
  /// state this maintains).
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressed.remove(event.logicalKey);
    }
  }

  bool _any(List<LogicalKeyboardKey> keys) => keys.any(_pressed.contains);

  /// The normalized movement direction this frame (WASD + arrows).
  WorldPos getMovementVector() {
    var x = 0.0;
    var y = 0.0;
    if (_any(const [LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft])) {
      x -= 1;
    }
    if (_any(const [LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight])) {
      x += 1;
    }
    if (_any(const [LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp])) {
      y -= 1;
    }
    if (_any(const [LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown])) {
      y += 1;
    }
    return WorldPos(x, y).normalized();
  }
}
