import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// The kind of the surface currently on top. DERIVED from the stack, never
/// assigned: an empty stack IS gameplay, so the two can never disagree.
enum UIState { gameplay, menu, dialog, overlay, textEntry }

/// The single owner of what is on screen — the Dart port of
/// `ui_state_machine.gd`.
///
/// Two master groups that never coexist:
///
///   GROUP 1 (gameplay overlay) : HUD, hotbar, notifications, XP bar
///   GROUP 2 (surfaces)         : menus, dialogs, overlays, text entry
///
/// and one invariant that makes the exclusion structural instead of remembered:
///
///   group 1 is visible  ⇔  the surface stack is empty
///
/// Nothing outside this class decides HUD visibility. The HUD subscribes to
/// [hudVisibleChanged] and obeys, so "a surface forgot to restore the HUD"
/// stops being a thing that can be written. The spec's predecessor instead
/// paired hide/show calls at each call site and stacked layer KINDS, so a pop
/// removed *some* menu entry rather than *this* one; two opens against one
/// close left the HUD hidden for the rest of the session with no way to
/// attribute the orphan. Entries here are keyed by their owning object, which
/// is what removes that whole class of bug rather than patching its instances.
///
/// Registered at boot and never null after (rule 28).
///
/// This is also rule 25's arbiter: a back/cancel press is routed ONCE, through
/// [requestCancel], and surfaces answer the routed request instead of reading
/// the button themselves.
///
/// PORT NOTE — the spec detaches a surface whose Node leaves the tree, because
/// a freed node could otherwise strand the stack and take the HUD with it.
/// Dart has no such lifecycle hook, so the obligation moves to the surface: a
/// widget pops itself in `dispose()`. [popSurface] on an owner that is not on
/// the stack stays a defined no-op precisely so that a double teardown is
/// harmless.
final class UIStateMachine {
  /// Top-of-stack kind changed.
  final stateChanged = EventSignal<UIState>();

  /// Group 1's visibility flipped. Fires on TRANSITIONS only, never repeatedly,
  /// so a subscriber can trust that a signal means a change.
  final hudVisibleChanged = EventSignal<bool>();

  /// A surface was taken off screen by an incoming exclusive one and must hide
  /// itself. It is already off the stack when this fires — the handler only
  /// does visuals.
  final surfaceEvicted = EventSignal<Object>();

  /// The player pressed back/cancel and the top surface owns that press.
  final cancelRequested = EventSignal<Object>();

  /// Which kinds each incoming kind takes the screen from.
  ///
  /// [UIState.textEntry] evicts nothing on purpose: it stacks on whatever
  /// opened it, which is what lets a marker editor sit over the still-visible
  /// map, and a label editor over its dialog, under one rule instead of two
  /// special cases.
  static const Map<UIState, List<UIState>> _evicts = <UIState, List<UIState>>{
    UIState.menu: <UIState>[UIState.menu],
    UIState.dialog: <UIState>[UIState.menu],
    UIState.overlay: <UIState>[UIState.menu, UIState.dialog],
    UIState.textEntry: <UIState>[],
  };

  /// Stack order, bottom to top.
  final List<Object> _stack = <Object>[];

  /// Kind of each stacked surface, keyed by owner so a pop can never hit the
  /// wrong one.
  final Map<Object, UIState> _kinds = <Object, UIState>{};

  /// Held for the duration of a transition, including while its signals are
  /// being delivered. See [pushSurface] for why rejection beats queueing.
  bool _inTransition = false;
  UIState _state = UIState.gameplay;
  bool _hudVisible = true;

  UIState get state => _state;
  bool get isHudVisible => _hudVisible;
  int get surfaceCount => _stack.length;

  /// Puts a surface on screen. Returns false when the push was REFUSED, which
  /// happens in exactly two cases:
  ///
  ///   - this owner already has a surface open (a double open)
  ///   - a transition is in flight, including from inside a handler of this
  ///     machine's own signals
  ///
  /// Refusing rather than queueing is deliberate. In the spec, one physical
  /// gamepad press once matched both cancel and inventory (the same button),
  /// and the resulting close+open pair landed in the same frame and stacked two
  /// menus. A queued second open would still open it, just later; a refused one
  /// never happens. The guard clears before this returns, so the next frame is
  /// free.
  bool pushSurface(Object owner, UIState kind) {
    assert(
      kind != UIState.gameplay,
      '[UIStateMachine] GAMEPLAY is the empty stack, not a surface',
    );
    if (_inTransition) return false;
    if (_kinds.containsKey(owner)) return false;

    _inTransition = true;
    _evictFor(kind);
    _stack.add(owner);
    _kinds[owner] = kind;
    _settle();
    _inTransition = false;
    return true;
  }

  /// Takes a surface off screen. Popping an owner that is not on the stack —
  /// because it already closed, or never opened — is a DEFINED no-op, not a
  /// swallowed error: the whole point of keying by owner is that callers need
  /// not track whether someone else already removed them.
  void popSurface(Object owner) {
    if (_inTransition) return;
    if (!_kinds.containsKey(owner)) return;

    _inTransition = true;
    _detach(owner);
    _settle();
    _inTransition = false;
  }

  bool isOpen(Object owner) => _kinds.containsKey(owner);

  bool hasSurfaceOfKind(UIState kind) => kind == UIState.gameplay
      ? _stack.isEmpty
      : _kinds.values.contains(kind);

  /// Routes a back/cancel press to the top surface. Returns whether a surface
  /// OWNED the press — not whether it closed.
  ///
  /// The distinction is the fix for "a fast back press on the map opens the
  /// inventory": the caller uses this to decide whether the press was already
  /// spoken for, and a surface that answers back by cancelling a drag, or by
  /// closing over an animation, has still consumed it. Tying the answer to "did
  /// the stack shrink synchronously" would hand the press onward in exactly
  /// those cases and reopen the bug.
  bool requestCancel() {
    if (_stack.isEmpty) return false;
    cancelRequested.emit(_stack.last);
    return true;
  }

  /// Removes everything the incoming kind is exclusive with. Runs inside the
  /// guard, so an evicted surface calling [popSurface] from its handler is
  /// refused — harmlessly, since it is already detached.
  void _evictFor(UIState kind) {
    final evictedKinds = _evicts[kind]!;
    if (evictedKinds.isEmpty) return;
    for (final existing in List<Object>.of(_stack)) {
      if (evictedKinds.contains(_kinds[existing])) {
        _detach(existing);
        surfaceEvicted.emit(existing);
      }
    }
  }

  void _detach(Object owner) {
    _stack.remove(owner);
    _kinds.remove(owner);
  }

  /// Recomputes the derived state and emits ONLY what actually changed.
  void _settle() {
    final nextState = _stack.isEmpty ? UIState.gameplay : _kinds[_stack.last]!;
    final nextHudVisible = _stack.isEmpty;
    if (nextState != _state) {
      _state = nextState;
      stateChanged.emit(_state);
    }
    if (nextHudVisible != _hudVisible) {
      _hudVisible = nextHudVisible;
      hudVisibleChanged.emit(_hudVisible);
    }
  }
}
