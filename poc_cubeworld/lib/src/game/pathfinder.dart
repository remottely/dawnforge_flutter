import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/ivec3.dart';
import '../world/voxel_world.dart';

/// Stage 31: A* on the block grid for walking mobs (Godot's `pathfinder.gd`). A
/// node is a feet cell (air, air above, something to stand on below); the moves
/// are the 4 horizontal steps, a step up of one (with head room) and a drop of
/// up to [maxDrop] onto a landing. Lava is never entered, water costs 3x, soul
/// sand 2x; the heuristic is the Manhattan distance. At most `maxNodes`
/// expansions per call; when the goal is not reached the best partial path
/// toward it is returned (closest node by heuristic, ties on the lower cost).
class Pathfinder {
  static const int maxDrop = 3;
  static const int defaultMaxNodes = 600;
  static const List<IVec3> _four = [IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 0, 1), IVec3(0, 0, -1)];

  /// Cell centres (x + 0.5, y, z + 0.5) from the first step after [from] to the
  /// goal, or the partial path; empty when [from] has nowhere to go.
  static List<Vector3> find(VoxelWorld world, IVec3 from, IVec3 to,
      {int maxNodes = defaultMaxNodes, bool canJump = true}) {
    final gScore = <IVec3, double>{from: 0.0};
    final cameFrom = <IVec3, IVec3>{};
    final closed = <IVec3>{};
    final open = _Heap()..push(_h(from, to), 0.0, from);
    var best = from;
    var bestH = _h(from, to);
    var bestG = 0.0;
    var expanded = 0;
    while (open.isNotEmpty && expanded < maxNodes) {
      final cur = open.pop();
      if (!closed.add(cur)) continue;
      expanded += 1;
      if (cur == to) {
        best = cur;
        break;
      }
      final curG = gScore[cur]!;
      final curH = _h(cur, to);
      if (curH < bestH || (curH == bestH && curG < bestG)) {
        best = cur;
        bestH = curH;
        bestG = curG;
      }
      for (final d in _four) {
        final step = _stepTo(world, cur, cur + d, canJump);
        if (step == null) continue;
        final ng = curG + _cost(world, step) + (step.y - cur.y).abs() * 0.5;
        if (ng >= (gScore[step] ?? double.infinity)) continue;
        gScore[step] = ng;
        cameFrom[step] = cur;
        open.push(ng + _h(step, to), ng, step);
      }
    }
    final cells = <IVec3>[];
    var walk = best;
    while (cameFrom.containsKey(walk)) {
      cells.add(walk);
      walk = cameFrom[walk]!;
    }
    return [for (final c in cells.reversed) Vector3(c.x + 0.5, c.y.toDouble(), c.z + 0.5)];
  }

  /// Where a walker standing in [cur] ends up when it moves toward the column of
  /// [n]: [n] itself, one up, a landing below, or null when nothing there can be
  /// stood on.
  static IVec3? _stepTo(VoxelWorld world, IVec3 cur, IVec3 n, bool canJump) {
    if (walkable(world, n)) return n;
    if (canJump && !world.isSolid(cur + const IVec3(0, 2, 0)) && walkable(world, n + IVec3.up)) return n + IVec3.up;
    if (world.isSolid(n) || world.isSolid(n + IVec3.up) || _lava(world, n)) return null;
    for (var k = 1; k <= maxDrop; k++) {
      final m = n - IVec3(0, k, 0);
      if (walkable(world, m)) return m;
      if (world.isSolid(m) || _lava(world, m)) return null;
    }
    return null;
  }

  static bool walkable(VoxelWorld world, IVec3 c) {
    if (world.isSolid(c) || world.isSolid(c + IVec3.up)) return false;
    if (_lava(world, c) || _lava(world, c + IVec3.up)) return false;
    return world.isSolid(c + IVec3.down) || world.isLiquid(c);
  }

  static bool _lava(VoxelWorld world, IVec3 c) => Blocks.liquidKind(world.getBlock(c)) == 'lava';

  /// 1 per cell; 3 through water; 2 over soul sand (`speedMult` 0.5), read from
  /// the block under the feet.
  static double _cost(VoxelWorld world, IVec3 c) {
    if (world.isLiquid(c)) return 3.0;
    return 1.0 / Blocks.speedMult(world.getBlock(c + IVec3.down));
  }

  static double _h(IVec3 a, IVec3 b) => ((a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs()).toDouble();
}

/// A binary min-heap on f, then g (so equal f prefers the deeper node).
class _Heap {
  final List<double> _f = [];
  final List<double> _g = [];
  final List<IVec3> _cells = [];

  bool get isNotEmpty => _cells.isNotEmpty;

  bool _less(int i, int j) => _f[i] < _f[j] || (_f[i] == _f[j] && _g[i] > _g[j]);

  void _swap(int i, int j) {
    final f = _f[i];
    _f[i] = _f[j];
    _f[j] = f;
    final g = _g[i];
    _g[i] = _g[j];
    _g[j] = g;
    final c = _cells[i];
    _cells[i] = _cells[j];
    _cells[j] = c;
  }

  void push(double f, double g, IVec3 cell) {
    _f.add(f);
    _g.add(g);
    _cells.add(cell);
    var i = _cells.length - 1;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (!_less(i, parent)) break;
      _swap(i, parent);
      i = parent;
    }
  }

  IVec3 pop() {
    final top = _cells[0];
    final last = _cells.length - 1;
    _swap(0, last);
    _f.removeLast();
    _g.removeLast();
    _cells.removeLast();
    var i = 0;
    while (true) {
      final l = i * 2 + 1;
      final r = l + 1;
      var m = i;
      if (l < last && _less(l, m)) m = l;
      if (r < last && _less(r, m)) m = r;
      if (m == i) break;
      _swap(i, m);
      i = m;
    }
    return top;
  }
}
