import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// The one handedness conversion of the port, at the render boundary.
///
/// The game keeps Godot's right-handed world everywhere (+X east, -Z north,
/// yaw 0 looks down -Z with +X on screen-right). flutter_scene's view is
/// left-handed: `PerspectiveCamera` builds `right = up x forward` and projects
/// +forward into the screen, so a right-handed world fed to it unchanged lands
/// mirrored left-right (world +X on screen-LEFT at yaw 0). Until this camera the
/// port compensated piecemeal (a mirrored right vector, a flipped mouse sign,
/// quads wound the other way); now the camera mirrors clip-space x once and the
/// rest of the game uses Godot's conventions unchanged.
///
/// Consequences, all handled where they arise:
/// - Screen winding reverses, so hand-built meshes wind like Godot (clockwise
///   seen from the face's normal side) and the engine's own primitives
///   (`CuboidGeometry`, `SphereGeometry`, wound for its native handedness) go
///   through [GodotCamera.primitive], a mirrored child the engine re-winds.
/// - The shadow pass is not mirrored, so the shadow caster faces setting is the
///   opposite enum of what it would be for engine-wound geometry.
/// - The engine-derived `cameraRight` (SSAO, SSR, GI, contact shadows,
///   refraction) would disagree with the view; the game enables none of them.
/// - `Camera.worldToScreen` / `getFrustum` read [getViewTransform], so HUD
///   projection and frustum culling follow the mirror for free.
class GodotCamera extends PerspectiveCamera {
  GodotCamera({
    required Vector3 super.position,
    required Vector3 super.target,
    required Vector3 super.up,
    super.fovRadiansY,
    super.fovNear,
    super.fovFar,
  });

  @override
  CameraProjection get projection => _MirroredPerspectiveProjection(fovRadiansY: fovRadiansY, near: fovNear, far: fovFar);

  /// An engine primitive (symmetric about its local x = 0) as a child node
  /// mirrored in x: the geometry is unchanged, the engine flips its cull winding
  /// for the mirrored transform, and the faces stay outside-in under this
  /// camera. Transform the returned node's parent, never this node's scale.
  static Node primitive(Mesh mesh, {bool castsShadows = true}) => Node(mesh: mesh)
    ..scale = Vector3(-1, 1, 1)
    ..castsShadows = castsShadows;

  /// A node holding [mesh] through [primitive], for callers that move, scale
  /// or rotate the returned node.
  static Node primitiveNode(Mesh mesh, {bool castsShadows = true}) =>
      Node()..add(primitive(mesh, castsShadows: castsShadows))..castsShadows = castsShadows;
}

/// A perspective lens with clip-space x negated (a subclass, because the shadow
/// cascades cast `camera.projection` to [PerspectiveProjection]).
class _MirroredPerspectiveProjection extends PerspectiveProjection {
  _MirroredPerspectiveProjection({required super.fovRadiansY, required super.near, required super.far});

  @override
  Matrix4 getProjectionMatrix(double aspectRatio, {Vector2? jitter}) {
    final m = super.getProjectionMatrix(aspectRatio, jitter: jitter);
    m.setRow(0, -m.getRow(0));
    return m;
  }
}
