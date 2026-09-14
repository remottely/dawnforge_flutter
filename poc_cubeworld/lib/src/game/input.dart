import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pointer_lock/pointer_lock.dart';

/// Every action the game reads. Keys are physical (WASD stays WASD on any
/// layout), matching the Godot POC's input map.
enum GameAction {
  moveForward,
  moveBack,
  moveLeft,
  moveRight,
  jump,
  sprint,
  sneak,
  attack,
  use,
  inventory,
  dropItem,
  toggleView,
  ability,
  ability2,
  glide,
  interact,
  pause,
  eat,
  map,
  debugHud,
  screenshot,
  fly,
  dodge,
  journal,
  skipTutorial, // stage 30
}

/// Held keys, one-shot presses, mouse buttons, wheel and the captured mouse
/// delta. The simulation drains it once per fixed step.
class GameInput {
  GameInput() {
    final lock = PointerLock.instance;
    _stateSub = lock.onStateChanged.listen((state) {
      if (state == CaptureState.released && wantCapture) {
        // An unrequested release (focus loss): the game notices via
        // [captureLost] and opens its pause menu.
        captureLost = true;
        wantCapture = false;
      }
    });
  }

  static const Map<GameAction, List<PhysicalKeyboardKey>> _keys = {
    GameAction.moveForward: [PhysicalKeyboardKey.keyW],
    GameAction.moveBack: [PhysicalKeyboardKey.keyS],
    GameAction.moveLeft: [PhysicalKeyboardKey.keyA],
    GameAction.moveRight: [PhysicalKeyboardKey.keyD],
    GameAction.jump: [PhysicalKeyboardKey.space],
    GameAction.sprint: [PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight],
    GameAction.sneak: [PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight],
    GameAction.inventory: [PhysicalKeyboardKey.keyE, PhysicalKeyboardKey.tab],
    GameAction.dropItem: [PhysicalKeyboardKey.keyQ],
    GameAction.toggleView: [PhysicalKeyboardKey.keyV],
    GameAction.ability: [PhysicalKeyboardKey.keyR],
    // Stage 23: Q, the same physical key Godot binds to both drop_item and
    // ability2 (a press does both there too).
    GameAction.ability2: [PhysicalKeyboardKey.keyQ],
    GameAction.glide: [PhysicalKeyboardKey.keyG],
    GameAction.interact: [PhysicalKeyboardKey.keyF],
    GameAction.pause: [PhysicalKeyboardKey.escape],
    GameAction.eat: [PhysicalKeyboardKey.keyH],
    GameAction.map: [PhysicalKeyboardKey.keyM],
    GameAction.debugHud: [PhysicalKeyboardKey.f1],
    GameAction.screenshot: [PhysicalKeyboardKey.f2],
    GameAction.fly: [PhysicalKeyboardKey.f5],
    GameAction.dodge: [PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight],
    GameAction.journal: [PhysicalKeyboardKey.keyJ],
    GameAction.skipTutorial: [PhysicalKeyboardKey.f6],
  };

  static const List<PhysicalKeyboardKey> _digits = [
    PhysicalKeyboardKey.digit1,
    PhysicalKeyboardKey.digit2,
    PhysicalKeyboardKey.digit3,
    PhysicalKeyboardKey.digit4,
    PhysicalKeyboardKey.digit5,
    PhysicalKeyboardKey.digit6,
    PhysicalKeyboardKey.digit7,
    PhysicalKeyboardKey.digit8,
    PhysicalKeyboardKey.digit9,
  ];

  final Set<PhysicalKeyboardKey> _held = {};
  final Set<PhysicalKeyboardKey> _pressed = {};
  bool _leftDown = false;
  bool _rightDown = false;
  bool _leftPressed = false;
  bool _rightPressed = false;
  int _wheel = 0;
  double _dragDx = 0.0;
  double _dragDy = 0.0;
  StreamSubscription<CaptureState>? _stateSub;

  /// Whether the game wants the mouse captured (Godot's MOUSE_MODE_CAPTURED).
  bool wantCapture = false;
  bool captureLost = false;

  bool get pointerLockSupported => PointerLock.instance.isSupported;
  bool get isCaptured => wantCapture && (PointerLock.instance.isCaptured || !pointerLockSupported);

  Future<void> capture() async {
    wantCapture = true;
    captureLost = false;
    _dragDx = 0;
    _dragDy = 0;
    if (PointerLock.instance.isSupported) await PointerLock.instance.capture();
  }

  Future<void> release() async {
    wantCapture = false;
    if (PointerLock.instance.isSupported) await PointerLock.instance.release();
  }

  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    final key = event.physicalKey;
    if (event is KeyDownEvent) {
      _held.add(key);
      _pressed.add(key);
    } else if (event is KeyUpEvent) {
      _held.remove(key);
    }
    // Swallow everything while playing so macOS does not beep at held keys.
    return KeyEventResult.handled;
  }

  void releaseKeys() => _held.clear();

  /// Probe hook: hold or release an action's first key as if it were typed, so
  /// a screenshot run can drive the simulation without a keyboard.
  void probeHold(GameAction a, bool down) {
    final key = _keys[a]!.first;
    if (down) {
      _held.add(key);
      _pressed.add(key);
    } else {
      _held.remove(key);
    }
  }

  void onPointerDown(PointerDownEvent e) {
    if (e.buttons & kPrimaryMouseButton != 0) {
      _leftDown = true;
      _leftPressed = true;
    }
    if (e.buttons & kSecondaryMouseButton != 0) {
      _rightDown = true;
      _rightPressed = true;
    }
  }

  void onPointerUp(PointerUpEvent e) {
    _leftDown = false;
    _rightDown = false;
  }

  void onPointerMove(PointerMoveEvent e) {
    // Drag-to-look fallback where the pointer cannot be locked.
    if (!pointerLockSupported && wantCapture) {
      _dragDx += e.delta.dx;
      _dragDy += e.delta.dy;
    }
  }

  void onPointerSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      if (e.scrollDelta.dy > 0) _wheel += 1;
      if (e.scrollDelta.dy < 0) _wheel -= 1;
    }
  }

  bool down(GameAction a) {
    switch (a) {
      case GameAction.attack:
        return _leftDown;
      case GameAction.use:
        return _rightDown;
      default:
        for (final k in _keys[a]!) {
          if (_held.contains(k)) return true;
        }
        return false;
    }
  }

  bool justPressed(GameAction a) {
    switch (a) {
      case GameAction.attack:
        return _leftPressed;
      case GameAction.use:
        return _rightPressed;
      default:
        for (final k in _keys[a]!) {
          if (_pressed.contains(k)) return true;
        }
        return false;
    }
  }

  /// The hotbar digit pressed this tick (0..8), or -1.
  int hotbarPressed() {
    for (var i = 0; i < 9; i++) {
      if (_pressed.contains(_digits[i])) return i;
    }
    return -1;
  }

  /// Wheel steps this tick: positive = down.
  int takeWheel() {
    final w = _wheel;
    _wheel = 0;
    return w;
  }

  /// The mouse motion since the previous tick, in logical pixels.
  Offset takeLookDelta() {
    if (pointerLockSupported) {
      if (!wantCapture) return Offset.zero;
      return PointerLock.instance.takeDelta();
    }
    final d = Offset(_dragDx, _dragDy);
    _dragDx = 0;
    _dragDy = 0;
    return d;
  }

  /// Forgets the one-shot presses; call at the end of every tick.
  void endTick() {
    _pressed.clear();
    _leftPressed = false;
    _rightPressed = false;
  }

  void dispose() {
    _stateSub?.cancel();
  }
}
