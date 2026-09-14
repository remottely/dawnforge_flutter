import '../core/blocks.dart';
import '../core/ivec3.dart';
import '../world/voxel_world.dart';
import 'sfx.dart';

/// Stage 27: redstone-lite (Godot `src/game/circuits.gd`). Host-only, owned by
/// [VoxelWorld] and ticked from the simulation step inside the flow's `blocks`
/// batch. Every state (lever on/off, wire on/off, lamp, door, piston) is a
/// block id, so a flip is a plain `setBlock`: meshing, the save and the
/// network batch come free.
///
/// Sources: `lever_on`, `button_on` (a press, 1 s), a `pressure_plate` while a
/// body stands on it ([setPressedPlates], fed by `Game`'s plate check). Power
/// runs along `wire_*` with a strength that starts at 15 beside a source and
/// drops by one per cell; wires link on the same plane (4 neighbours) and one
/// step up or down along a block edge (the staircase rule: the climb needs no
/// opaque block over this cell, the drop needs no opaque block in the far
/// cell). A powered wire or a source powers its six neighbours: a lamp lights,
/// an iron door opens, a piston extends, TNT ignites ([onTntPowered]).
///
/// Nothing is incremental: an edit near a circuit marks its cell dirty, and the
/// next tick floods every wire network the dirty cells touch (capped at
/// [networkCap] cells) and recomputes it from scratch.
class Circuits {
  Circuits(this.world)
      : _wireOn = Blocks.indexOf('wire_on'),
        _leverOff = Blocks.indexOf('lever_off'),
        _leverOn = Blocks.indexOf('lever_on'),
        _button = Blocks.indexOf('button'),
        _buttonOn = Blocks.indexOf('button_on'),
        _lampOff = Blocks.indexOf('redstone_lamp_off'),
        _lampOn = Blocks.indexOf('redstone_lamp_on'),
        _plate = Blocks.indexOf('pressure_plate'),
        _tnt = Blocks.indexOf('tnt'),
        _wireOff = Blocks.indexOf('wire_off');

  static const double period = 0.1;
  static const int maxStrength = 15;
  static const int networkCap = 400;
  static const double buttonSeconds = 1.0;
  static const List<IVec3> six = [
    IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 1, 0), IVec3(0, -1, 0), IVec3(0, 0, 1), IVec3(0, 0, -1),
  ];
  static const List<IVec3> four = [IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 0, 1), IVec3(0, 0, -1)];

  final VoxelWorld world;

  /// Networks rebuilt, for the probes.
  int recomputes = 0;

  /// Godot's `tnt_powered` signal: TNT beside a live wire or a source.
  void Function(IVec3 at)? onTntPowered;

  final Map<IVec3, int> _power = {}; // wire cell -> strength 1..15 (absent = 0)
  final Set<IVec3> _dirty = {}; // cells whose networks need a rebuild
  Set<IVec3> _plates = {}; // plates with a body on them, this tick
  final Map<IVec3, double> _buttons = {}; // pressed buttons -> seconds left
  double _timer = period;
  bool _applying = false;

  final int _wireOff, _wireOn, _leverOff, _leverOn, _button, _buttonOn, _lampOff, _lampOn, _plate, _tnt;

  // --- what the world and the player call -----------------------------------------

  /// The player's use action on a lever or a button. Any side may call it: the
  /// edit travels as a block edit, and the HOST's [touch] starts the button
  /// timer when `button_on` lands.
  bool useBlock(IVec3 b) {
    final id = world.getBlock(b);
    if (id == _leverOff) return world.setBlock(b, _leverOn);
    if (id == _leverOn) return world.setBlock(b, _leverOff);
    if (id == _button) return world.setBlock(b, _buttonOn);
    return false;
  }

  /// Every block edit passes here (from `VoxelWorld.setBlock`). A circuit block
  /// appearing or vanishing, or any edit beside a wire, marks the cell for the
  /// next rebuild.
  void touch(IVec3 b, int old, int id) {
    if (_applying) return;
    if (id == _buttonOn) {
      _buttons[b] = buttonSeconds;
    } else if (old == _buttonOn) {
      _buttons.remove(b);
    }
    if (old == _wireOff || old == _wireOn) _power.remove(b);
    if (_isCircuit(old) || _isCircuit(id)) {
      _dirty.add(b);
      return;
    }
    for (final d in six) {
      if (Blocks.isWire(world.getBlock(b + d))) {
        _dirty.add(b);
        return;
      }
    }
  }

  /// The plates with a body on them this simulation tick; a plate that changed
  /// state wakes its network.
  void setPressedPlates(Set<IVec3> pressed) {
    for (final cell in pressed) {
      if (!_plates.contains(cell)) _dirty.add(cell);
    }
    for (final cell in _plates) {
      if (!pressed.contains(cell)) _dirty.add(cell);
    }
    _plates = Set.of(pressed);
  }

  void tick(double dt) {
    for (final cell in List.of(_buttons.keys)) {
      final left = _buttons[cell]! - dt;
      _buttons[cell] = left;
      if (left <= 0.0) {
        _buttons.remove(cell);
        if (world.getBlock(cell) == _buttonOn) world.setBlock(cell, _button); // `touch` marks it dirty
      }
    }
    _timer += dt;
    if (_dirty.isEmpty || _timer < period) return;
    _timer = 0.0;
    final seeds = List.of(_dirty);
    _dirty.clear();
    _recompute(seeds);
  }

  /// The strength a wire cell carries (0 for no wire or an unpowered one).
  int strengthAt(IVec3 b) => _power[b] ?? 0;

  int get pending => _dirty.length;

  // --- the rebuild ------------------------------------------------------------------

  bool _isCircuit(int id) {
    if (id == Blocks.air) return false;
    return Blocks.isWire(id) || id == _leverOff || id == _leverOn || id == _button || id == _buttonOn ||
        id == _lampOff || id == _lampOn || id == _plate || id == _tnt || Blocks.isIronDoor(id) || Blocks.isPiston(id) ||
        Blocks.isPoweredRail(id);
  }

  bool _isSource(IVec3 b) {
    final id = world.getBlock(b);
    if (id == _leverOn || id == _buttonOn) return true;
    return id == _plate && _plates.contains(b);
  }

  bool _isOpaqueAt(IVec3 b) => Blocks.isOpaque(world.getBlock(b));

  /// The wire cells [b] links to: same plane, one up along an edge (nothing
  /// opaque over [b]), one down along an edge (the far cell not opaque).
  List<IVec3> _links(IVec3 b) {
    final out = <IVec3>[];
    final openAbove = !_isOpaqueAt(b + IVec3.up);
    for (final d in four) {
      final n = b + d;
      final nid = world.getBlock(n);
      if (Blocks.isWire(nid)) {
        out.add(n);
        continue;
      }
      if (openAbove && Blocks.isWire(world.getBlock(n + IVec3.up))) {
        out.add(n + IVec3.up);
      } else if (!Blocks.isOpaque(nid) && Blocks.isWire(world.getBlock(n + IVec3.down))) {
        out.add(n + IVec3.down);
      }
    }
    return out;
  }

  /// Any six-neighbour that is a source or a live wire powers this cell.
  bool _isPowered(IVec3 b) {
    for (final d in six) {
      final n = b + d;
      if (_isSource(n) || world.getBlock(n) == _wireOn) return true;
    }
    return false;
  }

  void _recompute(List<IVec3> seeds) {
    recomputes += 1;
    // 1. Every wire network a seed touches, flooded whole (capped).
    final wires = <IVec3>{};
    final frontier = <IVec3>[];
    for (final s in seeds) {
      for (final c in [s, for (final d in six) s + d]) {
        if (Blocks.isWire(world.getBlock(c)) && wires.add(c)) frontier.add(c);
      }
    }
    var head = 0;
    while (head < frontier.length && wires.length < networkCap) {
      final c = frontier[head++];
      for (final n in _links(c)) {
        if (wires.add(n)) frontier.add(n);
      }
    }
    // 2. Strength: 15 beside a source, one less per link, the best feeder wins.
    final strength = <IVec3, int>{};
    final queue = <IVec3>[];
    for (final c in wires) {
      for (final d in six) {
        if (_isSource(c + d)) {
          strength[c] = maxStrength;
          queue.add(c);
          break;
        }
      }
    }
    head = 0;
    while (head < queue.length) {
      final c = queue[head++];
      final s = strength[c]!;
      if (s <= 1) continue;
      for (final n in _links(c)) {
        if (wires.contains(n) && (strength[n] ?? 0) < s - 1) {
          strength[n] = s - 1;
          queue.add(n);
        }
      }
    }
    // 3. Write the wires, then let everything beside a wire, a seed or a source react.
    _applying = true;
    for (final c in wires) {
      final s = strength[c] ?? 0;
      if (s > 0) {
        _power[c] = s;
      } else {
        _power.remove(c);
      }
      final want = s > 0 ? _wireOn : _wireOff;
      if (world.getBlock(c) != want) world.setBlock(c, want);
    }
    final candidates = <IVec3>{};
    for (final c in wires) {
      for (final d in six) {
        candidates.add(c + d);
      }
    }
    for (final s in seeds) {
      candidates.add(s);
      for (final d in six) {
        candidates.add(s + d);
      }
    }
    for (final c in candidates) {
      _react(c);
    }
    _applying = false;
  }

  void _react(IVec3 c) {
    final id = world.getBlock(c);
    if (id == Blocks.air) return;
    if (id == _lampOff || id == _lampOn) {
      final want = _isPowered(c) ? _lampOn : _lampOff;
      if (id != want) world.setBlock(c, want);
    } else if (id == _tnt) {
      if (_isPowered(c)) onTntPowered?.call(c);
    } else if (Blocks.isIronDoor(id)) {
      _reactDoor(c, id);
    } else if (Blocks.isPiston(id)) {
      _reactPiston(c, id);
    } else if (Blocks.isPoweredRail(id)) {
      _reactPoweredRails(c);
    }
  }

  /// Stage 28: a powered rail is on when its own cell is powered or one within
  /// eight cells along its run of powered rails is (a lever beside one cell
  /// lights the whole segment). The run is flooded from [c] over the four
  /// sides, capped at 64, and every cell written at once.
  void _reactPoweredRails(IVec3 c) {
    final run = <IVec3>[c];
    final seen = <IVec3>{c};
    var head = 0;
    while (head < run.length && run.length < 64) {
      final cur = run[head++];
      for (final d in four) {
        final n = cur + d;
        if (seen.contains(n)) continue;
        final nid = world.getBlock(n);
        if (nid != Blocks.air && Blocks.isPoweredRail(nid)) {
          seen.add(n);
          run.add(n);
        }
      }
    }
    final dist = <IVec3, int>{};
    final queue = <IVec3>[];
    for (final cell in run) {
      if (_isPowered(cell)) {
        dist[cell] = 0;
        queue.add(cell);
      }
    }
    head = 0;
    while (head < queue.length) {
      final cur = queue[head++];
      for (final d in four) {
        final n = cur + d;
        if (seen.contains(n) && !dist.containsKey(n)) {
          dist[n] = dist[cur]! + 1;
          queue.add(n);
        }
      }
    }
    for (final cell in run) {
      final id = world.getBlock(cell);
      var name = Blocks.idOf(id);
      if (name.endsWith('_on')) name = name.substring(0, name.length - 3);
      final on = (dist[cell] ?? 99) <= 8;
      final want = Blocks.indexOf(on ? '${name}_on' : name);
      if (id != want) world.setBlock(cell, want);
    }
  }

  /// Both halves open together; either half powered opens the door.
  void _reactDoor(IVec3 c, int id) {
    var lower = c;
    if (Blocks.isIronDoor(world.getBlock(c + IVec3.down))) lower = c + IVec3.down;
    final upper = lower + IVec3.up;
    final powered = _isPowered(lower) || _isPowered(upper);
    var name = Blocks.idOf(id);
    if (name.endsWith('_open')) name = name.substring(0, name.length - 5);
    final want = Blocks.indexOf(powered ? '${name}_open' : name);
    if (world.getBlock(lower) != want) {
      world.setBlock(lower, want);
      Sfx.play('door', -6.0);
    }
    if (Blocks.isIronDoor(world.getBlock(upper)) && world.getBlock(upper) != want) world.setBlock(upper, want);
  }

  /// Extend: the block in front moves one cell along the facing when the cell
  /// past it gives way (air, a plant, a liquid); a blocked piston stays
  /// retracted. Retract: the head pulls back and the pushed block stays where
  /// it went (no sticky pistons).
  void _reactPiston(IVec3 c, int id) {
    final name = Blocks.idOf(id);
    final extended = name.endsWith('_on');
    final powered = _isPowered(c);
    if (extended == powered) return;
    final base = extended ? name.substring(0, name.length - 3) : name;
    if (!powered) {
      world.setBlock(c, Blocks.indexOf(base));
      return;
    }
    final dir = Blocks.pistonDir(id);
    final front = c + dir;
    final fid = world.getBlock(front);
    if (fid != Blocks.air) {
      final beyond = front + dir;
      if (Blocks.hardness(fid) < 0.0 || !Blocks.isReplaceable(world.getBlock(beyond))) return;
      world.setBlock(beyond, fid);
      world.setBlock(front, Blocks.air);
      _dirty.add(front); // the moved block may be a circuit part: next tick sees it
      _dirty.add(beyond);
    }
    world.setBlock(c, Blocks.indexOf('${base}_on'));
    Sfx.play('place', -8.0, 0.7);
  }
}
