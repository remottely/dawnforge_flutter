import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/item_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.1c: the pickup's collection handshake — reserve, fly, collect; a full
/// bag refuses and the pickup stays grounded.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_probe',
      'max_stack': 10,
      'magnet_speed': 12.5,
    });
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_collector',
      'inventory_size': 1,
    });
  });
  tearDown(resetCoreSystems);

  IActor collector() => ActorFactory.create('t1_actor_collector', WorldPos.zero);

  const step = 1.0 / 30;

  test('near pickup reserves, flies the magnet, and lands in the bag', () {
    final actor = collector();
    final pickup =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(10, 0), 3);

    // 12.5 tiles/s * 16 px = 200 px/s: 10px is one step's flight, collected
    // within a couple of ticks.
    for (var i = 0; i < 5 && !pickup.collected; i++) {
      pickup.tick(
        step,
        collectorPosition: actor.position,
        collectorInventory: actor.inventory,
      );
    }

    expect(pickup.collected, isTrue);
    expect(actor.inventory.countOf('t1_item_probe'), 3);
  });

  test('a far pickup never starts the flight', () {
    final actor = collector();
    final pickup =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(100, 0), 3);

    for (var i = 0; i < 10; i++) {
      pickup.tick(
        step,
        collectorPosition: actor.position,
        collectorInventory: actor.inventory,
      );
    }

    expect(pickup.collected, isFalse);
    expect(pickup.position, const WorldPos(100, 0));
    expect(actor.inventory.countOf('t1_item_probe'), 0);
  });

  test('the reservation is honored between two competing pickups', () {
    final actor = collector(); // 1 slot × max_stack 10
    final first =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(8, 0), 6);
    final second =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(-8, 0), 6);

    for (var i = 0; i < 10; i++) {
      first.tick(
        step,
        collectorPosition: actor.position,
        collectorInventory: actor.inventory,
      );
      second.tick(
        step,
        collectorPosition: actor.position,
        collectorInventory: actor.inventory,
      );
    }

    // The first promise took 6 of the 10; the second 6 never fit — that
    // pickup stays on the ground, uncollected and intact.
    expect(first.collected, isTrue);
    expect(second.collected, isFalse);
    expect(actor.inventory.countOf('t1_item_probe'), 6);
  });
}
