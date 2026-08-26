import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';

/// The database of every authored item (rule 2).
final class ItemRegistry extends RegistryBase<ItemData> {
  ItemData getItem(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = ItemData.fromJson(json);
    register(data.id, data);
  }
}
