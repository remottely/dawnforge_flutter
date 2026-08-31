import 'dart:math';

import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/domain/production/drop_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// Rolls the host's loot table and spawns pickups — port of
/// `drop_component.gd` (logic slice: crop stage tables arrive with
/// `CropDropComponent` in FP4.4; the difficulty multiplier stays a caller
/// parameter until a DifficultySystem exists; tier resolution is the
/// caller's, there being one biome and no islands yet).
///
/// The RNG arrives by constructor — the sim owns randomness, tests inject a
/// seed. Which entries roll is one rule and stays here; a subclass only ever
/// decides WHICH table ([activeDropEntries]), the lesson the spec's
/// CropDropComponent drift bought.
class DropComponent extends IComponent {
  DropComponent(this._random);

  final Random _random;

  /// What was actually dropped, after every roll: `(item, amount)` pairs.
  final itemsDropped = EventSignal<List<(ItemData, int)>>();

  /// The table this drop rolls. Overridden by hosts whose loot depends on
  /// runtime state — a crop's table is chosen by its growth stage.
  List<DropEntry> get activeDropEntries => data.drops;

  /// Rolls the table and scatters the results around [sourceCenter] (the
  /// anchor `WorldDropHelper.calculateDropPosition` computed for the host).
  /// An empty table is a legitimate authored answer: the object yields
  /// nothing, and nothing is emitted.
  void dropItems(
    WorldPos sourceCenter, {
    double multiplier = 1.0,
  }) {
    final entries = activeDropEntries;
    if (entries.isEmpty) return;

    final rolled = <(ItemData, int)>[];
    for (final entry in entries) {
      if (!DropRules.shouldRoll(_random.nextDouble(), entry.chance)) continue;
      final base = entry.minAmount +
          _random.nextInt(entry.maxAmount - entry.minAmount + 1);
      final amount =
          DropRules.calculateAmount(base, multiplier, _random.nextDouble());
      if (amount > 0) {
        rolled.add((locator<ItemRegistry>().getItem(entry.itemId), amount));
      }
    }
    if (rolled.isEmpty) return;

    for (final (item, amount) in rolled) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = _rangeRoll(
        EngineConstants.dropDistanceMin * GameConstants.tileDimension,
        EngineConstants.dropDistanceMax * GameConstants.tileDimension,
      );
      // The landing — not the spawn point — is what has to be a tile an
      // item can sit on; resolveLandingPosition judges it against the
      // source's own elevation.
      final target = WorldDropHelper.resolveLandingPosition(
        DropRules.calculateSpreadPosition(sourceCenter, angle, distance),
        sourceCenter,
      );
      WorldDropHelper.spawnPickup(item, amount, target, sourceCenter);
    }
    itemsDropped.emit(rolled);
  }

  double _rangeRoll(double min, double max) =>
      min + _random.nextDouble() * (max - min);
}
