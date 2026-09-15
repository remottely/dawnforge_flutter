import 'dart:ui' show ImageFilter;

import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/workstation_component.dart';
import 'package:dawnforge/src/core/domain/production/crafting_rules.dart';
import 'package:dawnforge/src/core/domain/production/production_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:dawnforge/src/core/ui/widgets/panel_button.dart';
import 'package:dawnforge/src/core/ui/widgets/recipe_slot_view.dart';
import 'package:flutter/widgets.dart';

/// The bench, open — the Dart port of `workstation_ui.gd`.
///
/// Pick a recipe, say how many, press Make it, watch the bar. The station does
/// the making; this panel only ever ASKS it to, and reads back what it says
/// through the same signals any other listener would get.
///
/// THE GAME DOES NOT PAUSE BEHIND IT (rule 30), exactly as the bag does not:
/// a `GameInputManager` blocker stops the player from acting while the
/// simulation keeps running, and the blur is a live `BackdropFilter` so the
/// world is SEEN moving. It matters more here than anywhere: a batch takes
/// seconds of world time, and those seconds are ticking on the fixed step
/// behind this very panel.
///
/// Which of the two views is drawn is DERIVED from the station, never stored
/// (rule 8): `station.isProducing` is the whole of the question, and it lives
/// on the data soul where a save will find it. The spec keeps `_is_open` and
/// swaps `visible` flags on two containers; a flag that can disagree with the
/// machine is a flag that eventually does.
///
/// PORT DELTAS, each a system that is not here to be called. The four toasts
/// (`notification.production_started`, `.production_complete`,
/// `.not_enough_materials`, `.production_failed`) wait for FP5.1's
/// notification queue — there is no surface that shows one yet, so the strings
/// are not authored either; a refusal is said by a DISABLED button instead,
/// which is the same answer given before the press rather than after it. The
/// network branch of `_on_start_pressed` (ask the host, or start locally) is
/// study D4's unported half. Pagination, the font-scale and zoom handlers and
/// the hover-preview of a recipe are FP5.2's settings and FP5.1's indicator.
final class WorkstationPanelView extends StatefulWidget {
  const WorkstationPanelView({
    required this.station,
    required this.inventory,
    required this.title,
    required this.onClose,
    super.key,
  });

  /// The machine. A component and not a host (rule 13): everything this panel
  /// does with a station goes through it, and naming the host here would tie
  /// the screen to a `Prop` for nothing.
  final WorkstationComponent station;

  /// Whose pockets pay. Also a component, for the same reason.
  final InventoryComponent inventory;

  /// What the station is called, in the player's language. Passed in rather
  /// than read here because the name belongs to the station's DATA and this
  /// panel already holds the component that holds it — one reader, at the
  /// place that mounts the panel.
  final String title;

  /// Takes the panel off screen. Owned by whoever mounted it.
  final VoidCallback onClose;

  @override
  State<WorkstationPanelView> createState() => WorkstationPanelViewState();
}

const _panel = Color(0xE61B1712);
const _panelBorder = Color(0xFF4A3B2A);
const _title = Color(0xFFF6EDE0);
const _dim = Color(0xFFBFAE97);
const _short = Color(0xFFE07A5F);
const _enough = Color(0xFF7FBF5A);
const _accent = Color(0xFF6B5220);
const _danger = Color(0xFF6B2A20);

/// Recipes per row — the spec's `RECIPE_GRID_COLUMNS`.
const int _gridColumns = 4;

/// How wide the details column draws beside the grid. Wide enough for the
/// quantity row, which is the longest thing in it: a label, three buttons and
/// the number between them.
const double _detailsWidth = 300;

final class WorkstationPanelViewState extends State<WorkstationPanelView> {
  final List<void Function()> _subscriptions = <void Function()>[];

  /// The recipe the player is looking at, or null before they have picked one.
  /// View state, and only view state: nothing in the world knows about it.
  ItemCraftableData? _selected;

  /// How many the player has asked for. Never below one, never above what
  /// `CraftingRules` allows — both enforced where it changes, so no reader has
  /// to re-check.
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Both stacks, for the two different questions they answer — the same
    // pairing the bag makes, and for the same reason.
    final ui = locator<UIStateMachine>()..pushSurface(this, UIState.menu);
    final blockers = locator<GameInputManager>()..pushUiBlocker(this);
    assert(
      !blockers.isGameplayEnabled,
      '[WorkstationPanelView] blocker not held',
    );
    _subscriptions.addAll(<void Function()>[
      // What the player can afford changed under them — every recipe's dot,
      // every ingredient line and the Make it button read the bag.
      widget.inventory.inventoryChanged.connect(_redraw),
      widget.inventory.slotChanged.connect((_) => _redraw()),
      // The ONE subscription to the machine's tick, held by the panel. The
      // spec gives each recipe slot its own and carries a `teardown()` to
      // undo them; one subscription cannot be forgotten in forty places.
      widget.station.productionProgress.connect((_) => _redraw()),
      widget.station.productionStarted.connect((_) => _redraw()),
      widget.station.itemProduced.connect((_) => _redraw()),
      widget.station.productionCompleted.connect(_redraw),
      widget.station.productionCancelled.connect((_) => _redraw()),
      ui.cancelRequested.connect((owner) {
        if (identical(owner, this)) widget.onClose();
      }),
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
    locator<UIStateMachine>().popSurface(this);
    locator<GameInputManager>().popUiBlocker(this);
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  // ============================================
  // WHAT THE PLAYER CAN PAY FOR
  // ============================================

  /// The largest order the bag covers, for [recipe].
  int _maxCraftable(ItemCraftableData recipe) =>
      CraftingRules.maxCraftable(recipe.ingredients, widget.inventory.countOf);

  bool _canAfford(ItemCraftableData recipe, int quantity) =>
      CraftingRules.canCraft(
        recipe.ingredients,
        widget.inventory.countOf,
        quantity: quantity,
      );

  // ============================================
  // THE PRESSES
  // ============================================

  void _select(ItemCraftableData recipe) {
    setState(() {
      _selected = recipe;
      // A new recipe starts at one, as the spec's does: the number left over
      // from the last one is a number about something else.
      _quantity = 1;
    });
  }

  void _stepQuantity(int by) {
    final recipe = _selected;
    if (recipe == null) return;
    final ceiling = _maxCraftable(recipe);
    setState(() => _quantity = _clampQuantity(_quantity + by, ceiling));
  }

  void _takeMax() {
    final recipe = _selected;
    if (recipe == null) return;
    final ceiling = _maxCraftable(recipe);
    setState(() => _quantity = _clampQuantity(ceiling, ceiling));
  }

  /// One place decides what a legal order is. The floor is one — an order of
  /// nothing is not an order — and the ceiling is whatever the bag covers,
  /// which `CraftingRules.maxCraftable` has already capped at the spec's
  /// hundred. A player holding nothing lands on one and the Make it button is
  /// what refuses, not a quantity of zero nobody can read.
  static int _clampQuantity(int wanted, int ceiling) {
    if (wanted < 1) return 1;
    if (ceiling >= 1 && wanted > ceiling) return ceiling;
    return wanted;
  }

  void _start() {
    final recipe = _selected;
    if (recipe == null) return;
    // The station asks the same question again with its own copy of the bag,
    // and its answer is the one that counts. This call is a request, not a
    // command — which is why the button is disabled rather than this being
    // an assert.
    widget.station.startProduction(recipe, _quantity, widget.inventory);
  }

  // ============================================
  // THE TWO VIEWS
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // The live world, blurred — filtered every frame from what is actually
        // painted behind it, never a snapshot (rule 30).
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: const ColoredBox(color: Color(0x66000000)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _title,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.station.isProducing)
                    _progressView()
                  else
                    _selectionView(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectionView() {
    final recipes = widget.station.availableRecipes();
    final rowCount = (recipes.length / _gridColumns).ceil();
    final selected = _selected;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var row = 0; row < rowCount; row++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var column = 0; column < _gridColumns; column++)
                    if (row * _gridColumns + column < recipes.length)
                      _recipeSlot(recipes[row * _gridColumns + column]),
                ],
              ),
          ],
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: _detailsWidth,
          child: selected == null ? _noSelection() : _details(selected),
        ),
      ],
    );
  }

  Widget _recipeSlot(ItemCraftableData recipe) => RecipeSlotView(
        recipe: recipe,
        isSelected: recipe.id == _selected?.id,
        canCraft: _canAfford(recipe, 1),
        onSelected: _select,
      );

  Widget _noSelection() => Text(
        tr('ui.workstation.select_recipe'),
        style: const TextStyle(fontSize: 13, color: _dim),
      );

  /// Everything the player needs to decide: what it makes, what it costs
  /// against what they have, how long it takes, and how many.
  Widget _details(ItemCraftableData recipe) {
    final items = locator<ItemRegistry>();
    final ceiling = _maxCraftable(recipe);
    final affordable = _canAfford(recipe, _quantity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          recipe.displayName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _title,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr('ui.workstation.requires'),
          style: const TextStyle(fontSize: 12, color: _dim),
        ),
        for (final line in recipe.ingredients)
          _ingredientLine(
            name: items.getItem(line.itemId).displayName,
            have: widget.inventory.countOf(line.itemId),
            need: line.amount * _quantity,
          ),
        const SizedBox(height: 6),
        Text(
          trFormat('ui.workstation.output_format', <String, Object>{
            'amount': recipe.craftAmount * _quantity,
            'item': recipe.displayName,
          }),
          style: const TextStyle(fontSize: 13, color: _title),
        ),
        Text(
          trFormat('ui.workstation.time_seconds', <String, Object>{
            // The station's own multiplier is in this number, which is the
            // whole reason it is asked of the DATA and not of the recipe: a
            // faster bench really does say a smaller number.
            'seconds': widget.station.workstationData
                .effectiveTime(recipe, quantity: _quantity)
                .toStringAsFixed(1),
          }),
          style: const TextStyle(fontSize: 12, color: _dim),
        ),
        const SizedBox(height: 10),
        _quantityStepper(ceiling),
        const SizedBox(height: 10),
        PanelButton(
          label: tr('ui.workstation.start_production'),
          onPressed: _start,
          isEnabled: affordable,
          tint: _accent,
          minWidth: _detailsWidth,
        ),
      ],
    );
  }

  /// One ingredient, as two numbers rather than one colour. The spec draws the
  /// amount the recipe needs and paints it green or red; green and red are the
  /// same to a colour-blind player, and this game is written for readers of
  /// seven. The colour stays as well — it is a second way to say it, never the
  /// only one.
  Widget _ingredientLine({
    required String name,
    required int have,
    required int need,
  }) =>
      Text(
        trFormat('ui.workstation.ingredient_have_need', <String, Object>{
          'have': have,
          'need': need,
          'item': name,
        }),
        style: TextStyle(fontSize: 12, color: have >= need ? _enough : _short),
      );

  Widget _quantityStepper(int ceiling) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            tr('ui.workstation.quantity'),
            style: const TextStyle(fontSize: 12, color: _dim),
          ),
          const SizedBox(width: 6),
          PanelButton(
            label: '-',
            onPressed: () => _stepQuantity(-1),
            isEnabled: _quantity > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$_quantity',
              style: const TextStyle(fontSize: 14, color: _title),
            ),
          ),
          PanelButton(
            label: '+',
            onPressed: () => _stepQuantity(1),
            isEnabled: _quantity < ceiling,
          ),
          const SizedBox(width: 6),
          PanelButton(
            label: tr('ui.workstation.max'),
            onPressed: _takeMax,
            isEnabled: ceiling > 1 && _quantity < ceiling,
          ),
        ],
      );

  /// What a working bench shows. Everything on it is read from the station,
  /// so the panel can be closed and reopened mid-batch and say the same thing.
  Widget _progressView() {
    final recipe = widget.station.currentRecipe!;
    final data = widget.station.workstationData;
    final current = ProductionRules.currentItemNumber(
      data.initialQuantity,
      data.remainingQuantity,
    );

    return SizedBox(
      // The progress view takes the whole of the panel the grid and the
      // details had between them, so the panel does not resize when a batch
      // starts — a window that jumps under a press reads as a bug.
      width: _detailsWidth + ItemSlotView.size * _gridColumns + 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // A batch of one says only what is being made; a batch of five
            // says which of the five. Two keys, because a sentence that
            // always reads "1 of 1" teaches the player to stop reading it.
            data.initialQuantity == 1
                ? trFormat('ui.workstation.producing', <String, Object>{
                    'item': recipe.displayName,
                  })
                : trFormat(
                    'ui.workstation.producing_progress',
                    <String, Object>{
                      'item': recipe.displayName,
                      'current': current,
                      'total': data.initialQuantity,
                    },
                  ),
            style: const TextStyle(fontSize: 14, color: _title),
          ),
          const SizedBox(height: 8),
          _ProgressBar(progress: widget.station.currentProgress),
          const SizedBox(height: 10),
          PanelButton(
            label: tr('ui.workstation.cancel'),
            onPressed: widget.station.cancelProduction,
            tint: _danger,
          ),
        ],
      ),
    );
  }

  /// The chosen recipe and the ordered amount — read by the tests, and by
  /// nothing else.
  ItemCraftableData? get selectedRecipe => _selected;
  int get quantity => _quantity;
}

/// How far the unit on the bench has got, drawn as one bar.
final class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  /// In [0, 1] — one unit's worth, not the batch's. The spec's bar is the same
  /// one: a batch's progress is said in words above it, because "3 of 5" is a
  /// number a player can act on and 0.6 of a bar is not.
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: ItemSlotView.size * _gridColumns,
        height: 12,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2318),
            border: Border.all(color: _panelBorder),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: const ColoredBox(color: _enough),
          ),
        ),
      );
}
