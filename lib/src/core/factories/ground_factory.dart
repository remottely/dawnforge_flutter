import 'package:dawnforge/src/core/base/world_objects/grounds/ground_buildable.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// The ONLY construction site of ground tiles (rule 1). Ground is addressed by
/// its tile, so creation takes a [GridPos]; the world position is derived by
/// [GridManager] — never raw arithmetic (Godot repo §6).
abstract final class GroundFactory {
  static GroundBuildable create(String id, GridPos gridPos) {
    final data = locator<GroundRegistry>().getGround(id);
    final ground = GroundBuildable()
      ..initialize(data.clone())
      ..position = locator<GridManager>().gridToWorldCorner(gridPos);
    return ground;
  }
}
