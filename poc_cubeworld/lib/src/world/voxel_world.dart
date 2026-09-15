import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import 'package:voxel_core/voxel_core.dart';
import '../game/circuits.dart';
import 'terrain_generator.dart';
import 'terrain_material.dart';

typedef BlockChanged = void Function(IVec3 block, int oldId, int newId);
typedef StructureAt = ({int x, int y, int z, int type});

/// The POC's world facade. Chunk streaming, jobs, edits and light live in
/// voxel_core's [ChunkStreamer] (VP1.6); this class keeps what is the game's:
/// one flutter_scene Node per chunk under [root] (it is the streamer's sink),
/// the terrain materials, the terrain generator, liquid flow, circuits,
/// dimension rules and the save format.
class VoxelWorld implements ChunkMeshSink {
  VoxelWorld({required this.seedValue, int loadRadius = 8}) {
    _streamer = ChunkStreamer(table: Blocks.table, sink: this, loadRadius: loadRadius);
    _generator = TerrainGenerator(ids: Blocks.generatorIds(), seed: seedValue);
    // Stage 31: the three lit surfaces share the terrain shader's light term fed
    // by [setSkyIntensity]; specular 0 is Godot's `specular_disabled` with sky
    // reflections off (the dielectric F0 added ~0.04 of the sky to every face).
    matSolid = TerrainMaterial()
      ..roughnessFactor = 1.0
      ..metallicFactor = 0.0
      ..specular = 0.0;
    matCutout = TerrainMaterial()
      ..roughnessFactor = 1.0
      ..metallicFactor = 0.0
      ..specular = 0.0
      ..doubleSided = true;
    matLiquid = TerrainMaterial()
      ..roughnessFactor = 0.15
      ..metallicFactor = 0.1
      ..alphaMode = AlphaMode.blend
      ..doubleSided = true;
    // Stage 27: unlit, so a lamp's faces keep their colour at night.
    matGlow = UnlitMaterial()..vertexColorWeight = 1.0;
    circuits = Circuits(this);
  }

  static const int sizeX = ChunkSize.sizeX;
  static const int sizeZ = ChunkSize.sizeZ;
  static const int sizeY = ChunkSize.sizeY;
  static const int volume = ChunkSize.volume;
  static const int frameBudgetUsec = ChunkStreamer.frameBudgetUsec;
  static const List<ChunkPos> ring = ChunkStreamer.ring;

  late final ChunkStreamer _streamer;

  final Node root = Node(name: 'World');
  int seedValue;
  BlockChanged? onBlockChanged;

  int get loadRadius => _streamer.loadRadius;
  set loadRadius(int value) => _streamer.loadRadius = value;
  int get unloadRadius => _streamer.unloadRadius;
  set unloadRadius(int value) => _streamer.unloadRadius = value;
  int get maxInflight => _streamer.maxInflight;
  set maxInflight(int value) => _streamer.maxInflight = value;

  Map<ChunkPos, Uint8List> get chunks => _streamer.chunks;
  int get chunksBuilt => _streamer.chunksBuilt;
  int get facesEmitted => _streamer.facesEmitted;
  double get meshMsTotal => _streamer.meshMsTotal;
  int get remeshesQueued => _streamer.remeshesQueued;

  final Map<ChunkPos, Node> _nodes = {};
  late TerrainGenerator _generator;
  ChunkWorkerPool? _pool;
  late final TerrainMaterial matSolid;
  late final TerrainMaterial matCutout;
  late final TerrainMaterial matLiquid;
  late final UnlitMaterial matGlow;

  /// Stage 31: [lightingEnabled] false is `--no-light` (set before [start]).
  bool lightingEnabled = true;

  /// Stage 31: how much of the baked skylight shows (1.0 noon, 0.35 night, 0.0
  /// underworld), read by the three terrain materials when they bind.
  void setSkyIntensity(double value) {
    matSolid.skyIntensity = value;
    matCutout.skyIntensity = value;
    matLiquid.skyIntensity = value;
  }

  /// Stage 31: (sky, block) light of a cell, 0..15 each, as the last mesh job of
  /// its chunk computed it. A cell whose chunk has no mesh yet reads as open sky.
  CellLight lightAt(IVec3 b) => _streamer.lightAt(b);

  /// Stage 31: vertices of the chunk's last mesh whose AO is below 1.
  int aoVertsOf(ChunkPos pos) => _streamer.aoVertsOf(pos);

  /// Stage 31: keep what a mesh job learnt about its chunk's light.
  void storeLight(ChunkPos pos, ChunkMeshResult surface) => _streamer.storeLight(pos, surface);

  /// Stage 27: redstone-lite, host-only like the flow ([flowEnabled] gates both).
  /// Stage 29: rebuilt on a dimension switch, so not final.
  late Circuits circuits;

  /// Stage 29: the ONE dimension this world holds (0 overworld, 1 underworld).
  static const int dimOverworld = 0;
  static const int dimUnderworld = 1;
  static const int structFortress = 9;
  int get dimension => _streamer.dimension;

  /// VP1.5: made in a static so the closure sent to the worker isolates
  /// captures only [ids] and [seed], never this world and its scene nodes.
  static ChunkGeneratorFactory _generatorFactory(Map<String, int> ids, int seed) =>
      () => TerrainGenerator(ids: ids, seed: seed);

  Future<void> start() async {
    _pool?.dispose();
    final pool = ChunkWorkerPool(WorkerConfig(
      generator: _generatorFactory(Blocks.generatorIds(), seedValue),
      table: Blocks.table,
      lighting: lightingEnabled,
    ));
    await pool.start();
    _pool = pool;
    _streamer.jobs = pool;
  }

  void dispose() {
    _pool?.dispose();
    _pool = null;
    _streamer.jobs = null;
  }

  TerrainGenerator get generator => _generator;

  Future<void> setWorldSeed(int value) async {
    seedValue = value;
    _generator.setSeed(value);
    await start();
  }

  int surfaceHeight(int x, int z) => _generator.surfaceHeight(x, z);
  int biomeAt(int x, int z) => _generator.biomeAt(x, z);

  static ChunkPos chunkOfVec(Vector3 v) => (x: (v.x / sizeX).floor(), z: (v.z / sizeZ).floor());

  static ChunkPos chunkOf(IVec3 b) => ChunkStreamer.chunkOf(b);
  static ChunkPos chunkOfXZ(int x, int z) => ChunkStreamer.chunkOfXZ(x, z);
  static int index(int x, int y, int z) => ChunkSize.index(x, y, z);

  bool get isIdle => _streamer.isIdle;
  int get loadedChunkCount => _streamer.loadedChunkCount;
  int get pendingCount => _streamer.pendingCount;

  void updateAround(Vector3 worldPosition) => _streamer.updateAround(chunkOfVec(worldPosition));

  void refresh() => _streamer.refresh();

  /// Chunks with a mesh in the scene: the window `loadRadius` fills ([chunks]
  /// also holds the generated ring around it).
  int get meshCount => _streamer.meshCount;

  /// Stage 24: a smaller render distance takes effect at once.
  void trimWindow() => _streamer.trimWindow();

  /// Once per frame: upload finished surfaces within the frame budget, then
  /// dispatch more work.
  void update() => _streamer.update();

  // --- the streamer's sink: one scene node per chunk ------------------------------

  Node? _surfaceNode(MeshSurface s, Material material) {
    if (s.isEmpty) return null;
    final geometry = MeshGeometry.fromArrays(
      positions: s.positions,
      normals: s.normals,
      colors: s.colors,
      texCoords1: s.light, // stage 31: (sky / 15, block / 15), Godot's UV2
      indices: s.indices,
      retainCpuData: false,
    );
    return Node(mesh: Mesh(geometry, material))..shadowStatic = true;
  }

  @override
  void apply(ChunkPos pos, ChunkMeshResult surface) {
    final old = _nodes[pos];
    if (old != null) root.remove(old);
    final node = Node(name: 'chunk_${pos.x}_${pos.z}')..position = Vector3(pos.x * sizeX.toDouble(), 0, pos.z * sizeZ.toDouble());
    final solid = _surfaceNode(surface.solid, matSolid);
    final cutout = _surfaceNode(surface.cutout, matCutout);
    final liquid = _surfaceNode(surface.liquid, matLiquid);
    final glow = _surfaceNode(surface.glow, matGlow);
    if (solid != null) node.add(solid);
    if (cutout != null) node.add(cutout);
    if (glow != null) node.add(glow);
    if (liquid != null) node.add(liquid);
    root.add(node);
    _nodes[pos] = node;
  }

  @override
  void remove(ChunkPos pos) {
    final node = _nodes.remove(pos);
    if (node != null) root.remove(node);
  }

  // --- block access -------------------------------------------------------------

  int getBlock(IVec3 b) => getBlockXYZ(b.x, b.y, b.z);

  int getBlockXYZ(int x, int y, int z) => _streamer.getBlockXYZ(x, y, z);

  bool isLoaded(IVec3 b) => chunks.containsKey(chunkOf(b));

  bool isSolid(IVec3 b) => isSolidXYZ(b.x, b.y, b.z);

  bool isSolidXYZ(int x, int y, int z) {
    if (y < 0) return true;
    return Blocks.isSolid(getBlockXYZ(x, y, z));
  }

  bool isLiquid(IVec3 b) => Blocks.isLiquid(getBlock(b));

  bool setBlock(IVec3 b, int id) {
    final old = getBlock(b);
    if (!_streamer.setBlock(b, id)) return false;
    _flowTouch(b, old, id);
    if (flowEnabled) circuits.touch(b, old, id);
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

  void reset() => _streamer.reset();

  List<StructureAt> structuresNear(ChunkPos pos) => _generator.structuresNearIn(pos.x, pos.z, dimension);

  // --- stage 29: dimensions ---------------------------------------------------------

  /// Leave every chunk of the current dimension behind (its edits kept under
  /// its own key) and start generating [d]. Jobs in flight keep the old epoch
  /// and are dropped when they land.
  void switchDimension(int d) {
    if (d == dimension) return;
    _generator.setDimension(d);
    _flowQueue.clear();
    _flowDist.clear();
    final onTnt = circuits.onTntPowered;
    circuits = Circuits(this)..onTntPowered = onTnt;
    _streamer.switchDimension(d);
  }

  /// Edited cells of dimension [d] (the live one reads the live map).
  int editCountIn(int d) => _streamer.editCountIn(d);

  /// An edit for a dimension that is not loaded (a host broadcast while this
  /// peer is elsewhere): it waits in that dimension's delta and lands when its
  /// chunk generates.
  void storeEdit(int d, IVec3 b, int id) {
    if (d == dimension) {
      setBlock(b, id);
      return;
    }
    _streamer.storeEditElsewhere(d, b, id);
  }

  // --- persistence (edit delta) ---------------------------------------------------

  static const int saveMagic = 0x4342574F; // "CBWO"

  /// Version 2 (stage 29): the edit delta of every dimension, one block per
  /// dimension after the seed. Version 1 (one delta) still loads as dimension 0.
  static const int saveVersion = 2;
  static const int saveDimensions = 2;

  Uint8List editsToBytes() {
    final byDimension = _streamer.editsByDimension;
    var size = 4 + 4 + 8;
    for (var dim = 0; dim < saveDimensions; dim++) {
      size += 4;
      for (final e in (byDimension[dim] ?? const <ChunkPos, Map<int, int>>{}).values) {
        size += 8 + 8 + 4 + e.length * 5;
      }
    }
    final d = ByteData(size);
    var o = 0;
    d.setUint32(o, saveMagic, Endian.little); o += 4;
    d.setUint32(o, saveVersion, Endian.little); o += 4;
    d.setInt64(o, seedValue, Endian.little); o += 8;
    for (var dim = 0; dim < saveDimensions; dim++) {
      final all = byDimension[dim] ?? const <ChunkPos, Map<int, int>>{};
      d.setUint32(o, all.length, Endian.little); o += 4;
      for (final e in all.entries) {
        d.setInt64(o, e.key.x, Endian.little); o += 8;
        d.setInt64(o, e.key.z, Endian.little); o += 8;
        d.setUint32(o, e.value.length, Endian.little); o += 4;
        for (final b in e.value.entries) {
          d.setUint32(o, b.key, Endian.little); o += 4;
          d.setUint8(o, b.value); o += 1;
        }
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
    final version = d.getUint32(o, Endian.little);
    if (version != saveVersion && version != 1) return null;
    o += 4;
    final seed = d.getInt64(o, Endian.little); o += 8;
    final byDimension = <int, Map<ChunkPos, Map<int, int>>>{};
    for (var dim = 0; dim < (version >= 2 ? saveDimensions : 1); dim++) {
      final all = <ChunkPos, Map<int, int>>{};
      final n = d.getUint32(o, Endian.little); o += 4;
      for (var c = 0; c < n; c++) {
        final cx = d.getInt64(o, Endian.little); o += 8;
        final cz = d.getInt64(o, Endian.little); o += 8;
        final count = d.getUint32(o, Endian.little); o += 4;
        final edits = <int, int>{};
        for (var e = 0; e < count; e++) {
          final i = d.getUint32(o, Endian.little); o += 4;
          edits[i] = d.getUint8(o); o += 1;
        }
        all[(x: cx, z: cz)] = edits;
      }
      byDimension[dim] = all;
    }
    _streamer.replaceEdits(byDimension);
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

  int get editCount => _streamer.editCount;

  @visibleForTesting
  double debugWindowFill() => math.min(1.0, meshCount / math.pow(loadRadius * 2 + 1, 2));
}
