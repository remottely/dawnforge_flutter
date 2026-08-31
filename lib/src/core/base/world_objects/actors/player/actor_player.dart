import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';

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

  /// The press. Aims, and hands the aim to whatever is in this player's hand.
  ///
  /// What the press MEANS is the hand's (see [ItemHand]); what this class owns
  /// is when a press is the world's at all, and what it costs. Returns whether
  /// the action landed, which is not whether the press was spent — the two
  /// answers come back together in [ActionOutcome], because only the hand can
  /// tell them apart.
  bool performPrimaryAction() {
    // Rule 30's half of "the game never pauses": a surface that must hold the
    // player pushes a blocker, and gameplay asks whether it may act. Nothing
    // is frozen; this press simply is not the world's.
    if (!locator<GameInputManager>().isGameplayEnabled) return false;
    if (!canPerformAction) return false;

    final outcome = usePrimaryAction(aimAtCursor());
    // An aim at nothing costs nothing; anything the hand actually DID takes
    // the cadence, landed or not, so hammering a rock you cannot break is not
    // free.
    if (outcome != ActionOutcome.none) _actionCooldown = actionSpeedCooldown;
    return outcome == ActionOutcome.landed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_actionCooldown > 0) _actionCooldown -= dt;
  }
}
