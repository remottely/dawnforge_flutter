import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:flutter/widgets.dart';

/// The bar along the bottom of the screen — the Dart port of `hotbar_ui.gd`.
///
/// It shows ONE PAGE of the bag at a time and one slot is always selected: that
/// slot is what the actor is holding. Pages exist because a bag is thirty slots
/// and a screen is not; the page is a window over the same slots the inventory
/// panel shows whole, never a second container.
///
/// The selection itself lives in the data soul, not here (rule 8) — this widget
/// reads `InventoryComponent.selectedSlot` and asks the component to move it.
/// The spec keeps that counter in its own hotbar, which is why closing the bag
/// there could lose what the player was holding; here the bar can be rebuilt
/// from nothing and the hand stays the same.
final class HotbarView extends StatefulWidget {
  const HotbarView({required this.inventory, super.key});

  /// Rows of slots the bar shows at once — the spec's `WIDGETS_PER_ROW`, which
  /// is the number of `SlotRowWidget`s it stacks, not a count of slots.
  static const int rowsPerPage = 2;

  /// Slots on one page. The bag's size is a whole number of these.
  static const int slotsPerPage = rowsPerPage * GameConstants.slotsPerRow;

  final InventoryComponent inventory;

  @override
  State<HotbarView> createState() => HotbarViewState();
}

final class HotbarViewState extends State<HotbarView> {
  final List<void Function()> _subscriptions = <void Function()>[];

  /// Which page is on screen. This one IS view state: it is a scroll position
  /// over the bag, not a fact about the bag, and it is derived back from the
  /// selection whenever the two could disagree.
  int _page = 0;

  int get pageCount =>
      (widget.inventory.maxSlots / HotbarView.slotsPerPage).ceil();

  int get pageStart => _page * HotbarView.slotsPerPage;

  /// The last page is short whenever the bag is not a whole number of pages.
  int get slotsOnPage {
    final remaining = widget.inventory.maxSlots - pageStart;
    return remaining < HotbarView.slotsPerPage
        ? remaining
        : HotbarView.slotsPerPage;
  }

  int get page => _page;

  @override
  void initState() {
    super.initState();
    final inventory = widget.inventory;
    final input = locator<InputHelper>();
    _subscriptions.addAll(<void Function()>[
      // Contents changed anywhere: only a redraw, the selection is untouched.
      inventory.inventoryChanged.connect(_redraw),
      inventory.slotChanged.connect((_) => _redraw()),
      // The selection moved, or what it points at changed underneath it.
      inventory.selectionChanged.connect((_) => _followSelection()),
      input.hotbarSlotPressed.connect(_selectOnPage),
      input.hotbarPageFlipped.connect(flipPage),
      input.hotbarStepped.connect(step),
    ]);
    // The bar opens on whatever the soul was already holding — after a save
    // that is not slot zero, and the page has to be the one containing it.
    _followSelection();
  }

  @override
  void dispose() {
    for (final unsubscribe in _subscriptions) {
      unsubscribe();
    }
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  /// Brings the page containing the selected slot on screen. Called rather than
  /// assumed: the selection can move from outside this widget entirely — a
  /// script arming a tool, a save being loaded — and a bar showing a page that
  /// does not contain the held item is the bug this closes.
  void _followSelection() {
    final selected = widget.inventory.selectedSlot;
    final owningPage = selected ~/ HotbarView.slotsPerPage;
    if (mounted) {
      setState(() => _page = owningPage);
    } else {
      _page = owningPage;
    }
  }

  /// Selects by position within the visible page. A press past the end of a
  /// short last page selects nothing — the slot is not there to be chosen.
  void _selectOnPage(int indexOnPage) {
    if (indexOnPage < 0 || indexOnPage >= slotsOnPage) return;
    widget.inventory.selectSlot(pageStart + indexOnPage);
  }

  /// Moves the selection one slot along the current page, wrapping inside it.
  void step(int direction) {
    final relative = widget.inventory.selectedSlot - pageStart;
    final next = (relative + direction + slotsOnPage) % slotsOnPage;
    widget.inventory.selectSlot(pageStart + next);
  }

  /// Turns to another page, circular, keeping the selection at the same
  /// position within it where the new page is long enough to have one.
  void flipPage(int direction) {
    final relative = widget.inventory.selectedSlot - pageStart;
    final pages = pageCount;
    setState(() => _page = (_page + direction + pages) % pages);
    final available = slotsOnPage;
    final target = relative < available ? relative : available - 1;
    // selectSlot announces, which brings us back through _followSelection —
    // harmlessly, since it computes the page we just turned to.
    widget.inventory.selectSlot(pageStart + target);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = widget.inventory;
    final selected = inventory.selectedSlot;
    final rows = <Widget>[];
    for (var row = 0; row * GameConstants.slotsPerRow < slotsOnPage; row++) {
      final slots = <Widget>[];
      for (var column = 0; column < GameConstants.slotsPerRow; column++) {
        final indexOnPage = row * GameConstants.slotsPerRow + column;
        if (indexOnPage >= slotsOnPage) break;
        final globalIndex = pageStart + indexOnPage;
        slots.add(
          GestureDetector(
            // Input parity (rule 12): the same intent the number keys raise,
            // reachable by a finger. Both end at `selectSlot`, so neither can
            // grow a behavior the other lacks.
            onTap: () => inventory.selectSlot(globalIndex),
            child: ItemSlotView(
              stack: inventory.slots[globalIndex],
              isSelected: globalIndex == selected,
            ),
          ),
        );
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: slots));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...rows,
            if (pageCount > 1) _PageDots(count: pageCount, current: _page),
          ],
        ),
      ),
    );
  }
}

/// One dot per page, the current one lit. Drawn only when there is more than
/// one page — a single dot would say nothing and still take room.
final class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  static const _lit = Color(0xFFFFD95A);
  static const _dim = Color(0x99666666);

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == current ? _lit : _dim,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
