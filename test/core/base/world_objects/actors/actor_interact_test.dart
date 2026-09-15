import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_workstation.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(e): THE REACH. The third verb — after the swing and the build — and
/// the first one whose range is the TARGET's rather than the hand's.
///
/// What it must prove is what the slice claims: only a prop whose data says
/// it answers a reach answers one, the reach is the authored one measured
/// edge to edge, and every refusal comes back as a `false` a caller can read
/// rather than as silence (rule 20).
void main() {
  setUp(() {
    registerCoreSystems();

    // Bare hands: every actor is built with a hand, and it resolves through
    // the item registry the moment the component attaches.
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_tool_melee_hand',
      'tool_type': 'INNATE',
      'tier': 1,
      'attack_damage': 1,
    });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
      'base_max_health': 10,
    });

    locator<PropRegistry>()
      // A bench you may use from two tiles away, as the pack authors it.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_bench',
        'type': 'prop_workstation_data',
        'workstation_type': 'SMELTER',
        'tier': 1,
        'base_max_health': 10,
        'interaction_range': 2.0,
        'interaction_prompt': 'Interact [E]',
      })
      // The same bench with its reach authored down to nothing: it still
      // answers, but only from the tile beside it.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_bench_close',
        'type': 'prop_workstation_data',
        'workstation_type': 'SMELTER',
        'tier': 1,
        'base_max_health': 10,
        'interaction_range': 0.0,
      })
      // A rock: no interaction fields, no component, no answer.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_rock',
        'tier': 1,
        'base_max_health': 10,
      });

    final grid = locator<GridManager>();
    for (var x = -4; x <= 12; x++) {
      for (var y = -4; y <= 12; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  IActor playerAt(GridPos tile) =>
      ActorFactory.create('t1_actor_probe_player', grid().gridToWorld(tile));

  Prop propAt(String id, GridPos at) {
    final prop = PropFactory.create(
      id,
      grid().gridToWorld(at),
      random: Random(20260910),
    );
    grid().occupyPropTiles(at, prop);
    return prop;
  }

  AimSnapshot aimFrom(IActor actor, GridPos at) => AimSnapshot.fromPoint(
        actor.position,
        grid().gridToWorld(at),
        actor.direction.lookDirection,
      );

  test('a bench in reach answers, and says who reached it', () {
    final actor = playerAt(const GridPos(4, 5));
    final bench = propAt('t1_prop_probe_bench', const GridPos(5, 5))
        as PropWorkstation;
    IActor? heard;
    bench.interactable.interacted.connect((who) => heard = who);

    expect(actor.tryInteract(aimFrom(actor, const GridPos(5, 5))), isTrue);
    expect(heard, same(actor), reason: 'the signal carries the interactor');
  });

  test('a reach on a bench is announced on the bus, with both parties', () {
    // The station knows it was touched and only the shell can put a widget on
    // screen, so the two halves meet here (FP4.5f). A `Prop` that imported a
    // screen would be a simulation that cannot run without one.
    final actor = playerAt(const GridPos(4, 5));
    final bench = propAt('t1_prop_probe_bench', const GridPos(5, 5))
        as PropWorkstation;
    final announced = <(Object, Object)>[];
    locator<Events>().workstationInteracted.connect(announced.add);

    expect(actor.tryInteract(aimFrom(actor, const GridPos(5, 5))), isTrue);

    expect(announced, hasLength(1));
    expect(announced.single.$1, same(bench));
    expect(announced.single.$2, same(actor));
  });

  test('open ground answers nothing, and it is not an error', () {
    final actor = playerAt(const GridPos(4, 5));
    expect(actor.tryInteract(aimFrom(actor, const GridPos(5, 5))), isFalse);
  });

  test('a rock is not interactable — it authors no reach, so it has none', () {
    final actor = playerAt(const GridPos(4, 5));
    final rock = propAt('t1_prop_probe_rock', const GridPos(5, 5));

    expect(actor.tryInteract(aimFrom(actor, const GridPos(5, 5))), isFalse);
    expect(
      rock.hasComponent('InteractableComponent'),
      isFalse,
      reason: 'a component goes where its data says (L-005), not on every prop',
    );
  });

  test('the reach is the AUTHORED one: two tiles reaches, zero does not', () {
    final far = playerAt(const GridPos(3, 5));
    propAt('t1_prop_probe_bench', const GridPos(5, 5));
    expect(
      far.tryInteract(aimFrom(far, const GridPos(5, 5))),
      isTrue,
      reason: 'two tiles of authored range, measured edge to edge',
    );

    final other = playerAt(const GridPos(8, 5));
    propAt('t1_prop_probe_bench_close', const GridPos(11, 5));
    expect(
      other.tryInteract(aimFrom(other, const GridPos(11, 5))),
      isFalse,
      reason: 'a bench authored with no reach is refused from three tiles out',
    );
  });

  test('too far is a refusal, not a silence', () {
    final actor = playerAt(const GridPos(0, 5));
    final bench = propAt('t1_prop_probe_bench', const GridPos(8, 5))
        as PropWorkstation;
    var heard = 0;
    bench.interactable.interacted.connect((_) => heard++);

    expect(actor.tryInteract(aimFrom(actor, const GridPos(8, 5))), isFalse);
    expect(heard, 0, reason: 'a refused reach never reaches the object');
  });

  test('a dead actor reaches for nothing', () {
    final actor = playerAt(const GridPos(4, 5));
    propAt('t1_prop_probe_bench', const GridPos(5, 5));
    actor.health.takeDamage(999, source: actor);

    expect(actor.health.isAlive, isFalse);
    expect(actor.tryInteract(aimFrom(actor, const GridPos(5, 5))), isFalse);
  });

  test('the authored prompt crosses from the pack to the component', () {
    final bench = propAt('t1_prop_probe_bench', const GridPos(5, 5))
        as PropWorkstation;
    expect(bench.interactable.prompt, 'Interact [E]');
    expect(
      bench.interactable.rangePixels,
      2.0 * 16,
      reason: 'tiles in the pack, pixels at the gate, converted exactly once',
    );
  });
}
