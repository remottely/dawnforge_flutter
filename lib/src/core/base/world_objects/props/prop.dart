import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';

/// Host of every prop. Created only by `PropFactory.create()` (rule 1).
class Prop extends WorldObject {
  /// Typed view over the injected soul.
  PropData get propData => data as PropData;
}
