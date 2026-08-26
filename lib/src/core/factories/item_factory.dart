import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// The ONLY construction site of item pickups (rule 1). Also the future
/// replication hook: a spawn fact arriving off the wire lands here directly,
/// never through `WorldDropHelper` (the spec's MP3.2 seam, kept warm).
abstract final class ItemFactory {
  static ItemWorld createPickup(String id, WorldPos position, int amount) {
    final data = locator<ItemRegistry>().getItem(id);
    return ItemWorld()
      ..initialize(data.clone(), amount)
      ..position = position;
  }
}
