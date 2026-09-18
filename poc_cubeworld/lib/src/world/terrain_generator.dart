import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_scene/noise.dart';

import 'package:voxel_core/voxel_core.dart';

/// Pure (seed, position) terrain: biomes from temperature/humidity/continental
/// noise, a height field with hills and ridged mountains, 3D caves, ores by
/// depth, lava in the deep, and decorations (trees, cacti, plants) that can
/// cross chunk borders. Runs on worker isolates; nothing here touches the scene.
class TerrainGenerator implements ChunkGenerator {
  TerrainGenerator({required this.ids, required int seed, this.playground = false}) {
    _stone = ids['stone']!;
    _dirt = ids['dirt']!;
    _grass = ids['grass']!;
    _sand = ids['sand']!;
    _water = ids['water']!;
    _oakLog = ids['oak_log']!;
    _oakLeaves = ids['oak_leaves']!;
    _gravel = ids['gravel']!;
    _sandstone = ids['sandstone']!;
    _snow = ids['snow']!;
    _spruceLog = ids['spruce_log']!;
    _spruceLeaves = ids['spruce_leaves']!;
    _cactus = ids['cactus']!;
    _coalOre = ids['coal_ore']!;
    _ironOre = ids['iron_ore']!;
    _goldOre = ids['gold_ore']!;
    _diamondOre = ids['diamond_ore']!;
    _bedrock = ids['bedrock']!;
    _tallGrass = ids['tall_grass']!;
    _flowerRed = ids['flower_red']!;
    _flowerYellow = ids['flower_yellow']!;
    _lava = ids['lava']!;
    _clay = ids['clay']!;
    _deadBush = ids['dead_bush']!;
    _mushroom = ids['mushroom']!;
    _ice = ids['ice']!;
    _darkStone = ids['dark_stone']!;
    _mossyBricks = ids['mossy_stone_bricks']!;
    _stoneBricks = ids['stone_bricks']!;
    _chest = ids['chest']!;
    _lamp = ids['lamp']!;
    _boneBlock = ids['bone_block']!;
    _planks = ids['oak_planks']!;
    _ladderId = ids['ladder']!;
    _spawnerId = ids['spawner']!;
    _glassId = ids['glass']!;
    _craftingTable = ids['crafting_table']!;
    _furnace = ids['furnace']!;
    _torch = ids['torch']!;
    _fence = ids['oak_fence']!;
    _tnt = ids['tnt']!;
    _cobblestone = ids['cobblestone']!;
    _pressurePlate = ids['pressure_plate']!;
    _mud = ids['mud']!;
    _reeds = ids['reeds']!;
    _jungleLog = ids['jungle_log']!;
    _vines = ids['vines']!;
    _fern = ids['fern']!;
    _melon = ids['melon']!;
    _bed = ids['bed']!;
    _farmland = ids['farmland']!;
    _wheat = ids['wheat_2']!;
    _slab = ids['oak_slab']!;
    _redstoneOre = ids['redstone_ore']!;
    _railEw = ids['rail_ew']!;
    _hellstone = ids['hellstone']!;
    _soulSand = ids['soul_sand']!;
    _glowstone = ids['glowstone']!;
    _quartzOre = ids['nether_quartz_ore']!;
    _netherBrick = ids['nether_brick']!;
    _fortressCore = ids['fortress_core']!;
    setSeed(seed);
  }

  static const int sizeX = ChunkSize.sizeX;
  static const int sizeZ = ChunkSize.sizeZ;
  static const int sizeY = ChunkSize.sizeY;
  static const int seaLevel = 46;
  static const int volume = ChunkSize.volume;

  static const int biomeOcean = 0,
      biomeBeach = 1,
      biomePlains = 2,
      biomeForest = 3,
      biomeDesert = 4,
      biomeSnow = 5,
      biomeMountain = 6,
      biomeSwamp = 7,
      biomeJungle = 8,
      biomeUnderworld = 9; // stage 29: the whole second dimension is one biome

  /// Stage 29: the dimension a chunk is generated for.
  static const int dimOverworld = 0, dimUnderworld = 1;
  int _dimension = dimOverworld;
  void setDimension(int d) => _dimension = d;
  int get dimension => _dimension;

  static const int structNone = 0, structDungeon = 1, structTower = 2, structCamp = 3, structVillage = 4;
  static const int structRuin = 5, structWell = 6, structMine = 7, structTemple = 8;

  /// Stage 33: a playground world flattens a plaza around the spawn: grass at
  /// [plazaFloor] (the feet level) over x/z in [plazaMin, plazaMax), no caves,
  /// trees or structures there, and the natural height eased back in over
  /// [plazaBlend] blocks outside it. The underworld is untouched.
  final bool playground;
  static const int plazaMin = -64, plazaMax = 80, plazaFloor = 64, plazaBlend = 16;

  /// Whether column ([x], [z]) is within [margin] blocks of the plaza.
  static bool inPlaza(int x, int z, [int margin = 0]) =>
      x >= plazaMin - margin && x < plazaMax + margin && z >= plazaMin - margin && z < plazaMax + margin;

  /// Blocks from column ([x], [z]) to the plaza's edge (0 inside).
  static int plazaDistance(int x, int z) {
    final dx = x < plazaMin ? plazaMin - x : (x >= plazaMax ? x - plazaMax + 1 : 0);
    final dz = z < plazaMin ? plazaMin - z : (z >= plazaMax ? z - plazaMax + 1 : 0);
    return math.max(dx, dz);
  }

  /// A structure a playground keeps out of the plaza (48 blocks clear, the
  /// size of the largest one).
  bool _structureAllowed(({int x, int y, int z, int type}) s) => !playground || !inPlaza(s.x, s.z, 48);

  static const int _air = 0;
  final Map<String, int> ids;
  late int _stone, _dirt, _grass, _sand, _water, _oakLog, _oakLeaves, _gravel, _sandstone, _snow,
      _spruceLog, _spruceLeaves, _cactus, _coalOre, _ironOre, _goldOre, _diamondOre, _bedrock,
      _tallGrass, _flowerRed, _flowerYellow, _lava, _clay, _deadBush, _mushroom, _ice, _darkStone,
      _mossyBricks, _stoneBricks, _chest, _lamp, _boneBlock, _planks, _ladderId, _spawnerId,
      _glassId, _craftingTable, _furnace, _torch, _fence, _tnt, _cobblestone, _pressurePlate,
      // Stage 26: the swamp's mud and reeds, the jungle's logs, vines, ferns and
      // melons, and what a village hut holds (bed, farmland + ripe wheat, the slab roof).
      _mud, _reeds, _jungleLog, _vines, _fern, _melon, _bed, _farmland, _wheat, _slab,
      // Stage 27: redstone ore, veined below y 30.
      _redstoneOre,
      // Stage 28: the rail down an abandoned mine's corridor.
      _railEw,
      // Stage 29: the underworld's blocks and the fortress bricks.
      _hellstone, _soulSand, _glowstone, _quartzOre, _netherBrick, _fortressCore;

  int _seed = 0;
  int get seed => _seed;
  late FastNoiseLite _continental, _hills, _mountainMask, _ridge, _temperature, _humidity, _cave, _cavern, _detail, _river, _hell, _hellPatch;

  static FastNoiseLite _make(int seed, double freq, int octaves, [FractalType fractal = FractalType.fbm]) =>
      FastNoiseLite(seed: seed)
        ..noiseType = NoiseType.openSimplex2S
        ..fractalType = fractal
        ..octaves = octaves
        ..frequency = freq;

  void setSeed(int seed) {
    _seed = seed;
    _continental = _make(seed, 0.0016, 3);
    _hills = _make(seed ^ 0x1234567, 0.0055, 3);
    _mountainMask = _make(seed ^ 0x2345678, 0.0028, 2);
    _ridge = _make(seed ^ 0x3456789, 0.014, 3, FractalType.ridged);
    _temperature = _make(seed ^ 0x456789A, 0.0020, 2);
    _humidity = _make(seed ^ 0x56789AB, 0.0024, 2);
    _cave = _make(seed ^ 0x6789ABC, 0.050, 2);
    _cavern = _make(seed ^ 0x789ABCD, 0.020, 2);
    _detail = _make(seed ^ 0x89ABCDE, 0.06, 1); // stage 26: the swamp pools
    _river = _make(seed ^ 0x9ABCDEF, 0.0030, 2);
    _hell = _make(seed ^ 0x0A1B2C3, 0.030, 2); // stage 29: the underworld's caverns
    _hellPatch = _make(seed ^ 0x0B2C3D4, 0.070, 1); // soul sand patches on its floors
  }

  static int index(int x, int y, int z) => ChunkSize.index(x, y, z);

  static double _smooth(double a, double b, double t) {
    t = ((t - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  int surfaceHeight(int x, int z) {
    if (!playground) return _naturalHeight(x, z);
    final d = plazaDistance(x, z);
    if (d == 0) return plazaFloor;
    if (d >= plazaBlend) return _naturalHeight(x, z);
    return _lerp(plazaFloor.toDouble(), _naturalHeight(x, z).toDouble(), _smooth(0, plazaBlend.toDouble(), d.toDouble())).round();
  }

  int _naturalHeight(int x, int z) {
    final xd = x.toDouble(), zd = z.toDouble();
    final cont = _continental.getNoise2(xd, zd);
    final land = _smooth(-0.35, 0.15, cont);
    var h = _lerp(24, 54, land);
    h += _hills.getNoise2(xd, zd) * (4.0 + 7.0 * land);
    final m = ((_mountainMask.getNoise2(xd, zd) - 0.25).clamp(0.0, double.infinity)) / 0.75 * land;
    if (m > 0) {
      final r = (_ridge.getNoise2(xd, zd) + 1.0) * 0.5;
      h += m * (18.0 + r * 48.0);
    }
    // Rivers: a narrow band where a low-frequency noise crosses zero, carved to just below sea level.
    final rv = _river.getNoise2(xd, zd).abs();
    if (rv < 0.045 && h > seaLevel - 3 && h < 80) {
      final t = rv / 0.045;
      final bed = seaLevel - 3 + t * t * 2.0;
      h = _lerp(bed, h, t * t * t);
    }
    // Stage 26: a swamp is low and flat. Where the climate says swamp and the land
    // sits just above the sea, the hills are pressed down to a plain two blocks
    // over sea level.
    if (h >= seaLevel + 1 && h < seaLevel + 9 && _isSwampClimate(x, z)) {
      h = seaLevel + 2 + (h - seaLevel - 2) * 0.3;
    }
    return h.toInt().clamp(6, sizeY - 6);
  }

  bool _isSwampClimate(int x, int z) {
    final t = _temperature.getNoise2(x.toDouble(), z.toDouble());
    final hum = _humidity.getNoise2(x.toDouble(), z.toDouble());
    return hum > 0.42 && t > 0.1 && !(t > 0.30 && hum < 0.05);
  }

  /// A swamp column whose surface block is a one-deep pool (water over mud).
  bool _swampPool(int wx, int wz, int h, int biome) =>
      biome == biomeSwamp && h > seaLevel && _detail.getNoise2(wx * 1.5, wz * 1.5) > 0.28;

  int biomeAt(int x, int z) => _dimension == dimUnderworld ? biomeUnderworld : _biomeFor(x, z, surfaceHeight(x, z));

  int _biomeFor(int x, int z, int h) {
    if (playground && inPlaza(x, z)) return biomePlains; // stage 33: the plaza is grass
    if (h < seaLevel - 2) return biomeOcean;
    final t = _temperature.getNoise2(x.toDouble(), z.toDouble()) - ((h - 72).clamp(0, 1 << 30)) / 50.0;
    final hum = _humidity.getNoise2(x.toDouble(), z.toDouble());
    if (h > 86) return biomeMountain;
    if (h <= seaLevel + 1) return t < -0.4 ? biomeSnow : biomeBeach;
    if (t < -0.35) return biomeSnow;
    if (t > 0.30 && hum < 0.05) return biomeDesert;
    if (hum > 0.42 && t > 0.1 && h < seaLevel + 6) return biomeSwamp;
    if (t > 0.22 && hum > 0.28) return biomeJungle; // stage 26: hot and wet
    if (hum > 0.22) return biomeForest;
    return biomePlains;
  }

  static int _u32(int v) => v & 0xFFFFFFFF;

  int hash(int x, int y, int z) {
    var h = _u32(x * 73856093) ^ _u32(y * 19349663) ^ _u32(z * 83492791) ^ _u32(_u32(_seed) * 2654435761);
    h = _u32(h);
    h ^= h >> 13;
    h = _u32(h * 0x5bd1e995);
    h ^= h >> 15;
    return h;
  }

  /// The chunk of the generator's current dimension ([setDimension]).
  Uint8List generate(int chunkX, int chunkZ) => generateIn(chunkX, chunkZ, _dimension);

  /// Stage 29: the chunk of an explicit dimension. The worker binds the
  /// dimension at dispatch, so a job started before a switch still writes what
  /// it was asked for.
  @override
  Uint8List generateIn(int chunkX, int chunkZ, int dimension) {
    if (dimension == dimUnderworld) return _generateUnderworld(chunkX, chunkZ);
    final blocks = Uint8List(volume);
    final ox = chunkX * sizeX, oz = chunkZ * sizeZ;
    for (var z = 0; z < sizeZ; z++) {
      for (var x = 0; x < sizeX; x++) {
        final wx = ox + x, wz = oz + z;
        final h = surfaceHeight(wx, wz);
        final biome = _biomeFor(wx, wz, h);
        for (var y = 0; y < sizeY; y++) {
          var id = _air;
          if (y == 0) {
            id = _bedrock;
          } else if (y < h - 4) {
            id = y < 22 ? _darkStone : _stone;
          } else if (y < h - 1) {
            id = biome == biomeDesert || biome == biomeBeach ? _sandstone : (biome == biomeMountain ? _stone : _dirt);
            if (y == h - 2 && biome == biomeSwamp && _swampPool(wx, wz, h, biome)) id = _mud; // the pool's bed
          } else if (y == h - 1) {
            switch (biome) {
              case biomeOcean:
                id = hash(wx, 0, wz) % 5 == 0 ? _gravel : (hash(wx, 1, wz) % 7 == 0 ? _clay : _sand);
              case biomeBeach:
              case biomeDesert:
                id = _sand;
              case biomeSnow:
                id = _snow;
              case biomeMountain:
                id = h > 100 ? _snow : (hash(wx, 2, wz) % 4 == 0 ? _gravel : _stone);
              case biomeSwamp:
                if (_swampPool(wx, wz, h, biome)) {
                  id = _water;
                } else {
                  id = hash(wx >> 1, 3, wz >> 1) % 5 < 2 ? _mud : (hash(wx, 3, wz) % 7 == 0 ? _clay : _grass);
                }
              default:
                id = _grass;
            }
          } else if (y <= seaLevel) {
            id = (biome == biomeSnow && y == seaLevel) ? _ice : _water;
          }

          // Ores replace stone: a 2x2x2 cell decides a vein, a block hash thins it.
          if (id == _stone || id == _darkStone) {
            final cell = hash(wx >> 1, y >> 1, wz >> 1);
            final fine = hash(wx, y, wz);
            if (fine % 100 < 55) {
              final r = cell % 10000;
              if (y < 14 && r < 60) {
                id = _diamondOre;
              } else if (y < 32 && r < 200) {
                id = _goldOre;
              } else if (y < 64 && r < 520) {
                id = _ironOre;
              } else if (y < 30 && r < 710) {
                id = _redstoneOre; // stage 27: about a third of coal's share, deep only
              } else if (r < 1100) {
                id = _coalOre;
              }
            }
          }

          // Caves: cheese caves everywhere in rock, caverns deeper, sealed near
          // the surface unless an entrance noise opens it.
          if (id != _air && id != _bedrock && id != _water && id != _ice && y > 1 && !(playground && inPlaza(wx, wz, 2))) {
            final c = _cave.getNoise3(wx.toDouble(), y * 1.5, wz.toDouble());
            final depth = h - y;
            var open = false;
            if (c > 0.44 && depth > 3) open = true;
            if (y < 40 && _cavern.getNoise3(wx.toDouble(), y * 2.0, wz.toDouble()) > 0.55 && depth > 6) open = true;
            if (c > 0.60 && depth <= 3 && h > seaLevel + 2) open = true; // entrance
            if (open) id = y <= 10 ? _lava : _air;
          }

          if (id != _air) blocks[index(x, y, z)] = id;
        }
      }
    }
    _decorate(blocks, ox, oz, structuresNearIn(chunkX, chunkZ, dimOverworld));
    _buildStructures(blocks, chunkX, chunkZ);
    return blocks;
  }

  /// How far outside a chunk a tree may stand and still drop a leaf inside it:
  /// the widest crown (5) plus the far side of a 2x2 trunk (1).
  static const int _reach = 6;

  /// Stage 41: the tree grid. The world is cut into [_treePatch] squares and at
  /// most one tree grows in each, never closer than [_treeInset] to the patch
  /// border — so two trunks always stand `2 * _treeInset + 1` blocks apart.
  /// Trees used to be rolled per column, which let two of them touch and made a
  /// forest a wall; the patch is what puts a path between the trunks.
  static const int _treePatch = 7, _treeInset = 2;

  /// How many patches of a biome carry a tree, in per cent. Roughly a quarter
  /// of the old per-column rate, which is what doubles the gap between trunks.
  /// The beach is the exception: stage 42 keeps every tree out of the water, and
  /// the only dry beach column is the one row right on the waterline, so its
  /// share is raised to keep the palms it used to grow standing in the sea.
  static int treeChance(int biome) => switch (biome) {
        biomeForest => 92,
        biomeJungle => 47,
        biomeSnow => 37,
        biomeSwamp => 27,
        biomePlains => 20,
        biomeMountain => 20,
        biomeBeach => 30,
        biomeDesert => 8,
        _ => 0,
      };

  /// The column of the patch holding ([wx], [wz]) where its tree may grow, and
  /// the patch's hash. Pure position, so every chunk agrees on it; public so a
  /// test can walk the grid without generating a world.
  ({int x, int z, int hash}) treePatchOf(int wx, int wz) {
    const span = _treePatch - 2 * _treeInset;
    final px = _floorDiv(wx, _treePatch), pz = _floorDiv(wz, _treePatch);
    final h = hash(px, 91, pz);
    return (
      x: px * _treePatch + _treeInset + (h >> 8) % span,
      z: pz * _treePatch + _treeInset + (h >> 16) % span,
      hash: h,
    );
  }

  /// The eight directions a limb or a frond can take.
  static const List<(int, int)> _compass = [
    (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), //
  ];

  /// Trees, cacti and plants. The small stuff belongs to this chunk's own
  /// columns; a tree is looked for over every column that can REACH this chunk,
  /// so a crown crossing a border arrives whole.
  void _decorate(Uint8List blocks, int ox, int oz, List<({int x, int y, int z, int type})> near) {
    for (var z = -_reach; z < sizeZ + _reach; z++) {
      for (var x = -_reach; x < sizeX + _reach; x++) {
        final inside = x >= 0 && x < sizeX && z >= 0 && z < sizeZ;
        final wx = ox + x, wz = oz + z;
        // The patch is a hash and the height is noise, so the cheap question
        // goes first: a column outside the chunk matters only for its tree.
        final patch = treePatchOf(wx, wz);
        final tree = patch.x == wx && patch.z == wz;
        if (!inside && !tree) continue;
        if (playground && inPlaza(wx, wz, 8)) continue; // stage 33: nothing leans into the plaza
        final h = surfaceHeight(wx, wz);
        final biome = _biomeFor(wx, wz, h);
        final pool = biome == biomeSwamp && _swampPool(wx, wz, h, biome);
        if (tree && patch.hash % 100 < treeChance(biome) && !pool && _treeGround(wx, wz, h) && !_underStructure(near, wx, wz)) {
          _growTree(blocks, ox, oz, wx, h, wz, biome, patch.hash);
        }
        if (!inside || pool) continue; // nothing grows in a pool
        if (blocks[index(x, h - 1, z)] == _air) continue;
        _plantSmall(blocks, x, h, z, wx, wz, biome, hash(wx, 7, wz));
      }
    }
  }

  /// Stage 42: where a tree is allowed to put its foot. Dry land standing clear
  /// of the sea, with no cave mouth eating the very block it would stand on.
  /// The answer comes from the position alone — the chunk being filled has no
  /// say in it — so the two chunks a crown straddles always agree on whether
  /// the tree is there at all. While only the owning chunk could refuse, the
  /// other one still wrote its half of the crown, and that half hung in the
  /// air with no trunk anywhere under it.
  bool _treeGround(int wx, int wz, int h) {
    if (h <= seaLevel) return false; // a trunk standing in water is a tree floating on it
    return !_carved(wx, h - 1, wz, h);
  }

  /// The cave test of [generateIn] asked about one block: true where the rock at
  /// ([wx], [wy], [wz]) is carved away. Positional like everything else here, so
  /// a tree and a builder can both ask it about a column that is not theirs.
  bool _carved(int wx, int wy, int wz, int h) {
    if (playground && inPlaza(wx, wz, 2)) return false;
    final depth = h - wy;
    final c = _cave.getNoise3(wx.toDouble(), wy * 1.5, wz.toDouble());
    if (c > 0.44 && depth > 3) return true;
    if (wy < 40 && depth > 6 && _cavern.getNoise3(wx.toDouble(), wy * 2.0, wz.toDouble()) > 0.55) return true;
    return c > 0.60 && depth <= 3 && h > seaLevel + 2;
  }

  /// Stage 42: how far around a structure no tree may root — what it writes
  /// inside of, widened by [_reach], the farthest any part of a tree ever stands
  /// from its own trunk. A builder runs after the trees and writes over whatever
  /// it lands on; when that was a trunk, everything above the cut stayed behind,
  /// hanging over the roof with nothing under it. Keeping the trees out is also
  /// what makes a village a clearing, with never a tree felled to get one.
  static int _structureClearance(int type) {
    final footprint = switch (type) {
      structVillage => _villageClearRadius,
      structCamp => 8,
      structRuin => 6,
      structTemple => 6,
      structTower => 4,
      structWell => 3,
      structMine => 3,
      _ => 0, // the dungeon is dug under the trees, never through them
    };
    return footprint == 0 ? 0 : footprint + _reach;
  }

  bool _underStructure(List<({int x, int y, int z, int type})> near, int wx, int wz) {
    for (final s in near) {
      final r = _structureClearance(s.type);
      if (r == 0) continue;
      final dx = s.x - wx, dz = s.z - wz;
      if (dx * dx + dz * dz <= r * r) return true;
    }
    return false;
  }

  // --- the tree canvas ----------------------------------------------------------
  // Stage 42: a tree is drawn here first and only then printed into the world.
  // [_blitTree] walks the six faces outward from the stump and keeps just what
  // the walk reaches, so a frayed leaf with nothing under it, a vine hanging off
  // the air and a branch touching the trunk by a corner alone all fall away
  // before anyone can see them float. The canvas is in world coordinates, which
  // is the other half of the fix: every hash a shape rolls is now the same hash
  // in both chunks that share the tree.

  static const int _canvasR = 8, _canvasW = _canvasR * 2 + 1, _canvasH = 40;
  static const int _canvasLayer = _canvasW * _canvasW;
  final Uint8List _canvas = Uint8List(_canvasLayer * _canvasH);
  final Uint8List _kept = Uint8List(_canvasLayer * _canvasH);
  final List<int> _painted = <int>[];
  final List<int> _walk = <int>[];

  /// The surface height under each column of the canvas, sampled at most once
  /// per tree — [_colStamp] holds the serial number of the tree that filled it.
  final Int32List _colHeight = Int32List(_canvasLayer);
  final Int32List _colStamp = Int32List(_canvasLayer);
  int _treeSerial = 0;

  /// The world column and ground height the canvas is centred on.
  int _treeX = 0, _treeY = 0, _treeZ = 0;

  /// Leaves and vines: what a log may be drawn over, and what may never be
  /// drawn over anything.
  bool _isSoft(int id) => id == _oakLeaves || id == _spruceLeaves || id == _vines;

  /// Paints one block of the tree being drawn, in world coordinates.
  void _ink(int x, int y, int z, int id) {
    final dx = x - _treeX, dy = y - _treeY, dz = z - _treeZ;
    if (dx < -_canvasR || dx > _canvasR || dz < -_canvasR || dz > _canvasR) return;
    if (dy < 0 || dy >= _canvasH) return;
    final i = (dy * _canvasW + dz + _canvasR) * _canvasW + dx + _canvasR;
    final cur = _canvas[i];
    if (cur == 0) {
      _painted.add(i);
    } else if (_isSoft(id) || !_isSoft(cur)) {
      return; // only a log is drawn over a leaf, and nothing over a log
    }
    _canvas[i] = id;
  }

  /// What the canvas holds at a world position, 0 for nothing.
  int _inked(int x, int y, int z) {
    final dx = x - _treeX, dy = y - _treeY, dz = z - _treeZ;
    if (dx < -_canvasR || dx > _canvasR || dz < -_canvasR || dz > _canvasR) return 0;
    if (dy < 0 || dy >= _canvasH) return 0;
    return _canvas[(dy * _canvasW + dz + _canvasR) * _canvasW + dx + _canvasR];
  }

  /// Draws the biome's tree on the canvas and prints the part of it that holds
  /// together onto this chunk.
  void _growTree(Uint8List b, int ox, int oz, int wx, int y, int wz, int biome, int hsh) {
    _treeX = wx;
    _treeY = y;
    _treeZ = wz;
    _treeSerial++;
    _plantTree(wx, y, wz, biome, hsh);
    _blitTree(b, ox, oz);
  }

  /// True where the world will not take the tree's block: inside the ground or
  /// under the water. Positional like [_treeGround], never read from the chunk.
  bool _blockedAt(int i) {
    final dy = i ~/ _canvasLayer, col = i % _canvasLayer;
    final wy = _treeY + dy;
    if (wy <= seaLevel) return true;
    if (_colStamp[col] != _treeSerial) {
      _colStamp[col] = _treeSerial;
      _colHeight[col] = surfaceHeight(_treeX + col % _canvasW - _canvasR, _treeZ + col ~/ _canvasW - _canvasR);
    }
    return wy < _colHeight[col];
  }

  /// Walks one face out of a kept block.
  void _stepTo(int i, bool inside) {
    if (!inside || _canvas[i] == 0 || _kept[i] != 0 || _blockedAt(i)) return;
    _kept[i] = 1;
    _walk.add(i);
  }

  /// The flood fill from the stump, then the print, then the wipe.
  void _blitTree(Uint8List b, int ox, int oz) {
    _walk.clear();
    for (final i in _painted) {
      if (i < _canvasLayer) _stepTo(i, true); // the blocks standing on the ground
    }
    for (var q = 0; q < _walk.length; q++) {
      final i = _walk[q];
      final dy = i ~/ _canvasLayer, rest = i % _canvasLayer;
      final dz = rest ~/ _canvasW, dx = rest % _canvasW;
      _stepTo(i - 1, dx > 0);
      _stepTo(i + 1, dx < _canvasW - 1);
      _stepTo(i - _canvasW, dz > 0);
      _stepTo(i + _canvasW, dz < _canvasW - 1);
      _stepTo(i - _canvasLayer, dy > 0);
      _stepTo(i + _canvasLayer, dy < _canvasH - 1);
    }
    for (final i in _painted) {
      if (_kept[i] != 0) {
        final dy = i ~/ _canvasLayer, rest = i % _canvasLayer;
        final dz = rest ~/ _canvasW, dx = rest % _canvasW;
        _setIfInside(b, _treeX + dx - _canvasR - ox, _treeY + dy, _treeZ + dz - _canvasR - oz, _canvas[i]);
      }
      _canvas[i] = 0;
      _kept[i] = 0;
    }
    _painted.clear();
  }

  /// The tree this biome grows, planted on the canvas with its patch's [hsh].
  void _plantTree(int x, int y, int z, int biome, int hsh) {
    final tall = (hsh >> 12) % 5;
    switch (biome) {
      case biomeForest:
        if ((hsh >> 20) % 100 < 30) {
          _placeBigOak(x, y, z, 14 + tall, hsh);
        } else {
          _placeOak(x, y, z, 9 + tall % 4, hsh);
        }
      case biomePlains:
        _placeOak(x, y, z, 9 + tall % 4, hsh);
      case biomeSwamp:
        _placeWillow(x, y, z, 9 + tall % 3, hsh);
      case biomeJungle:
        _placeJungleTree(x, y, z, 16 + tall + (hsh >> 18) % 3, hsh);
      case biomeSnow:
        _placeSpruce(x, y, z, 12 + tall);
      case biomeMountain:
        if (y < 96) _placeSpruce(x, y, z, 11 + tall);
      case biomeDesert || biomeBeach:
        _placePalm(x, y, z, 8 + tall, hsh);
    }
  }

  /// Grass, flowers, mushrooms, reeds, cacti and melons: one roll per column.
  void _plantSmall(Uint8List b, int x, int y, int z, int wx, int wz, int biome, int hsh) {
    final roll = hsh % 1000;
    switch (biome) {
      case biomeForest:
        if (roll < 185) {
          _setIfInside(b, x, y, z, _tallGrass);
        } else if (roll < 210) {
          _setIfInside(b, x, y, z, _mushroom);
        } else if (roll < 230) {
          _setIfInside(b, x, y, z, _flowerRed);
        }
      case biomePlains:
        if (roll < 144) {
          _setIfInside(b, x, y, z, _tallGrass);
        } else if (roll < 166) {
          _setIfInside(b, x, y, z, _flowerYellow);
        } else if (roll < 184) {
          _setIfInside(b, x, y, z, _flowerRed);
        }
      case biomeSwamp:
        // Godot tests PoolEdge first; the roll goes first here (same result,
        // four fewer height samples on most columns).
        if (roll < 550 && _poolEdge(wx, wz)) {
          _setIfInside(b, x, y, z, _reeds);
        } else if (roll < 278) {
          _setIfInside(b, x, y, z, _tallGrass);
        } else if (roll < 318) {
          _setIfInside(b, x, y, z, _mushroom);
        }
      case biomeJungle:
        if (roll < 292) {
          _setIfInside(b, x, y, z, _fern);
        } else if (roll < 382) {
          _setIfInside(b, x, y, z, _tallGrass);
        } else if (roll < 394) {
          _placeMelons(b, x, y, z, hsh);
        }
      case biomeDesert:
        if (roll < 12) {
          final ch = 2 + ((hsh >> 10) % 2);
          for (var i = 0; i < ch; i++) {
            _setIfInside(b, x, y + i, z, _cactus);
          }
        } else if (roll < 40) {
          _setIfInside(b, x, y, z, _deadBush);
        }
    }
  }

  /// A rounded crown: a ball of leaves [r] wide, squashed in y and frayed at the
  /// rim so no two look stamped from the same mould. Its centre block is always
  /// laid, which is what hangs the ball on the trunk it is drawn around.
  void _crown(int x, int y, int z, int r, int leaves) {
    final rim = r * r + r;
    for (var dy = -r; dy <= r; dy++) {
      for (var dz = -r; dz <= r; dz++) {
        for (var dx = -r; dx <= r; dx++) {
          final d2 = dx * dx + dz * dz + dy * dy * 2;
          if (d2 > rim) continue;
          if (d2 > rim - r && hash(x + dx, y + dy, z + dz) % 4 == 0) continue;
          _ink(x + dx, y + dy, z + dz, leaves);
        }
      }
    }
  }

  /// A limb: [len] steps out along ([dx], [dz]), rising every other one, with a
  /// small crown on its end. A diagonal step is taken one axis at a time and
  /// leaves its corner block behind, because two logs that meet at an edge hold
  /// nothing — every block of this world joins its neighbour by a face.
  void _limb(int x, int y, int z, int dx, int dz, int len, int log, int leaves) {
    var lx = x, ly = y, lz = z;
    for (var i = 0; i < len; i++) {
      if (dx != 0) {
        lx += dx;
        _ink(lx, ly, lz, log);
      }
      if (dz != 0) {
        lz += dz;
        _ink(lx, ly, lz, log);
      }
      if (i.isOdd) {
        ly++;
        _ink(lx, ly, lz, log);
      }
    }
    _crown(lx, ly + 1, lz, 2, leaves);
  }

  /// Stage 41, the oak: a bare trunk 9-12 blocks tall, two limbs near the top
  /// and a rounded crown over them. Nothing of it hangs at head height, so a
  /// forest is walked through instead of squeezed past.
  void _placeOak(int x, int y, int z, int trunk, int hsh) {
    final top = y + trunk;
    for (var i = 0; i < 2; i++) {
      final dir = _compass[((hsh >> (4 + i * 3)) + i * 3) % 8];
      _limb(x, top - 3 + i, z, dir.$1, dir.$2, 2, _oakLog, _oakLeaves);
    }
    _crown(x, top - 1, z, 3, _oakLeaves);
    for (var i = 0; i <= trunk; i++) {
      _ink(x, y + i, z, _oakLog);
    }
  }

  /// Stage 41, the forest giant: a 2x2 trunk 14-18 blocks tall, four limbs and
  /// a crown five blocks wide riding over the canopy of its neighbours.
  void _placeBigOak(int x, int y, int z, int trunk, int hsh) {
    final top = y + trunk;
    _crown(x, top, z, 5, _oakLeaves);
    _crown(x + 1, top - 2, z + 1, 4, _oakLeaves);
    for (var i = 0; i < 4; i++) {
      final dir = _compass[(i * 2 + (hsh >> 6) % 2) % 8];
      final bx = x + (dir.$1 > 0 ? 1 : 0), bz = z + (dir.$2 > 0 ? 1 : 0);
      _limb(bx, top - 5 + i % 2, bz, dir.$1, dir.$2, 3, _oakLog, _oakLeaves);
    }
    for (var i = 0; i <= trunk; i++) {
      for (var dz = 0; dz <= 1; dz++) {
        for (var dx = 0; dx <= 1; dx++) {
          _ink(x + dx, y + i, z + dz, _oakLog);
        }
      }
    }
  }

  /// Stage 41, the spruce: a tall bare trunk under tiers that widen downward,
  /// the lowest of them well over a walker's head.
  void _placeSpruce(int x, int y, int z, int trunk) {
    final bare = math.max(5, trunk ~/ 3);
    for (var dy = bare; dy <= trunk; dy++) {
      final fromTop = trunk - dy;
      var r = math.min(4, 1 + fromTop ~/ 4);
      if (fromTop % 3 == 2) r -= 1; // the skirts pinch in between the tiers
      for (var dz = -r; dz <= r; dz++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx * dx + dz * dz > r * r + 1) continue;
          _ink(x + dx, y + dy, z + dz, _spruceLeaves);
        }
      }
    }
    _ink(x, y + trunk + 1, z, _spruceLeaves);
    for (var i = 0; i < trunk; i++) {
      _ink(x, y + i, z, _spruceLog);
    }
  }

  /// A swamp column beside a pool (any of the four neighbours is one).
  bool _poolEdge(int wx, int wz) {
    for (var i = 0; i < 4; i++) {
      final nx = wx + (i == 0 ? 1 : (i == 1 ? -1 : 0));
      final nz = wz + (i == 2 ? 1 : (i == 3 ? -1 : 0));
      final nh = surfaceHeight(nx, nz);
      if (_swampPool(nx, nz, nh, _biomeFor(nx, nz, nh))) return true;
    }
    return false;
  }

  /// Stage 41, the swamp willow: a trunk 9-11 tall under a wide flat canopy
  /// whose rim droops in hanging leaf columns.
  void _placeWillow(int x, int y, int z, int trunk, int hsh) {
    final top = y + trunk;
    for (var layer = 0; layer < 2; layer++) {
      final ly = top - layer;
      for (var dz = -4; dz <= 4; dz++) {
        for (var dx = -4; dx <= 4; dx++) {
          if (dx * dx + dz * dz > (layer == 0 ? 12 : 18)) continue;
          _ink(x + dx, ly, z + dz, _oakLeaves);
        }
      }
    }
    for (var dz = -4; dz <= 4; dz++) {
      for (var dx = -4; dx <= 4; dx++) {
        final d2 = dx * dx + dz * dz;
        if (d2 < 10 || d2 > 18 || hash(x + dx, 5, z + dz) % 3 == 0) continue;
        for (var i = 1; i <= 2 + (hash(x + dx, 6, z + dz) % 3); i++) {
          _ink(x + dx, top - 1 - i, z + dz, _oakLeaves);
        }
      }
    }
    final dir = _compass[(hsh >> 7) % 8];
    _limb(x, top - 3, z, dir.$1, dir.$2, 2, _oakLog, _oakLeaves);
    for (var i = 0; i <= trunk; i++) {
      _ink(x, y + i, z, _oakLog);
    }
  }

  /// Stage 41, the jungle giant: a 2x2 trunk 16-24 blocks tall, a crown at the
  /// top, a second one halfway up and vines falling from both rims.
  void _placeJungleTree(int x, int y, int z, int trunk, int hsh) {
    final top = y + trunk;
    _crown(x, top, z, 4, _oakLeaves);
    _crown(x + 1, top - 6, z + 1, 3, _oakLeaves);
    for (var i = 0; i < 2; i++) {
      final dir = _compass[((hsh >> (5 + i * 4)) + i * 4) % 8];
      final bx = x + (dir.$1 > 0 ? 1 : 0), bz = z + (dir.$2 > 0 ? 1 : 0);
      _limb(bx, top - 7, bz, dir.$1, dir.$2, 2, _jungleLog, _oakLeaves);
    }
    _vineFall(x, top - 2, z, 4, hsh);
    _vineFall(x + 1, top - 7, z + 1, 3, hsh ^ 0x5f5f);
    for (var i = 0; i <= trunk; i++) {
      for (var dz = 0; dz <= 1; dz++) {
        for (var dx = 0; dx <= 1; dx++) {
          _ink(x + dx, y + i, z + dz, _jungleLog);
        }
      }
    }
  }

  /// Vines falling 2-6 blocks from the rim of a crown [r] wide. Stage 42: a
  /// vine only hangs where the canvas already holds a leaf to hang it on.
  void _vineFall(int x, int y, int z, int r, int hsh) {
    for (var dz = -r; dz <= r; dz++) {
      for (var dx = -r; dx <= r; dx++) {
        final d2 = dx * dx + dz * dz;
        if (d2 < (r - 1) * (r - 1) || d2 > r * r + 1) continue;
        if (_inked(x + dx, y, z + dz) == 0) continue;
        final vh = hash(x + dx, 8, z + dz) ^ hsh;
        if (vh % 5 < 2) continue;
        for (var i = 1; i <= 2 + ((vh >> 4) % 5); i++) {
          _ink(x + dx, y - i, z + dz, _vines);
        }
      }
    }
  }

  /// Stage 41, the palm of the beaches and the oases: a bare leaning trunk
  /// under a star of fronds, the one tree the desert and the sand ever grow.
  /// Stage 42: the lean steps one axis at a time, so the trunk climbs by faces
  /// and never hangs off the corner of the log below it.
  void _placePalm(int x, int y, int z, int trunk, int hsh) {
    final lean = _compass[(hsh >> 9) % 8];
    var tx = x, tz = z;
    for (var i = 0; i <= trunk; i++) {
      if (i > 4 && i % 5 == 0) {
        if (lean.$1 != 0) {
          tx += lean.$1;
          _ink(tx, y + i - 1, tz, _jungleLog);
        }
        if (lean.$2 != 0) {
          tz += lean.$2;
          _ink(tx, y + i - 1, tz, _jungleLog);
        }
      }
      _ink(tx, y + i, tz, _jungleLog);
    }
    final top = y + trunk;
    _ink(tx, top + 1, tz, _oakLeaves);
    for (var d = 0; d < 8; d++) {
      final dir = _compass[d];
      _frond(tx, top + 1, tz, dir.$1, dir.$2, 2 + ((hsh >> (d * 2)) % 2));
    }
  }

  /// One frond of a palm: leaves stepping out a face at a time from the crown's
  /// heart, drooping by one block at the tip.
  void _frond(int x, int y, int z, int dx, int dz, int len) {
    var fx = x, fy = y, fz = z;
    for (var i = 1; i <= len; i++) {
      if (dx != 0) {
        fx += dx;
        _ink(fx, fy, fz, _oakLeaves);
      }
      if (dz != 0) {
        fz += dz;
        _ink(fx, fy, fz, _oakLeaves);
      }
      if (i == len) {
        fy -= 1;
        _ink(fx, fy, fz, _oakLeaves);
      }
    }
  }

  /// A melon patch: the block itself and up to two neighbours on the ground.
  void _placeMelons(Uint8List b, int x, int y, int z, int hsh) {
    _setIfInside(b, x, y, z, _melon);
    if ((hsh >> 14) % 2 == 0) _setIfInside(b, x + 1, y, z, _melon);
    if ((hsh >> 15) % 2 == 0) _setIfInside(b, x, y, z + 1, _melon);
  }

  void _setIfInside(Uint8List b, int x, int y, int z, int id) {
    if (x < 0 || x >= sizeX || z < 0 || z >= sizeZ || y < 0 || y >= sizeY) return;
    final i = index(x, y, z);
    if (b[i] == _air || id == 0) {
      b[i] = id;
    } else if (id != 0 && b[i] != 0 && _isSoft(b[i])) {
      b[i] = id; // trunks overwrite canopy
    }
  }

  // --- structures ---------------------------------------------------------------
  // One candidate per 6x6-chunk region, decided by hash so every chunk agrees. A
  // chunk writes only the blocks of the structure that fall inside it.
  static const int _regionChunks = 6;

  static int _floorDiv(int a, int b) => (a / b).floor();

  /// (x, y, z, type) of the structure whose region contains this chunk, or null.
  ({int x, int y, int z, int type})? _regionStructure(int regionX, int regionZ) {
    final h = hash(regionX * 7919, 11, regionZ * 104729);
    final sx = regionX * _regionChunks * sizeX + (h % (_regionChunks * sizeX - 24)) + 12;
    final sz = regionZ * _regionChunks * sizeZ + ((h >> 8) % (_regionChunks * sizeZ - 24)) + 12;
    final roll = (h >> 16) % 100;
    final surface = surfaceHeight(sx, sz);
    final biome = _biomeFor(sx, sz, surface);
    if (biome == biomeOcean) return null;
    if (roll < 45) {
      final sy = (surface - 14 - ((h >> 24) % 14)).clamp(14, surface - 10);
      return (x: sx, y: sy, z: sz, type: structDungeon);
    } else if (roll < 75) {
      return (x: sx, y: surface, z: sz, type: structTower);
    } else if (roll < 82) {
      return (x: sx, y: surface, z: sz, type: structCamp);
    } else if (biome == biomePlains || biome == biomeForest) {
      return (x: sx, y: surface, z: sz, type: structVillage);
    }
    return null;
  }

  /// Structures whose region touches the chunk: records of (x, y, z, type).
  List<({int x, int y, int z, int type})> structuresNear(int chunkX, int chunkZ) => structuresNearIn(chunkX, chunkZ, _dimension);

  List<({int x, int y, int z, int type})> structuresNearIn(int chunkX, int chunkZ, int dimension) {
    final list = <({int x, int y, int z, int type})>[];
    if (dimension == dimUnderworld) {
      final fx = _floorDiv(chunkX, _fortressRegionChunks), fz = _floorDiv(chunkZ, _fortressRegionChunks);
      for (var dz = -1; dz <= 1; dz++) {
        for (var dx = -1; dx <= 1; dx++) {
          final f = _fortressAt(fx + dx, fz + dz);
          if (f != null) list.add(f);
        }
      }
      return list;
    }
    final rx = _floorDiv(chunkX, _regionChunks), rz = _floorDiv(chunkZ, _regionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _regionStructure(rx + dx, rz + dz);
        if (s != null && _structureAllowed(s)) list.add(s);
      }
    }
    final mx = _floorDiv(chunkX, _minorRegionChunks), mz = _floorDiv(chunkZ, _minorRegionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _minorStructure(mx + dx, mz + dz);
        if (s != null && _structureAllowed(s)) list.add(s);
      }
    }
    return list;
  }

  void _buildStructures(Uint8List blocks, int chunkX, int chunkZ) {
    final ox = chunkX * sizeX, oz = chunkZ * sizeZ;
    final rx = _floorDiv(chunkX, _regionChunks), rz = _floorDiv(chunkZ, _regionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _regionStructure(rx + dx, rz + dz);
        if (s == null || !_structureAllowed(s)) continue;
        switch (s.type) {
          case structDungeon:
            _dungeon(blocks, ox, oz, s.x, s.y, s.z);
          case structTower:
            _tower(blocks, ox, oz, s.x, s.y, s.z);
          case structCamp:
            _camp(blocks, ox, oz, s.x, s.y, s.z);
          case structVillage:
            _village(blocks, ox, oz, s.x, s.y, s.z);
        }
      }
    }
    final mx = _floorDiv(chunkX, _minorRegionChunks), mz = _floorDiv(chunkZ, _minorRegionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _minorStructure(mx + dx, mz + dz);
        if (s == null || !_structureAllowed(s)) continue;
        switch (s.type) {
          case structRuin:
            _ruins(blocks, ox, oz, s.x, s.y, s.z);
          case structWell:
            _well(blocks, ox, oz, s.x, s.y, s.z);
          case structMine:
            _mine(blocks, ox, oz, s.x, s.y, s.z);
          case structTemple:
            _temple(blocks, ox, oz, s.x, s.y, s.z);
        }
      }
    }
  }

  void _put(Uint8List b, int ox, int oz, int wx, int wy, int wz, int id) {
    final x = wx - ox, z = wz - oz;
    if (x < 0 || x >= sizeX || z < 0 || z >= sizeZ || wy < 1 || wy >= sizeY) return;
    b[index(x, wy, z)] = id;
  }

  void _dungeon(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    // Three rooms in a row joined by corridors; boss room at the end with the chest.
    for (var room = 0; room < 3; room++) {
      final rcx = cx + room * 12, rcz = cz;
      final half = room == 2 ? 6 : 4;
      final hgt = room == 2 ? 6 : 4;
      for (var x = -half; x <= half; x++) {
        for (var z = -half; z <= half; z++) {
          for (var y = 0; y <= hgt; y++) {
            final wall = x == -half || x == half || z == -half || z == half || y == 0 || y == hgt;
            final id = wall ? (hash(rcx + x, cy + y, rcz + z) % 4 == 0 ? _mossyBricks : _stoneBricks) : _air;
            _put(b, ox, oz, rcx + x, cy + y, rcz + z, id);
          }
        }
      }
      _put(b, ox, oz, rcx - half + 1, cy + 1, rcz - half + 1, _lamp);
      _put(b, ox, oz, rcx + half - 1, cy + 1, rcz + half - 1, _lamp);
      if (room < 2) _put(b, ox, oz, rcx, cy + 1, rcz + 2, _spawnerId);
      if (room == 2) {
        _put(b, ox, oz, rcx, cy + 1, rcz, _chest);
        _put(b, ox, oz, rcx + 2, cy + 1, rcz - 2, _boneBlock);
        _put(b, ox, oz, rcx - 3, cy + 1, rcz + 3, _goldOre);
      }
      if (room < 2) {
        for (var x = half; x <= half + 12 - 4; x++) {
          for (var y = 1; y <= 2; y++) {
            _put(b, ox, oz, rcx + x, cy + y, rcz, _air);
          }
          _put(b, ox, oz, rcx + x, cy, rcz, _stoneBricks);
          _put(b, ox, oz, rcx + x, cy + 3, rcz, _stoneBricks);
          _put(b, ox, oz, rcx + x, cy + 1, rcz - 1, _stoneBricks);
          _put(b, ox, oz, rcx + x, cy + 2, rcz - 1, _stoneBricks);
          _put(b, ox, oz, rcx + x, cy + 1, rcz + 1, _stoneBricks);
          _put(b, ox, oz, rcx + x, cy + 2, rcz + 1, _stoneBricks);
        }
      }
    }
    // A shaft up to the surface from the first room, with ladders.
    final top = surfaceHeight(cx - 3, cz - 3);
    for (var y = cy + 1; y < top + 1; y++) {
      _put(b, ox, oz, cx - 3, y, cz - 3, _air);
      _put(b, ox, oz, cx - 3, y, cz - 4, y < top - 1 ? _stoneBricks : 0);
      _put(b, ox, oz, cx - 3, y, cz - 3, _ladderId);
    }
  }

  void _tower(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    const h = 9;
    for (var x = -2; x <= 2; x++) {
      for (var z = -2; z <= 2; z++) {
        final wall = x.abs() == 2 || z.abs() == 2;
        for (var y = -3; y <= h; y++) {
          var id = _air;
          if (y < 0) {
            id = _stoneBricks;
          } else if (y == 0) {
            id = _stoneBricks;
          } else if (wall) {
            final door = z == 2 && x == 0 && y <= 2;
            final window = y % 3 == 2 && (x == 0 || z == 0);
            id = door || window ? _air : (hash(cx + x, cy + y, cz + z) % 5 == 0 ? _mossyBricks : _stoneBricks);
          } else if (y == h - 1) {
            id = _planks;
          }
          _put(b, ox, oz, cx + x, cy + y, cz + z, id);
        }
        if (wall && (x + z) % 2 == 0) _put(b, ox, oz, cx + x, cy + h + 1, cz + z, _stoneBricks);
      }
    }
    _put(b, ox, oz, cx, cy + h, cz, _chest);
    _put(b, ox, oz, cx - 1, cy + h, cz - 1, _lamp);
    for (var y = 1; y < h - 1; y++) {
      _put(b, ox, oz, cx - 1, cy + y, cz - 1, _ladderId);
    }
    _put(b, ox, oz, cx - 1, cy + h - 1, cz - 1, _air);
  }

  /// Stage 26: 4-7 huts on a ring around a central well, each levelled onto its
  /// own ground, joined to the well by gravel paths, plus a fenced wheat plot.
  /// `_hutCount` / `_hutAt` are the layout every chunk (and the probe) agrees on.
  static const int _villageRing = 11;

  int villageHutCount(int cx, int cz) => _hutCount(cx, cz);

  int _hutCount(int cx, int cz) => 4 + (hash(cx, 51, cz) % 4);

  /// Godot's `Mathf.RoundToInt` rounds half to even and Dart's `round` half away
  /// from zero; a cosine times the ring radius never lands on a half.
  ({int x, int z}) _hutAt(int cx, int cz, int i) {
    final n = _hutCount(cx, cz);
    final a = i * math.pi * 2 / n + (hash(cx, 52, cz) % 100) / 100.0;
    final r = _villageRing + (hash(cx, 53 + i, cz) % 3);
    return (x: cx + (math.cos(a) * r).round(), z: cz + (math.sin(a) * r).round());
  }

  /// World (x, z) of every hut centre, for the probe.
  List<({int x, int z})> villageHuts(int cx, int cz) => [for (var i = 0; i < _hutCount(cx, cz); i++) _hutAt(cx, cz, i)];

  static const int _villageClearRadius = 24;

  /// A forest village is a clearing and not huts under a canopy. Stage 42 does it
  /// by keeping the trees out ([_structureClearance]) instead of cutting them
  /// down: a saw that ran here after the trees left every crown it cut hanging
  /// over the village with no trunk under it.
  void _village(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    final n = _hutCount(cx, cz);
    final wy = surfaceHeight(cx, cz);
    for (var i = 0; i < n; i++) {
      final hut = _hutAt(cx, cz, i);
      final hy = surfaceHeight(hut.x, hut.z);
      _hut(b, ox, oz, hut.x, hy, hut.z, i);
      _path(b, ox, oz, hut.x, hut.z, cx, cz);
    }
    // Well
    for (var x = -1; x <= 1; x++) {
      for (var z = -1; z <= 1; z++) {
        final rim = x.abs() == 1 || z.abs() == 1;
        _levelColumn(b, ox, oz, cx + x, cz + z, wy - 1, wy + 5, _cobblestone);
        _put(b, ox, oz, cx + x, wy, cz + z, rim ? _stoneBricks : _water);
        _put(b, ox, oz, cx + x, wy - 1, cz + z, rim ? _stoneBricks : _water);
        for (var y = 1; y < 4; y++) {
          if (x.abs() == 1 && z.abs() == 1) _put(b, ox, oz, cx + x, wy + y, cz + z, _oakLog);
        }
        _put(b, ox, oz, cx + x, wy + 4, cz + z, _planks);
      }
    }
    _put(b, ox, oz, cx + 3, wy, cz, _lamp);
    _put(b, ox, oz, cx - 3, wy, cz, _lamp);
    // Farm plot: 9x7 fenced, two rows of ripe wheat on farmland either side of a
    // water channel.
    final fx = cx + 5, fz = cz - _villageRing - 6;
    final fy = surfaceHeight(fx, fz);
    for (var z = -3; z <= 3; z++) {
      for (var x = -4; x <= 4; x++) {
        final wx = fx + x, wz = fz + z;
        final edge = x.abs() == 4 || z.abs() == 3;
        _levelColumn(b, ox, oz, wx, wz, fy - 1, fy + 3, _dirt);
        if (edge) {
          _put(b, ox, oz, wx, fy - 1, wz, _grass);
          _put(b, ox, oz, wx, fy, wz, _fence);
        } else if (z == 0) {
          _put(b, ox, oz, wx, fy - 1, wz, _water);
        } else {
          _put(b, ox, oz, wx, fy - 1, wz, _farmland);
          _put(b, ox, oz, wx, fy, wz, _wheat);
        }
      }
    }
    _put(b, ox, oz, fx, fy, fz + 3, _air); // the gate
    _put(b, ox, oz, fx + 4, fy + 1, fz + 3, _torch);
  }

  /// A gravel path along x then along z, one block wide, laid on each column's
  /// own ground.
  void _path(Uint8List b, int ox, int oz, int fromX, int fromZ, int toX, int toZ) {
    final stepX = toX > fromX ? 1 : -1, stepZ = toZ > fromZ ? 1 : -1;
    for (var x = fromX; x != toX; x += stepX) {
      if ((x - toX).abs() <= 2 && (fromZ - toZ).abs() <= 2) break;
      final y = surfaceHeight(x, fromZ);
      _put(b, ox, oz, x, y - 1, fromZ, _gravel);
      _put(b, ox, oz, x, y, fromZ, _air);
    }
    for (var z = fromZ; z != toZ; z += stepZ) {
      if ((z - toZ).abs() <= 2) break;
      final y = surfaceHeight(toX, z);
      _put(b, ox, oz, toX, y - 1, z, _gravel);
      _put(b, ox, oz, toX, y, z, _air);
    }
  }

  /// A 5x5 hut: cobblestone floor, plank walls with log corners, a door gap
  /// facing the well side, a glass window, a plank ceiling ringed with slabs,
  /// and inside a torch, a bed and a chest (`LootTables.tables['village']`).
  void _hut(Uint8List b, int ox, int oz, int cx, int cy, int cz, int variant) {
    const w = 2, d = 2, h = 4;
    final doorZ = variant % 2 == 0 ? d : -d;
    for (var x = -w; x <= w; x++) {
      for (var z = -d; z <= d; z++) {
        _levelColumn(b, ox, oz, cx + x, cz + z, cy - 1, cy + h + 2, _cobblestone);
        for (var y = -2; y <= h + 1; y++) {
          var id = _air;
          final wall = x.abs() == w || z.abs() == d;
          final corner = x.abs() == w && z.abs() == d;
          if (y < 0) {
            id = _cobblestone; // foundation
          } else if (y == 0) {
            id = _cobblestone; // floor
          } else if (y == h) {
            id = _planks; // ceiling
          } else if (y == h + 1) {
            id = wall ? _slab : (x == 0 && z == 0 ? _slab : _air); // slab roof rim + cap
          } else if (corner) {
            id = _oakLog;
          } else if (wall) {
            final door = z == doorZ && x == 0 && y <= 2;
            final window = y == 2 && (x == 0 && z == -doorZ);
            id = door ? _air : (window ? _glassId : _planks);
          }
          _put(b, ox, oz, cx + x, cy + y, cz + z, id);
        }
      }
    }
    final back = -doorZ + (doorZ > 0 ? 1 : -1);
    final front = doorZ - (doorZ > 0 ? 1 : -1);
    _put(b, ox, oz, cx - w + 1, cy + 1, cz + back, _chest);
    _put(b, ox, oz, cx + w - 1, cy + 1, cz + back, _bed);
    _put(b, ox, oz, cx, cy + 3, cz, _torch);
    if (variant == 2) _put(b, ox, oz, cx + w - 1, cy + 1, cz + front, _craftingTable);
    if (variant == 3) _put(b, ox, oz, cx - w + 1, cy + 1, cz + front, _furnace);
  }

  void _camp(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    for (var x = -3; x <= 3; x++) {
      for (var z = -2; z <= 2; z++) {
        // Stage 42: a block taller than it was, because the roof now carries a
        // block under each step and the shelter would have lost its headroom.
        final roof = 4 - z.abs();
        _put(b, ox, oz, cx + x, cy + roof, cz + z, _planks);
        // Stage 42: the slope of the roof climbs by faces. Each row used to sit
        // one block over and one across from the next, touching it by an edge
        // alone, so the ridge of the tent hung over a gap it never reached.
        if (roof > 1) _put(b, ox, oz, cx + x, cy + roof - 1, cz + z, _planks);
        if (x.abs() == 3) {
          // And the corner post stands on its own ground: pitched on a slope,
          // the camp used to hold a post in the air.
          var foot = cy;
          if (z.abs() == 2) {
            final ground = surfaceHeight(cx + x, cz + z);
            foot = math.min(cy, ground);
            // Pitched at the lip of a swamp pool, the post reaches the bed under
            // it instead of resting on the water lying on the bed.
            if (_swampPool(cx + x, cz + z, ground, _biomeFor(cx + x, cz + z, ground))) foot = math.min(foot, ground - 1);
            while (foot > 1 && foot > ground - 10 && _carved(cx + x, foot - 1, cz + z, ground)) {
              foot--; // a cave mouth under the corner is no reason to hang a post over it
            }
          }
          for (var y = foot; y < cy + roof; y++) {
            _put(b, ox, oz, cx + x, y, cz + z, z.abs() == 2 ? _oakLog : _air);
          }
        }
      }
    }
    _put(b, ox, oz, cx, cy, cz, _chest);
    _put(b, ox, oz, cx + 6, cy, cz, _lamp);
    for (var y = math.min(cy - 1, surfaceHeight(cx + 6, cz)); y <= cy - 1; y++) {
      _put(b, ox, oz, cx + 6, y, cz, _stone); // the lamp's block reaches the ground too
    }
  }

  // --- minor structures: ruins, wells, abandoned mines, desert temples ------------
  // A second, denser grid (4x4 chunks) with its own hash; a candidate is dropped
  // when it sits inside the 48-block footprint of any primary structure, so the two
  // layers never overwrite each other. The mine corridor (up to 30 long, underground
  // at [mineFloorY]) is the only piece that reaches past its own region.
  static const int _minorRegionChunks = 4;
  static const int _minorMargin = 16;
  static const int _primaryClearance = 48;

  /// Floor y of every mine corridor: the chest, spawner and torches sit one above.
  static const int mineFloorY = 24;

  ({int x, int y, int z, int type})? _minorStructure(int regionX, int regionZ) {
    final h = hash(regionX * 6151, 23, regionZ * 12289);
    const span = _minorRegionChunks * sizeX;
    final sx = regionX * span + _minorMargin + (h % (span - 2 * _minorMargin));
    final sz = regionZ * span + _minorMargin + ((h >> 8) % (span - 2 * _minorMargin));
    final roll = (h >> 16) % 100;
    final surface = surfaceHeight(sx, sz);
    final biome = _biomeFor(sx, sz, surface);
    if (surface <= seaLevel + 1) return null; // ocean, beach, river bed
    var type = structNone;
    switch (biome) {
      case biomePlains:
        type = roll < 45 ? structRuin : (roll < 75 ? structWell : (roll < 82 ? structMine : structNone));
      case biomeForest:
        type = roll < 55 ? structRuin : (roll < 65 ? structMine : structNone);
      case biomeMountain:
        type = roll < 70 ? structMine : structNone;
      case biomeSnow:
        type = roll < 25 ? structMine : structNone;
      case biomeDesert:
        type = roll < 55 ? structTemple : structNone;
    }
    if (type == structNone) return null;
    final prx = _floorDiv(_floorDiv(sx, sizeX), _regionChunks);
    final prz = _floorDiv(_floorDiv(sz, sizeZ), _regionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final p = _regionStructure(prx + dx, prz + dz);
        if (p == null) continue;
        if ((p.x - sx).abs() < _primaryClearance && (p.z - sz).abs() < _primaryClearance) return null;
      }
    }
    return (x: sx, y: surface, z: sz, type: type);
  }

  /// The block already in this chunk at a world position; null outside it.
  int? _get(Uint8List b, int ox, int oz, int wx, int wy, int wz) {
    final x = wx - ox, z = wz - oz;
    if (x < 0 || x >= sizeX || z < 0 || z >= sizeZ || wy < 1 || wy >= sizeY) return null;
    return b[index(x, wy, z)];
  }

  bool _isRock(int id) =>
      id == _stone || id == _darkStone || id == _coalOre || id == _ironOre || id == _goldOre;

  /// Fills the column below [floorY] down to the local ground and clears the air
  /// above it up to [clearTo], so a structure sits on the ground on a slope instead
  /// of floating or sinking.
  void _levelColumn(Uint8List b, int ox, int oz, int wx, int wz, int floorY, int clearTo, int fill) {
    final ground = surfaceHeight(wx, wz);
    for (var y = ground - 1; y < floorY; y++) {
      _put(b, ox, oz, wx, y, wz, fill);
    }
    for (var y = floorY + 1; y <= clearTo; y++) {
      _put(b, ox, oz, wx, y, wz, _air);
    }
  }

  /// Broken stone-brick walls 2-4 high with gaps around a cracked cobblestone floor;
  /// a chest half the time, one or two plants growing on the wall tops.
  void _ruins(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    const half = 3;
    final h = hash(cx, 31, cz);
    final plantA = h % 24, plantB = (h >> 5) % 24;
    var edgeIndex = 0;
    for (var z = -half; z <= half; z++) {
      for (var x = -half; x <= half; x++) {
        final wx = cx + x, wz = cz + z;
        _levelColumn(b, ox, oz, wx, wz, cy - 1, cy + 5, _cobblestone);
        final hole = hash(wx, 32, wz) % 4 == 0;
        _put(b, ox, oz, wx, cy - 1, wz, hole ? _grass : _cobblestone);
        final edge = x.abs() == half || z.abs() == half;
        if (!edge) continue;
        final wh = hash(wx, 33, wz);
        final height = wh % 10 < 3 ? 0 : 2 + ((wh >> 4) % 3);
        for (var y = 0; y < height; y++) {
          _put(b, ox, oz, wx, cy + y, wz, hash(wx, cy + y, wz) % 5 < 2 ? _mossyBricks : _stoneBricks);
        }
        if (height > 0 && (edgeIndex == plantA || edgeIndex == plantB)) {
          _put(b, ox, oz, wx, cy + height, wz, (wh >> 12) % 2 == 0 ? _tallGrass : _flowerRed);
        }
        edgeIndex++;
      }
    }
    if ((h >> 10) % 2 == 0) _put(b, ox, oz, cx, cy, cz, _chest);
  }

  /// A 3x3 cobblestone ring one block above the ground, water four deep in the
  /// middle, two fence posts and a plank roof at height 3.
  void _well(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    for (var z = -1; z <= 1; z++) {
      for (var x = -1; x <= 1; x++) {
        final wx = cx + x, wz = cz + z;
        final rim = x.abs() == 1 || z.abs() == 1;
        _levelColumn(b, ox, oz, wx, wz, cy - 5, cy + 2, _cobblestone);
        for (var y = cy - 4; y <= cy; y++) {
          _put(b, ox, oz, wx, y, wz, rim ? _cobblestone : _water);
        }
        _put(b, ox, oz, wx, cy + 3, wz, _planks);
      }
    }
    for (var y = 1; y <= 2; y++) {
      _put(b, ox, oz, cx - 1, cy + y, cz, _fence);
      _put(b, ox, oz, cx + 1, cy + y, cz, _fence);
    }
  }

  /// A ladder shaft from the surface down to [mineFloorY], then a 3x3 corridor 20-30
  /// long towards +x with log-and-plank support beams every 4 blocks, a torch pair on
  /// every second beam, ore veins exposed in the walls, a chest at the end and a
  /// spawner a third of the time.
  void _mine(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    final h = hash(cx, 41, cz);
    final len = 20 + (h % 11);
    const fy = mineFloorY;
    // Head frame on the surface: a 3x3 clearing with four fence posts and a roof.
    for (var z = -1; z <= 1; z++) {
      for (var x = -1; x <= 1; x++) {
        _levelColumn(b, ox, oz, cx + x, cz + z, cy - 1, cy + 3, _cobblestone);
        _put(b, ox, oz, cx + x, cy - 1, cz + z, _cobblestone);
        _put(b, ox, oz, cx + x, cy + 2, cz + z, _planks);
        if (x.abs() == 1 && z.abs() == 1) {
          _put(b, ox, oz, cx + x, cy, cz + z, _fence);
          _put(b, ox, oz, cx + x, cy + 1, cz + z, _fence);
        }
      }
    }
    // Shaft: ladder from the corridor floor up through the surface block.
    for (var y = fy + 1; y <= cy; y++) {
      _put(b, ox, oz, cx, y, cz, _ladderId);
    }
    for (var x = 1; x <= len; x++) {
      final wx = cx + x;
      for (var z = -2; z <= 2; z++) {
        for (var y = 0; y <= 4; y++) {
          final wy = fy + y, wz = cz + z;
          final inside = z.abs() <= 1 && y >= 1 && y <= 3;
          if (inside) {
            _put(b, ox, oz, wx, wy, wz, _air);
            continue;
          }
          final cur = _get(b, ox, oz, wx, wy, wz);
          if (cur == null) continue;
          if (cur == _air || cur == _lava || cur == _water) {
            _put(b, ox, oz, wx, wy, wz, _stone);
            continue;
          }
          if (!_isRock(cur)) continue;
          final vein = hash(wx, wy, wz) % 100;
          if (vein < 5) {
            _put(b, ox, oz, wx, wy, wz, _goldOre);
          } else if (vein < 18) {
            _put(b, ox, oz, wx, wy, wz, _ironOre);
          }
        }
      }
      if (x % 4 == 2) {
        final lit = x % 8 == 2;
        for (var y = 1; y <= 2; y++) {
          _put(b, ox, oz, wx, fy + y, cz - 1, _oakLog);
          _put(b, ox, oz, wx, fy + y, cz + 1, _oakLog);
        }
        _put(b, ox, oz, wx, fy + 3, cz, _planks);
        _put(b, ox, oz, wx, fy + 3, cz - 1, lit ? _torch : _planks);
        _put(b, ox, oz, wx, fy + 3, cz + 1, lit ? _torch : _planks);
      }
    }
    // Stage 28: a rail down the centre line, from the shaft to the chest.
    for (var x = 1; x < len; x++) {
      _put(b, ox, oz, cx + x, fy + 1, cz, _railEw);
    }
    _put(b, ox, oz, cx + len, fy + 1, cz, _chest);
    if ((h >> 8) % 3 == 0) _put(b, ox, oz, cx + len - 3, fy + 1, cz, _spawnerId);
  }

  /// A sandstone step pyramid, 9x9 at the base and five levels of two blocks each,
  /// with a hollow 3x3x3 chamber at the base holding two chests and a lamp, a pressure
  /// plate in the chamber floor centre with TNT under it, and an entrance corridor on
  /// the south (+z) side.
  void _temple(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    for (var z = -4; z <= 4; z++) {
      for (var x = -4; x <= 4; x++) {
        _levelColumn(b, ox, oz, cx + x, cz + z, cy - 1, cy + 12, _sandstone);
      }
    }
    for (var level = 0; level < 5; level++) {
      final hw = 4 - level;
      for (var dy = 0; dy < 2; dy++) {
        for (var z = -hw; z <= hw; z++) {
          for (var x = -hw; x <= hw; x++) {
            _put(b, ox, oz, cx + x, cy + level * 2 + dy, cz + z, _sandstone);
          }
        }
      }
    }
    for (var z = -1; z <= 1; z++) {
      for (var x = -1; x <= 1; x++) {
        for (var y = 1; y <= 3; y++) {
          _put(b, ox, oz, cx + x, cy + y, cz + z, _air);
        }
      }
    }
    _put(b, ox, oz, cx, cy - 1, cz, _tnt);
    _put(b, ox, oz, cx, cy, cz, _pressurePlate); // stage 23: the trap that lights it
    _put(b, ox, oz, cx - 1, cy + 1, cz - 1, _chest);
    _put(b, ox, oz, cx + 1, cy + 1, cz - 1, _chest);
    _put(b, ox, oz, cx, cy + 4, cz, _lamp);
    for (var z = 2; z <= 4; z++) {
      for (var y = 1; y <= 2; y++) {
        _put(b, ox, oz, cx, cy + y, cz + z, _air);
      }
    }
  }

  // --- stage 29: the underworld -------------------------------------------------
  // A cavernous slab between the bedrock floor (y 7) and roof (y 100): 3D noise
  // opens about 40% of the volume, the rock is hellstone, a lava ocean fills
  // every open cell at y <= 28, soul sand patches the floors, glowstone hangs
  // from the ceilings, quartz veins the walls.
  static const int hellFloorY = 7, hellRoofY = 100, lavaSeaY = 28;

  bool _hellOpen(int wx, int y, int wz) {
    final n = _hell.getNoise3(wx.toDouble(), y * 1.4, wz.toDouble());
    // Solid bias near the floor and the roof so the slab has a floor to walk and a lid.
    var edge = 0.0;
    if (y < hellFloorY + 6) edge = (hellFloorY + 6 - y) / 6.0;
    if (y > hellRoofY - 8) edge = math.max(edge, (y - (hellRoofY - 8)) / 8.0);
    return n - edge * 0.6 > 0.08;
  }

  Uint8List _generateUnderworld(int chunkX, int chunkZ) {
    final blocks = Uint8List(volume);
    final ox = chunkX * sizeX, oz = chunkZ * sizeZ;
    final open = List<bool>.filled(sizeY, false);
    for (var z = 0; z < sizeZ; z++) {
      for (var x = 0; x < sizeX; x++) {
        final wx = ox + x, wz = oz + z;
        for (var y = 0; y < sizeY; y++) {
          open[y] = y > hellFloorY && y < hellRoofY && _hellOpen(wx, y, wz);
        }
        final patch = _hellPatch.getNoise2(wx.toDouble(), wz.toDouble()) > 0.38;
        for (var y = 0; y <= hellRoofY; y++) {
          int id;
          if (y == 0 || y == hellFloorY || y == hellRoofY) {
            id = _bedrock;
          } else if (open[y]) {
            id = y <= lavaSeaY ? _lava : _air;
          } else {
            id = _hellstone;
            final floorTop = y + 1 < sizeY && open[y + 1] && y > lavaSeaY;
            final ceiling = y > 0 && open[y - 1] && y > lavaSeaY + 2;
            if (floorTop && patch) {
              id = _soulSand;
            } else if (ceiling && hash(wx >> 1, y, wz >> 1) % 23 == 0) {
              id = _glowstone;
              // A cluster hangs one or two cells into the cavern below.
              final len = 1 + hash(wx, y, wz) % 2;
              for (var k = 1; k <= len; k++) {
                if (y - k > lavaSeaY && open[y - k]) blocks[index(x, y - k, z)] = _glowstone;
              }
            } else {
              final cell = hash(wx >> 1, y >> 1, wz >> 1);
              if (hash(wx, y, wz) % 100 < 55 && cell % 10000 < 650) id = _quartzOre;
            }
          }
          final i = index(x, y, z);
          if (blocks[i] == _air) blocks[i] = id; // a glowstone cluster written from above stays
        }
      }
    }
    _buildFortresses(blocks, chunkX, chunkZ);
    return blocks;
  }

  /// The fortress: one candidate per 8x8-chunk region (60% of regions), a
  /// nether-brick hall running +x from its origin. [_fortressAt] is what every
  /// chunk and the game agree on.
  static const int _fortressRegionChunks = 8;
  static const int structFortress = 9;

  ({int x, int y, int z, int type})? _fortressAt(int regionX, int regionZ) {
    final h = hash(regionX * 7127, 29, regionZ * 15919);
    const span = _fortressRegionChunks * sizeX;
    final sx = regionX * span + 16 + h % (span - 96);
    final sz = regionZ * span + 16 + (h >> 8) % (span - 32);
    final sy = 60 - 10 + (h >> 20) % 21;
    if ((h >> 16) % 10 >= 6) return null;
    return (x: sx, y: sy, z: sz, type: structFortress);
  }

  int _fortressLength(int sx, int sz) => 40 + hash(sx, 30, sz) % 21;

  /// The layout the probe and `Game` read: the hall's length and far end, the
  /// throne room centre, the core block cell, the blaze spot (hall middle) and
  /// the two side-room chests.
  ({int length, IVec3 hallEnd, IVec3 throne, IVec3 core, IVec3 blaze, IVec3 chestA, IVec3 chestB}) fortressLayout(
      int sx, int sy, int sz) {
    final len = _fortressLength(sx, sz);
    return (
      length: len,
      hallEnd: IVec3(sx + len, sy, sz),
      throne: IVec3(sx + len + 5, sy, sz),
      core: IVec3(sx + len + 5, sy, sz),
      blaze: IVec3(sx + len ~/ 2, sy + 1, sz),
      chestA: IVec3(sx + len ~/ 3, sy + 1, sz + 7),
      chestB: IVec3(sx + len * 2 ~/ 3, sy + 1, sz - 7),
    );
  }

  void _buildFortresses(Uint8List blocks, int chunkX, int chunkZ) {
    final ox = chunkX * sizeX, oz = chunkZ * sizeZ;
    final fx = _floorDiv(chunkX, _fortressRegionChunks), fz = _floorDiv(chunkZ, _fortressRegionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final f = _fortressAt(fx + dx, fz + dz);
        if (f != null) _fortress(blocks, ox, oz, f.x, f.y, f.z);
      }
    }
  }

  /// A hall 5 wide x 5 tall (interior) and 40-60 long of nether brick, pillars
  /// every 8 blocks down to the bedrock floor, arched windows on both sides,
  /// glowstone in the ceiling every 8 blocks, two side rooms (one chest each)
  /// off the hall, a blaze spot at the middle, and a throne room 9x9x7 at the
  /// far end with lava channels along its walls and the fortress core in the
  /// centre of its floor.
  void _fortress(Uint8List b, int ox, int oz, int sx, int sy, int sz) {
    final len = _fortressLength(sx, sz);
    // Hall shell: walls z = +-3, floor y = sy, ceiling y = sy + 6, interior air.
    for (var x = 0; x <= len; x++) {
      final wx = sx + x;
      if (wx < ox - 1 || wx > ox + sizeX) continue;
      for (var z = -3; z <= 3; z++) {
        for (var y = 0; y <= 6; y++) {
          final wall = z.abs() == 3 || y == 0 || y == 6;
          var id = wall ? _netherBrick : _air;
          if (wall && z.abs() == 3 && y >= 2 && y <= 4 && x % 6 == 3 && x > 2 && x < len - 2) id = _air; // window
          if (wall && z.abs() == 3 && y == 3 && x % 6 == 0) id = _glowstone; // a sconce between the windows
          if (y == 6 && z == 0 && x % 8 == 4) id = _glowstone;
          _put(b, ox, oz, wx, sy + y, sz + z, id);
        }
      }
      // Pillars to the bedrock floor at both wall lines, every 8 blocks.
      if (x % 8 == 0) {
        for (var y = sy - 1; y > hellFloorY; y--) {
          _put(b, ox, oz, wx, y, sz - 3, _netherBrick);
          _put(b, ox, oz, wx, y, sz + 3, _netherBrick);
        }
      }
    }
    // Side rooms: 5x5 interior off the +z wall at a third, off the -z wall at two thirds.
    _sideRoom(b, ox, oz, sx + len ~/ 3, sy, sz, 1);
    _sideRoom(b, ox, oz, sx + len * 2 ~/ 3, sy, sz, -1);
    // Throne room: 9x9 interior, 7 tall, centred 5 past the hall's end.
    final cx = sx + len + 5, cz = sz;
    for (var x = -5; x <= 5; x++) {
      for (var z = -5; z <= 5; z++) {
        final wx = cx + x, wz = cz + z;
        if (wx < ox || wx >= ox + sizeX || wz < oz || wz >= oz + sizeZ) continue;
        for (var y = 0; y <= 8; y++) {
          final wall = x.abs() == 5 || z.abs() == 5 || y == 0 || y == 8;
          var id = wall ? _netherBrick : _air;
          if (x == -5 && z.abs() <= 1 && y >= 1 && y <= 4) id = _air; // the door from the hall
          if (wall && y == 4 && x.abs() != 5 && z.abs() == 5 && x % 3 == 0) id = _glowstone; // sconces along both side walls
          if (wall && y == 4 && x == 5 && z % 3 == 0) id = _glowstone; // and the back wall
          if (y == 0 && (z.abs() == 4 || x.abs() == 4) && !(x == -4 && z.abs() <= 1)) id = _lava; // moat sunk in the floor ring
          if (y == 8 && (x % 3 == 0) && (z % 3 == 0)) id = _glowstone;
          if (y == 0 && x == 0 && z == 0) id = _fortressCore;
          _put(b, ox, oz, wx, sy + y, wz, id);
        }
        // The room floor's underside and pillars so the moat has a bed.
        _put(b, ox, oz, wx, sy - 1, wz, _netherBrick);
        if (x.abs() == 5 && z.abs() == 5) {
          for (var y = sy - 2; y > hellFloorY; y--) {
            _put(b, ox, oz, wx, y, wz, _netherBrick);
          }
        }
      }
    }
    // A glowstone-lit dais step at the far wall behind the core.
    for (var z = -2; z <= 2; z++) {
      _put(b, ox, oz, cx + 3, sy + 1, cz + z, _netherBrick);
    }
    _put(b, ox, oz, cx + 3, sy + 2, cz, _glowstone);
  }

  void _sideRoom(Uint8List b, int ox, int oz, int rx, int ry, int hz, int side) {
    // Interior z from hz + side*4 .. hz + side*8 (5 cells), x rx-2..rx+2; the hall wall opens.
    final zc = hz + side * 6;
    for (var x = -3; x <= 3; x++) {
      for (var z = -3; z <= 3; z++) {
        final wx = rx + x, wz = zc + z;
        if (wx < ox || wx >= ox + sizeX || wz < oz || wz >= oz + sizeZ) continue;
        for (var y = 0; y <= 5; y++) {
          final wall = x.abs() == 3 || z.abs() == 3 || y == 0 || y == 5;
          var id = wall ? _netherBrick : _air;
          if (wz == hz + side * 3 && x.abs() <= 1 && y >= 1 && y <= 3) id = _air; // doorway through the hall wall
          _put(b, ox, oz, wx, ry + y, wz, id);
        }
      }
    }
    _put(b, ox, oz, rx, ry + 1, hz + side * 7, _chest);
    _put(b, ox, oz, rx, ry + 4, zc, _glowstone);
  }
}
