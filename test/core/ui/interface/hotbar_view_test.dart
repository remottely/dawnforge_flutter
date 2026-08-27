import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/ui/interface/hotbar_view.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.2b: the bar over one page of the bag. Every case here is page math or
/// the selection following it — the two things the spec's own history shows
/// going wrong, and the two a screenshot cannot check.
void main() {
  setUp(() {
    registerCoreSystems();
    // 30 slots = three pages of ten, the player's own size.
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'inventory_size': 30,
    });
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_pebble',
      'max_stack': 10,
    });
  });
  tearDown(resetCoreSystems);

  InventoryComponent bag() =>
      ActorFactory.create('t1_actor_probe_player', WorldPos.zero).inventory;

  /// Mounts the bar and hands back the state that owns the page math.
  Future<HotbarViewState> pump(
    WidgetTester tester,
    InventoryComponent inventory,
  ) async {
    final key = GlobalKey<HotbarViewState>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HotbarView(key: key, inventory: inventory),
      ),
    );
    return key.currentState!;
  }

  void pressDigit(int digit) => locator<InputHelper>().handleKeyEvent(
        KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.digit1,
          logicalKey: LogicalKeyboardKey(
            LogicalKeyboardKey.digit0.keyId + digit % 10,
          ),
          timeStamp: Duration.zero,
        ),
      );

  testWidgets('draws one page of slots, with the selected one marked',
      (tester) async {
    final inventory = bag();
    final state = await pump(tester, inventory);

    expect(state.pageCount, 3);
    expect(find.byType(ItemSlotView), findsNWidgets(HotbarView.slotsPerPage));

    final marked = tester
        .widgetList<ItemSlotView>(find.byType(ItemSlotView))
        .where((slot) => slot.isSelected);
    expect(marked, hasLength(1),
        reason: 'exactly one slot is in hand, always');
  });

  testWidgets('a number key selects by position within the visible page',
      (tester) async {
    final inventory = bag();
    final state = await pump(tester, inventory);

    pressDigit(3);
    await tester.pump();
    expect(inventory.selectedSlot, 2);

    // The same key on page two means the third slot OF THAT PAGE, which is
    // what makes the keys muscle memory instead of absolute addresses.
    state.flipPage(1);
    await tester.pump();
    pressDigit(3);
    await tester.pump();
    expect(inventory.selectedSlot, HotbarView.slotsPerPage + 2);
  });

  testWidgets('stepping wraps inside the page, never onto the next one',
      (tester) async {
    final inventory = bag();
    final state = await pump(tester, inventory);

    inventory.selectSlot(0);
    state.step(-1);
    await tester.pump();
    expect(inventory.selectedSlot, HotbarView.slotsPerPage - 1,
        reason: 'stepping back off the front wraps to the end of the SAME page');

    state.step(1);
    await tester.pump();
    expect(inventory.selectedSlot, 0);
  });

  testWidgets('flipping pages is circular and keeps the position in the row',
      (tester) async {
    final inventory = bag();
    final state = await pump(tester, inventory);

    inventory.selectSlot(4);
    state.flipPage(1);
    await tester.pump();
    expect(state.page, 1);
    expect(inventory.selectedSlot, HotbarView.slotsPerPage + 4);

    // Three pages: forward from the last returns to the first.
    state
      ..flipPage(1)
      ..flipPage(1);
    await tester.pump();
    expect(state.page, 0);
    expect(inventory.selectedSlot, 4);
  });

  testWidgets('the page follows a selection moved from outside the bar',
      (tester) async {
    final inventory = bag();
    final state = await pump(tester, inventory);
    expect(state.page, 0);

    // Nothing in the widget did this — a script, a tool being armed, a save
    // being loaded. The bar must still be showing what the actor holds.
    inventory.selectSlot(25);
    await tester.pump();
    expect(state.page, 2);
    expect(find.byType(ItemSlotView), findsNWidgets(HotbarView.slotsPerPage));
  });

  testWidgets('the bar opens on the slot the soul was already holding',
      (tester) async {
    // Selected as a loaded save would leave it, before the bar exists at all.
    final inventory = bag()..selectSlot(17);

    final state = await pump(tester, inventory);
    expect(state.page, 1,
        reason: 'the first page drawn is the one holding the held item');
    expect(inventory.selectedSlot, 17);
  });

  testWidgets('a tap selects the slot it landed on', (tester) async {
    final inventory = bag();
    await pump(tester, inventory);

    // Input parity (rule 12): the finger reaches what the number key reaches.
    await tester.tap(find.byType(ItemSlotView).at(6));
    await tester.pump();
    expect(inventory.selectedSlot, 6);
  });

  testWidgets('one physical press moves the selection exactly one slot',
      (tester) async {
    final inventory = bag();
    await pump(tester, inventory);
    final input = locator<InputHelper>();
    var intents = 0;
    input.hotbarStepped.connect((_) => intents++);

    const key = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyE,
      logicalKey: LogicalKeyboardKey.keyE,
      timeStamp: Duration.zero,
    );
    input
      ..handleKeyEvent(key)
      // A repeat is the SAME press held down (rule 24): the operating system
      // keeps sending it, and a second intent here would walk the selection
      // across the bar while the player holds one key.
      ..handleKeyEvent(const KeyRepeatEvent(
        physicalKey: PhysicalKeyboardKey.keyE,
        logicalKey: LogicalKeyboardKey.keyE,
        timeStamp: Duration.zero,
      ));
    await tester.pump();

    expect(intents, 1);
    expect(inventory.selectedSlot, 1);
  });

  testWidgets('the bar unsubscribes when it leaves the screen', (tester) async {
    final inventory = bag();
    await pump(tester, inventory);
    await tester.pumpWidget(const SizedBox.shrink());

    // A listener outliving its widget is a leak and a setState after dispose.
    inventory
      ..selectSlot(11)
      ..addItem(locator<ItemRegistry>().getItem('t1_item_pebble'), 3);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
