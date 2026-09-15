import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/loadout_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// Grants a new world's loadout — the port of `starting_loadout_rules.gd`'s
/// `apply`, without the two halves that have no subject here yet.
///
/// PORT DELTAS, each named rather than stubbed: the `DEBUG_LOADOUT`
/// switchboard is `D-3` (not ported); `sync_slots_to_tier` sizes the bag by
/// the player's tier through `TierSystem`, which is FP7.5 — the bag is the
/// authored `inventory_size` until then; and `granted_xp` goes to the same
/// system, so a loadout that authors any is REFUSED (assert) rather than
/// silently granted nothing (rule 20). The creative-mode branch is
/// `RuntimeConfig`'s and unported.
abstract final class StartingLoadoutRules {
  /// Puts the loadout [loadoutId] into [player]'s bag, once. Every line must
  /// fit whole — a loadout the authored bag cannot hold is a content error,
  /// not a partial grant.
  static void apply(
    IActor player, {
    String loadoutId = GameConstants.startingLoadoutId,
  }) {
    final loadout = locator<LoadoutRegistry>().getLoadout(loadoutId);
    assert(
      loadout.grantedXp == 0,
      '[StartingLoadoutRules] $loadoutId authors ${loadout.grantedXp} XP, and '
      'XP has no system to land in yet (FP7.5) — it would be granted nothing',
    );
    final items = locator<ItemRegistry>();
    for (final line in loadout.entries) {
      final leftOver = player.inventory.addItem(
        items.getItem(line.itemId),
        line.amount,
      );
      assert(
        leftOver == 0,
        '[StartingLoadoutRules] $loadoutId grants ${line.amount}× '
        '${line.itemId} and $leftOver did not fit the authored bag',
      );
    }
  }
}
