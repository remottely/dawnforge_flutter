import '../core/blocks.dart';
import 'package:voxel_core/voxel_core.dart';
import '../world/voxel_world.dart';

/// Stage 28: the rail graph (Godot `src/game/rails.gd`). A rail block id names
/// the two ends it joins ([connections]): a straight joins two opposite sides,
/// a curve two adjacent ones, a slope its low side on the same level and its
/// high side one cell up. [orient] picks the id a rail at a cell should be from
/// what lies around it, [place] / [removed] keep the neighbours agreeing, and
/// [nextCell] walks the graph the way a minecart does.
class Rails {
  Rails._();

  static const IVec3 n = IVec3(0, 0, -1);
  static const IVec3 s = IVec3(0, 0, 1);
  static const IVec3 e = IVec3(1, 0, 0);
  static const IVec3 w = IVec3(-1, 0, 0);
  static const List<IVec3> four = [n, e, s, w];

  /// Orientation suffix -> the two ends. A slope's high end carries dy = +1.
  static const Map<String, List<IVec3>> ends = {
    'ns': [IVec3(0, 0, -1), IVec3(0, 0, 1)],
    'ew': [IVec3(1, 0, 0), IVec3(-1, 0, 0)],
    'ne': [IVec3(0, 0, -1), IVec3(1, 0, 0)],
    'nw': [IVec3(0, 0, -1), IVec3(-1, 0, 0)],
    'se': [IVec3(0, 0, 1), IVec3(1, 0, 0)],
    'sw': [IVec3(0, 0, 1), IVec3(-1, 0, 0)],
    'slope_n': [IVec3(0, 0, 1), IVec3(0, 1, -1)],
    'slope_e': [IVec3(-1, 0, 0), IVec3(1, 1, 0)],
    'slope_s': [IVec3(0, 0, -1), IVec3(0, 1, 1)],
    'slope_w': [IVec3(1, 0, 0), IVec3(-1, 1, 0)],
  };

  /// "ns", "ew", "ne", ..., "slope_w" of a rail id.
  static String suffixOf(int id) {
    var name = Blocks.idOf(id);
    if (name.endsWith('_on')) name = name.substring(0, name.length - 3);
    if (name.startsWith('powered_rail_')) return name.substring('powered_rail_'.length);
    return name.substring('rail_'.length);
  }

  /// The rail id of [baseId]'s kind ("rail" / "powered_rail", `_on` kept)
  /// turned to [suffix]. A powered rail only has the two straights.
  static int withSuffix(int baseId, String suffix) {
    final name = Blocks.idOf(baseId);
    if (name.startsWith('powered_rail_')) {
      var sfx = suffix;
      if (sfx != 'ns' && sfx != 'ew') sfx = sfx.endsWith('n') || sfx.endsWith('s') ? 'ns' : 'ew';
      return Blocks.indexOf('powered_rail_$sfx${name.endsWith('_on') ? '_on' : ''}');
    }
    return Blocks.indexOf('rail_$suffix');
  }

  /// The two ends a rail joins, as steps from its cell (the high end of a slope
  /// steps up).
  static List<IVec3> connections(int id) => ends[suffixOf(id)]!;

  static bool isRailAt(VoxelWorld world, IVec3 c) {
    final id = world.getBlock(c);
    return id != Blocks.air && Blocks.isRail(id);
  }

  static IVec3 flat(IVec3 d) => IVec3(d.x, 0, d.z);

  static IVec3 _neg(IVec3 d) => IVec3(-d.x, -d.y, -d.z);

  /// The cell a cart leaves [cell] into through the end [end] (one of
  /// [connections]), or [cell] itself when the line stops there. A flat end
  /// also reaches a slope one cell down whose high side climbs back toward
  /// [cell].
  static IVec3 nextCell(VoxelWorld world, IVec3 cell, IVec3 end) {
    final c = cell + end;
    if (isRailAt(world, c)) return c;
    if (end.y == 0) {
      final below = c + IVec3.down;
      if (isRailAt(world, below)) {
        final bid = world.getBlock(below);
        if (Blocks.isRailSlope(bid)) {
          for (final e in connections(bid)) {
            if (e.y == 1 && flat(e) == _neg(end)) return below;
          }
        }
      }
    }
    return cell;
  }

  /// The end of the rail at [cell] that points back toward [from] (the cell a
  /// cart came from), or [IVec3.zero] when that rail does not join [from].
  static IVec3 endToward(VoxelWorld world, IVec3 cell, IVec3 from) {
    final id = world.getBlock(cell);
    if (id == Blocks.air || !Blocks.isRail(id)) return IVec3.zero;
    final back = flat(from - cell);
    for (final e in connections(id)) {
      if (flat(e) == back) return e;
    }
    return IVec3.zero;
  }

  /// The id a rail of [baseId]'s kind at [cell] should be, from the rails
  /// around it: a rail one cell up on a side makes a slope toward it; two sides
  /// make a straight or a curve; one side a straight along it; none keeps the
  /// axis the cell already has (or ns).
  static int orient(VoxelWorld world, IVec3 cell, int baseId) {
    final strong = <IVec3>[]; // sides whose rail points back at us
    final weak = <IVec3>[]; // sides with a rail that faces elsewhere
    var up = IVec3.zero;
    for (final d in four) {
      final nb = cell + d;
      if (isRailAt(world, nb)) {
        final nid = world.getBlock(nb);
        var facesUs = false;
        var climbsAway = false;
        for (final e in connections(nid)) {
          if (flat(e) == _neg(d)) {
            facesUs = e.y == 0;
            climbsAway = e.y == 1;
          }
        }
        if (climbsAway) continue; // its high side is over our head, it joins the cell above us
        if (facesUs) {
          strong.add(d);
        } else {
          weak.add(d);
        }
        continue;
      }
      final below = nb + IVec3.down;
      if (isRailAt(world, below) && Blocks.isRailSlope(world.getBlock(below))) {
        for (final e in connections(world.getBlock(below))) {
          if (e.y == 1 && flat(e) == _neg(d)) strong.add(d);
        }
      }
      final above = nb + IVec3.up;
      if (up == IVec3.zero && isRailAt(world, above) && Blocks.isSolid(world.getBlock(nb))) up = d;
    }
    final powered = Blocks.isPoweredRail(baseId);
    if (up != IVec3.zero && !powered) {
      return withSuffix(baseId, 'slope${Blocks.facingSuffix(up.x.toDouble(), up.z.toDouble())}');
    }
    final sides = [...strong, ...weak];
    if (sides.length >= 2) {
      // A through line wins over a corner; the strong sides come first, so a
      // corner joins the rails that actually point at this cell.
      if (sides.contains(n) && sides.contains(s)) return withSuffix(baseId, 'ns');
      if (sides.contains(e) && sides.contains(w)) return withSuffix(baseId, 'ew');
      final a = sides[0], b = sides[1];
      final zs = a.z < 0 || b.z < 0 ? 'n' : 's';
      final xs = a.x > 0 || b.x > 0 ? 'e' : 'w';
      return withSuffix(baseId, '$zs$xs');
    }
    if (sides.length == 1) return withSuffix(baseId, sides[0].z != 0 ? 'ns' : 'ew');
    final current = world.getBlock(cell);
    if (current != Blocks.air && Blocks.isRail(current)) {
      final sfx = suffixOf(current);
      if (sfx == 'ns' || sfx == 'ew') return withSuffix(baseId, sfx);
      return withSuffix(baseId, sfx.endsWith('n') || sfx.endsWith('s') ? 'ns' : 'ew');
    }
    return withSuffix(baseId, 'ns');
  }

  /// Every cell whose rail may change when [cell] does: the four sides, one up
  /// and one down.
  static List<IVec3> neighbours(IVec3 cell) => [
        for (final d in four) ...[cell + d, cell + d + IVec3.up, cell + d + IVec3.down],
      ];

  /// Re-orient the rail at [c], if there is one.
  static void refresh(VoxelWorld world, IVec3 c) {
    if (!isRailAt(world, c)) return;
    final id = world.getBlock(c);
    final want = orient(world, c, id);
    if (want != id) world.setBlock(c, want);
  }

  /// Lay a rail of [baseId]'s kind at [cell], oriented by its neighbours, and
  /// turn the neighbours to meet it (then the new rail once more, so it sees a
  /// neighbour that just became a slope toward it). Returns the id laid.
  static int place(VoxelWorld world, IVec3 cell, int baseId) {
    final id = orient(world, cell, baseId);
    world.setBlock(cell, id);
    for (final nb in neighbours(cell)) {
      refresh(world, nb);
    }
    refresh(world, cell);
    return world.getBlock(cell);
  }

  /// After the rail at [cell] went: the neighbours no longer lean on it.
  static void removed(VoxelWorld world, IVec3 cell) {
    for (final nb in neighbours(cell)) {
      refresh(world, nb);
    }
  }
}
