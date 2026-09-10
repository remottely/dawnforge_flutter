import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';

/// The database of every authored prop (rule 2).
final class PropRegistry extends RegistryBase<PropData> {
  PropData getProp(String id) => get(id);

  /// Routes the pack's concrete prop type to its data class.
  ///
  /// The `_` arm is the same shape `ItemRegistry`'s is, and for the same
  /// reason: the pack authors more prop families than have classes here
  /// (`prop_storage_data`, `prop_sleepable_data` and the rest), and every one of them reads as a plain [PropData] until the system
  /// that needs its extra fields is ported. That is the honest answer for a
  /// family whose extras nothing reads, not a fallback over missing data
  /// (rule 5).
  ///
  /// Until 0.47.0 there was no switch at all, so the smelter — authored
  /// `prop_workstation_data` since it was imported — came back as a plain prop
  /// with its `workstation_type` dropped on the floor. Nothing noticed,
  /// because nothing had asked yet.
  void registerJson(Map<String, Object?> json) {
    final data = switch (json['type']) {
      'prop_crop_data' => PropCropData.fromJson(json),
      'prop_workstation_data' => PropWorkstationData.fromJson(json),
      _ => PropData.fromJson(json),
    };
    register(data.id, data);
  }
}
