import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';

/// Host of every buildable terrain tile. Created only by
/// `GroundFactory.create()` (rule 1). Ground is materialized a chunk column at
/// a time, so its heavier components are built lazily on the core (FP3).
class GroundBuildable extends WorldObject {
  /// Typed view over the injected soul.
  GroundBuildableData get groundData => data as GroundBuildableData;
}
