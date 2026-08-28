import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/item_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.1c: the pickup's collection handshake — reserve, fly, collect; a full
/// bag refuses and the pickup stays grounded. Since FP4.2b the handshake opens
/// with the authored `pickup_delay`, without which nothing can ever be put
/// down: a drop lands at the dropper's feet and would fly straight back.
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

  /// Ticks [pickup] against [actor] for [steps] fixed steps, stopping early
  /// once it is collected.
  void run(ItemWorld pickup, IActor actor, int steps) {
    for (var i = 0; i < steps && !pickup.collected; i++) {
      pickup.tick(
        step,
        collectorPosition: actor.position,
        collectorInventory: actor.inventory,
      );
    }
  }

  /// Fixed steps that cover the probe item's authored `pickup_delay`, plus
  /// room for the reserve step and the flight.
  ///
  /// Derived from the data, never hand-counted: the delay is content, and a
  /// test that spells `15` goes quietly wrong the day someone authors 1.0.
  /// The margin is not decoration either — accumulating 1/30 fifteen times
  /// lands on 0.4999…, so the delay eats a sixteenth step that exact division
  /// does not predict.
  int stepsPastDelay() =>
      (locator<ItemRegistry>().getItem('t1_item_probe').pickupDelay / step)
          .ceil() +
      4;

  test('near pickup reserves, flies the magnet, and lands in the bag', () {
    final actor = collector();
    final pickup =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(10, 0), 3);

    // The authored pickup_delay runs down first — nothing may reserve it
    // before then. 12.5 tiles/s * 16 px = 200 px/s, so 10px is one step's
    // flight and it is collected within a tick or two after that.
    run(pickup, actor, stepsPastDelay());

    expect(pickup.collected, isTrue);
    expect(actor.inventory.countOf('t1_item_probe'), 3);
  });

  test("a pickup at the collector's feet waits out its authored delay", () {
    final actor = collector();
    // Exactly where a dropped item lands: on top of the dropper, deep inside
    // the magnet radius and inside the collect threshold too. Without the
    // delay this is collected on the first step and putting anything down is
    // impossible.
    final pickup =
        ItemFactory.createPickup('t1_item_probe', WorldPos.zero, 3);
    final delay =
        locator<ItemRegistry>().getItem('t1_item_probe').pickupDelay;
    expect(delay, greaterThan(0), reason: 'the probe must author a real delay');

    // One step short of the delay: still on the ground, still nobody's.
    final held = (delay / step).floor();
    run(pickup, actor, held);
    expect(pickup.collected, isFalse);
    expect(actor.inventory.countOf('t1_item_probe'), 0);

    // And it is a delay, not a refusal — it collects once the wait is over.
    run(pickup, actor, stepsPastDelay());
    expect(pickup.collected, isTrue);
    expect(actor.inventory.countOf('t1_item_probe'), 3);
  });

  test('a far pickup never starts the flight', () {
    final actor = collector();
    final pickup =
        ItemFactory.createPickup('t1_item_probe', const WorldPos(100, 0), 3);

    run(pickup, actor, stepsPastDelay() + 10);

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

    for (var i = 0; i < stepsPastDelay() + 10; i++) {
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
