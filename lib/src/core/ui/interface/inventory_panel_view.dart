import 'dart:ui' show ImageFilter;

import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/domain/inventory/inventory_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:dawnforge/src/core/ui/widgets/panel_button.dart';
import 'package:flutter/widgets.dart';

/// The whole bag, open — the Dart port of `inventory_ui.gd` and the drag half
/// of `inventory_slot_ui.gd`.
///
/// THE GAME DOES NOT PAUSE BEHIND IT (rule 30). There is no `pauseEngine`
/// anywhere in this repo and there is not going to be: the panel pushes a
/// `GameInputManager` blocker, which stops the player from ACTING, while the
/// simulation keeps running — the world behind the blur really is moving, and
/// the blur is a live `BackdropFilter` over it rather than a captured
/// snapshot, so you can watch it move. That is the visible half of the rule
/// and the reason a snapshot would be a lie rather than an optimisation.
///
/// It is a surface (`UIState.menu`), so it registers with the `UIStateMachine`
/// and answers the back press the machine ROUTES to it (rule 25) instead of
/// reading the key itself. Two surfaces reacting independently to one press is
/// how a menu closes itself while another opens on top.
final class InventoryPanelView extends StatefulWidget {
  const InventoryPanelView({
    required this.inventory,
    required this.onClose,
    required this.onDropToWorld,
    required this.onOpenCrafting,
    super.key,
  });

  final InventoryComponent inventory;

  /// Takes the panel off screen. Owned by whoever mounted it — the panel asks,
  /// it does not reach for the overlay stack itself.
  final VoidCallback onClose;

  /// Puts the whole of one slot on the ground at the holder's feet.
  final void Function(int slotIndex) onDropToWorld;

  /// Opens what the player can make with their own two hands (`D-2`). The bag
  /// is where it belongs: the hand-craft has no bench in the world to walk up
  /// to, so the only place it can be reached from is the thing the player is
  /// already carrying.
  final VoidCallback onOpenCrafting;

  @override
  State<InventoryPanelView> createState() => InventoryPanelViewState();
}

const _panel = Color(0xE61B1712);
const _panelBorder = Color(0xFF4A3B2A);
const _title = Color(0xFFF6EDE0);

/// How wide the slot grid draws, and therefore how wide the toolbar above it
/// has to be for its button to sit at the grid's right edge rather than at the
/// title's. Derived from the two numbers that decide it, never guessed.
const double _gridWidth = GameConstants.slotsPerRow * ItemSlotView.size;

final class InventoryPanelViewState extends State<InventoryPanelView> {
  final List<void Function()> _subscriptions = <void Function()>[];

  /// The slot a drag is currently lifted from, or -1. View-only: it says which
  /// slot to draw hollow while its contents are under the player's finger.
  int _draggingFrom = -1;

  @override
  void initState() {
    super.initState();
    final inventory = widget.inventory;
    // Both stacks, deliberately: the machine answers what is ON SCREEN, the
    // blocker answers WHO MAY ACT, and they are not the same question — a
    // text-entry surface over a live map blocks input without hiding the HUD.
    // The spec keeps them separate for the same reason.
    final ui = locator<UIStateMachine>()..pushSurface(this, UIState.menu);
    final blockers = locator<GameInputManager>()..pushUiBlocker(this);
    assert(!blockers.isGameplayEnabled, '[InventoryPanelView] blocker not held');
    _subscriptions.addAll(<void Function()>[
      inventory.inventoryChanged.connect(_redraw),
      inventory.slotChanged.connect((_) => _redraw()),
      // The ROUTED press, not the key: the machine decided this surface owns
      // it, so this is the only thing that gets to answer.
      ui.cancelRequested.connect((owner) {
        if (identical(owner, this)) widget.onClose();
      }),
      // An exclusive surface took the screen. Already off the stack when this
      // arrives — the handler only does visuals, which here means leaving.
      ui.surfaceEvicted.connect((owner) {
        if (identical(owner, this)) widget.onClose();
      }),
    ]);
  }

  @override
  void dispose() {
    for (final unsubscribe in _subscriptions) {
      unsubscribe();
    }
    // The spec detaches a surface when its node leaves the tree; Dart has no
    // such hook, so the surface owes it here. Both are defined no-ops if
    // something already removed us, which is what makes owing it safe.
    locator<UIStateMachine>().popSurface(this);
    locator<GameInputManager>().popUiBlocker(this);
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  /// One stack landing on another. Which of the three things happens is not
  /// the widget's decision — the container answers it, in one place, for the
  /// hotbar and every future chest as well.
  void _drop(int from, int to) {
    if (from == to) return;
    final inventory = widget.inventory;
    final source = inventory.slots[from];
    if (source.isEmpty) return;

    if (locator<InputHelper>().isSplitModifierHeld) {
      // Half, rounded up, so a stack of one still moves rather than sitting
      // there refusing — `InventoryRules.splitHalfAmount` is the same rule the
      // spec's split reads, and reading it here means there is one of it.
      inventory.moveWithin(from, to, InventoryRules.splitHalfAmount(source.amount));
      return;
    }

    final destination = inventory.slots[to];
    final sameKind = !destination.isEmpty &&
        InventoryRules.areIdsEqual(destination.itemId, source.itemId);
    if (destination.isEmpty || sameKind) {
      inventory.mergeStacks(from, to);
    } else {
      inventory.swapSlots(from, to);
    }
  }

  Widget _slot(int index) {
    final inventory = widget.inventory;
    final stack = inventory.slots[index];
    final view = ItemSlotView(
      stack: stack,
      isSelected: index == inventory.selectedSlot,
    );

    return DragTarget<int>(
      onAcceptWithDetails: (details) => _drop(details.data, index),
      builder: (context, candidate, rejected) {
        if (stack.isEmpty) return view;
        return Draggable<int>(
          data: index,
          onDragStarted: () => setState(() => _draggingFrom = index),
          onDragEnd: (_) => setState(() => _draggingFrom = -1),
          feedback: Opacity(opacity: 0.85, child: view),
          // Hollow, not gone: the slot keeps its place in the grid so nothing
          // reflows under the finger mid-drag.
          childWhenDragging: ItemSlotView(
            stack: stack,
            isSelected: false,
            isGhost: true,
          ),
          child: view,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = widget.inventory;
    final rowCount =
        (inventory.maxSlots / GameConstants.slotsPerRow).ceil();

    return Stack(
      children: <Widget>[
        // The live world, blurred. `BackdropFilter` filters what is actually
        // painted behind it every frame — the trees keep swaying, the boar
        // keeps walking. Rule 30 says the world must be SEEN moving, and this
        // is the whole of how.
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: const ColoredBox(color: Color(0x66000000)),
          ),
        ),
        // Everything outside the panel is where you let go to put a thing on
        // the ground. Behind the panel in the stack, so a drop onto a slot is
        // taken by the slot.
        Positioned.fill(
          child: DragTarget<int>(
            onAcceptWithDetails: (details) =>
                widget.onDropToWorld(details.data),
            builder: (context, candidate, rejected) =>
                const SizedBox.expand(),
          ),
        ),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _panel,
              border: Border.all(color: _panelBorder, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: _gridWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Text(
                          // Rule 19: no user-facing literal, ever.
                          tr('ui.menu.tab.inventory'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _title,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: PanelButton(
                            label: tr('ui.inventory.craft'),
                            onPressed: widget.onOpenCrafting,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          // The container reorders itself; the button only
                          // asks. Which pocket a thing lands in is decided
                          // once, for every inventory in the game, and a
                          // widget is the wrong place to know any of it.
                          child: PanelButton(
                            // Rule 19: the label is a key, in all three
                            // locales.
                            label: tr('ui.inventory.sort'),
                            onPressed: inventory.sortItems,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var row = 0; row < rowCount; row++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (var column = 0;
                            column < GameConstants.slotsPerRow;
                            column++)
                          if (row * GameConstants.slotsPerRow + column <
                              inventory.maxSlots)
                            _slot(row * GameConstants.slotsPerRow + column),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The slot a drag is lifted from, or -1 — read by the tests, which is the
  /// only thing outside this class that has any business knowing.
  int get draggingFrom => _draggingFrom;
}
