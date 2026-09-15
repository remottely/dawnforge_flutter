import 'package:flutter_scene/scene.dart';
import 'package:voxel_core/voxel_core.dart';

import '../core/blocks.dart';
import '../world/voxel_world.dart';

/// The POC's body: voxel_core's [VoxelBody] (VP1.8) plus what only this game
/// needs — the scene node that carries its visuals, the world it lives in
/// typed as the POC's facade, and lava named as a liquid kind.
class SceneBody extends VoxelBody {
  final Node node = Node();
  late VoxelWorld world;

  @override
  void setup(covariant VoxelWorld q, double hw, double h) {
    world = q;
    super.setup(q, hw, h);
  }

  /// Pushes the position into the scene node. Call after moving.
  void syncNode() => node.position = position.clone();

  static final int _lava = Blocks.liquidKinds.indexOf('lava');

  /// Lava at the feet or the head.
  bool get inLava => feetLiquid == _lava || headLiquid == _lava;
}
