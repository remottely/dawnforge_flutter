import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/ivec3.dart';
import 'chunk_mesher.dart';
import 'chunk_worker.dart';
import 'terrain_generator.dart';

typedef ChunkPos = ({int x, int z});
typedef BlockChanged = void Function(IVec3 block, int oldId, int newId);
typedef StructureAt = ({int x, int y, int z, int type});

/// Chunk streaming around a centre, isolate generation + meshing, edit-delta
/// persistence. Owns one flutter_scene Node per chunk under [root].
class VoxelWorld {
  VoxelWorld({required this.seedValue, this.loadRadius = 8}) : unloadRadius = loadRadius + 2 {
    _generator = TerrainGenerator(ids: Blocks.generatorIds(), seed: seedValue);
    matSolid = PhysicallyBasedMaterial()
      ..roughnessFactor = 1.0
      ..metallicFactor = 0.0;
    matCutout = PhysicallyBasedMaterial()
      ..roughnessFactor = 1.0
      ..metallicFactor = 0.0
      ..doubleSided = true;
    matLiquid = PhysicallyBasedMaterial()
      ..roughnessFactor = 0.15
      ..metallicFactor = 0.1
      ..alphaMode = AlphaMode.blend
      ..doubleSided = true;
  }

  static const int sizeX = 16;
  static const int sizeZ = 16;
  static const int sizeY = 128;
  static const int volume = sizeX * sizeZ * sizeY;
  static const int frameBudgetUsec = 7000;

  final Node root = Node(name: 'World');
  int loadRadius;
  int unloadRadius;
  int maxInflight = 24;
  int seedValue;
  BlockChanged? onBlockChanged;

  final Map<ChunkPos, Uint8List> chunks = {};
  int chunksBuilt = 0;
  int facesEmitted = 0;

  final Map<ChunkPos, Node> _nodes = {};
  final List<ChunkPos> _pending = [];
  ChunkPos _center = (x: 999999, z: 999999);
  late TerrainGenerator _generator;
  ChunkWorkerPool? _pool;
  late final PhysicallyBasedMaterial matSolid;
  late final PhysicallyBasedMaterial matCutout;
  late final PhysicallyBasedMaterial matLiquid;

  final Set<ChunkPos> _genInflight = {};
  final Set<ChunkPos> _meshInflight = {};
  final Map<ChunkPos, ChunkMeshResult> _surfaceReady = {};
  final Map<ChunkPos, Map<int, int>> _edits = {};

  static const List<ChunkPos> ring = [
    (x: 0, z: 0), (x: -1, z: 0), (x: 1, z: 0), (x: 0, z: -1), (x: 0, z: 1),
    (x: -1, z: -1), (x: 1, z: -1), (x: -1, z: 1), (x: 1, z: 1),
  ];

  Future<void> start() async {
    _pool?.dispose();
    final pool = ChunkWorkerPool(WorkerConfig(
      seed: seedValue,
      ids: Blocks.generatorIds(),
      palette: Blocks.palette(),
      shapes: Blocks.shapes(),
      opaque: Blocks.opaqueTable(),
      emission: Blocks.emission(),
    ));
    await pool.start();
    _pool = pool;
  }

  void dispose() {
    _pool?.dispose();
    _pool = null;
  }

  TerrainGenerator get generator => _generator;

  Future<void> setWorldSeed(int value) async {
    seedValue = value;
    _generator.setSeed(value);
    await start();
  }

  int surfaceHeight(int x, int z) => _generator.surfaceHeight(x, z);
  int biomeAt(int x, int z) => _generator.biomeAt(x, z);

  static ChunkPos chunkOf(IVec3 b) => (x: (b.x / sizeX).floor(), z: (b.z / sizeZ).floor());
  static ChunkPos chunkOfXZ(int x, int z) => (x: (x / sizeX).floor(), z: (z / sizeZ).floor());
  static int index(int x, int y, int z) => x + sizeX * (z + sizeZ * y);

  bool get isIdle => _pending.isEmpty && _genInflight.isEmpty && _meshInflight.isEmpty && _surfaceReady.isEmpty;
  int get loadedChunkCount => chunks.length;
  int get pendingCount => _pending.length;

  void updateAround(Vector3 worldPosition) {
    final centre = (x: (worldPosition.x / sizeX).floor(), z: (worldPosition.z / sizeZ).floor());
    if (centre == _center) return;
    _center = centre;
    _refreshWindow();
  }

  void refresh() => _center = (x: 999999, z: 999999);

  /// Chunks with a mesh in the scene: the window `loadRadius` fills ([chunks]
  /// also holds the generated ring around it).
  int get meshCount => _nodes.length;

  /// Stage 24: a smaller render distance takes effect at once — everything
  /// past [loadRadius] goes now instead of waiting for the player to walk out
  /// of the unload band.
  void trimWindow() {
    for (final pos in _nodes.keys.toList()) {
      if ((pos.x - _center.x).abs() > loadRadius || (pos.z - _center.z).abs() > loadRadius) _unload(pos);
    }
    for (final pos in chunks.keys.toList()) {
      if ((pos.x - _center.x).abs() > loadRadius + 1 || (pos.z - _center.z).abs() > loadRadius + 1) chunks.remove(pos);
    }
  }

  void _refreshWindow() {
    _pending.clear();
    for (var dz = -loadRadius; dz <= loadRadius; dz++) {
      for (var dx = -loadRadius; dx <= loadRadius; dx++) {
        final pos = (x: _center.x + dx, z: _center.z + dz);
        if (!_nodes.containsKey(pos)) _pending.add(pos);
      }
    }
    int d2(ChunkPos p) => (p.x - _center.x) * (p.x - _center.x) + (p.z - _center.z) * (p.z - _center.z);
    _pending.sort((a, b) => d2(a).compareTo(d2(b)));
    for (final pos in _nodes.keys.toList()) {
      if ((pos.x - _center.x).abs() > unloadRadius || (pos.z - _center.z).abs() > unloadRadius) _unload(pos);
    }
    for (final pos in chunks.keys.toList()) {
      if ((pos.x - _center.x).abs() > unloadRadius + 1 || (pos.z - _center.z).abs() > unloadRadius + 1) chunks.remove(pos);
    }
  }

  /// Once per frame: upload finished surfaces within the frame budget, then
  /// dispatch more work.
  void update() {
    final sw = Stopwatch()..start();
    final applied = <ChunkPos>[];
    for (final e in _surfaceReady.entries) {
      if (chunks.containsKey(e.key)) _applySurface(e.key, e.value);
      applied.add(e.key);
      if (sw.elapsedMicroseconds >= frameBudgetUsec) break;
    }
    for (final pos in applied) {
      _surfaceReady.remove(pos);
      _pending.remove(pos);
    }
    _dispatch();
  }

  void _dispatch() {
    final pool = _pool;
    if (pool == null) return;
    for (final pos in List.of(_pending)) {
      if (_genInflight.length + _meshInflight.length >= maxInflight) return;
      if (_meshInflight.contains(pos) || _surfaceReady.containsKey(pos)) continue;
      var ringReady = true;
      for (final o in ring) {
        final n = (x: pos.x + o.x, z: pos.z + o.z);
        if (chunks.containsKey(n)) continue;
        ringReady = false;
        if (!_genInflight.contains(n)) {
          _genInflight.add(n);
          pool.generate(n.x, n.z).then((blocks) {
            _genInflight.remove(n);
            if (_pool != pool) return;
            _applyEdits(n, blocks);
            chunks[n] = blocks;
          }).catchError((Object e) {
            _genInflight.remove(n);
          });
        }
      }
      if (!ringReady) continue;
      _meshInflight.add(pos);
      final vols = [for (final o in ring) chunks[(x: pos.x + o.x, z: pos.z + o.z)]];
      pool.mesh(pos.x, pos.z, vols).then((surface) {
        _meshInflight.remove(pos);
        if (_pool != pool) return;
        _surfaceReady[pos] = surface;
      }).catchError((Object e) {
        _meshInflight.remove(pos);
      });
    }
  }

  Node? _surfaceNode(MeshSurface s, Material material) {
    if (s.isEmpty) return null;
    final geometry = MeshGeometry.fromArrays(
      positions: s.positions,
      normals: s.normals,
      colors: s.colors,
      indices: s.indices,
      retainCpuData: false,
    );
    return Node(mesh: Mesh(geometry, material))..shadowStatic = true;
  }

  void _applySurface(ChunkPos pos, ChunkMeshResult surface) {
    chunksBuilt += 1;
    facesEmitted += surface.faces;
    final old = _nodes[pos];
    if (old != null) root.remove(old);
    final node = Node(name: 'chunk_${pos.x}_${pos.z}')..position = Vector3(pos.x * sizeX.toDouble(), 0, pos.z * sizeZ.toDouble());
    final solid = _surfaceNode(surface.solid, matSolid);
    final cutout = _surfaceNode(surface.cutout, matCutout);
    final liquid = _surfaceNode(surface.liquid, matLiquid);
    if (solid != null) node.add(solid);
    if (cutout != null) node.add(cutout);
    if (liquid != null) node.add(liquid);
    root.add(node);
    _nodes[pos] = node;
  }

  void _unload(ChunkPos pos) {
    final node = _nodes.remove(pos);
    if (node != null) root.remove(node);
  }

  void _applyEdits(ChunkPos pos, Uint8List blocks) {
    final edits = _edits[pos];
    if (edits == null) return;
    for (final e in edits.entries) {
      blocks[e.key] = e.value;
    }
  }

  // --- block access -------------------------------------------------------------

  int getBlock(IVec3 b) => getBlockXYZ(b.x, b.y, b.z);

  int getBlockXYZ(int x, int y, int z) {
    if (y < 0 || y >= sizeY) return Blocks.air;
    final pos = chunkOfXZ(x, z);
    final blocks = chunks[pos];
    if (blocks == null) return Blocks.air;
    return blocks[index(x - pos.x * sizeX, y, z - pos.z * sizeZ)];
  }

  bool isLoaded(IVec3 b) => chunks.containsKey(chunkOf(b));

  bool isSolid(IVec3 b) => isSolidXYZ(b.x, b.y, b.z);

  bool isSolidXYZ(int x, int y, int z) {
    if (y < 0) return true;
    return Blocks.isSolid(getBlockXYZ(x, y, z));
  }

  bool isLiquid(IVec3 b) => Blocks.isLiquid(getBlock(b));

  bool setBlock(IVec3 b, int id) {
    if (b.y < 1 || b.y >= sizeY) return false;
    final pos = chunkOf(b);
    final blocks = chunks[pos];
    if (blocks == null) return false;
    final lx = b.x - pos.x * sizeX;
    final lz = b.z - pos.z * sizeZ;
    final i = index(lx, b.y, lz);
    final old = blocks[i];
    if (old == id) return false;
    blocks[i] = id;
    (_edits[pos] ??= {})[i] = id;
    _queueRemesh(pos);
    final dx = lx == 0 ? -1 : (lx == sizeX - 1 ? 1 : 0);
    final dz = lz == 0 ? -1 : (lz == sizeZ - 1 ? 1 : 0);
    if (dx != 0) _queueRemesh((x: pos.x + dx, z: pos.z));
    if (dz != 0) _queueRemesh((x: pos.x, z: pos.z + dz));
    if (dx != 0 && dz != 0) _queueRemesh((x: pos.x + dx, z: pos.z + dz));
    _flowTouch(b, old, id);
    onBlockChanged?.call(b, old, id);
    return true;
  }

  // --- liquid flow (stage 22) ------------------------------------------------------
  // Host-only cellular flow, seeded by EDITS alone so an idle world costs
  // nothing: generated lakes are sources resting on solid and never enter the
  // queue.

  static const int flowBudget = 400;
  static const Map<String, double> flowPeriod = {'water': 0.25, 'lava': 0.6};
  static const Map<String, int> flowReach = {'water': 4, 'lava': 2};

  /// A flowing cell loaded from a save: it re-derives its distance when touched.
  static const int flowUnknown = 99;
  static const List<IVec3> _six = [
    IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 1, 0), IVec3(0, -1, 0), IVec3(0, 0, 1), IVec3(0, 0, -1),
  ];
  static const List<IVec3> _four = [IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 0, 1), IVec3(0, 0, -1)];

  /// False on a client: the host owns the flow and every cell it writes
  /// arrives as a plain block edit.
  bool flowEnabled = true;

  /// Liquid cells to visit, in insertion order (Godot's Dictionary keys).
  Set<IVec3> _flowQueue = <IVec3>{};

  /// Horizontal steps from the feeding source (flowing cells only).
  final Map<IVec3, int> _flowDist = {};
  final Map<String, double> _flowTimer = {'water': 0.0, 'lava': 0.0};

  /// Cells written by the flow, for the probe.
  int flowUpdates = 0;

  int get flowPending => _flowQueue.length;

  /// The recorded distance of a cell, or [fallback] when it has none.
  int flowDistOf(IVec3 b, [int fallback = 0]) => _flowDist[b] ?? fallback;

  /// Every edit wakes the liquids around it: the cell itself when it is one,
  /// and each liquid neighbour (a feeder that vanished, a wall that opened, a
  /// lava cell now touching water).
  void _flowTouch(IVec3 b, int old, int id) {
    if (!flowEnabled) return;
    if (Blocks.isLiquid(id)) {
      _flowQueue.add(b);
    } else if (Blocks.isLiquid(old)) {
      _flowDist.remove(b);
    }
    for (final d in _six) {
      final n = b + d;
      if (Blocks.isLiquid(getBlock(n))) _flowQueue.add(n);
    }
  }

  /// The distance of a liquid cell from its source: 0 for a source or a cell
  /// fed from above.
  int _distOf(IVec3 b, int id) => Blocks.isLiquidSource(id) ? 0 : (_flowDist[b] ?? flowUnknown);

  /// Once per simulation tick on the host / solo.
  void tickFlow(double dt) {
    if (!flowEnabled) return;
    if (_flowQueue.isEmpty) {
      for (final k in _flowTimer.keys) {
        _flowTimer[k] = 0.0;
      }
      return;
    }
    final due = <String>{};
    for (final k in _flowTimer.keys) {
      _flowTimer[k] = _flowTimer[k]! + dt;
      if (_flowTimer[k]! >= flowPeriod[k]!) {
        _flowTimer[k] = 0.0;
        due.add(k);
      }
    }
    if (due.isEmpty) return;
    final batch = _flowQueue;
    _flowQueue = <IVec3>{};
    var visited = 0;
    for (final b in batch) {
      final id = getBlock(b);
      final kind = Blocks.liquidKind(id);
      if (kind == '') continue;
      if (!due.contains(kind) || visited >= flowBudget) {
        _flowQueue.add(b); // not its turn yet, or over budget: next tick
        continue;
      }
      visited += 1;
      _flowCell(b, id, kind);
    }
  }

  void _flowCell(IVec3 b, int id, String kind) {
    // Lava touching water hardens: a source into obsidian when the pack has
    // it, otherwise cobblestone; a flowing cell into cobblestone.
    if (kind == 'lava') {
      for (final d in _six) {
        if (Blocks.liquidKind(getBlock(b + d)) == 'water') {
          final hard = Blocks.isLiquidSource(id) && Blocks.has('obsidian') ? 'obsidian' : 'cobblestone';
          _flowSet(b, Blocks.indexOf(hard));
          return;
        }
      }
    }
    var dist = _distOf(b, id);
    if (!Blocks.isLiquidSource(id)) {
      // A flowing cell lives only while something feeds it: the same liquid
      // above, or a horizontal neighbour closer to a source. Re-derive the
      // distance from the best feeder.
      var fed = flowUnknown;
      if (Blocks.liquidKind(getBlock(b + IVec3.up)) == kind) {
        fed = 0;
      } else {
        for (final d in _four) {
          final n = b + d;
          final nid = getBlock(n);
          if (Blocks.liquidKind(nid) == kind) fed = math.min(fed, _distOf(n, nid) + 1);
        }
      }
      // A feeder must be strictly closer to the source than this cell was (a
      // sibling or a child does not count), so removing a source drains its
      // whole puddle in order.
      if (fed > flowReach[kind]! || fed > dist) fed = flowUnknown;
      if (fed == flowUnknown) {
        _flowDist.remove(b);
        _flowSet(b, Blocks.air);
        return;
      }
      if (fed != dist) {
        _flowDist[b] = fed;
        dist = fed;
        for (final d in _four) {
          if (Blocks.liquidKind(getBlock(b + d)) == kind) _flowQueue.add(b + d);
        }
      }
    }
    // Spread: down first (a fall resets the distance); sideways only when
    // resting on a solid or on a source. Above a flowing cell the column just
    // keeps falling: the cell that lands on something does the spreading, so a
    // stream is one block wide.
    final below = b + IVec3.down;
    final belowId = getBlock(below);
    if (_flowCanEnter(belowId)) {
      _flowDist[below] = 0;
      _flowSet(below, Blocks.flowOf(kind));
      return;
    }
    if (!(Blocks.isSolid(belowId) || Blocks.isLiquidSource(belowId))) return;
    if (dist >= flowReach[kind]!) return;
    for (final d in _four) {
      final n = b + d;
      final nid = getBlock(n);
      if (_flowCanEnter(nid)) {
        _flowDist[n] = dist + 1;
        _flowSet(n, Blocks.flowOf(kind));
      } else if (Blocks.liquidKind(nid) == kind && !Blocks.isLiquidSource(nid) && _distOf(n, nid) > dist + 1) {
        _flowDist[n] = dist + 1;
        _flowQueue.add(n);
      }
    }
  }

  /// Air and plants give way to a liquid; anything else (another liquid
  /// included) does not.
  bool _flowCanEnter(int id) => Blocks.isReplaceable(id) && !Blocks.isLiquid(id);

  void _flowSet(IVec3 b, int id) {
    if (setBlock(b, id)) flowUpdates += 1;
  }

  void _queueRemesh(ChunkPos pos) {
    if (!chunks.containsKey(pos) || !_nodes.containsKey(pos)) return;
    if (!_pending.contains(pos)) _pending.insert(0, pos);
  }

  /// Highest solid block y at a column among LOADED chunks, or the generator's guess.
  int groundHeight(int x, int z) {
    final pos = chunkOfXZ(x, z);
    final blocks = chunks[pos];
    if (blocks == null) return surfaceHeight(x, z);
    final lx = x - pos.x * sizeX;
    final lz = z - pos.z * sizeZ;
    for (var y = sizeY - 1; y > 0; y--) {
      if (Blocks.isSolid(blocks[index(lx, y, lz)])) return y + 1;
    }
    return 1;
  }

  void reset() {
    for (final node in _nodes.values) {
      root.remove(node);
    }
    _nodes.clear();
    chunks.clear();
    _pending.clear();
    _surfaceReady.clear();
    _center = (x: 999999, z: 999999);
  }

  List<StructureAt> structuresNear(ChunkPos pos) => _generator.structuresNear(pos.x, pos.z);

  // --- persistence (edit delta) ---------------------------------------------------

  static const int saveMagic = 0x4342574F; // "CBWO"
  static const int saveVersion = 1;

  Uint8List editsToBytes() {
    var size = 4 + 4 + 8 + 4;
    for (final e in _edits.values) {
      size += 8 + 8 + 4 + e.length * 5;
    }
    final d = ByteData(size);
    var o = 0;
    d.setUint32(o, saveMagic, Endian.little); o += 4;
    d.setUint32(o, saveVersion, Endian.little); o += 4;
    d.setInt64(o, seedValue, Endian.little); o += 8;
    d.setUint32(o, _edits.length, Endian.little); o += 4;
    for (final e in _edits.entries) {
      d.setInt64(o, e.key.x, Endian.little); o += 8;
      d.setInt64(o, e.key.z, Endian.little); o += 8;
      d.setUint32(o, e.value.length, Endian.little); o += 4;
      for (final b in e.value.entries) {
        d.setUint32(o, b.key, Endian.little); o += 4;
        d.setUint8(o, b.value); o += 1;
      }
    }
    return d.buffer.asUint8List();
  }

  /// Returns the seed the edits were made against, or null when unreadable.
  int? loadEditsFromBytes(Uint8List bytes) {
    if (bytes.length < 20) return null;
    final d = ByteData.sublistView(bytes);
    var o = 0;
    if (d.getUint32(o, Endian.little) != saveMagic) return null;
    o += 4;
    if (d.getUint32(o, Endian.little) != saveVersion) return null;
    o += 4;
    final seed = d.getInt64(o, Endian.little); o += 8;
    final n = d.getUint32(o, Endian.little); o += 4;
    _edits.clear();
    for (var c = 0; c < n; c++) {
      final cx = d.getInt64(o, Endian.little); o += 8;
      final cz = d.getInt64(o, Endian.little); o += 8;
      final count = d.getUint32(o, Endian.little); o += 4;
      final edits = <int, int>{};
      for (var e = 0; e < count; e++) {
        final i = d.getUint32(o, Endian.little); o += 4;
        edits[i] = d.getUint8(o); o += 1;
      }
      _edits[(x: cx, z: cz)] = edits;
    }
    return seed;
  }

  Future<void> saveEdits(String path) async {
    final f = File(path);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(editsToBytes(), flush: true);
  }

  Future<bool> loadEdits(String path) async {
    final f = File(path);
    if (!await f.exists()) return false;
    final seed = loadEditsFromBytes(await f.readAsBytes());
    if (seed == null) return false;
    if (seed != seedValue) await setWorldSeed(seed);
    return true;
  }

  int get editCount => _edits.values.fold(0, (a, e) => a + e.length);

  @visibleForTesting
  double debugWindowFill() => math.min(1.0, _nodes.length / math.pow(loadRadius * 2 + 1, 2));
}
