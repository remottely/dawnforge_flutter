import 'dart:math' as math;

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/grounds/ground_buildable.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/actor_occupancy_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_tool_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/domain/vitality/world_object_death_rules.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// What an action is aimed at.
///
/// The spec passes a `Node2D` and asks it what it is on the way down. Two
/// kinds ever arrive, and in this port they are not the same SHAPE: a prop or
/// an actor is a host with a data soul, while terrain is nodeless (FP3.4) — a
/// streamed tile is a [GridPos] and its data, with no object to hand anybody.
///
/// So the kind is a type, not a cast (rule 18). It stays ONE argument to ONE
/// gate rather than becoming two entry points, because the whole value of the
/// spec's helper is that one ORDER decides every verb: split it in two and the
/// ground rules and the object rules are free to be asked in different orders,
/// which is the bug the file's own comments were written against.
sealed class DamageTarget {
  const DamageTarget();
}

/// A prop, an actor — anything with a host and a soul.
final class ObjectTarget extends DamageTarget {
  ObjectTarget(this.object)
      : assert(
          object is! GroundBuildable,
          '[ObjectTarget] ground is addressed by its TILE — use GroundTarget. '
          'A tile arriving as an object would take the generic occupancy '
          'clause instead of its own, which is the second copy of one rule',
        );

  final WorldObject object;
}

/// A terrain tile, which has no host to name.
final class GroundTarget extends DamageTarget {
  const GroundTarget(this.tile);

  final GridPos tile;
}

/// May this source act on this target? — the port of
/// `world_object_permission_helper.gd`.
///
/// One yes/no per interaction verb, asked by gameplay before it swings and (in
/// the spec) by the cursor indicator before it draws, so the crosshair never
/// promises an action the swing would refuse. That double consumer is the
/// reason the answer lives here instead of inside each tool.
///
/// **The ORDER inside [canDamageTarget] is the port.** Two of its steps look
/// safer the other way round and are not; both are marked where they sit.
///
/// PORT DELTAS — every one of them a gate whose SUBJECT is unported, left out
/// rather than stubbed (rule 5: an unreachable branch is a lie about what the
/// game does):
///   - the squad friendly-fire guard (no squads — FP7);
///   - player-vs-player under `DifficultySystem` (singleplayer, decision D4);
///   - the waterable/tillable bypass, which belongs at the marked seam above
///     the occupancy rule (FP4.4's farming components);
///   - `can_build_on_target` — and its subject is NOT the data class any more.
///     `ItemBuildableData` has existed since 0.35.0; what is missing is the
///     SECOND CONSUMER. [canDamageTarget]'s only caller in this port is
///     `ItemHandTool.primaryAction`, and `HeldItemComponent._rebuildHand`
///     routes every `ItemBuildableData` to the BUILD hand before the tool arm
///     is reached — so the source can never be holding a blueprint when this
///     gate is asked, and the branch would be unreachable code the day it was
///     written. In the spec it is reachable because `interaction_indicator.gd`
///     asks the same question about whatever the cursor is over, blueprint in
///     hand or not. That indicator is FP5.1, and it is what brings this arm
///     with it. The reach check does already exist here: [isWithinRange]
///     landed with the swing that needed it, so placement inherited the same
///     measurement rather than inventing a second one;
///   - the elevation split of `allowed_tools`, where a tile with a rock on it
///     answers to the ROCK's tools (FP7, with ground destruction);
///   - `show_feedback` → `WorldObjectFeedback` (FP5.1's notification queue);
///   - `can_use_minigame_tool` and `is_supporting_higher_ground` (FP7).
abstract final class WorldObjectPermissionHelper {
  /// Whether [source] may damage [target] — the one gate every destructive
  /// path meets.
  static bool canDamageTarget(DamageTarget target, IActor source) {
    // 1. WHICH VERB is this act, asked ONCE (rule 33), because the gates below
    // apply to some verbs and not others. Farming TRANSFORMS a tile's surface
    // — it only ever spawns a prop on top, it cannot remove the tile — so the
    // ground an actor stands on neither appears nor vanishes, and neither the
    // destruction lock nor the occupancy rule further down is about it.
    final isFarmAct = canFarmTarget(target, source);

    // 1. THE DESTRUCTION LOCK. Ground only, and skipped for a farm act.
    if (target is GroundTarget &&
        !isFarmAct &&
        !canGroundBeDestroyed(target.tile)) {
      return false;
    }

    // 1.5. THE WATERING/TILLING BYPASS BELONGS HERE (FP4.4) — above the
    // occupancy rule, for the same reason 1.6 is: watering a crop and tilling
    // a field add and remove nothing anyone is standing on.

    // 1.6. THE BYPASSES. A farm act is legal even where a destruction would
    // not be, and this is the first of the two places the ORDER matters: put
    // the occupancy rule above this line — it reads as the safer arrangement —
    // and you can no longer till the tile you are standing on, silently, with
    // no error to trace it by.
    if (isFarmAct) return true;

    // 1.7. NOTHING IS DESTROYED OUT FROM UNDER AN ACTOR unless the object
    // itself allows it. Asked here because this is where every destructive
    // path meets: a tool, a companion's harvest, and the cursor's indicator
    // all come through.
    //
    // GROUND IS EXEMPT — the second place the order matters. Not because a
    // tile may be cut from under you (it may not), but because
    // [canGroundBeDestroyed] above already asked this very question, with an
    // extra clause of its own. Asking again here would be the THIRD copy of
    // one rule, which is the shape of bug `ActorOccupancyHelper` exists to end.
    if (target is ObjectTarget &&
        ActorOccupancyHelper.isDestructionBlocked(target.object)) {
      return false;
    }

    // 2. THE DATA REQUIREMENTS: the right KIND of tool, and a GOOD ENOUGH one.
    final data = dataOf(target);
    return validateTools(data, source, data.allowedTools);
  }

  /// Whether [source] holds a tool that TRANSFORMS this ground (rule 33), and
  /// whether there is room for what the transform would put there.
  ///
  /// `farmTools` is declared on `GroundBuildableData` and nowhere else — only
  /// ground farms, so anything else is refused before a tool is even read.
  static bool canFarmTarget(DamageTarget target, IActor source) {
    if (target is! GroundTarget) return false;

    final data = _groundDataAt(target.tile);
    if (data.farmTools.isEmpty) return false;

    final tool = WorldObjectToolHelper.toolTypeOf(source);
    if (tool == null || !data.farmTools.contains(tool)) return false;

    // Room for the prop the transform spawns. Props only — ACTORS ARE
    // DELIBERATELY IGNORED (the spec passes `ignore_actors: true` here), which
    // is the same statement 1.6 makes: you may plant under your own feet.
    return locator<GridManager>().isPropSpaceAvailable(target.tile);
  }

  /// Whether this terrain tile may be taken away at all.
  ///
  /// The spec's `GroundBuildable.can_be_destroyed`, which the gate above leans
  /// on for the exemption at 1.7. Its extra clause is the first one: a tile
  /// holding a prop is not destroyed out from under the prop.
  ///
  /// PORT DELTA: the spec's third clause — an attachment bound to this cell
  /// dying with it, which is how mining a mountain sealed whoever stood on the
  /// staircase cut into its face — waits for `AttachmentComponent`, the same
  /// absence `ActorOccupancyHelper` recorded at 0.26.0.
  static bool canGroundBeDestroyed(GridPos tile) {
    if (locator<GridManager>().getPropAt(tile) != null) return false;
    return !ActorOccupancyHelper.isGroundDestructionBlocked(
      _groundDataAt(tile),
      tile,
    );
  }

  /// The tool gate against the target's own declared list.
  static bool validateToolRequirement(IWorldObjectData data, IActor source) =>
      validateTools(data, source, data.allowedTools);

  /// The same gate against an explicitly chosen list. The caller passes it
  /// rather than this helper guessing, because one target can have two
  /// destructions with two lists — a tile with a rock standing on it is the
  /// spec's case, and it arrives with elevation (FP7).
  ///
  /// An EMPTY [allowed] refuses everything; that lives once, inside
  /// [WorldObjectDeathRules.hasAllowedTool], where 0.27.0 wrote down why (an
  /// authored refusal, not a missing value). The spec states it again here,
  /// and stating one rule twice is how the two copies eventually disagree.
  static bool validateTools(
    IWorldObjectData data,
    IActor source,
    List<ToolType> allowed,
  ) {
    if (!WorldObjectDeathRules.hasAllowedTool(
      WorldObjectToolHelper.toolTypeOf(source),
      allowed,
    )) {
      return false;
    }
    return WorldObjectDeathRules.meetsTierRequirement(
      WorldObjectToolHelper.tierOf(source),
      data.tier,
    );
  }

  /// Whether [target] is close enough for [source] to reach, given a reach of
  /// [rangePixels].
  ///
  /// EDGE TO EDGE, not centre to centre: the actor's BODY rect against the
  /// target's AREA rect — the same two rects `ActorOccupancyHelper` already
  /// defines, so what counts as "standing on" and what counts as "close
  /// enough" are measured off one geometry. Centre-to-centre would make a
  /// one-tile reach mean "your centre within 16px of its centre", which is
  /// almost nowhere: a three-tile tree would be unreachable from every tile
  /// that is not its anchor.
  ///
  /// PORT DELTA: the spec measures against a published INTERACTION rect, which
  /// a hover component and four other classes resolve per target type. It has
  /// no equivalent here; the area rect is the honest stand-in, and it is the
  /// rect that actually holds the ground.
  static bool isWithinRange(
    IActor source,
    DamageTarget target,
    double rangePixels,
  ) =>
      switch (target) {
        ObjectTarget(:final object) => isAreaWithinRange(
            source,
            locator<GridManager>().worldToGrid(object.position),
            rangePixels,
            width: object.data.gridWidth,
            height: object.data.gridHeight,
          ),
        GroundTarget(:final tile) =>
          isAreaWithinRange(source, tile, rangePixels),
      };

  /// The same reach, measured against a FOOTPRINT rather than a thing.
  ///
  /// Building needs it and destroying does not: what a blueprint reaches for
  /// has no host yet, so there is nothing to hand [isWithinRange] — only a
  /// corner and a size. Splitting it out is what keeps the two verbs on ONE
  /// geometry (FP4.3b's obligation): a smelter you may build is a smelter you
  /// could have broken from the same spot, and the day that stops being true
  /// is the day a player is refused a build they can see is in range.
  static bool isAreaWithinRange(
    IActor source,
    GridPos anchor,
    double rangePixels, {
    int width = 1,
    int height = 1,
  }) =>
      _gapBetween(
        ActorOccupancyHelper.bodyRectOf(source),
        ActorOccupancyHelper.areaRect(anchor, width: width, height: height),
      ) <=
      rangePixels;

  /// The shortest distance between two rects — zero when they overlap.
  static double _gapBetween(WorldRect a, WorldRect b) {
    final dx = math.max(0, math.max(a.left - b.right, b.left - a.right));
    final dy = math.max(0, math.max(a.top - b.bottom, b.top - a.bottom));
    return math.sqrt(dx * dx + dy * dy);
  }

  /// The soul behind a target, whichever shape it arrived in.
  static IWorldObjectData dataOf(DamageTarget target) => switch (target) {
        ObjectTarget(:final object) => object.data,
        GroundTarget(:final tile) => _groundDataAt(tile),
      };

  static GroundBuildableData _groundDataAt(GridPos tile) {
    final data = locator<GridManager>().getGroundDataAt(tile);
    assert(
      data != null,
      '[WorldObjectPermissionHelper] aimed at $tile, which holds no ground. '
      'A tile within reach is a tile the streaming has loaded — an empty one '
      'is a caller that resolved the aim against the void (rule 5)',
    );
    return data!;
  }
}
