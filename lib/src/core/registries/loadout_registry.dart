import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/progression/i_starting_loadout_data.dart';

/// The database of every authored starting loadout (rule 2). One document
/// today; a second `.md` beside it is a second loadout.
final class LoadoutRegistry extends RegistryBase<IStartingLoadoutData> {
  IStartingLoadoutData getLoadout(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = IStartingLoadoutData.fromJson(json);
    register(data.id, data);
  }
}
