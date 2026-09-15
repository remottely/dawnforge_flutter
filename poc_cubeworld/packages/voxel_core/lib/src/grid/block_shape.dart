/// How a block is drawn and what it collides with. The declaration order is a
/// contract: the mesher reads a shape as its `index` from a byte table.
enum BlockShape {
  cube,
  cross,
  liquid,
  torch,
  flower,
  panelZ,
  panelX,
  wallTorch,
  slab,
  fence,
  stairsN,
  stairsE,
  stairsS,
  stairsW,
  wire,
  // One shape per rail orientation (the mesher draws bars over ties).
  railNs,
  railEw,
  railNe,
  railNw,
  railSe,
  railSw,
  railSlopeN,
  railSlopeE,
  railSlopeS,
  railSlopeW,
}

/// An axis-aligned box as min / max corners (Godot's AABB is position + size;
/// min / max reads the same faces without a subtraction per test).
class CollisionBox {
  const CollisionBox(this.x0, this.y0, this.z0, this.x1, this.y1, this.z1);

  /// The whole cell.
  static const CollisionBox full = CollisionBox(0, 0, 0, 1, 1, 1);

  /// A fence post, 1.5 tall so it cannot be jumped; rails stop no body.
  static const CollisionBox fencePost = CollisionBox(0.375, 0, 0.375, 0.625, 1.5, 0.625);

  final double x0, y0, z0, x1, y1, z1;

  double min(int axis) => axis == 0 ? x0 : (axis == 1 ? y0 : z0);
  double max(int axis) => axis == 0 ? x1 : (axis == 1 ? y1 : z1);

  CollisionBox shifted(int dx, int dy, int dz) =>
      CollisionBox(x0 + dx, y0 + dy, z0 + dz, x1 + dx, y1 + dy, z1 + dz);

  @override
  String toString() => 'Box($x0, $y0, $z0 .. $x1, $y1, $z1)';
}

/// The boxes a body collides with, in the block's own 0..1 space. Empty for a
/// block that stops no body. Stairs: the bottom slab plus the high step at the
/// back, the same halves the mesher draws (N = high step at z 0..0.5, E = at
/// x 0.5..1). The lists are constants: never mutate one.
List<CollisionBox> collisionBoxesOf(BlockShape shape, {required bool solid}) {
  if (!solid) return const [];
  const half = CollisionBox(0, 0, 0, 1, 0.5, 1);
  return switch (shape) {
    BlockShape.slab => const [half],
    BlockShape.fence => const [CollisionBox.fencePost],
    BlockShape.stairsN => const [half, CollisionBox(0, 0.5, 0, 1, 1, 0.5)],
    BlockShape.stairsS => const [half, CollisionBox(0, 0.5, 0.5, 1, 1, 1)],
    BlockShape.stairsE => const [half, CollisionBox(0.5, 0.5, 0, 1, 1, 1)],
    BlockShape.stairsW => const [half, CollisionBox(0, 0.5, 0, 0.5, 1, 1)],
    _ => const [CollisionBox.full],
  };
}
