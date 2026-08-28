import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/ui/interface/inventory_panel_view.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.2b: the bag, open. Three things here cannot be checked by looking at
/// it — that the surface registers and unregisters on BOTH stacks, that the
/// back press reaches it only when routed (rule 25), and that a drag resolves
/// through the container's verbs rather than the widget's own bookkeeping.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'inventory_size': 10,
    });
    // A REAL spritesheet path on both probes. A slot draws its item's icon,
    // and step 03 guarantees every authored item has a sheet — so an item
    // without one is not a lean fixture, it is an item that could not exist,
    // and `ContentPaths.resolveRes` says so (rule 5). The image itself never
    // finishes decoding inside a widget test's fake-async zone, which is
    // exactly right here: the icon simply draws nothing and the drag under
    // test is unaffected.
    const sheet = 'res://data/forge_almanac/01_biomes/t1/items/sprites/'
        't1_item_coal.png';
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_pebble',
      'max_stack': 10,
      'spritesheet': sheet,
    });
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_hand_axe',
      'max_stack': 1,
      'spritesheet': sheet,
    });
    // Rule 19: the panel's title goes through tr(), so a locale must exist.
    locator<LocalizationSystem>().loadLocale('en', <String, Object?>{
      'strings': <String, Object?>{'ui.menu.tab.inventory': 'Inventory'},
    });
  });
  tearDown(resetCoreSystems);

  InventoryComponent bag() =>
      ActorFactory.create('t1_actor_probe_player', WorldPos.zero).inventory;

  var closed = 0;
  final droppedToWorld = <int>[];

  Future<void> pump(WidgetTester tester, InventoryComponent inventory) async {
    closed = 0;
    droppedToWorld.clear();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        // `Draggable` floats its feedback in an `Overlay`, so it requires one
        // above it. The app has it — `MaterialApp` → `Navigator` → `Overlay`
        // sits above the `GameWidget` the panel is an overlay of — and this
        // is the smallest thing that stands in for it here.
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (context) => InventoryPanelView(
                inventory: inventory,
                onClose: () => closed++,
                onDropToWorld: droppedToWorld.add,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('opening registers on both stacks; closing clears both',
      (tester) async {
    final inventory = bag();
    await pump(tester, inventory);

    final ui = locator<UIStateMachine>();
    expect(ui.state, UIState.menu);
    expect(ui.isHudVisible, isFalse);
    // Rule 30: the player is stopped from ACTING, the game is not stopped.
    // Nothing in this repo can pause it — there is no pause to call.
    expect(locator<GameInputManager>().isGameplayEnabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(ui.state, UIState.gameplay);
    expect(ui.isHudVisible, isTrue);
    expect(locator<GameInputManager>().isGameplayEnabled, isTrue,
        reason: 'a surface that leaves owes its blocker back');
  });

  testWidgets('the world behind it is live, not a snapshot', (tester) async {
    await pump(tester, bag());
    // Rule 30's visible half: a BackdropFilter filters what is ACTUALLY
    // painted behind it each frame. A captured image would look the same in a
    // screenshot and be a lie in motion, which is why the widget type is the
    // thing asserted.
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('the title is translated, never a literal', (tester) async {
    await pump(tester, bag());
    expect(find.text('Inventory'), findsOneWidget);
  });

  testWidgets('it draws every slot the bag has, not just a page',
      (tester) async {
    final inventory = bag();
    await pump(tester, inventory);
    expect(find.byType(ItemSlotView), findsNWidgets(inventory.maxSlots));
  });

  testWidgets('the routed back press closes it; an unrouted one never arrives',
      (tester) async {
    final inventory = bag();
    await pump(tester, inventory);

    // Rule 25: the panel answers what the ARBITER hands it. Asking the
    // machine is what a key press does.
    expect(locator<UIStateMachine>().requestCancel(), isTrue);
    expect(closed, 1);

    // And a cancel routed to somebody else is not this panel's business —
    // two surfaces answering one press is how a menu closes itself while
    // another opens on top.
    //
    // Text entry, because it evicts nothing: the panel is still open and
    // still registered, just no longer on top. (`onClose` here only counts;
    // nothing unmounts the widget, so the surface really does stay on the
    // stack — which is what makes this the honest arrangement to test.)
    locator<UIStateMachine>()
      ..pushSurface(Object(), UIState.textEntry)
      ..requestCancel();
    expect(closed, 1, reason: 'the panel answered a press it did not own');
  });

  testWidgets('escape reaches the panel only through the arbiter',
      (tester) async {
    await pump(tester, bag());
    var arbitrated = 0;
    locator<UIStateMachine>().cancelRequested.connect((_) => arbitrated++);

    // The key raises a bare fact. Nothing but the arbiter listens for it, so
    // the panel does not move until somebody routes it.
    locator<InputHelper>().handleKeyEvent(const KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    ));
    expect(closed, 0, reason: 'the panel must not read the key itself');
    expect(arbitrated, 0);

    locator<UIStateMachine>().requestCancel();
    expect(closed, 1);
  });

  testWidgets('an evicting surface takes the screen and the panel leaves',
      (tester) async {
    await pump(tester, bag());
    // A second MENU evicts the first. The panel is already off the stack when
    // it hears — the handler only does visuals, which here means closing.
    locator<UIStateMachine>().pushSurface(Object(), UIState.menu);
    expect(closed, 1);
  });

  group('drag resolves through the container', () {
    /// Drags the widget at [from] onto the one at [to].
    Future<void> drag(WidgetTester tester, int from, int to) async {
      final source = tester.getCenter(find.byType(ItemSlotView).at(from));
      final target = tester.getCenter(find.byType(ItemSlotView).at(to));
      final gesture = await tester.startGesture(source);
      await tester.pump(kLongPressTimeout);
      await gesture.moveTo(target);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('onto an empty slot, the stack moves whole', (tester) async {
      final inventory = bag();
      final pebble = locator<ItemRegistry>().getItem('t1_item_pebble');
      inventory.setSlot(0, pebble, 6);
      await pump(tester, inventory);

      await drag(tester, 0, 3);
      expect(inventory.slots[0].isEmpty, isTrue);
      expect(inventory.slots[3].amount, 6);
    });

    testWidgets('onto a matching stack, they merge', (tester) async {
      final inventory = bag();
      final pebble = locator<ItemRegistry>().getItem('t1_item_pebble');
      inventory
        ..setSlot(0, pebble, 6)
        ..setSlot(1, pebble, 2);
      await pump(tester, inventory);

      await drag(tester, 0, 1);
      expect(inventory.slots[1].amount, 8);
      expect(inventory.slots[0].isEmpty, isTrue);
    });

    testWidgets('onto a different item, they trade places', (tester) async {
      final inventory = bag()
        ..setSlot(0, locator<ItemRegistry>().getItem('t1_item_pebble'), 6)
        ..setSlot(1, locator<ItemRegistry>().getItem('t1_item_hand_axe'), 1);
      await pump(tester, inventory);

      await drag(tester, 0, 1);
      expect(inventory.slots[0].itemId, 't1_item_hand_axe');
      expect(inventory.slots[1].itemId, 't1_item_pebble');
      expect(inventory.slots[1].amount, 6);
    });

    testWidgets('with the split modifier held, only half moves',
        (tester) async {
      final inventory = bag()
        ..setSlot(0, locator<ItemRegistry>().getItem('t1_item_pebble'), 7);
      await pump(tester, inventory);

      // Held through the SSOT, which is where every key in this game is read
      // (rule 11) — the widget asks it rather than the keyboard.
      locator<InputHelper>().handleKeyEvent(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.shiftLeft,
        logicalKey: LogicalKeyboardKey.shiftLeft,
        timeStamp: Duration.zero,
      ));
      await drag(tester, 0, 4);

      // Half of seven, rounded up — the same rule the spec's split reads.
      expect(inventory.slots[4].amount, 4);
      expect(inventory.slots[0].amount, 3);
    });

    testWidgets('dropped outside the panel, it goes to the ground',
        (tester) async {
      final inventory = bag()
        ..setSlot(2, locator<ItemRegistry>().getItem('t1_item_pebble'), 5);
      await pump(tester, inventory);

      final source = tester.getCenter(find.byType(ItemSlotView).at(2));
      final gesture = await tester.startGesture(source);
      await tester.pump(kLongPressTimeout);
      // The top-left corner: outside the panel, over the world.
      await gesture.moveTo(const Offset(4, 4));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // The panel asks; it does not reach into the world itself. What the
      // request DOES is the shell's, which is what keeps this widget usable
      // over a chest that drops somewhere else entirely.
      expect(droppedToWorld, <int>[2]);
    });
  });
}
