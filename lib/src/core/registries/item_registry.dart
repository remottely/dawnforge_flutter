import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';

/// The database of every authored item (rule 2).
final class ItemRegistry extends RegistryBase<ItemData> {
  ItemData getItem(String id) => get(id);

  /// Routes the pack's concrete item type to its data class.
  ///
  /// The `_` arm is NOT `GroundRegistry`'s throw, and the difference is the
  /// state of the port rather than a difference of principle. Both ground
  /// families the pack authors have a class here, so an unknown one there is a
  /// type nobody wrote code for. Items are the opposite: the pack authors six
  /// families (`item_tool_melee_data`, `item_consumable_data`,
  /// `item_projectile_data`, `item_craftable_data`, `item_buildable_data`, and
  /// documents that name `item_data` itself), and exactly one of them has a
  /// class of its own so far. Listing the other five as arms that all build an
  /// [ItemData] would be a table that says nothing; `_` says the same thing
  /// once — *this family reads as a plain item, because its class is not
  /// ported yet* — which is what every item in the game has done since FP1.
  ///
  /// It is not a fallback over missing data either (rule 5): the base class IS
  /// the honest answer for a family whose extra fields nothing reads. FP4.5's
  /// `ItemCraftableData` takes the next arm, and the arm after that is what
  /// finally makes the `_` worth turning into a throw.
  void registerJson(Map<String, Object?> json) {
    final data = switch (json['type']) {
      'item_buildable_data' => ItemBuildableData.fromJson(json),
      _ => ItemData.fromJson(json),
    };
    register(data.id, data);
  }
}
