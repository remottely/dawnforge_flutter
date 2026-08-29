import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// Reading the tool behind an action — the port of `world_object_tool_helper.gd`.
///
/// Every damage, farm, build and drop decision starts with the same two
/// questions: what tool is this actor swinging, and how good is it. They are
/// asked here so that no path invents its own way of looking into a hand.
///
/// PORT DELTA — the source is an [IActor], full stop. The spec accepts one
/// other thing, an `ItemHandProjectile` that carries the tool type and tier it
/// was FIRED with, because an arrow may outlive the archer. Projectiles are
/// unported; when they arrive they widen this signature, and the reason the
/// spec gives for the carried copy comes with them.
abstract final class WorldObjectToolHelper {
  /// Which tool [source] is acting with, or null when it holds none.
  ///
  /// Null is the spec's `-1` said in Dart. It refuses everything downstream
  /// (`WorldObjectDeathRules.hasAllowedTool`), which is the point: a plank is
  /// not a tool and a creature with no weapon breaks nothing. A PLAYER never
  /// answers null — an empty hotbar slot is bare hands, an `INNATE` tool.
  static ToolType? toolTypeOf(IActor source) =>
      source.heldItem.currentItem?.toolType;

  /// How good that tool is. Zero for an empty hand — the spec's own answer,
  /// and one that fails every tier requirement, since content starts at 1.
  static int tierOf(IActor source) => source.heldItem.currentItem?.tier ?? 0;
}
