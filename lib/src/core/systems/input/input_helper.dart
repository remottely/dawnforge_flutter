import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';
import 'package:flame/events.dart';
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

  // ============================================
  // DISCRETE INTENTS (FP4.2b)
  // ============================================
  // Movement is a STATE the sim samples once per fixed step. A hotbar
  // selection is an EVENT: one physical press must move the selection exactly
  // one slot, and polling "is 3 held" every frame would move it every frame
  // (rule 24). So discrete presses leave here as intents, and interfaces
  // subscribe to the intent instead of ever looking at a key — which is what
  // keeps rule 11's single source of truth true for surfaces too, and lets a
  // gamepad or a tap raise the same intent for free (rule 12).

  /// A hotbar slot was chosen by position WITHIN the visible page (0-based,
  /// so the `1` key is 0). Which global slot that is depends on the page the
  /// hotbar is showing, which is the hotbar's business and not this class's.
  final hotbarSlotPressed = EventSignal<int>();

  /// The player asked for the previous (-1) or next (+1) page of the bag.
  final hotbarPageFlipped = EventSignal<int>();

  /// The player asked to step the selection one slot along the current page.
  final hotbarStepped = EventSignal<int>();

  /// The player asked to open or close the bag.
  final inventoryToggled = EventSignal0();

  /// The player asked to use what is in their hand, at the cursor. One press,
  /// one intent (rule 24): the swing is fired by whoever subscribes, never by
  /// polling a button every frame.
  final primaryActionPressed = EventSignal0();

  /// The player pressed back/cancel. Exactly ONE thing may answer this, which
  /// is why it leaves here as a bare fact and `UIStateMachine.requestCancel()`
  /// decides who owns it (rule 25). Nothing else in the game may listen for
  /// the escape key.
  final cancelPressed = EventSignal0();

  /// Whether the modifier that means "part of this, not all of it" is down —
  /// a drag carrying half a stack instead of the whole one.
  ///
  /// A polled STATE rather than an intent, and the one thing here that is:
  /// the question is only ever asked at the instant of a drop, about the
  /// modifier held at that instant. Asking `HardwareKeyboard` from the widget
  /// would answer the same, and would be the second place in the codebase
  /// that reads a key (rule 11).
  bool get isSplitModifierHeld => _any(const <LogicalKeyboardKey>[
        LogicalKeyboardKey.shiftLeft,
        LogicalKeyboardKey.shiftRight,
        LogicalKeyboardKey.shift,
      ]);

  static const _slotKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
    LogicalKeyboardKey.digit0,
  ];

  /// The render layer forwards every key event here (rule 24: handlers read
  /// the event they were handed; per-frame polling happens in update, off the
  /// state this maintains).
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressed.add(event.logicalKey);
      _raiseIntents(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressed.remove(event.logicalKey);
    }
    // A KeyRepeatEvent is deliberately neither: it must not re-add a key that
    // is already down, and it must never raise a second intent for one press.
  }

  /// Turns one KEY DOWN into whatever discrete intent it means. Down only —
  /// the whole point of the split is that a press happens once.
  void _raiseIntents(LogicalKeyboardKey key) {
    final slot = _slotKeys.indexOf(key);
    if (slot >= 0) {
      hotbarSlotPressed.emit(slot);
      return;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      hotbarPageFlipped.emit(-1);
      return;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      hotbarPageFlipped.emit(1);
      return;
    }
    if (key == LogicalKeyboardKey.keyQ) {
      hotbarStepped.emit(-1);
      return;
    }
    if (key == LogicalKeyboardKey.keyE) {
      hotbarStepped.emit(1);
      return;
    }
    if (key == LogicalKeyboardKey.keyI || key == LogicalKeyboardKey.tab) {
      inventoryToggled.emit();
      return;
    }
    if (key == LogicalKeyboardKey.escape) {
      cancelPressed.emit();
    }
  }

  // ============================================
  // THE UNIFIED CURSOR (FP4.3a)
  // ============================================
  // Rule 11 in one field: gameplay asks WHERE THE PLAYER IS POINTING and gets
  // one answer, whatever moved the pointer. Nothing here had needed it until
  // the swing had to be aimed, so nothing had grown the seam.

  /// Where the pointer is, in SCREEN space — the raw fact, and the only one
  /// stored. Screen rather than world because that is what a pointer event
  /// actually reports, and because of [getCursorWorldPos]'s own reason.
  WorldPos _cursorScreenPos = WorldPos.zero;

  /// How a screen point becomes a world point, set by the render layer at
  /// boot with the camera's own projection. The sim never touches the camera;
  /// this field is the single wire between the two, and a world that starts
  /// after another one replaces it rather than adding a second.
  WorldPos Function(WorldPos screenPos)? screenToWorld;

  WorldPos getCursorScreenPos() => _cursorScreenPos;

  /// Where the player is pointing, in the world.
  ///
  /// COMPUTED ON EVERY ASK, never stored: the camera moves under a cursor
  /// that has not. A player walking with the mouse held still is aiming at a
  /// new tile every frame, and a cached world position would have them
  /// chopping the tree they walked away from.
  WorldPos getCursorWorldPos() {
    final project = screenToWorld;
    assert(
      project != null,
      '[InputHelper] the cursor was asked for a world position before the '
      'render layer set one (rule 5) — the binding happens at boot',
    );
    return project!(_cursorScreenPos);
  }

  /// The render layer forwards pointer motion here, event object and all, for
  /// the same reason [handleKeyEvent] takes a raw `KeyEvent`: the read of a
  /// raw pointer position happens in THIS file or nowhere (rule 11, and the
  /// `check_edited_file_rules` tripwire that enforces it).
  void handlePointerMove(PointerMoveEvent event) {
    _cursorScreenPos = WorldPos(event.canvasPosition.x, event.canvasPosition.y);
  }

  /// A click or a tap: the cursor goes where the pointer went down, and the
  /// primary action fires from there.
  ///
  /// This is what makes touch parity structural rather than a second code
  /// path (rule 12) — a finger IS the cursor for the instant it is down, so
  /// the tap both aims and acts. The mouse reaches the same two lines with
  /// its motion already tracked.
  ///
  /// PORT DELTA: the spec's third mode, the GAMEPAD's virtual cursor, is not
  /// here. It is a port of its own — the stick steers a cursor with its own
  /// speed and snapping, `stick_is_cursor` decides which cursor answers, and
  /// the OS pointer is warped onto it each frame with an echo guard so the
  /// warp does not hand the cursor back to the mouse. Until it lands, rule 12
  /// is broken in writing rather than in silence.
  void handleTapDown(TapDownEvent event) {
    _cursorScreenPos = WorldPos(event.canvasPosition.x, event.canvasPosition.y);
    primaryActionPressed.emit();
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
