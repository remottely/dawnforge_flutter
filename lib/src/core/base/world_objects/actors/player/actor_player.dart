import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// The actor a person is playing — the port of `actor_player.gd`'s first
/// concern: turning a press into a swing, at what the cursor is over, within
/// the reach of what is in hand.
///
/// Built by `ActorFactory` for any actor authored into the `player` group, the
/// same authored list bare hands and the permission gate read. Membership is
/// content; the factory does not know a player by name.
///
/// PORT DELTAS, all of them their own subjects: pulling a free prop, the
/// gift/hover/pull components, the death screen, the drop-aim vector, the
/// minigame surfaces and every network half. This class carries the reach, the
/// aim and the pace, and nothing else yet.
final class ActorPlayer extends IActor {
  /// Seconds before this player may act again. A never-serialized internal
  /// (rule 8) — a cooldown mid-flight is not state a save has any use for.
  double _actionCooldown = 0;

  /// Whether the last action's cooldown has run out. The spec's
  /// `can_perform_action`.
  bool get canPerformAction => _actionCooldown <= 0;

  /// Seconds between actions, from the authored `base_action_speed` — the
  /// spec's `1.0 / base_speed`. The player authors 0.5, so two seconds a
  /// swing: slow, and slow on purpose, because it is content.
  ///
  /// PORT DELTA: the spec then shortens it 3% per level, which is `TierSystem`
  /// (FP7).
  double get actionSpeedCooldown => 1 / actorData.baseActionSpeed;

  /// How far this player reaches right now, in PIXELS: the reach of the item
  /// in hand. A hand holding nothing reaches nothing — and cannot act anyway,
  /// which `IActor.usePrimaryActionOn` decides one step later.
  double get actionRange =>
      (heldItem.currentItem?.actionRange ?? 0) * GameConstants.tileDimension;

  /// Where this player is aiming, measured NOW — see [AimSnapshot] for why it
  /// is measured once and never re-derived.
  ///
  /// The origin is the body's own position and the point is the unified cursor
  /// (rule 11: asked of `InputHelper`, whatever moved it). When the two
  /// coincide — the cursor is on the player — the current facing stands.
  AimSnapshot aimAtCursor() => AimSnapshot.fromPoint(
        position,
        locator<InputHelper>().getCursorWorldPos(),
        direction.lookDirection,
      );

  /// The press. Aims, finds what is under the aim, and swings at it.
  ///
  /// THE STRICT SINGLE-TILE RULE, which the spec's own comment insists on: the
  /// only candidate is what the cursor is over. There is no radius, no nearest
  /// match and no falling through to a neighbour — a player who misses simply
  /// misses, and the alternative is a swing that splashes onto the tile beside
  /// the one they were looking at.
  ///
  /// Returns whether the blow landed, which is not whether the press was
  /// spent: an aim at nothing costs nothing, but a swing that hits armour it
  /// cannot dent still takes its cooldown.
  bool performPrimaryAction() {
    // Rule 30's half of "the game never pauses": a surface that must hold the
    // player pushes a blocker, and gameplay asks whether it may act. Nothing
    // is frozen; this press simply is not the world's.
    if (!locator<GameInputManager>().isGameplayEnabled) return false;
    if (!canPerformAction) return false;

    final target = propAt(aimAtCursor().point);
    if (target == null) return false;
    if (!WorldObjectPermissionHelper.isWithinRange(
      this,
      ObjectTarget(target),
      actionRange,
    )) {
      return false;
    }

    final landed = usePrimaryActionOn(target);
    // Spent whether or not it landed — the spec resets the cooldown on the
    // attempt, so hammering a rock you cannot break is not free.
    _actionCooldown = actionSpeedCooldown;
    return landed;
  }

  /// The prop holding the tile [point] falls in, or null for empty ground.
  Prop? propAt(WorldPos point) {
    final grid = locator<GridManager>();
    return grid.getPropAt(grid.worldToGrid(point));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_actionCooldown > 0) _actionCooldown -= dt;
  }
}
