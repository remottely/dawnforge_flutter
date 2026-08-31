import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// The hand that SWINGS — the port of `item_hand_tool_melee.gd`'s first
/// concern, and the whole of FP4.3a's harvest moved to where the spec keeps it.
///
/// Which hand an item gets is decided by whether it IS a tool, and the port
/// spells that as `toolType != null` because `tool_type` was lifted onto
/// `ItemData` at 0.27.0 — the spec declares it on the tool SUBCLASSES, which
/// are not ported (`item_data.dart` records why).
///
/// PORT DELTAS beyond the ones the base already lists: the swing animation and
/// the knockback impulse (no motion on screen, FP4.3a); the watering can's
/// refill-from-water branch and the durability block (FP4.4 and the durability
/// state the base's clone delta names); `action_effect_radius` and the
/// physics-shape query behind it, which is how the spec finds targets for an
/// AI that has no cursor — this port has one user and it aims.
final class ItemHandTool extends ItemHand {
  ItemHandTool(super.data, super.user);

  /// THE STRICT SINGLE-TILE RULE, which the spec's own comment insists on: the
  /// only candidate is what the aim is over. There is no radius, no nearest
  /// match and no falling through to a neighbour — a player who misses simply
  /// misses, and the alternative is a swing that splashes onto the tile beside
  /// the one they were looking at.
  @override
  ActionOutcome primaryAction(AimSnapshot aim) {
    final target = _propAt(aim.point);
    // Nothing under the aim, or too far: the press never became an action, so
    // it costs nothing. Reach is asked HERE rather than by the actor because
    // the reach is the ITEM's — a spear is longer than a hand, and the actor
    // holding it has no opinion.
    if (target == null) return ActionOutcome.none;
    if (!WorldObjectPermissionHelper.isWithinRange(
      user,
      ObjectTarget(target),
      reachPixels,
    )) {
      return ActionOutcome.none;
    }

    // Past here the swing HAPPENED. Whether it did anything is the gate's
    // answer and the target's health, and neither of them refunds the cadence.
    if (!WorldObjectPermissionHelper.canDamageTarget(
      ObjectTarget(target),
      user,
    )) {
      return ActionOutcome.spent;
    }
    return target.takeDamage(data.attackDamage, user)
        ? ActionOutcome.landed
        : ActionOutcome.spent;
  }

  /// The prop holding the tile [point] falls in, or null for empty ground.
  Prop? _propAt(WorldPos point) {
    final grid = locator<GridManager>();
    return grid.getPropAt(grid.worldToGrid(point));
  }
}
