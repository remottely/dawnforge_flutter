import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../grid/chunk_size.dart';

/// One vertex-coloured triangle list, ready for `MeshGeometry.fromArrays`.
/// Stage 31: [light] is the second texture coordinate set (Godot's UV2), two
/// floats per vertex: sky / 15 and block / 15 of the cell the face is lit from.
class MeshSurface {
  MeshSurface(this.positions, this.normals, this.colors, this.light, this.indices);
  final Float32List positions;
  final Float32List normals;
  final Float32List colors;
  final Float32List light;
  final Int32List indices;
  int get vertexCount => positions.length ~/ 3;
  int get faceCount => indices.length ~/ 6;
  bool get isEmpty => positions.isEmpty;
}

class ChunkMeshResult {
  ChunkMeshResult(this.solid, this.liquid, this.cutout, this.glow,
      {required this.sky, required this.block, this.aoVerts = 0, this.ms = 0.0});
  final MeshSurface solid;
  final MeshSurface liquid;
  final MeshSurface cutout;

  /// Stage 27: strong emitters (light >= [ChunkMesher.glowThreshold]), drawn
  /// unlit so a lamp reads at night.
  final MeshSurface glow;

  /// Stage 31: the chunk's own light volumes (no padding, 0..15 per cell,
  /// indexed like the block volume) for `VoxelWorld.lightAt`.
  final Uint8List sky;
  final Uint8List block;

  /// Stage 31: vertices of the lit faces whose AO is below 1 (the probe's proof).
  final int aoVerts;

  /// Stage 31: the job's own clock, fill + light + mesh + volume copy.
  final double ms;
  int get faces => solid.faceCount + liquid.faceCount + cutout.faceCount + glow.faceCount;
}

class _F32 {
  Float32List _d = Float32List(4096 * 3);
  int length = 0;
  void add(double v) {
    if (length == _d.length) {
      final n = Float32List(_d.length * 2);
      n.setAll(0, _d);
      _d = n;
    }
    _d[length++] = v;
  }

  void add3(double a, double b, double c) {
    add(a);
    add(b);
    add(c);
  }

  Float32List take() => Float32List.sublistView(_d, 0, length);
}

class _I32 {
  Int32List _d = Int32List(6144);
  int length = 0;
  void add(int v) {
    if (length == _d.length) {
      final n = Int32List(_d.length * 2);
      n.setAll(0, _d);
      _d = n;
    }
    _d[length++] = v;
  }

  Int32List take() => Int32List.sublistView(_d, 0, length);
}

class _Surface {
  final _F32 v = _F32();
  final _F32 n = _F32();
  final _F32 c = _F32();
  final _F32 l = _F32();
  final _I32 i = _I32();

  int get vertexCount => v.length ~/ 3;

  void vertex(double x, double y, double z, double nx, double ny, double nz, double r, double g, double b, double a,
      double sky, double block) {
    v.add3(x, y, z);
    n.add3(nx, ny, nz);
    c.add(r);
    c.add(g);
    c.add(b);
    c.add(a);
    l.add(sky);
    l.add(block);
  }

  /// Two triangles for the quad a-b-c-d, Godot's `Quad` index for index
  /// (clockwise seen from the normal side; `GodotCamera` renders Godot's
  /// handedness, so its winding is the front). Unflipped the shared diagonal is
  /// 0-2, flipped it is 1-3 (Godot's choice for an anisotropic AO:
  /// `flip = ao0 + ao2 < ao1 + ao3`).
  void quadIndices(int f, bool flip) {
    if (!flip) {
      i.add(f); i.add(f + 1); i.add(f + 2);
      i.add(f); i.add(f + 2); i.add(f + 3);
    } else {
      i.add(f + 1); i.add(f + 2); i.add(f + 3);
      i.add(f + 1); i.add(f + 3); i.add(f);
    }
  }

  MeshSurface toSurface() => MeshSurface(v.take(), n.take(), c.take(), l.take(), i.take());
}

/// Face-culling mesher with baked ambient occlusion, sky + block light,
/// per-voxel colour noise, liquids (lowered surface, own transparent surface),
/// cross plants, torches, and the sub-block solids (slab, fence, stairs) built
/// from axis-aligned boxes lit like cube faces. Works on a volume padded on every
/// horizontal side, filled from the eight neighbour chunks, so a border face
/// and its AO corners never guess.
///
/// Stage 31: the light is no longer baked into the vertex colour. The colour
/// carries block tint x face tint x AO; the second UV set carries (sky / 15,
/// block / 15) so the terrain shader can scale the sky half by the time of day.
/// The two light volumes (chunk-sized) ride the result for `lightAt`.
///
/// Stage 32: the _pad is the whole 3x3 ring ([pad] = 16, 48x48x128), so the light
/// BFS sees every emitter within reach of this chunk and a torch beside a border
/// lights both sides alike (no seam).
class ChunkMesher {
  ChunkMesher({
    required this.palette,
    required this.shape,
    required Uint8List opaque,
    required this.emission,
    this.lighting = true,
  }) : _opaque = List<bool>.generate(opaque.length, (i) => opaque[i] != 0);

  static const int _sizeX = ChunkSize.sizeX, _sizeZ = ChunkSize.sizeZ, _sizeY = ChunkSize.sizeY;

  /// Stage 32: the padded volume holds the whole 3x3 ring (16 cells a side), so
  /// a torch up to 15 cells past a border still reaches this chunk's faces and
  /// the light BFS is seam-free. The mesh loop and the AO reads are unchanged;
  /// only the fill and the two BFS grew, and their buffers are per isolate
  /// (static, Godot's `[ThreadStatic]`) rather than per mesher.
  static const int _pad = 16;
  static const int _px = _sizeX + 2 * _pad, _pz = _sizeZ + 2 * _pad;
  static const int _padVolume = _px * _pz * _sizeY;
  static const int _chunkVolume = _sizeX * _sizeZ * _sizeY;
  static const int _air = 0;
  static const int _maxLight = 15;

  static const int _shapeCube = 0,
      _shapeCross = 1,
      _shapeLiquid = 2,
      _shapeTorch = 3,
      _shapeFlower = 4,
      _shapePanelZ = 5,
      _shapePanelX = 6,
      _shapeWallTorch = 7,
      _shapeSlab = 8,
      _shapeFence = 9,
      _shapeStairsN = 10,
      _shapeStairsE = 11,
      _shapeStairsS = 12,
      _shapeStairsW = 13,
      _shapeWire = 14,
      _shapeRailNs = 15,
      _shapeRailEw = 16,
      _shapeRailNe = 17,
      _shapeRailNw = 18,
      _shapeRailSe = 19,
      _shapeRailSw = 20,
      _shapeRailSlopeN = 21,
      _shapeRailSlopeE = 22,
      _shapeRailSlopeS = 23,
      _shapeRailSlopeW = 24;

  /// The shape ints above in [BlockShape] order. They stay `const` ints, not
  /// `BlockShape.index` reads, because they sit in the hottest loop; a test pins
  /// this list to the enum.
  @visibleForTesting
  static const List<int> shapeIndices = [
    _shapeCube, _shapeCross, _shapeLiquid, _shapeTorch, _shapeFlower, _shapePanelZ, _shapePanelX, _shapeWallTorch,
    _shapeSlab, _shapeFence, _shapeStairsN, _shapeStairsE, _shapeStairsS, _shapeStairsW, _shapeWire,
    _shapeRailNs, _shapeRailEw, _shapeRailNe, _shapeRailNw, _shapeRailSe, _shapeRailSw,
    _shapeRailSlopeN, _shapeRailSlopeE, _shapeRailSlopeS, _shapeRailSlopeW,
  ];

  /// Emission at or above this draws on the unlit glow surface (stage 27).
  static const int glowThreshold = 10;

  /// 4 floats per block (rgba, linear).
  final Float32List palette;
  final Uint8List shape;
  final List<bool> _opaque;
  final Uint8List emission;

  /// Stage 31, `--no-light`: skylight everywhere, no block light, no BFS — the
  /// probe's cost comparison.
  final bool lighting;

  /// Stage 32: one 48x48x128 set per isolate (a worker isolate reuses it for
  /// every job; Dart statics are per isolate like C#'s `[ThreadStatic]`).
  static Uint8List? _tBlocks, _tSky, _tGlow;
  static Int32List? _tQueue;
  Uint8List _blocks = Uint8List(0);
  Uint8List _sky = Uint8List(0);
  Uint8List _glow = Uint8List(0);
  Int32List _queue = Int32List(0);
  final List<int> _emitters = [];

  /// Stage 32, tests only: seed the sky BFS from every lit cell (stage 31's
  /// rule) instead of only the cells with a darker side neighbour.
  @visibleForTesting
  static bool fullSkySeed = false;

  void _bindBuffers() {
    _blocks = _tBlocks ??= Uint8List(_padVolume);
    _sky = _tSky ??= Uint8List(_padVolume);
    _glow = _tGlow ??= Uint8List(_padVolume);
    _queue = _tQueue ??= Int32List(_padVolume * 2);
  }
  int _aoVerts = 0;

  // The light of the cell last read by [_lightUv]: sky / 15, block / 15.
  double _ls = 1.0, _lb = 0.0;

  // Face vertex corners, 4 per face: +Y, -Y, +X, -X, +Z, -Z.
  static const List<int> _faceVerts = [
    0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, // +Y
    0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, // -Y
    1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, // +X
    0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, // -X
    0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, // +Z
    0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, // -Z
  ];
  static const List<int> _faceOffsets = [0, 1, 0, 0, -1, 0, 1, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, -1];
  static const List<double> _faceTint = [1.0, 0.55, 0.82, 0.82, 0.70, 0.70];
  static const List<double> _aoFactor = [0.50, 0.68, 0.84, 1.0];

  static int _p(int x, int y, int z) => (x + _pad) + _px * ((z + _pad) + _pz * y);

  static bool _outside(int x, int z) => x < -_pad || x >= _sizeX + _pad || z < -_pad || z >= _sizeZ + _pad;

  int _at(int x, int y, int z) {
    if (y < 0 || y >= _sizeY) return _air;
    if (_outside(x, z)) return _air;
    return _blocks[_p(x, y, z)];
  }

  bool _opaqueAt(int x, int y, int z) {
    if (y < 0) return true;
    if (y >= _sizeY) return false;
    if (_outside(x, z)) return false;
    return _opaque[_blocks[_p(x, y, z)]];
  }

  void _fill(Uint8List c, Uint8List? nx, Uint8List? px, Uint8List? nz, Uint8List? pz,
      Uint8List? nxnz, Uint8List? pxnz, Uint8List? nxpz, Uint8List? pxpz) {
    _blocks.fillRange(0, _padVolume, 0);
    _copyChunk(c, 0, 0);
    _copyChunk(nx, -_sizeX, 0);
    _copyChunk(px, _sizeX, 0);
    _copyChunk(nz, 0, -_sizeZ);
    _copyChunk(pz, 0, _sizeZ);
    _copyChunk(nxnz, -_sizeX, -_sizeZ);
    _copyChunk(pxnz, _sizeX, -_sizeZ);
    _copyChunk(nxpz, -_sizeX, _sizeZ);
    _copyChunk(pxpz, _sizeX, _sizeZ);
  }

  /// Stage 32: one whole chunk volume into the padded buffer at the given cell
  /// offset (a missing neighbour stays air).
  void _copyChunk(Uint8List? vol, int ox, int oz) {
    if (vol == null || vol.length < _chunkVolume) return;
    for (var y = 0; y < _sizeY; y++) {
      for (var z = 0; z < _sizeZ; z++) {
        final dst = _p(ox, y, oz + z);
        _blocks.setRange(dst, dst + _sizeX, vol, ChunkSize.index(0, y, z));
      }
    }
  }

  /// Skylight floods each column from the top (a liquid takes 2), then both
  /// lights spread sideways and down at -1 a step (-2 through a liquid); block
  /// light starts at every emitter's `Blocks.emission()`.
  void _computeLight() {
    _sky.fillRange(0, _padVolume, 0);
    _glow.fillRange(0, _padVolume, 0);
    _emitters.clear();
    if (!lighting) {
      _sky.fillRange(0, _padVolume, _maxLight);
      return;
    }
    var tail = 0;
    // Flutter-side shortcut (the result is identical): every layer above the
    // highest non-air cell of the 48x48 volume is open sky with open-sky
    // neighbours, so it is filled with 15 at once and neither the column pass nor
    // the seeding scan visits it (the test's full seeding still walks all 128).
    const layer = _px * _pz;
    var topY = _sizeY - 1;
    if (!fullSkySeed) {
      while (topY >= 0) {
        final start = topY * layer;
        var any = false;
        for (var i = start; i < start + layer; i++) {
          if (_blocks[i] != _air) {
            any = true;
            break;
          }
        }
        if (any) break;
        topY--;
      }
      if (topY < _sizeY - 1) _sky.fillRange((topY + 1) * layer, _padVolume, _maxLight);
    }
    for (var z = -_pad; z < _sizeZ + _pad; z++) {
      for (var x = -_pad; x < _sizeX + _pad; x++) {
        var level = _maxLight;
        for (var y = topY; y >= 0; y--) {
          final cell = _p(x, y, z);
          final id = _blocks[cell];
          if (id != _air) {
            final e = id < emission.length ? emission[id] : 0;
            if (e > 0) {
              _glow[cell] = e;
              _emitters.add(cell);
            }
            if (_opaque[id]) {
              level = 0;
              continue;
            }
            if (shape[id] == _shapeLiquid) level = math.max(0, level - 2);
          }
          _sky[cell] = level;
          if (fullSkySeed && level > 1) _queue[tail++] = cell;
        }
      }
    }
    if (!fullSkySeed) {
      // Stage 32: only a cell with a darker side neighbour can hand light
      // sideways (the column pass already settled the vertical): full sky beside
      // full sky is the common case over the 48x48 columns and would spread
      // nothing, so it stays out of the queue.
      const hi = _sizeX + _pad - 1, hiZ = _sizeZ + _pad - 1;
      for (var y = 0; y <= topY; y++) {
        for (var z = -_pad; z <= hiZ; z++) {
          var cell = _p(-_pad, y, z);
          for (var x = -_pad; x <= hi; x++, cell++) {
            final level = _sky[cell];
            if (level <= 1) continue;
            final need = level - 1;
            if ((x > -_pad && _sky[cell - 1] < need) || (x < hi && _sky[cell + 1] < need) ||
                (z > -_pad && _sky[cell - _px] < need) || (z < hiZ && _sky[cell + _px] < need)) {
              _queue[tail++] = cell;
            }
          }
        }
      }
    }
    _spread(_sky, tail);
    if (_emitters.isNotEmpty) {
      tail = 0;
      for (final c in _emitters) {
        _queue[tail++] = c;
      }
      _spread(_glow, tail);
    }
  }

  void _spread(Uint8List light, int tail) {
    for (var head = 0; head < tail; head++) {
      final cell = _queue[head];
      final level = light[cell];
      if (level <= 1) continue;
      final y = cell ~/ (_px * _pz);
      final rest = cell - y * _px * _pz;
      final z = rest ~/ _px - _pad;
      final x = rest % _px - _pad;
      for (var f = 0; f < 6; f++) {
        final nx = x + _faceOffsets[f * 3], ny = y + _faceOffsets[f * 3 + 1], nz = z + _faceOffsets[f * 3 + 2];
        if (ny < 0 || ny >= _sizeY || _outside(nx, nz)) continue;
        final n = _p(nx, ny, nz);
        final nid = _blocks[n];
        if (_opaque[nid]) continue;
        final drop = shape[nid] == _shapeLiquid ? 2 : 1;
        if (light[n] >= level - drop) continue;
        light[n] = level - drop;
        if (tail < _queue.length) _queue[tail++] = n;
      }
    }
  }

  /// The light of the cell a face points into, as the shader reads it, into
  /// [_ls] (sky) and [_lb] (block), 0..1. Above the volume is open sky.
  void _lightUv(int x, int y, int z) {
    if (y >= _sizeY) {
      _ls = 1.0;
      _lb = 0.0;
    } else if (y < 0) {
      _ls = 0.0;
      _lb = 0.0;
    } else {
      final c = _p(x, y, z);
      _ls = _sky[c] / _maxLight;
      _lb = _glow[c] / _maxLight;
    }
  }

  static int _u32(int v) => v & 0xFFFFFFFF;

  static double _noise(int x, int y, int z, int chunkX, int chunkZ) {
    var h = _u32((x + chunkX * _sizeX) * 73856093) ^ _u32(y * 19349663) ^ _u32((z + chunkZ * _sizeZ) * 83492791);
    h = _u32(h);
    h ^= h >> 13;
    h = _u32(h * 0x5bd1e995);
    h ^= h >> 15;
    return 0.93 + (h % 1000) / 1000.0 * 0.14;
  }

  static int _ao(int side1, int side2, int corner) {
    if (side1 == 1 && side2 == 1) return 0;
    return 3 - (side1 + side2 + corner);
  }

  /// A flat-shaded axis-aligned box from `lo` to `hi` (chunk-local), one
  /// colour and one light for the top and one of each for the sides.
  void _box(_Surface s, double lx, double ly, double lz, double hx, double hy, double hz,
      double tr, double tg, double tb, double sr, double sg, double sb,
      double topSky, double topBlock, double sideSky, double sideBlock, {bool tint = true}) {
    for (var f = 0; f < 6; f++) {
      final k = f * 12;
      final t = tint ? _faceTint[f] : 1.0;
      final r = (f == 0 ? tr : sr) * t, g = (f == 0 ? tg : sg) * t, b = (f == 0 ? tb : sb) * t;
      final ls = f == 0 ? topSky : sideSky, lb = f == 0 ? topBlock : sideBlock;
      final nx = _faceOffsets[f * 3].toDouble(), ny = _faceOffsets[f * 3 + 1].toDouble(), nz = _faceOffsets[f * 3 + 2].toDouble();
      final first = s.vertexCount;
      for (var i = 0; i < 4; i++) {
        final vx = _faceVerts[k + i * 3] == 0 ? lx : hx;
        final vy = _faceVerts[k + i * 3 + 1] == 0 ? ly : hy;
        final vz = _faceVerts[k + i * 3 + 2] == 0 ? lz : hz;
        s.vertex(vx, vy, vz, nx, ny, nz, r, g, b, 1.0, ls, lb);
      }
      s.quadIndices(first, false);
    }
  }

  /// One box of a sub-block shape, in block-local [0,1] space. A face flush
  /// with the block boundary is culled and lit exactly like a cube face
  /// (neighbour cell, AO corners); an inner face is lit from the cell itself
  /// with no AO.
  void _subBox(_Surface s, int x, int y, int z, int id, bool cullSame, List<int> aos,
      double lox, double loy, double loz, double hix, double hiy, double hiz,
      double br, double bg, double bb, {int skipMask = 0}) {
    for (var f = 0; f < 6; f++) {
      if ((skipMask & (1 << f)) != 0) continue;
      final oxf = _faceOffsets[f * 3], oyf = _faceOffsets[f * 3 + 1], ozf = _faceOffsets[f * 3 + 2];
      final positive = oxf + oyf + ozf > 0;
      final double edge;
      if (oxf != 0) {
        edge = positive ? hix : lox;
      } else if (oyf != 0) {
        edge = positive ? hiy : loy;
      } else {
        edge = positive ? hiz : loz;
      }
      final flush = edge == (positive ? 1.0 : 0.0);
      var ax = x, ay = y, az = z;
      if (flush) {
        ax += oxf;
        ay += oyf;
        az += ozf;
        if (ay < 0) continue;
        final n = _at(ax, ay, az);
        if (n != _air) {
          if (_opaque[n]) continue;
          if (cullSame && n == id) continue;
        }
      }
      final tint = _faceTint[f];
      _lightUv(ax, ay, az);
      final ls = _ls, lb = _lb;
      final k = f * 12;
      var flip = false;
      if (flush) {
        for (var i = 0; i < 4; i++) {
          final sx = _faceVerts[k + i * 3] == 0 ? -1 : 1;
          final sy = _faceVerts[k + i * 3 + 1] == 0 ? -1 : 1;
          final sz = _faceVerts[k + i * 3 + 2] == 0 ? -1 : 1;
          int s1, s2, cr;
          if (oyf != 0) {
            s1 = _opaqueAt(ax + sx, ay, az) ? 1 : 0;
            s2 = _opaqueAt(ax, ay, az + sz) ? 1 : 0;
            cr = _opaqueAt(ax + sx, ay, az + sz) ? 1 : 0;
          } else if (oxf != 0) {
            s1 = _opaqueAt(ax, ay + sy, az) ? 1 : 0;
            s2 = _opaqueAt(ax, ay, az + sz) ? 1 : 0;
            cr = _opaqueAt(ax, ay + sy, az + sz) ? 1 : 0;
          } else {
            s1 = _opaqueAt(ax + sx, ay, az) ? 1 : 0;
            s2 = _opaqueAt(ax, ay + sy, az) ? 1 : 0;
            cr = _opaqueAt(ax + sx, ay + sy, az) ? 1 : 0;
          }
          aos[i] = _ao(s1, s2, cr);
          if (aos[i] < 3) _aoVerts++;
        }
        flip = aos[0] + aos[2] < aos[1] + aos[3];
      } else {
        aos[0] = aos[1] = aos[2] = aos[3] = 3;
      }
      final first = s.vertexCount;
      for (var i = 0; i < 4; i++) {
        final t = tint * _aoFactor[aos[i]];
        final vx = x + (_faceVerts[k + i * 3] == 0 ? lox : hix);
        final vy = y + (_faceVerts[k + i * 3 + 1] == 0 ? loy : hiy);
        final vz = z + (_faceVerts[k + i * 3 + 2] == 0 ? loz : hiz);
        s.vertex(vx, vy, vz, oxf.toDouble(), oyf.toDouble(), ozf.toDouble(), br * t, bg * t, bb * t, 1.0, ls, lb);
      }
      s.quadIndices(first, flip);
    }
  }

  void _quad(_Surface s, List<double> a, List<double> b, List<double> c, List<double> d, double nx, double ny, double nz,
      double r1, double g1, double b1, double r2, double g2, double b2, double ls, double lb) {
    final first = s.vertexCount;
    s.vertex(a[0], a[1], a[2], nx, ny, nz, r1, g1, b1, 1, ls, lb);
    s.vertex(b[0], b[1], b[2], nx, ny, nz, r2, g2, b2, 1, ls, lb);
    s.vertex(c[0], c[1], c[2], nx, ny, nz, r2, g2, b2, 1, ls, lb);
    s.vertex(d[0], d[1], d[2], nx, ny, nz, r1, g1, b1, 1, ls, lb);
    s.quadIndices(first, false);
  }

  /// The eight neighbours of a chunk meshed alone: `[chunk, ...noNeighbours]`.
  /// Every cell past its border reads as air.
  static const List<Uint8List?> noNeighbours = [null, null, null, null, null, null, null, null];

  /// Meshes chunk ([chunkX], [chunkZ]). [ring] is the chunk volume and its eight
  /// neighbours in [ChunkStreamer.ring] order (c, nx, px, nz, pz, nxnz, pxnz,
  /// nxpz, pxpz); a missing neighbour is null and reads as air.
  ChunkMeshResult build(int chunkX, int chunkZ, List<Uint8List?> ring) {
    if (ring.length != 9) throw ArgumentError.value(ring.length, 'ring', 'a chunk and its eight neighbours');
    final c = ring[0];
    if (c == null) throw ArgumentError.notNull('ring[0]');
    final watch = Stopwatch()..start();
    _bindBuffers();
    _aoVerts = 0;
    _fill(c, ring[1], ring[2], ring[3], ring[4], ring[5], ring[6], ring[7], ring[8]);
    _computeLight();

    final solid = _Surface();
    final liquid = _Surface();
    final cutout = _Surface();
    final glow = _Surface(); // stage 27: strong emitters, drawn unlit so a lamp glows at night
    final aos = List<int>.filled(4, 0);

    for (var y = 0; y < _sizeY; y++) {
      for (var z = 0; z < _sizeZ; z++) {
        for (var x = 0; x < _sizeX; x++) {
          final id = _blocks[_p(x, y, z)];
          if (id == _air) continue;
          final sh = shape[id];
          final noise = _noise(x, y, z, chunkX, chunkZ);
          final br = palette[id * 4] * noise, bg = palette[id * 4 + 1] * noise, bb = palette[id * 4 + 2] * noise;
          final ba = palette[id * 4 + 3];
          final ox = x.toDouble(), oy = y.toDouble(), oz = z.toDouble();

          if (sh == _shapeCross || sh == _shapeFlower) {
            // A plant is lit from its own cell, no AO.
            _lightUv(x, y, z);
            final ls = _ls, lb = _lb;
            final cr = br, cg = bg, cb = bb;
            final dr = cr * 0.7, dg = cg * 0.7, db = cb * 0.7;
            final jx = ((x * 7 + z * 13 + y) % 5) * 0.06 - 0.12, jz = ((x * 3 + z * 11) % 5) * 0.06 - 0.12;
            if (sh == _shapeCross) {
              const w = 0.28;
              final hgt = 0.55 + ((x + z) % 3) * 0.1;
              final c0x = ox + 0.5 + jx, c0z = oz + 0.5 + jz;
              for (var k = 0; k < 2; k++) {
                final dx = w, dz = k == 0 ? w : -w;
                final a = [c0x - dx, oy, c0z - dz], b = [c0x + dx, oy, c0z + dz];
                final nX = 0.7, nZ = k == 0 ? -0.7 : 0.7;
                _quad(cutout, a, [a[0], a[1] + hgt, a[2]], [b[0], b[1] + hgt, b[2]], b, nX, 0, nZ, dr, dg, db, cr, cg, cb, ls, lb);
                _quad(cutout, b, [b[0], b[1] + hgt, b[2]], [a[0], a[1] + hgt, a[2]], a, -nX, 0, -nZ, dr, dg, db, cr, cg, cb, ls, lb);
              }
            } else {
              // A stem and a small coloured head.
              const sr = 0.30, sg = 0.55, sb = 0.22;
              final c0x = ox + 0.5 + jx, c0z = oz + 0.5 + jz;
              const d = 0.05;
              _quad(cutout, [c0x - d, oy, c0z - d], [c0x - d, oy + 0.45, c0z - d], [c0x + d, oy + 0.45, c0z + d], [c0x + d, oy, c0z + d],
                  0.7, 0, -0.7, sr, sg, sb, sr, sg, sb, ls, lb);
              _quad(cutout, [c0x + d, oy, c0z + d], [c0x + d, oy + 0.45, c0z + d], [c0x - d, oy + 0.45, c0z - d], [c0x - d, oy, c0z - d],
                  -0.7, 0, 0.7, sr, sg, sb, sr, sg, sb, ls, lb);
              _box(cutout, c0x - 0.14, oy + 0.40, c0z - 0.14, c0x + 0.14, oy + 0.62, c0z + 0.14, cr, cg, cb, cr, cg, cb, ls, lb, ls, lb);
            }
            continue;
          }

          if (sh == _shapeTorch) {
            // Flame on top, stick sides: the flame is full bright (block 15,
            // whatever the cell says), the stick takes the cell's light.
            _lightUv(x, y, z);
            _box(solid, ox + 0.4, oy, oz + 0.4, ox + 0.6, oy + 0.62, oz + 0.6, br, bg, bb, 0.45, 0.32, 0.18,
                0.0, 1.0, _ls, _lb, tint: false);
            continue;
          }

          if (sh == _shapePanelZ || sh == _shapePanelX || sh == _shapeWallTorch) {
            _lightUv(x, y, z);
            final ls = _ls, lb = _lb;
            if (sh == _shapeWallTorch) {
              // Leans on the first opaque horizontal neighbour; full bright by design.
              double lx, ly, lz, hx, hy, hz;
              if (_opaqueAt(x - 1, y, z)) {
                lx = 0.0; ly = 0.3; lz = 0.4; hx = 0.2; hy = 0.85; hz = 0.6;
              } else if (_opaqueAt(x + 1, y, z)) {
                lx = 0.8; ly = 0.3; lz = 0.4; hx = 1.0; hy = 0.85; hz = 0.6;
              } else if (_opaqueAt(x, y, z - 1)) {
                lx = 0.4; ly = 0.3; lz = 0.0; hx = 0.6; hy = 0.85; hz = 0.2;
              } else {
                lx = 0.4; ly = 0.3; lz = 0.8; hx = 0.6; hy = 0.85; hz = 1.0;
              }
              _box(solid, ox + lx, oy + ly, oz + lz, ox + hx, oy + hy, oz + hz, br, bg, bb, 0.45, 0.32, 0.18, 0.0, 1.0, 0.0, 1.0);
            } else {
              const t = 0.1875;
              if (sh == _shapePanelZ) {
                _box(solid, ox, oy, oz, ox + 1, oy + 1, oz + t, br, bg, bb, br, bg, bb, ls, lb, ls, lb);
              } else {
                _box(solid, ox, oy, oz, ox + t, oy + 1, oz + 1, br, bg, bb, br, bg, bb, ls, lb, ls, lb);
              }
              const kr = 0.85, kg = 0.75, kb = 0.35;
              if (sh == _shapePanelZ) {
                _box(solid, ox + 0.78, oy + 0.45, oz - 0.04, ox + 0.9, oy + 0.57, oz + t + 0.04, kr, kg, kb, kr, kg, kb, ls, lb, ls, lb);
              } else {
                _box(solid, ox - 0.04, oy + 0.45, oz + 0.78, ox + t + 0.04, oy + 0.57, oz + 0.9, kr, kg, kb, kr, kg, kb, ls, lb, ls, lb);
              }
            }
            continue;
          }

          final isRail = sh >= _shapeRailNs && sh <= _shapeRailSlopeW;
          if ((sh >= _shapeSlab && sh <= _shapeStairsW) || sh == _shapeWire || isRail) {
            // Stairs never cull against their own kind: a step's face may sit
            // against a neighbour's empty half.
            final cullSame = sh == _shapeSlab || sh == _shapeFence || isRail;
            if (isRail) {
              // Stage 28: two thin bars over wooden ties. A straight runs the
              // bars the whole cell; a curve draws the half of each axis it
              // joins; a slope stacks four steps rising toward its high side
              // (the cart interpolates the real line, the steps only read as a
              // ramp).
              final tr = 0.42 * noise, tg = 0.30 * noise, tb = 0.17 * noise;
              const b0 = 0.1875, b1 = 0.3125, b2 = 0.6875, b3 = 0.8125, ty = 0.0625, by = 0.125;
              void barsZ(double z0, double z1, double yo) {
                _subBox(solid, x, y, z, id, cullSame, aos, b0, yo + ty, z0, b1, yo + by, z1, br, bg, bb);
                _subBox(solid, x, y, z, id, cullSame, aos, b2, yo + ty, z0, b3, yo + by, z1, br, bg, bb);
              }

              void barsX(double x0, double x1, double yo) {
                _subBox(solid, x, y, z, id, cullSame, aos, x0, yo + ty, b0, x1, yo + by, b1, br, bg, bb);
                _subBox(solid, x, y, z, id, cullSame, aos, x0, yo + ty, b2, x1, yo + by, b3, br, bg, bb);
              }

              void tieZ(double zc, double yo) =>
                  _subBox(solid, x, y, z, id, cullSame, aos, 0.0625, yo, zc - 0.09375, 0.9375, yo + ty, zc + 0.09375, tr, tg, tb);
              void tieX(double xc, double yo) =>
                  _subBox(solid, x, y, z, id, cullSame, aos, xc - 0.09375, yo, 0.0625, xc + 0.09375, yo + ty, 0.9375, tr, tg, tb);
              if (sh == _shapeRailNs) {
                tieZ(0.22, 0);
                tieZ(0.78, 0);
                barsZ(0, 1, 0);
              } else if (sh == _shapeRailEw) {
                tieX(0.22, 0);
                tieX(0.78, 0);
                barsX(0, 1, 0);
              } else if (sh == _shapeRailNe) {
                tieZ(0.22, 0);
                tieX(0.78, 0);
                barsZ(0, 0.5, 0);
                barsX(0.5, 1, 0);
              } else if (sh == _shapeRailNw) {
                tieZ(0.22, 0);
                tieX(0.22, 0);
                barsZ(0, 0.5, 0);
                barsX(0, 0.5, 0);
              } else if (sh == _shapeRailSe) {
                tieZ(0.78, 0);
                tieX(0.78, 0);
                barsZ(0.5, 1, 0);
                barsX(0.5, 1, 0);
              } else if (sh == _shapeRailSw) {
                tieZ(0.78, 0);
                tieX(0.22, 0);
                barsZ(0.5, 1, 0);
                barsX(0, 0.5, 0);
              } else {
                // Four steps of a quarter block; step i spans the quarter
                // nearest the low side + i and sits i/4 higher.
                for (var i = 0; i < 4; i++) {
                  final lo = i * 0.25, hi = lo + 0.25, yo = i * 0.25;
                  if (sh == _shapeRailSlopeE) {
                    tieX(lo + 0.125, yo);
                    barsX(lo, hi, yo);
                  } else if (sh == _shapeRailSlopeW) {
                    tieX(1.0 - lo - 0.125, yo);
                    barsX(1.0 - hi, 1.0 - lo, yo);
                  } else if (sh == _shapeRailSlopeS) {
                    tieZ(lo + 0.125, yo);
                    barsZ(lo, hi, yo);
                  } else {
                    tieZ(1.0 - lo - 0.125, yo);
                    barsZ(1.0 - hi, 1.0 - lo, yo);
                  }
                }
              }
            } else if (sh == _shapeSlab) {
              _subBox(solid, x, y, z, id, cullSame, aos, 0, 0, 0, 1, 0.5, 1, br, bg, bb);
            } else if (sh == _shapeWire) {
              // Stage 27: redstone wire, an eighth of a block lying on the floor.
              _subBox(solid, x, y, z, id, cullSame, aos, 0, 0, 0, 1, 0.125, 1, br, bg, bb);
            } else if (sh == _shapeFence) {
              // Centre post, then two rails toward every horizontal neighbour
              // that is a fence or an opaque block. _at reads the padded
              // volume, so a neighbour across the chunk border connects too.
              const p0 = 0.375, p1 = 0.625, r0 = 0.4375, r1 = 0.5625;
              _subBox(solid, x, y, z, id, cullSame, aos, p0, 0, p0, p1, 1, p1, br, bg, bb);
              bool joins(int dx, int dz) {
                final n = _at(x + dx, y, z + dz);
                return n != _air && (_opaque[n] || shape[n] == _shapeFence);
              }

              void rails(double lx, double lz, double hx, double hz) {
                _subBox(solid, x, y, z, id, cullSame, aos, lx, 0.375, lz, hx, 0.5, hz, br, bg, bb);
                _subBox(solid, x, y, z, id, cullSame, aos, lx, 0.75, lz, hx, 0.875, hz, br, bg, bb);
              }

              if (joins(1, 0)) rails(p1, r0, 1.0, r1);
              if (joins(-1, 0)) rails(0.0, r0, p0, r1);
              if (joins(0, 1)) rails(r0, p1, r1, 1.0);
              if (joins(0, -1)) rails(r0, 0.0, r1, p0);
            } else {
              // Bottom slab plus a top-half back step; the step's bottom face
              // is inside the block.
              _subBox(solid, x, y, z, id, cullSame, aos, 0, 0, 0, 1, 0.5, 1, br, bg, bb);
              double slx, sly, slz, shx, shy, shz;
              if (sh == _shapeStairsN) {
                slx = 0; sly = 0.5; slz = 0; shx = 1; shy = 1; shz = 0.5;
              } else if (sh == _shapeStairsS) {
                slx = 0; sly = 0.5; slz = 0.5; shx = 1; shy = 1; shz = 1;
              } else if (sh == _shapeStairsE) {
                slx = 0.5; sly = 0.5; slz = 0; shx = 1; shy = 1; shz = 1;
              } else {
                slx = 0; sly = 0.5; slz = 0; shx = 0.5; shy = 1; shz = 1;
              }
              _subBox(solid, x, y, z, id, cullSame, aos, slx, sly, slz, shx, shy, shz, br, bg, bb, skipMask: 1 << 1);
            }
            continue;
          }

          final isLiquid = sh == _shapeLiquid;
          final above = _at(x, y + 1, z);
          final top = isLiquid && above != id ? 0.875 : 1.0;
          final glows = !isLiquid && id < emission.length && emission[id] >= glowThreshold;
          final target = isLiquid || ba < 0.99 ? liquid : (glows ? glow : solid);

          for (var f = 0; f < 6; f++) {
            final oxf = _faceOffsets[f * 3], oyf = _faceOffsets[f * 3 + 1], ozf = _faceOffsets[f * 3 + 2];
            final ax = x + oxf, ay = y + oyf, az = z + ozf;
            final n = _at(ax, ay, az);
            if (ay < 0) continue;
            if (n != _air) {
              if (_opaque[n]) continue;
              if (n == id) continue; // water-water, glass-glass
              if (isLiquid && shape[n] == _shapeLiquid) continue;
            }
            final tint = _faceTint[f];
            _lightUv(ax, ay, az);
            final ls = _ls, lb = _lb;
            final k = f * 12;
            var flip = false;
            if (!isLiquid) {
              for (var i = 0; i < 4; i++) {
                final sx = _faceVerts[k + i * 3] == 0 ? -1 : 1;
                final sy = _faceVerts[k + i * 3 + 1] == 0 ? -1 : 1;
                final sz = _faceVerts[k + i * 3 + 2] == 0 ? -1 : 1;
                int s1, s2, cr;
                if (oyf != 0) {
                  s1 = _opaqueAt(ax + sx, ay, az) ? 1 : 0;
                  s2 = _opaqueAt(ax, ay, az + sz) ? 1 : 0;
                  cr = _opaqueAt(ax + sx, ay, az + sz) ? 1 : 0;
                } else if (oxf != 0) {
                  s1 = _opaqueAt(ax, ay + sy, az) ? 1 : 0;
                  s2 = _opaqueAt(ax, ay, az + sz) ? 1 : 0;
                  cr = _opaqueAt(ax, ay + sy, az + sz) ? 1 : 0;
                } else {
                  s1 = _opaqueAt(ax + sx, ay, az) ? 1 : 0;
                  s2 = _opaqueAt(ax, ay + sy, az) ? 1 : 0;
                  cr = _opaqueAt(ax + sx, ay + sy, az) ? 1 : 0;
                }
                aos[i] = _ao(s1, s2, cr);
                if (aos[i] < 3) _aoVerts++;
              }
              flip = aos[0] + aos[2] < aos[1] + aos[3];
            } else {
              aos[0] = aos[1] = aos[2] = aos[3] = 3;
            }
            final first = target.vertexCount;
            for (var i = 0; i < 4; i++) {
              final t = tint * _aoFactor[aos[i]];
              final vx = ox + _faceVerts[k + i * 3];
              final vy = oy + _faceVerts[k + i * 3 + 1] * top;
              final vz = oz + _faceVerts[k + i * 3 + 2];
              target.vertex(vx, vy, vz, oxf.toDouble(), oyf.toDouble(), ozf.toDouble(), br * t, bg * t, bb * t, ba, ls, lb);
            }
            target.quadIndices(first, flip);
          }
        }
      }
    }
    // The chunk's own light volumes (no padding) for `VoxelWorld.lightAt`.
    final skyOut = Uint8List(_chunkVolume);
    final blockOut = Uint8List(_chunkVolume);
    for (var y = 0; y < _sizeY; y++) {
      for (var z = 0; z < _sizeZ; z++) {
        final dst = ChunkSize.index(0, y, z), src = _p(0, y, z);
        skyOut.setRange(dst, dst + _sizeX, _sky, src);
        blockOut.setRange(dst, dst + _sizeX, _glow, src);
      }
    }
    watch.stop();
    return ChunkMeshResult(solid.toSurface(), liquid.toSurface(), cutout.toSurface(), glow.toSurface(),
        sky: skyOut, block: blockOut, aoVerts: _aoVerts, ms: watch.elapsedMicroseconds / 1000.0);
  }
}
