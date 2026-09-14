import 'dart:math' as math;
import 'dart:typed_data';

/// One vertex-coloured triangle list, ready for `MeshGeometry.fromArrays`.
class MeshSurface {
  MeshSurface(this.positions, this.normals, this.colors, this.indices);
  final Float32List positions;
  final Float32List normals;
  final Float32List colors;
  final Int32List indices;
  int get vertexCount => positions.length ~/ 3;
  int get faceCount => indices.length ~/ 6;
  bool get isEmpty => positions.isEmpty;
}

class ChunkMeshResult {
  ChunkMeshResult(this.solid, this.liquid, this.cutout, this.glow);
  final MeshSurface solid;
  final MeshSurface liquid;
  final MeshSurface cutout;

  /// Stage 27: strong emitters (light >= [ChunkMesher.glowThreshold]), drawn
  /// unlit so a lamp reads at night.
  final MeshSurface glow;
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
  final _I32 i = _I32();

  int get vertexCount => v.length ~/ 3;

  void vertex(double x, double y, double z, double nx, double ny, double nz, double r, double g, double b, double a) {
    v.add3(x, y, z);
    n.add3(nx, ny, nz);
    c.add(r);
    c.add(g);
    c.add(b);
    c.add(a);
  }

  /// Two triangles for the quad a-b-c-d, wound counter-clockwise (flutter_scene
  /// front faces) — the Godot POC wound clockwise, so the diagonals are mirrored.
  void quadIndices(int f, bool flip) {
    if (!flip) {
      i.add(f); i.add(f + 2); i.add(f + 1);
      i.add(f); i.add(f + 3); i.add(f + 2);
    } else {
      i.add(f + 1); i.add(f + 3); i.add(f + 2);
      i.add(f + 1); i.add(f); i.add(f + 3);
    }
  }

  MeshSurface toSurface() => MeshSurface(v.take(), n.take(), c.take(), i.take());
}

/// Face-culling mesher with baked ambient occlusion, sky + block light,
/// per-voxel colour noise, liquids (lowered surface, own transparent surface),
/// cross plants, torches, and the sub-block solids (slab, fence, stairs) built
/// from axis-aligned boxes lit like cube faces. Works on a volume padded by one block on every
/// horizontal side, filled from the eight neighbour chunks, so a border face
/// and its AO corners never guess.
class ChunkMesher {
  ChunkMesher({
    required this.palette,
    required this.shape,
    required Uint8List opaque,
    required this.emission,
  }) : _opaque = List<bool>.generate(opaque.length, (i) => opaque[i] != 0);

  static const int sizeX = 16, sizeZ = 16, sizeY = 128;
  static const int _px = sizeX + 2, _pz = sizeZ + 2;
  static const int _padVolume = _px * _pz * sizeY;
  static const int _air = 0;
  static const int _maxLight = 15;
  static const double _ambientFloor = 0.16;

  static const int shapeCube = 0,
      shapeCross = 1,
      shapeLiquid = 2,
      shapeTorch = 3,
      shapeFlower = 4,
      shapePanelZ = 5,
      shapePanelX = 6,
      shapeWallTorch = 7,
      shapeSlab = 8,
      shapeFence = 9,
      shapeStairsN = 10,
      shapeStairsE = 11,
      shapeStairsS = 12,
      shapeStairsW = 13,
      shapeWire = 14,
      shapeRailNs = 15,
      shapeRailEw = 16,
      shapeRailNe = 17,
      shapeRailNw = 18,
      shapeRailSe = 19,
      shapeRailSw = 20,
      shapeRailSlopeN = 21,
      shapeRailSlopeE = 22,
      shapeRailSlopeS = 23,
      shapeRailSlopeW = 24;

  /// Emission at or above this draws on the unlit glow surface (stage 27).
  static const int glowThreshold = 10;

  /// 4 floats per block (rgba, linear).
  final Float32List palette;
  final Uint8List shape;
  final List<bool> _opaque;
  final Uint8List emission;

  final Uint8List _blocks = Uint8List(_padVolume);
  final Uint8List _sky = Uint8List(_padVolume);
  final Uint8List _glow = Uint8List(_padVolume);
  final Int32List _queue = Int32List(_padVolume);
  final List<int> _emitters = [];

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

  static int _p(int x, int y, int z) => (x + 1) + _px * ((z + 1) + _pz * y);
  static int index(int x, int y, int z) => x + sizeX * (z + sizeZ * y);

  int _at(int x, int y, int z) {
    if (y < 0 || y >= sizeY) return _air;
    if (x < -1 || x > sizeX || z < -1 || z > sizeZ) return _air;
    return _blocks[_p(x, y, z)];
  }

  bool _opaqueAt(int x, int y, int z) {
    if (y < 0) return true;
    if (y >= sizeY) return false;
    if (x < -1 || x > sizeX || z < -1 || z > sizeZ) return false;
    return _opaque[_blocks[_p(x, y, z)]];
  }

  void _fill(Uint8List c, Uint8List? nx, Uint8List? px, Uint8List? nz, Uint8List? pz,
      Uint8List? nxnz, Uint8List? pxnz, Uint8List? nxpz, Uint8List? pxpz) {
    _blocks.fillRange(0, _padVolume, 0);
    for (var y = 0; y < sizeY; y++) {
      for (var z = 0; z < sizeZ; z++) {
        final src = index(0, y, z);
        final dst = _p(0, y, z);
        _blocks.setRange(dst, dst + sizeX, c, src);
        if (nx != null) _blocks[_p(-1, y, z)] = nx[index(sizeX - 1, y, z)];
        if (px != null) _blocks[_p(sizeX, y, z)] = px[index(0, y, z)];
      }
      for (var x = 0; x < sizeX; x++) {
        if (nz != null) _blocks[_p(x, y, -1)] = nz[index(x, y, sizeZ - 1)];
        if (pz != null) _blocks[_p(x, y, sizeZ)] = pz[index(x, y, 0)];
      }
      if (nxnz != null) _blocks[_p(-1, y, -1)] = nxnz[index(sizeX - 1, y, sizeZ - 1)];
      if (pxnz != null) _blocks[_p(sizeX, y, -1)] = pxnz[index(0, y, sizeZ - 1)];
      if (nxpz != null) _blocks[_p(-1, y, sizeZ)] = nxpz[index(sizeX - 1, y, 0)];
      if (pxpz != null) _blocks[_p(sizeX, y, sizeZ)] = pxpz[index(0, y, 0)];
    }
  }

  void _computeLight() {
    _sky.fillRange(0, _padVolume, 0);
    _glow.fillRange(0, _padVolume, 0);
    _emitters.clear();
    var tail = 0;
    for (var z = -1; z <= sizeZ; z++) {
      for (var x = -1; x <= sizeX; x++) {
        var level = _maxLight;
        for (var y = sizeY - 1; y >= 0; y--) {
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
            if (shape[id] == shapeLiquid) level = math.max(0, level - 2);
          }
          _sky[cell] = level;
          if (level > 1) _queue[tail++] = cell;
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
      final z = rest ~/ _px - 1;
      final x = rest % _px - 1;
      for (var f = 0; f < 6; f++) {
        final nx = x + _faceOffsets[f * 3], ny = y + _faceOffsets[f * 3 + 1], nz = z + _faceOffsets[f * 3 + 2];
        if (ny < 0 || ny >= sizeY || nx < -1 || nx > sizeX || nz < -1 || nz > sizeZ) continue;
        final n = _p(nx, ny, nz);
        final nid = _blocks[n];
        if (_opaque[nid]) continue;
        final drop = shape[nid] == shapeLiquid ? 2 : 1;
        if (light[n] >= level - drop) continue;
        light[n] = level - drop;
        if (tail < _queue.length) _queue[tail++] = n;
      }
    }
  }

  double _lightFactor(int x, int y, int z) {
    int level;
    if (y >= sizeY) {
      level = _maxLight;
    } else if (y < 0) {
      level = 0;
    } else {
      final c = _p(x, y, z);
      level = math.max(_sky[c], _glow[c]);
    }
    return _ambientFloor + (1.0 - _ambientFloor) * (level / _maxLight);
  }

  static int _u32(int v) => v & 0xFFFFFFFF;

  static double _noise(int x, int y, int z, int chunkX, int chunkZ) {
    var h = _u32((x + chunkX * sizeX) * 73856093) ^ _u32(y * 19349663) ^ _u32((z + chunkZ * sizeZ) * 83492791);
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
  /// colour for the top and one for the sides.
  void _box(_Surface s, double lx, double ly, double lz, double hx, double hy, double hz,
      double tr, double tg, double tb, double sr, double sg, double sb, {bool tint = true}) {
    for (var f = 0; f < 6; f++) {
      final k = f * 12;
      final t = tint ? _faceTint[f] : 1.0;
      final r = (f == 0 ? tr : sr) * t, g = (f == 0 ? tg : sg) * t, b = (f == 0 ? tb : sb) * t;
      final nx = _faceOffsets[f * 3].toDouble(), ny = _faceOffsets[f * 3 + 1].toDouble(), nz = _faceOffsets[f * 3 + 2].toDouble();
      final first = s.vertexCount;
      for (var i = 0; i < 4; i++) {
        final vx = _faceVerts[k + i * 3] == 0 ? lx : hx;
        final vy = _faceVerts[k + i * 3 + 1] == 0 ? ly : hy;
        final vz = _faceVerts[k + i * 3 + 2] == 0 ? lz : hz;
        s.vertex(vx, vy, vz, nx, ny, nz, r, g, b, 1.0);
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
      final tint = _faceTint[f] * _lightFactor(ax, ay, az);
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
        s.vertex(vx, vy, vz, oxf.toDouble(), oyf.toDouble(), ozf.toDouble(), br * t, bg * t, bb * t, 1.0);
      }
      s.quadIndices(first, flip);
    }
  }

  void _quad(_Surface s, List<double> a, List<double> b, List<double> c, List<double> d, double nx, double ny, double nz,
      double r1, double g1, double b1, double r2, double g2, double b2) {
    final first = s.vertexCount;
    s.vertex(a[0], a[1], a[2], nx, ny, nz, r1, g1, b1, 1);
    s.vertex(b[0], b[1], b[2], nx, ny, nz, r2, g2, b2, 1);
    s.vertex(c[0], c[1], c[2], nx, ny, nz, r2, g2, b2, 1);
    s.vertex(d[0], d[1], d[2], nx, ny, nz, r1, g1, b1, 1);
    s.quadIndices(first, false);
  }

  ChunkMeshResult build(int chunkX, int chunkZ, Uint8List c, Uint8List? nx, Uint8List? px, Uint8List? nz,
      Uint8List? pz, Uint8List? nxnz, Uint8List? pxnz, Uint8List? nxpz, Uint8List? pxpz) {
    _fill(c, nx, px, nz, pz, nxnz, pxnz, nxpz, pxpz);
    _computeLight();

    final solid = _Surface();
    final liquid = _Surface();
    final cutout = _Surface();
    final glow = _Surface(); // stage 27: strong emitters, drawn unlit so a lamp glows at night
    final aos = List<int>.filled(4, 0);

    for (var y = 0; y < sizeY; y++) {
      for (var z = 0; z < sizeZ; z++) {
        for (var x = 0; x < sizeX; x++) {
          final id = _blocks[_p(x, y, z)];
          if (id == _air) continue;
          final sh = shape[id];
          final noise = _noise(x, y, z, chunkX, chunkZ);
          final br = palette[id * 4] * noise, bg = palette[id * 4 + 1] * noise, bb = palette[id * 4 + 2] * noise;
          final ba = palette[id * 4 + 3];
          final ox = x.toDouble(), oy = y.toDouble(), oz = z.toDouble();

          if (sh == shapeCross || sh == shapeFlower) {
            final lf = _lightFactor(x, y, z);
            final cr = br * lf, cg = bg * lf, cb = bb * lf;
            final dr = cr * 0.7, dg = cg * 0.7, db = cb * 0.7;
            final jx = ((x * 7 + z * 13 + y) % 5) * 0.06 - 0.12, jz = ((x * 3 + z * 11) % 5) * 0.06 - 0.12;
            if (sh == shapeCross) {
              const w = 0.28;
              final hgt = 0.55 + ((x + z) % 3) * 0.1;
              final c0x = ox + 0.5 + jx, c0z = oz + 0.5 + jz;
              for (var k = 0; k < 2; k++) {
                final dx = w, dz = k == 0 ? w : -w;
                final a = [c0x - dx, oy, c0z - dz], b = [c0x + dx, oy, c0z + dz];
                final nX = 0.7, nZ = k == 0 ? -0.7 : 0.7;
                _quad(cutout, a, [a[0], a[1] + hgt, a[2]], [b[0], b[1] + hgt, b[2]], b, nX, 0, nZ, dr, dg, db, cr, cg, cb);
                _quad(cutout, b, [b[0], b[1] + hgt, b[2]], [a[0], a[1] + hgt, a[2]], a, -nX, 0, -nZ, dr, dg, db, cr, cg, cb);
              }
            } else {
              final sr = 0.30 * lf, sg = 0.55 * lf, sb = 0.22 * lf;
              final c0x = ox + 0.5 + jx, c0z = oz + 0.5 + jz;
              const d = 0.05;
              _quad(cutout, [c0x - d, oy, c0z - d], [c0x - d, oy + 0.45, c0z - d], [c0x + d, oy + 0.45, c0z + d], [c0x + d, oy, c0z + d],
                  0.7, 0, -0.7, sr, sg, sb, sr, sg, sb);
              _quad(cutout, [c0x + d, oy, c0z + d], [c0x + d, oy + 0.45, c0z + d], [c0x - d, oy + 0.45, c0z - d], [c0x - d, oy, c0z - d],
                  -0.7, 0, 0.7, sr, sg, sb, sr, sg, sb);
              _box(cutout, c0x - 0.14, oy + 0.40, c0z - 0.14, c0x + 0.14, oy + 0.62, c0z + 0.14, cr, cg, cb, cr, cg, cb);
            }
            continue;
          }

          if (sh == shapeTorch) {
            // Flame on top, stick sides; the flame is unlit by design.
            _box(solid, ox + 0.4, oy, oz + 0.4, ox + 0.6, oy + 0.62, oz + 0.6, br, bg, bb, 0.45, 0.32, 0.18, tint: false);
            continue;
          }

          if (sh == shapePanelZ || sh == shapePanelX || sh == shapeWallTorch) {
            final lf = _lightFactor(x, y, z);
            final cr = br * lf, cg = bg * lf, cb = bb * lf;
            if (sh == shapeWallTorch) {
              // Leans on the first opaque horizontal neighbour.
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
              _box(solid, ox + lx, oy + ly, oz + lz, ox + hx, oy + hy, oz + hz, br, bg, bb, 0.45, 0.32, 0.18);
            } else {
              const t = 0.1875;
              if (sh == shapePanelZ) {
                _box(solid, ox, oy, oz, ox + 1, oy + 1, oz + t, cr, cg, cb, cr, cg, cb);
              } else {
                _box(solid, ox, oy, oz, ox + t, oy + 1, oz + 1, cr, cg, cb, cr, cg, cb);
              }
              final kr = 0.85 * lf, kg = 0.75 * lf, kb = 0.35 * lf;
              if (sh == shapePanelZ) {
                _box(solid, ox + 0.78, oy + 0.45, oz - 0.04, ox + 0.9, oy + 0.57, oz + t + 0.04, kr, kg, kb, kr, kg, kb);
              } else {
                _box(solid, ox - 0.04, oy + 0.45, oz + 0.78, ox + t + 0.04, oy + 0.57, oz + 0.9, kr, kg, kb, kr, kg, kb);
              }
            }
            continue;
          }

          final isRail = sh >= shapeRailNs && sh <= shapeRailSlopeW;
          if ((sh >= shapeSlab && sh <= shapeStairsW) || sh == shapeWire || isRail) {
            // Stairs never cull against their own kind: a step's face may sit
            // against a neighbour's empty half.
            final cullSame = sh == shapeSlab || sh == shapeFence || isRail;
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
              if (sh == shapeRailNs) {
                tieZ(0.22, 0);
                tieZ(0.78, 0);
                barsZ(0, 1, 0);
              } else if (sh == shapeRailEw) {
                tieX(0.22, 0);
                tieX(0.78, 0);
                barsX(0, 1, 0);
              } else if (sh == shapeRailNe) {
                tieZ(0.22, 0);
                tieX(0.78, 0);
                barsZ(0, 0.5, 0);
                barsX(0.5, 1, 0);
              } else if (sh == shapeRailNw) {
                tieZ(0.22, 0);
                tieX(0.22, 0);
                barsZ(0, 0.5, 0);
                barsX(0, 0.5, 0);
              } else if (sh == shapeRailSe) {
                tieZ(0.78, 0);
                tieX(0.78, 0);
                barsZ(0.5, 1, 0);
                barsX(0.5, 1, 0);
              } else if (sh == shapeRailSw) {
                tieZ(0.78, 0);
                tieX(0.22, 0);
                barsZ(0.5, 1, 0);
                barsX(0, 0.5, 0);
              } else {
                // Four steps of a quarter block; step i spans the quarter
                // nearest the low side + i and sits i/4 higher.
                for (var i = 0; i < 4; i++) {
                  final lo = i * 0.25, hi = lo + 0.25, yo = i * 0.25;
                  if (sh == shapeRailSlopeE) {
                    tieX(lo + 0.125, yo);
                    barsX(lo, hi, yo);
                  } else if (sh == shapeRailSlopeW) {
                    tieX(1.0 - lo - 0.125, yo);
                    barsX(1.0 - hi, 1.0 - lo, yo);
                  } else if (sh == shapeRailSlopeS) {
                    tieZ(lo + 0.125, yo);
                    barsZ(lo, hi, yo);
                  } else {
                    tieZ(1.0 - lo - 0.125, yo);
                    barsZ(1.0 - hi, 1.0 - lo, yo);
                  }
                }
              }
            } else if (sh == shapeSlab) {
              _subBox(solid, x, y, z, id, cullSame, aos, 0, 0, 0, 1, 0.5, 1, br, bg, bb);
            } else if (sh == shapeWire) {
              // Stage 27: redstone wire, an eighth of a block lying on the floor.
              _subBox(solid, x, y, z, id, cullSame, aos, 0, 0, 0, 1, 0.125, 1, br, bg, bb);
            } else if (sh == shapeFence) {
              // Centre post, then two rails toward every horizontal neighbour
              // that is a fence or an opaque block. _at reads the padded
              // volume, so a neighbour across the chunk border connects too.
              const p0 = 0.375, p1 = 0.625, r0 = 0.4375, r1 = 0.5625;
              _subBox(solid, x, y, z, id, cullSame, aos, p0, 0, p0, p1, 1, p1, br, bg, bb);
              bool joins(int dx, int dz) {
                final n = _at(x + dx, y, z + dz);
                return n != _air && (_opaque[n] || shape[n] == shapeFence);
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
              if (sh == shapeStairsN) {
                slx = 0; sly = 0.5; slz = 0; shx = 1; shy = 1; shz = 0.5;
              } else if (sh == shapeStairsS) {
                slx = 0; sly = 0.5; slz = 0.5; shx = 1; shy = 1; shz = 1;
              } else if (sh == shapeStairsE) {
                slx = 0.5; sly = 0.5; slz = 0; shx = 1; shy = 1; shz = 1;
              } else {
                slx = 0; sly = 0.5; slz = 0; shx = 0.5; shy = 1; shz = 1;
              }
              _subBox(solid, x, y, z, id, cullSame, aos, slx, sly, slz, shx, shy, shz, br, bg, bb, skipMask: 1 << 1);
            }
            continue;
          }

          final isLiquid = sh == shapeLiquid;
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
              if (isLiquid && shape[n] == shapeLiquid) continue;
            }
            final tint = _faceTint[f] * _lightFactor(ax, ay, az);
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
              target.vertex(vx, vy, vz, oxf.toDouble(), oyf.toDouble(), ozf.toDouble(), br * t, bg * t, bb * t, ba);
            }
            target.quadIndices(first, flip);
          }
        }
      }
    }
    return ChunkMeshResult(solid.toSurface(), liquid.toSurface(), cutout.toSurface(), glow.toSurface());
  }
}
