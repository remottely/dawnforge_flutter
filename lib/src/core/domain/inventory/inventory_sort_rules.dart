import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// Where an item lands when the grid is reordered — the Dart port of
/// `InventorySortRules.cs` (`shared/domain/inventory/`).
///
/// Three ranks, read in order: which drawer the item belongs to
/// ([categoryRank]), which shelf inside that drawer ([subcategoryRank]), and
/// how good it is ([tierRank]). The fourth axis the sort uses — the item's
/// displayed name — is deliberately absent here: it is localized, so the
/// alphabet that applies to it is the player's, and comparing it belongs to
/// the caller that already holds the locale.
///
/// Everything is a table, not a chain of comparisons, for the reason the whole
/// feature exists: "why is the bow above the staff" has to have exactly one
/// place to look.
///
/// It takes [ItemData] rather than primitives, unlike every other rules class
/// ported so far, and the spec's does too: a category is a question about the
/// item's PLACE IN THE HIERARCHY, and there is no primitive that carries it.
abstract final class InventorySortRules {
  // ============================================
  // CATEGORY
  // ============================================
  // The drawer order the player reads down the grid. Tools first because they
  // are what a survival inventory is opened for, then what is worn, then what
  // is eaten, then the stock a build or a craft draws on. Materials are last
  // because they are the bulk: a sorted inventory should put the six things
  // you act with above the forty you hoard.
  //
  // PORT DELTA — four of the seven have no subject in this port, and their
  // NUMBERS ARE HELD ANYWAY. `ItemArmorData`, `ItemConsumableData`,
  // `ItemCosmeticData` and `ItemProjectileData` are unported classes, so the
  // apple and the vinewhip — both authored with a `type` of their own in the
  // pack, both read back as plain [ItemData] by `ItemRegistry` — rank as
  // MATERIAL today. Renumbering the ladder down to the three live steps would
  // mean every family renumbers again on arrival, and a saved sort order is
  // not the only thing that reads these: the spec's own comment is that a
  // player asking "why is this above that" gets one table to look at, and two
  // engines answering with different integers is the fork the shared pack
  // contract exists to prevent (study §4).

  static const int categoryTool = 0;
  static const int categoryArmor = 1;
  static const int categoryConsumable = 2;
  static const int categoryBuildable = 3;
  static const int categoryCosmetic = 4;
  static const int categoryProjectile = 5;
  static const int categoryMaterial = 6;

  /// Which drawer this item belongs to. Checked most-specific first: in the
  /// spec every category below `ItemCraftableData` is one of its subclasses,
  /// so a broader test placed earlier would swallow the narrower ones.
  ///
  /// `toolType != null` is how this port spells the spec's `is IItemToolData`
  /// — the tool subclasses are unported and their two fields were lifted onto
  /// [ItemData] at 0.27.0. It reads the same authored `tool_type` the spec's
  /// subclass declares, so the two agree on every item in the pack.
  static int categoryRank(ItemData item) {
    if (item.toolType != null) return categoryTool;
    if (item is ItemBuildableData) return categoryBuildable;

    // Plain ItemData and BARE ItemCraftableData — ore, planks, fibre. A copper
    // bar is made rather than found and is still a material: being craftable
    // is not a category, which is why the spec's ladder tests the subclasses
    // and lets their parent fall through here. This is the honest bottom of
    // the hierarchy, not a fallback: an item that is none of the above is a
    // material by definition.
    return categoryMaterial;
  }

  // ============================================
  // SUBCATEGORY
  // ============================================

  /// Tool shelves. Harvesting tools lead — they are the ones a player reaches
  /// for between fights — and the three weapons close the drawer in the order
  /// they unlock. The relative order axe → sword → bow → staff is the one the
  /// design asked for; the remaining kinds are slotted beside the tool they
  /// are used interchangeably with.
  ///
  /// Order is the DATA here, so this list is the spec's verbatim and not the
  /// declaration order of [ToolType] (which mirrors the Godot int values, and
  /// would put the shovel first).
  static const List<ToolType> _toolOrder = <ToolType>[
    ToolType.axe,
    ToolType.pickaxe,
    ToolType.shovel,
    ToolType.hoe,
    ToolType.sickle,
    ToolType.sledgehammer,
    ToolType.wateringCan,
    ToolType.fishingRod,
    ToolType.scanner,
    ToolType.sword,
    ToolType.bow,
    ToolType.staff,
    ToolType.innate,
  ];

  /// Which shelf inside the drawer. Every live category here is one flat
  /// shelf except the tools.
  ///
  /// PORT DELTA: the spec's armour arm reads `ItemArmorData.slot`, which is
  /// already head-down as an enum order. No armour class exists here, so the
  /// arm is left out rather than stubbed (rule 5) — it arrives with the
  /// equipment system that gives `slot` a meaning.
  static int subcategoryRank(ItemData item) {
    final toolType = item.toolType;
    if (toolType != null) return toolTypeRank(toolType);
    return 0;
  }

  /// Position of a tool kind in [_toolOrder]. Throws on a kind that is not
  /// listed rather than sorting it to the front: a new [ToolType] silently
  /// landing above the axe is exactly the drift the table exists to prevent.
  ///
  /// Unreachable today — the table holds all thirteen kinds, and a test pins
  /// that it still does. It is a `throw` and not an `assert` on purpose: the
  /// day the enum grows past the table, a release build must not answer with
  /// a rank it made up.
  static int toolTypeRank(ToolType toolType) {
    final rank = _toolOrder.indexOf(toolType);
    if (rank < 0) {
      throw StateError(
        '[InventorySortRules] ToolType "${toolType.name}" is missing from the '
        'tool order — add it there to give it a place in the sort',
      );
    }
    return rank;
  }

  // ============================================
  // TIER
  // ============================================

  /// Rank by quality, negated so that a higher tier sorts earlier. The best
  /// axe you own is the one you want at the top of the axes, not at the
  /// bottom of them.
  static int tierRank(ItemData item) => -item.tier;
}
