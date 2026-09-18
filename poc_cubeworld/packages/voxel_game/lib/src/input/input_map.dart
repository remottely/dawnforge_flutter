import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gamepads/gamepads.dart';
import 'package:pointer_lock/pointer_lock.dart';

/// The mouse buttons an action can be bound to.
enum MouseBinding {
  /// The primary button.
  left,

  /// The secondary button.
  right,

  /// The middle button.
  middle,
}

/// The two analog triggers, bound as buttons (a press past half way).
enum TriggerBinding {
  /// L2 / LT.
  left,

  /// R2 / RT.
  right,
}

/// What presses what: physical keys (layout-independent, so WASD stays
/// WASD), mouse buttons, gamepad buttons and triggers, per action.
class InputBindings<A extends Object> {
  /// Bindings; an action may have any mix of the four.
  const InputBindings({this.keys = const {}, this.mouse = const {}, this.gamepad = const {}, this.triggers = const {}});

  /// Keys per action.
  final Map<A, List<PhysicalKeyboardKey>> keys;

  /// Mouse buttons per action.
  final Map<A, MouseBinding> mouse;

  /// Gamepad buttons per action.
  final Map<A, GamepadButton> gamepad;

  /// Gamepad triggers per action.
  final Map<A, TriggerBinding> triggers;
}

/// Held and just-pressed actions, the wheel and the look motion (mouse and
/// right stick), read by the simulation once per step and cleared by
/// [endTick]. Generic over the game's own action type; `VoxelAction` is the
/// kit's.
///
/// Feed it from a widget ([onKey], the pointer callbacks) and [attachGamepads];
/// or drive it from code with [hold] (tests, bots, cutscenes).
class InputMap<A extends Object> {
  /// A map over [bindings]. [lookSensitivity] turns a pixel of mouse motion
  /// into radians; a full stick turns [stickTurnRate] radians a second.
  InputMap(this.bindings, {this.lookSensitivity = 0.0022, this.stickTurnRate = 3.0, this.deadzone = 0.2});

  /// What presses what.
  final InputBindings<A> bindings;

  /// Radians per pixel of mouse motion.
  double lookSensitivity;

  /// Radians a second at full right-stick deflection.
  double stickTurnRate;

  /// Stick deflection below this is ignored.
  final double deadzone;

  static const double _triggerThreshold = 0.5;

  final Set<PhysicalKeyboardKey> _held = {};
  final Set<PhysicalKeyboardKey> _pressed = {};
  final Set<MouseBinding> _mouseHeld = {};
  final Set<MouseBinding> _mousePressed = {};
  final Set<A> _scriptHeld = {};
  final Set<A> _scriptPressed = {};
  final NormalizedGamepadState _pad = NormalizedGamepadState();
  final Set<GamepadButton> _padPressed = {};
  final Set<TriggerBinding> _triggerHeld = {};
  final Set<TriggerBinding> _triggerPressed = {};
  StreamSubscription<NormalizedGamepadEvent>? _padSub;
  StreamSubscription<CaptureState>? _lockSub;
  int _wheel = 0;
  Offset _drag = Offset.zero;
  Offset _scriptLook = Offset.zero;

  /// Whether the game wants the mouse captured (looking around).
  bool wantCapture = false;

  /// Set when the capture was lost without being asked (focus left the
  /// window): a game opens its pause menu on it.
  bool captureLost = false;

  /// Listens to gamepads and to pointer-lock state; a widget calls it once.
  void attachDevices() {
    _padSub ??= Gamepads.normalizedEvents.listen(_onPad);
    _lockSub ??= PointerLock.instance.onStateChanged.listen((state) {
      if (state == CaptureState.released && wantCapture) {
        captureLost = true;
        wantCapture = false;
      }
    });
  }

  /// Stops listening.
  void dispose() {
    _padSub?.cancel();
    _lockSub?.cancel();
  }

  /// Whether the platform locks the pointer (desktop); elsewhere a drag looks.
  bool get pointerLockSupported => PointerLock.instance.isSupported;

  /// Locks the pointer for looking around.
  Future<void> capture() async {
    wantCapture = true;
    captureLost = false;
    _drag = Offset.zero;
    if (pointerLockSupported) await PointerLock.instance.capture();
  }

  /// Frees the pointer (a menu opened).
  Future<void> release() async {
    wantCapture = false;
    if (pointerLockSupported) await PointerLock.instance.release();
  }

  /// A key event from a `Focus`; every key is handled while playing so the
  /// platform does not beep at held keys.
  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    final key = event.physicalKey;
    if (event is KeyDownEvent) {
      _held.add(key);
      _pressed.add(key);
    } else if (event is KeyUpEvent) {
      _held.remove(key);
    }
    return KeyEventResult.handled;
  }

  /// Forgets every held key (focus lost).
  void releaseKeys() {
    _held.clear();
    _mouseHeld.clear();
  }

  static Set<MouseBinding> _buttons(int mask) => {
        if (mask & kPrimaryMouseButton != 0) MouseBinding.left,
        if (mask & kSecondaryMouseButton != 0) MouseBinding.right,
        if (mask & kMiddleMouseButton != 0) MouseBinding.middle,
      };

  /// A pointer press.
  void onPointerDown(PointerDownEvent e) {
    final b = _buttons(e.buttons);
    _mouseHeld.addAll(b);
    _mousePressed.addAll(b);
  }

  /// A pointer release.
  void onPointerUp(PointerUpEvent e) => _mouseHeld.removeWhere((b) => !_buttons(e.buttons).contains(b));

  /// A pointer motion: the look, where the pointer cannot be locked.
  void onPointerMove(PointerMoveEvent e) {
    if (!pointerLockSupported && wantCapture) _drag += e.delta;
  }

  /// A wheel turn.
  void onPointerSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) _wheel += e.scrollDelta.dy.sign.toInt();
  }

  void _onPad(NormalizedGamepadEvent event) {
    final button = event.button;
    final was = button != null && _pad.isPressed(button);
    _pad.update(event);
    if (button != null && !was && _pad.isPressed(button)) _padPressed.add(button);
    for (final (t, b, a) in [
      (TriggerBinding.left, GamepadButton.leftTrigger, GamepadAxis.leftTrigger),
      (TriggerBinding.right, GamepadButton.rightTrigger, GamepadAxis.rightTrigger),
    ]) {
      final down = _pad.isPressed(b) || _pad.axisValue(a) > _triggerThreshold;
      if (down && !_triggerHeld.contains(t)) _triggerPressed.add(t);
      down ? _triggerHeld.add(t) : _triggerHeld.remove(t);
    }
  }

  /// Holds or releases [action] from code; a hold also counts as a press.
  void hold(A action, bool down) {
    if (down) {
      if (_scriptHeld.add(action)) _scriptPressed.add(action);
    } else {
      _scriptHeld.remove(action);
    }
  }

  /// Presses [action] once from code.
  void tap(A action) => _scriptPressed.add(action);

  /// Adds a look motion from code, in pixels.
  void look(double dx, double dy) => _scriptLook += Offset(dx, dy);

  /// Whether [action] is held.
  bool down(A action) {
    if (_scriptHeld.contains(action)) return true;
    for (final k in bindings.keys[action] ?? const <PhysicalKeyboardKey>[]) {
      if (_held.contains(k)) return true;
    }
    final m = bindings.mouse[action];
    if (m != null && _mouseHeld.contains(m)) return true;
    final g = bindings.gamepad[action];
    if (g != null && _pad.isPressed(g)) return true;
    final t = bindings.triggers[action];
    return t != null && _triggerHeld.contains(t);
  }

  /// Whether [action] was pressed since the last [endTick].
  bool justPressed(A action) {
    if (_scriptPressed.contains(action)) return true;
    for (final k in bindings.keys[action] ?? const <PhysicalKeyboardKey>[]) {
      if (_pressed.contains(k)) return true;
    }
    final m = bindings.mouse[action];
    if (m != null && _mousePressed.contains(m)) return true;
    final g = bindings.gamepad[action];
    if (g != null && _padPressed.contains(g)) return true;
    final t = bindings.triggers[action];
    return t != null && _triggerPressed.contains(t);
  }

  /// -1..1 from [negative] and [positive] held, plus [stick] past the
  /// deadzone ([invertStick] flips it: a stick's up is -y on screen).
  double axis(A negative, A positive, {GamepadAxis? stick, bool invertStick = false}) {
    var v = 0.0;
    if (down(negative)) v -= 1;
    if (down(positive)) v += 1;
    if (stick != null) {
      final s = _pad.axisValue(stick);
      if (s.abs() > deadzone) v += invertStick ? -s : s;
    }
    return v.clamp(-1.0, 1.0);
  }

  /// The digit key 1..9 pressed this step as 0..8, or -1.
  int digitPressed() {
    const digits = [
      PhysicalKeyboardKey.digit1, PhysicalKeyboardKey.digit2, PhysicalKeyboardKey.digit3, //
      PhysicalKeyboardKey.digit4, PhysicalKeyboardKey.digit5, PhysicalKeyboardKey.digit6,
      PhysicalKeyboardKey.digit7, PhysicalKeyboardKey.digit8, PhysicalKeyboardKey.digit9,
    ];
    for (var i = 0; i < digits.length; i++) {
      if (_pressed.contains(digits[i])) return i;
    }
    return -1;
  }

  /// Wheel steps since the last call; positive is down.
  int takeWheel() {
    final w = _wheel;
    _wheel = 0;
    return w;
  }

  /// The look since the last call, in radians (yaw right, pitch down
  /// positive): the mouse (or drag) motion plus [dt] of right stick.
  Offset takeLook(double dt) {
    var d = _scriptLook;
    _scriptLook = Offset.zero;
    if (pointerLockSupported) {
      if (wantCapture) d += PointerLock.instance.takeDelta();
    } else {
      d += _drag;
      _drag = Offset.zero;
    }
    var rad = d * lookSensitivity;
    final gx = _pad.axisValue(GamepadAxis.rightStickX), gy = _pad.axisValue(GamepadAxis.rightStickY);
    if (gx.abs() > deadzone || gy.abs() > deadzone) rad += Offset(gx, -gy) * (stickTurnRate * dt);
    return rad;
  }

  /// Forgets this step's presses; the game calls it after every step.
  void endTick() {
    _pressed.clear();
    _mousePressed.clear();
    _padPressed.clear();
    _triggerPressed.clear();
    _scriptPressed.clear();
  }
}
