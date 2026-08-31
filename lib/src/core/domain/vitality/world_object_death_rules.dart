import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// Pure domain rules for whether a tool may end a world object — the Dart port
/// of `WorldObjectDeathRules.cs`.
///
/// Two questions, and every destructive path in the game asks both: is this
/// the RIGHT KIND of tool, and is it GOOD ENOUGH. They are separate because
/// they fail for different reasons and the player is told different things —
/// "you need an axe" is not "you need a better axe".
abstract final class WorldObjectDeathRules {
  /// Whether [toolType] is one the target accepts.
  ///
  /// An EMPTY [allowed] refuses everything. That is an authored refusal, not a
  /// missing value: a crate with no allowed tools is a crate nothing breaks,
  /// and answering "anything goes" for an empty list would mean omitting the
  /// field quietly opened every object in the pack.
  ///
  /// A null [toolType] — the item in hand is not a tool at all — matches
  /// nothing, for the same reason.
  static bool hasAllowedTool(ToolType? toolType, List<ToolType> allowed) {
    if (toolType == null) return false;
    return allowed.contains(toolType);
  }

  /// Whether a tool of [toolTier] is good enough for a target of
  /// [targetTier]. One direction only: a better tool always works on a lesser
  /// thing, never the reverse.
  static bool meetsTierRequirement(int toolTier, int targetTier) =>
      toolTier >= targetTier;
}
