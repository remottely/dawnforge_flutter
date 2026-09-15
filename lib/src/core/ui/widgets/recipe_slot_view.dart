import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/ui/widgets/item_icon_view.dart';
import 'package:dawnforge/src/core/ui/widgets/item_slot_view.dart';
import 'package:flutter/widgets.dart';

/// The six looks a recipe slot can wear — the port of `recipe_slot_ui.gd`'s
/// `PanelStyle`.
///
/// It is an enum and not a pile of booleans (rule 9) because the states are
/// EXCLUSIVE and ordered: selected beats craftable, craftable beats disabled,
/// and hovering is a variant of the last two rather than a seventh thing. The
/// spec reaches the same answer with an if-ladder over three flags; naming the
/// six makes the ladder a table.
enum RecipeSlotState {
  craftable,
  disabled,
  selected,
  hoverCraftable,
  hoverDisabled;

  /// Which look a slot with these three facts wears. Selection wins over
  /// everything, including hover — a slot you have already chosen does not
  /// change under the pointer, or the details beside it would look like they
  /// belong to something else.
  static RecipeSlotState of({
    required bool isSelected,
    required bool canCraft,
    required bool isHovered,
  }) {
    if (isSelected) return RecipeSlotState.selected;
    if (isHovered) {
      return canCraft
          ? RecipeSlotState.hoverCraftable
          : RecipeSlotState.hoverDisabled;
    }
    return canCraft ? RecipeSlotState.craftable : RecipeSlotState.disabled;
  }
}

/// One recipe in the bench's grid — the Dart port of `recipe_slot_ui.gd`.
///
/// It is told what to show and shows it: the recipe, whether the player can
/// pay for it, and whether it is the chosen one. It holds no inventory and
/// subscribes to nothing.
///
/// PORT DELTA — the spec's slot subscribes to `inventory_changed` ITSELF, and
/// carries a `teardown()` whose comment records the leak that taught it to
/// (every recipe slot of every workstation ever opened re-running `can_craft`
/// on each pickup, forever). Here the PANEL holds the one subscription and
/// rebuilds its children, so there is no second place to forget.
///
/// PORT DELTA — the status dot is a WORD, not only a colour. The spec paints a
/// green or red square; green and red are the same square to a colour-blind
/// player, and this game is written for readers of seven.
final class RecipeSlotView extends StatefulWidget {
  const RecipeSlotView({
    required this.recipe,
    required this.isSelected,
    required this.canCraft,
    required this.onSelected,
    super.key,
  });

  final ItemCraftableData recipe;
  final bool isSelected;

  /// Whether the player can pay for ONE of this recipe right now.
  final bool canCraft;

  final void Function(ItemCraftableData recipe) onSelected;

  @override
  State<RecipeSlotView> createState() => _RecipeSlotViewState();
}

const _frame = Color(0xCC1B1712);
const _border = Color(0xFF4A3B2A);
const _borderSelected = Color(0xFFFFD95A);
const _borderCraftable = Color(0xFF7FBF5A);
const _fillSelected = Color(0xFF3A2E1E);
const _fillHover = Color(0xFF2C2318);
const _fillDisabled = Color(0x991B1712);
const _name = Color(0xFFF6EDE0);

final class _RecipeSlotViewState extends State<RecipeSlotView> {
  bool _isHovered = false;

  void _setHovered({required bool value}) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  /// The fill and the border this state wears. One table, the spec's own
  /// `_get_panel_style` switch, so "why is this one dark" has one place to
  /// look.
  (Color fill, Color border) _skin(RecipeSlotState state) =>
      switch (state) {
        RecipeSlotState.selected => (_fillSelected, _borderSelected),
        RecipeSlotState.craftable => (_frame, _borderCraftable),
        RecipeSlotState.disabled => (_fillDisabled, _border),
        RecipeSlotState.hoverCraftable => (_fillHover, _borderCraftable),
        RecipeSlotState.hoverDisabled => (_fillHover, _border),
      };

  @override
  Widget build(BuildContext context) {
    final state = RecipeSlotState.of(
      isSelected: widget.isSelected,
      canCraft: widget.canCraft,
      isHovered: _isHovered,
    );
    final (fill, border) = _skin(state);

    return MouseRegion(
      onEnter: (_) => _setHovered(value: true),
      onExit: (_) => _setHovered(value: false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelected(widget.recipe),
        child: SizedBox(
          width: ItemSlotView.size,
          height: ItemSlotView.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(
                color: border,
                width: state == RecipeSlotState.selected ? 3 : 1,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Opacity(
                      // A recipe you cannot pay for is still readable — dimmed
                      // is the answer, hidden is not: the player has to be able
                      // to look at it to learn what it costs.
                      opacity: widget.canCraft ? 1.0 : 0.45,
                      child: ItemIconView(itemId: widget.recipe.id),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 1,
                  child: Text(
                    widget.recipe.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1,
                      color: _name,
                      shadows: <Shadow>[
                        Shadow(blurRadius: 2),
                        Shadow(offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Whether the pointer is over this slot — read by the tests, which is the
  /// only thing outside this class with any business knowing.
  bool get isHovered => _isHovered;
}
