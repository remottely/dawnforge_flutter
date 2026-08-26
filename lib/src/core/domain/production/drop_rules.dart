import 'dart:math' as math;

import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Pure domain rules for loot drops — the Dart port of `DropRules.cs`
/// (`shared/domain/production/`). No host/component/engine dependency; every
/// roll arrives as a parameter, which is what keeps this class pure and its
/// tests deterministic.
abstract final class DropRules {
  static bool shouldRoll(double roll, double chance) => roll <= chance;

  /// How many units a drop entry yields once [multiplier] has been applied,
  /// with the fractional part settled by [roll] rather than thrown away.
  ///
  /// It used to be a bare floor in the Godot repo, and that made the
  /// multiplier a trap: most drops in this game yield exactly 1, so `1 * 1.5`
  /// floored back to 1 and **every multiplier below 2.0 was a silent no-op**
  /// on the majority of the content. A "50% more loot" rule wired to it would
  /// have shipped, passed its tests, printed correctly in the settings menu
  /// and changed nothing in the game.
  ///
  /// So the remainder is paid probabilistically: 1.5 yields 1 or 2, half the
  /// time each, and averages the 1.5 that was promised.
  static int calculateAmount(int baseAmount, double multiplier, double roll) {
    final exact = baseAmount * multiplier;
    final whole = exact.floor();
    return whole + (roll < exact - whole ? 1 : 0);
  }

  static WorldPos calculateSpreadPosition(
    WorldPos sourceCenter,
    double angle,
    double distance,
  ) =>
      sourceCenter + WorldPos(math.cos(angle), math.sin(angle)) * distance;

  /// Front-center drop anchor for workstations, with a small randomized
  /// jitter — the workstation's face, not its anchor tile, is where produce
  /// lands.
  static WorldPos workstationDropPosition(
    WorldPos basePos,
    int gridWidth,
    int gridHeight,
    double tileDimension,
    double angle,
    double jitterDistance,
  ) {
    final centerX = basePos.x + (gridWidth - 1) * tileDimension / 2;
    final dropYAnchor = basePos.y + gridHeight * tileDimension;
    return calculateSpreadPosition(
      WorldPos(centerX, dropYAnchor),
      angle,
      jitterDistance,
    );
  }

  /// Grid-size-based offset for prop/ground drops: the bigger the footprint,
  /// the further from the anchor the pile lands.
  static WorldPos gridOffsetPosition(
    WorldPos basePos,
    int gridWidth,
    int gridHeight,
    double offsetMultiplier,
  ) =>
      basePos +
      WorldPos((gridWidth - 1).toDouble(), (gridHeight - 1).toDouble()) *
          offsetMultiplier;
}
