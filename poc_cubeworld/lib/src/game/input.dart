import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gamepads/gamepads.dart';
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
  cycleWeather, // stage 33: playground F7
  cycleTime, // stage 33: playground F8
  rebuildExhibit, // stage 33: playground F9
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
    _gamepadSub = Gamepads.normalizedEvents.listen(_onGamepadEvent);
  }

  // A PS5/Xbox-style pad next to WASD (parity, not a second control scheme):
  // left stick moves, right stick looks, triggers are the mouse buttons.
  // Face/shoulder/dpad buttons cover the rest; F-key dev/probe tools
  // (debugHud, screenshot, fly, skipTutorial, the playground F7-F9) stay
  // keyboard-only on purpose, same as `_keys` leaves attack/use to the mouse.
  static const Map<GameAction, GamepadButton> _gamepadButtons = {
    GameAction.jump: GamepadButton.a,
    GameAction.sneak: GamepadButton.b,
    GameAction.interact: GamepadButton.x,
    GameAction.inventory: GamepadButton.y,
    GameAction.ability: GamepadButton.leftBumper,
    GameAction.ability2: GamepadButton.rightBumper,
    GameAction.sprint: GamepadButton.leftStick,
    GameAction.toggleView: GamepadButton.rightStick,
    GameAction.glide: GamepadButton.dpadUp,
    GameAction.dropItem: GamepadButton.dpadDown,
    GameAction.eat: GamepadButton.dpadLeft,
    GameAction.dodge: GamepadButton.dpadRight,
    GameAction.pause: GamepadButton.start,
    GameAction.map: GamepadButton.back,
    GameAction.journal: GamepadButton.touchpad,
  };

  // A finger is the camera, not a mouse button. A touch that travels further
  // than this many logical pixels is a look drag and swings nothing; one that
  // lifts where it landed is a tap, and taps once. Holding to mine belongs to
  // an on-screen button, not to a gesture that also has to steer the view.
  static const double _tapSlop = 12.0;

  static const double _stickDeadzone = 0.2;
  // Triggers arrive as a digital GamepadButton on some platforms and as an
  // analog GamepadAxis (0..1) on others (macOS/GCController reports L2/R2 as
  // axes, never as buttons) — a crossing of this threshold on either counts
  // as a press.
  static const double _triggerThreshold = 0.5;
  // Radians/second of yaw or pitch at full stick deflection; divided by the
  // mouse's own sensitivity constant so one settings slider covers both.
  static const double _gamepadLookRadiansPerSecond = 3.0;
  // Mirrors Player.mouseSensitivity (rad/pixel) — kept local to avoid an
  // input.dart <-> player.dart import cycle; update both if either changes.
  static const double _mouseSensitivityMirror = 0.0022;

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
    GameAction.cycleWeather: [PhysicalKeyboardKey.f7],
    GameAction.cycleTime: [PhysicalKeyboardKey.f8],
    GameAction.rebuildExhibit: [PhysicalKeyboardKey.f9],
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
  bool _gamepadAttackDown = false;
  bool _gamepadUseDown = false;
  int _wheel = 0;
  double _dragDx = 0.0;
  double _dragDy = 0.0;
  // Where each live finger landed, and which of them have already travelled
  // past [_tapSlop] and so became look drags.
  final Map<int, Offset> _touchOrigin = {};
  final Set<int> _touchDragged = {};
  StreamSubscription<CaptureState>? _stateSub;
  final NormalizedGamepadState _gamepadState = NormalizedGamepadState();
  final Set<GamepadButton> _gamepadPressed = {};
  StreamSubscription<NormalizedGamepadEvent>? _gamepadSub;

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

  /// One normalized gamepad event, applied to the running state. A button
  /// edge (was up, now down) also lands in [_gamepadPressed], the gamepad's
  /// own one-shot set, drained in [endTick] beside the keyboard's.
  void _onGamepadEvent(NormalizedGamepadEvent event) {
    final button = event.button;
    if (button != null) {
      final wasDown = _gamepadState.isPressed(button);
      _gamepadState.update(event);
      if (!wasDown && _gamepadState.isPressed(button)) _gamepadPressed.add(button);
    } else {
      _gamepadState.update(event);
    }
    // Attack/use are the mouse buttons everywhere else in this file; the
    // gamepad's own down-state is tracked separately (see [down] /
    // [justPressed]) so an idle stick event never stomps the mouse's state.
    // Read the trigger fresh from state (button OR axis, whichever this
    // platform reports) so a press is caught no matter which one arrived.
    final attackDown = _gamepadState.isPressed(GamepadButton.rightTrigger) ||
        _gamepadState.axisValue(GamepadAxis.rightTrigger) > _triggerThreshold;
    if (attackDown && !_gamepadAttackDown) _gamepadPressed.add(GamepadButton.rightTrigger);
    _gamepadAttackDown = attackDown;

    final useDown = _gamepadState.isPressed(GamepadButton.leftTrigger) ||
        _gamepadState.axisValue(GamepadAxis.leftTrigger) > _triggerThreshold;
    if (useDown && !_gamepadUseDown) _gamepadPressed.add(GamepadButton.leftTrigger);
    _gamepadUseDown = useDown;
  }

  /// Probe hook: hold or release an action's first key as if it were typed, so
  /// a screenshot run can drive the simulation without a keyboard.
  void probeHold(GameAction a, bool down) {
    // Stage 32: attack and use are the mouse buttons, held the same way.
    if (a == GameAction.attack) {
      _leftDown = down;
      if (down) _leftPressed = true;
      return;
    }
    if (a == GameAction.use) {
      _rightDown = down;
      if (down) _rightPressed = true;
      return;
    }
    final key = _keys[a]!.first;
    if (down) {
      _held.add(key);
      _pressed.add(key);
    } else {
      _held.remove(key);
    }
  }

  void onPointerDown(PointerDownEvent e) {
    // A touch reports itself as the primary button, so without this branch
    // every finger put on the screen held the attack down while it steered
    // the camera. The gesture is undecided until the finger moves or lifts.
    if (e.kind == PointerDeviceKind.touch) {
      _touchOrigin[e.pointer] = e.position;
      return;
    }
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
    if (e.kind == PointerDeviceKind.touch) {
      final origin = _touchOrigin.remove(e.pointer);
      final dragged = _touchDragged.remove(e.pointer);
      // A finger that never travelled is a tap, and taps the same one-shot the
      // left mouse button does. A null origin means the touch began over an
      // open screen (inventory, pause), where it was never the game's to read.
      if (origin != null && !dragged) _leftPressed = true;
      return;
    }
    _leftDown = false;
    _rightDown = false;
  }

  /// A touch the system took away (a system gesture, a call). It decided
  /// nothing, so it swings nothing — it is only forgotten.
  void onPointerCancel(PointerCancelEvent e) {
    _touchOrigin.remove(e.pointer);
    _touchDragged.remove(e.pointer);
  }

  void onPointerMove(PointerMoveEvent e) {
    if (e.kind == PointerDeviceKind.touch) {
      final origin = _touchOrigin[e.pointer];
      if (origin == null) return;
      if ((e.position - origin).distance > _tapSlop) _touchDragged.add(e.pointer);
      // A finger never locks, so it looks by dragging whatever the platform
      // says about pointer lock.
      if (_touchDragged.contains(e.pointer) && wantCapture) {
        _dragDx += e.delta.dx;
        _dragDy += e.delta.dy;
      }
      return;
    }
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
        return _leftDown || _gamepadAttackDown;
      case GameAction.use:
        return _rightDown || _gamepadUseDown;
      default:
        for (final k in _keys[a]!) {
          if (_held.contains(k)) return true;
        }
        final button = _gamepadButtons[a];
        return button != null && _gamepadState.isPressed(button);
    }
  }

  bool justPressed(GameAction a) {
    switch (a) {
      case GameAction.attack:
        return _leftPressed || _gamepadPressed.contains(GamepadButton.rightTrigger);
      case GameAction.use:
        return _rightPressed || _gamepadPressed.contains(GamepadButton.leftTrigger);
      default:
        for (final k in _keys[a]!) {
          if (_pressed.contains(k)) return true;
        }
        final button = _gamepadButtons[a];
        return button != null && _gamepadPressed.contains(button);
    }
  }

  /// The left stick's X axis (-1 left, 1 right), combined with A/D so either
  /// device drives the same wish vector (rule of parity, §the class doc).
  double moveAxisX() {
    var x = 0.0;
    if (down(GameAction.moveLeft)) x -= 1;
    if (down(GameAction.moveRight)) x += 1;
    final gx = _gamepadState.axisValue(GamepadAxis.leftStickX);
    if (gx.abs() > _stickDeadzone) x += gx;
    return x.clamp(-1.0, 1.0);
  }

  /// The left stick's Y axis, combined with W/S. Stick up (+1) means
  /// forward, same sense as [GameAction.moveForward] setting inputY to -1.
  double moveAxisY() {
    var y = 0.0;
    if (down(GameAction.moveForward)) y -= 1;
    if (down(GameAction.moveBack)) y += 1;
    final gy = _gamepadState.axisValue(GamepadAxis.leftStickY);
    if (gy.abs() > _stickDeadzone) y -= gy;
    return y.clamp(-1.0, 1.0);
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

  /// The mouse motion since the previous tick (in logical pixels), plus the
  /// right stick's own turn for this tick converted to the same unit so
  /// [Player]'s one `mouseSensitivity` multiply covers both devices. The
  /// stick is a held deflection rather than a discrete delta, so it needs
  /// [dt] to integrate into a per-tick amount; the mouse path does not.
  Offset takeLookDelta(double dt) {
    // The drag accumulator drains unconditionally: a finger fills it even on a
    // platform that does lock the pointer, and a delta left in it would arrive
    // as a jump the next time the view is captured.
    var d = Offset(_dragDx, _dragDy);
    _dragDx = 0;
    _dragDy = 0;
    if (pointerLockSupported && wantCapture) d += PointerLock.instance.takeDelta();
    final gx = _gamepadState.axisValue(GamepadAxis.rightStickX);
    final gy = _gamepadState.axisValue(GamepadAxis.rightStickY);
    if (gx.abs() > _stickDeadzone || gy.abs() > _stickDeadzone) {
      const pixelsPerRadian = 1.0 / _mouseSensitivityMirror;
      d += Offset(gx, -gy) * (_gamepadLookRadiansPerSecond * pixelsPerRadian * dt);
    }
    return d;
  }

  /// Forgets the one-shot presses; call at the end of every tick.
  void endTick() {
    _pressed.clear();
    _leftPressed = false;
    _rightPressed = false;
    _gamepadPressed.clear();
  }

  void dispose() {
    _stateSub?.cancel();
    _gamepadSub?.cancel();
  }
}
