import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.2b: the single owner of what is on screen, and rule 25's arbiter.
///
/// The invariant every case here defends is that the visible state is DERIVED
/// from the stack rather than assigned beside it — the predecessor's bug was
/// two sources of truth for "is the HUD up", and no amount of paired calls
/// fixes that.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  UIStateMachine machine() => locator<UIStateMachine>();

  /// A stand-in for a surface. Identity is all the machine uses, which is the
  /// point: entries are keyed by their owner, so a pop cannot hit the wrong one.
  Object surface(String name) => _Surface(name);

  test('an empty stack IS gameplay, and the HUD is up with it', () {
    final ui = machine();
    expect(ui.state, UIState.gameplay);
    expect(ui.isHudVisible, isTrue);
    expect(ui.hasSurfaceOfKind(UIState.gameplay), isTrue);
  });

  test('pushing a surface hides the HUD; popping it brings the HUD back', () {
    final ui = machine();
    final hudFlips = <bool>[];
    ui.hudVisibleChanged.connect(hudFlips.add);

    final bag = surface('bag');
    expect(ui.pushSurface(bag, UIState.menu), isTrue);
    expect(ui.state, UIState.menu);
    expect(ui.isHudVisible, isFalse);
    expect(ui.isOpen(bag), isTrue);

    ui.popSurface(bag);
    expect(ui.state, UIState.gameplay);
    expect(ui.isHudVisible, isTrue);

    // Transitions only — never a repeat, so a subscriber can trust a signal.
    expect(hudFlips, <bool>[false, true]);
  });

  test('a second menu evicts the first — one screen, one menu', () {
    final ui = machine();
    final evicted = <Object>[];
    ui.surfaceEvicted.connect(evicted.add);

    final bag = surface('bag');
    final map = surface('map');
    ui
      ..pushSurface(bag, UIState.menu)
      ..pushSurface(map, UIState.menu);

    expect(evicted, <Object>[bag]);
    expect(ui.isOpen(bag), isFalse);
    expect(ui.isOpen(map), isTrue);
    expect(ui.surfaceCount, 1);

    // The evicted surface is already detached when it hears about it, so its
    // handler only does visuals — and a pop from that handler is harmless.
    ui.popSurface(bag);
    expect(ui.surfaceCount, 1, reason: 'a stale pop must not take the live one');
  });

  test('text entry evicts nothing — it stacks on whatever opened it', () {
    final ui = machine();
    final map = surface('map');
    final marker = surface('marker-editor');
    ui
      ..pushSurface(map, UIState.menu)
      ..pushSurface(marker, UIState.textEntry);

    expect(ui.isOpen(map), isTrue, reason: 'the map must stay visible under it');
    expect(ui.state, UIState.textEntry);
    expect(ui.surfaceCount, 2);

    // Popping the top hands the screen back to what was under it.
    ui.popSurface(marker);
    expect(ui.state, UIState.menu);
    expect(ui.isHudVisible, isFalse, reason: 'the map still holds the screen');
  });

  test('an overlay takes the screen from both a menu and a dialog', () {
    final ui = machine();
    final bag = surface('bag');
    final confirm = surface('confirm');
    ui
      ..pushSurface(bag, UIState.menu)
      ..pushSurface(confirm, UIState.dialog);
    // A dialog evicts a menu but not another dialog.
    expect(ui.isOpen(bag), isFalse);
    expect(ui.surfaceCount, 1);

    final cutscene = surface('cutscene');
    ui.pushSurface(cutscene, UIState.overlay);
    expect(ui.isOpen(confirm), isFalse);
    expect(ui.state, UIState.overlay);
  });

  test('a double open by one owner is refused, never stacked twice', () {
    final ui = machine();
    final bag = surface('bag');
    expect(ui.pushSurface(bag, UIState.menu), isTrue);
    expect(ui.pushSurface(bag, UIState.menu), isFalse);
    expect(ui.surfaceCount, 1);

    // And one pop is enough to leave: it was only ever on the stack once.
    ui.popSurface(bag);
    expect(ui.surfaceCount, 0);
  });

  test('a push from inside a transition is refused, not queued', () {
    final ui = machine();
    final thief = surface('thief');
    var refused = false;
    // Firing from a signal handler is exactly the same-frame close+open pair
    // that once stacked two menus off one physical button.
    ui.stateChanged.connect((_) {
      refused = !ui.pushSurface(thief, UIState.menu);
    });

    ui.pushSurface(surface('bag'), UIState.menu);
    expect(refused, isTrue);
    expect(ui.surfaceCount, 1);
    expect(ui.isOpen(thief), isFalse);

    // The guard clears before the push returns — the next one is free.
    expect(ui.pushSurface(thief, UIState.dialog), isTrue);
  });

  test('cancel routes to the top surface only, and says it was owned', () {
    final ui = machine();
    // Rule 25: with nothing open the press is unclaimed, and the caller is the
    // one that gets to decide what gameplay does with it.
    expect(ui.requestCancel(), isFalse);

    final map = surface('map');
    final marker = surface('marker-editor');
    ui
      ..pushSurface(map, UIState.menu)
      ..pushSurface(marker, UIState.textEntry);

    final asked = <Object>[];
    ui.cancelRequested.connect(asked.add);

    expect(ui.requestCancel(), isTrue);
    expect(asked, <Object>[marker], reason: 'only the top surface is asked');

    // Owning the press is NOT the same as closing: a surface that answers by
    // cancelling a drag consumed it just the same, and the answer must not
    // depend on the stack shrinking.
    expect(ui.surfaceCount, 2);
  });

  test('popping an owner that never opened is a defined no-op', () {
    final ui = machine();
    final bag = surface('bag');
    ui
      ..pushSurface(bag, UIState.menu)
      ..popSurface(surface('ghost'));
    expect(ui.surfaceCount, 1);

    // A double teardown is harmless — which is what lets a widget pop itself
    // in dispose() without tracking whether someone else already did.
    ui
      ..popSurface(bag)
      ..popSurface(bag);
    expect(ui.surfaceCount, 0);
    expect(ui.isHudVisible, isTrue);
  });
}

/// A named identity — `Object()` would work, but a failure message that says
/// which surface leaked is worth the four lines.
final class _Surface {
  _Surface(this.name);
  final String name;

  @override
  String toString() => 'Surface($name)';
}
