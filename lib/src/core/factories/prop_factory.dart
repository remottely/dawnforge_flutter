import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// The ONLY construction site of props (rule 1).
abstract final class PropFactory {
  static Prop create(String id, WorldPos position) {
    final data = locator<PropRegistry>().getProp(id);
    final prop = Prop()
      ..initialize(data.clone())
      ..position = position;
    return prop;
  }
}
