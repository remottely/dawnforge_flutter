import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// Which recipes a bench of a given kind and rank may make — the port of
/// `PropWorkstationData.can_use_recipe` and `get_valid_recipes`, lifted out of
/// the station's data class at 0.76.0 because a station is no longer the only
/// bench: the player's own two hands are one too (`D-2`), at
/// [WorkstationType.none].
///
/// The GATE and the LIST are one sentence here, deliberately. They were two in
/// the spec once and disagreed, which is how a station offers a recipe it then
/// refuses to make.
///
/// It reads the item registry, which is what keeps it out of the pure `*Rules`
/// family: "which recipes exist" is a question only the registry can answer,
/// and there is exactly one of it for the app's whole life (rule 28).
abstract final class RecipeCatalog {
  /// Whether a bench of [type] at [tier] may make [recipe].
  ///
  /// Tier is CUMULATIVE, not exact: a bench of tier N makes every recipe of
  /// its type from the first tier up to N, so a tier 5 smelter still melts
  /// tier 1 bars. Written as `<=` and never as a list of accepted tiers, so
  /// the rule holds for however many tiers a pack declares.
  ///
  /// PORT DELTA — the spec adds a third clause, `TierSystem.is_content_unlocked`
  /// (the Forge Almanac / skill tree). Progression is unported (FP7), so the
  /// clause is left out rather than stubbed true: a stub would be a gate that
  /// says yes to everything while looking like a gate.
  static bool accepts(ItemCraftableData recipe, WorkstationType type, int tier) =>
      recipe.isCraftable && recipe.craftedAt == type && recipe.tier <= tier;

  /// Every recipe a bench of [type] at [tier] offers, ordered for a player to
  /// read: by tier, and then by id.
  ///
  /// Sorted by tier FIRST because the list is not one tier deep, and ids sort
  /// as TEXT, where `t10_` falls between `t1_` and `t2_`.
  ///
  /// PORT DELTA — the spec's `get_valid_recipes_cached` is not ported. It has
  /// no caller there either; the surface calls the uncached one. A cache
  /// nobody asks for is a second answer waiting to disagree with the first.
  static List<ItemCraftableData> availableAt(WorkstationType type, int tier) {
    final items = locator<ItemRegistry>();
    final found = <ItemCraftableData>[];
    for (final id in items.ids) {
      final item = items.getItem(id);
      if (item is ItemCraftableData && accepts(item, type, tier)) {
        found.add(item);
      }
    }
    found.sort(
      (a, b) =>
          a.tier != b.tier ? a.tier.compareTo(b.tier) : a.id.compareTo(b.id),
    );
    return found;
  }
}
