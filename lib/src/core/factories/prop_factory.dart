import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_crop.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_workstation.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// The ONLY construction site of props (rule 1).
abstract final class PropFactory {
  /// Builds the prop [id] at [position].
  ///
  /// [random] is the roll stream this prop's loot and scatter come out of;
  /// omitted, it opens one of its own. This is a dependency seam, not a data
  /// default (rule 6): randomness is not authored content, and handing it in
  /// is what lets a test say "this seed yields this outcome" — and what will
  /// let two machines roll one prop's death identically when there are two.
  static Prop create(String id, WorldPos position, {Random? random}) {
    final data = locator<PropRegistry>().getProp(id);
    final prop = _hostFor(data, random ?? Random())
      ..initialize(data.clone())
      ..position = position;
    return prop;
  }

  /// Which host shell a soul gets — the one place the data class decides the
  /// host class, which is what a factory is FOR (rule 1). The `_` arm is the
  /// plain prop, the honest host for every family whose extras have no
  /// component here yet (`PropRegistry.registerJson` says the same of the
  /// data side).
  static Prop _hostFor(PropData data, Random random) => switch (data) {
        PropCropData() => PropCrop(random),
        PropWorkstationData() => PropWorkstation(random),
        _ => Prop(random),
      };
}
