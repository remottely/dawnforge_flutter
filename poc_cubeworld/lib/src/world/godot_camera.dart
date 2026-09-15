import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';
import 'package:voxel_scene/voxel_scene.dart';

/// The one handedness conversion of the port, at the render boundary.
///
/// The game keeps Godot's right-handed world everywhere (+X east, -Z north,
/// yaw 0 looks down -Z with +X on screen-right). flutter_scene's view is
/// left-handed, so a right-handed world fed to it unchanged lands mirrored
/// left-right. Until this camera the port compensated piecemeal (a mirrored
/// right vector, a flipped mouse sign, quads wound the other way); now
/// voxel_scene's [MirroredCamera] mirrors clip-space x once and the rest of the
/// game uses Godot's conventions unchanged.
///
/// Consequences, all handled where they arise:
/// - Hand-built meshes wind like Godot (clockwise seen from the face's normal
///   side) and the engine's own primitives go through
///   [MirroredCamera.primitive] / [MirroredCamera.primitiveNode].
/// - The shadow pass is not mirrored, so the shadow caster faces setting is the
///   opposite enum of what it would be for engine-wound geometry.
/// - The engine-derived `cameraRight` (SSAO, SSR, GI, contact shadows,
///   refraction) would disagree with the view; the game enables none of them.
class GodotCamera extends MirroredCamera {
  GodotCamera({
    required super.position,
    required super.target,
    required Vector3 super.up,
    super.fovRadiansY,
    super.fovNear,
    super.fovFar,
  });

  /// [MirroredCamera.primitive], under the name the game's callers use.
  static Node primitive(Mesh mesh, {bool castsShadows = true}) => MirroredCamera.primitive(mesh, castsShadows: castsShadows);

  /// [MirroredCamera.primitiveNode], under the name the game's callers use.
  static Node primitiveNode(Mesh mesh, {bool castsShadows = true}) =>
      MirroredCamera.primitiveNode(mesh, castsShadows: castsShadows);
}
