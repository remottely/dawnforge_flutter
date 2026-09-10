import 'dart:typed_data';

import 'package:flutter_scene/noise.dart';

/// Pure (seed, position) terrain: biomes from temperature/humidity/continental
/// noise, a height field with hills and ridged mountains, 3D caves, ores by
/// depth, lava in the deep, and decorations (trees, cacti, plants) that can
/// cross chunk borders. Runs on worker isolates; nothing here touches the scene.
class TerrainGenerator {
  TerrainGenerator({required this.ids, required int seed}) {
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
    setSeed(seed);
  }

  static const int sizeX = 16;
  static const int sizeZ = 16;
  static const int sizeY = 128;
  static const int seaLevel = 46;
  static const int volume = sizeX * sizeZ * sizeY;

  static const int biomeOcean = 0,
      biomeBeach = 1,
      biomePlains = 2,
      biomeForest = 3,
      biomeDesert = 4,
      biomeSnow = 5,
      biomeMountain = 6,
      biomeSwamp = 7;

  static const int structNone = 0, structDungeon = 1, structTower = 2, structCamp = 3, structVillage = 4;
  static const int structRuin = 5, structWell = 6, structMine = 7, structTemple = 8;

  static const int _air = 0;
  final Map<String, int> ids;
  late int _stone, _dirt, _grass, _sand, _water, _oakLog, _oakLeaves, _gravel, _sandstone, _snow,
      _spruceLog, _spruceLeaves, _cactus, _coalOre, _ironOre, _goldOre, _diamondOre, _bedrock,
      _tallGrass, _flowerRed, _flowerYellow, _lava, _clay, _deadBush, _mushroom, _ice, _darkStone,
      _mossyBricks, _stoneBricks, _chest, _lamp, _boneBlock, _planks, _ladderId, _spawnerId,
      _glassId, _craftingTable, _furnace, _torch, _fence, _tnt, _cobblestone;

  int _seed = 0;
  int get seed => _seed;
  late FastNoiseLite _continental, _hills, _mountainMask, _ridge, _temperature, _humidity, _cave, _cavern, _river;

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
    _river = _make(seed ^ 0x9ABCDEF, 0.0030, 2);
  }

  static int index(int x, int y, int z) => x + sizeX * (z + sizeZ * y);

  static double _smooth(double a, double b, double t) {
    t = ((t - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  int surfaceHeight(int x, int z) {
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
    return h.toInt().clamp(6, sizeY - 6);
  }

  int biomeAt(int x, int z) => _biomeFor(x, z, surfaceHeight(x, z));

  int _biomeFor(int x, int z, int h) {
    if (h < seaLevel - 2) return biomeOcean;
    final t = _temperature.getNoise2(x.toDouble(), z.toDouble()) - ((h - 72).clamp(0, 1 << 30)) / 50.0;
    final hum = _humidity.getNoise2(x.toDouble(), z.toDouble());
    if (h > 86) return biomeMountain;
    if (h <= seaLevel + 1) return t < -0.4 ? biomeSnow : biomeBeach;
    if (t < -0.35) return biomeSnow;
    if (t > 0.30 && hum < 0.05) return biomeDesert;
    if (hum > 0.42 && t > 0.1 && h < seaLevel + 6) return biomeSwamp;
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

  Uint8List generate(int chunkX, int chunkZ) {
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
                id = hash(wx, 3, wz) % 3 == 0 ? _clay : _grass;
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
              } else if (r < 1100) {
                id = _coalOre;
              }
            }
          }

          // Caves: cheese caves everywhere in rock, caverns deeper, sealed near
          // the surface unless an entrance noise opens it.
          if (id != _air && id != _bedrock && id != _water && id != _ice && y > 1) {
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
    _decorate(blocks, ox, oz);
    _buildStructures(blocks, chunkX, chunkZ);
    return blocks;
  }

  static const int _reach = 3;

  /// Trees, cacti and plants. Walks every column whose feature can REACH this
  /// chunk and clips what lands here, so a canopy crosses a border whole.
  void _decorate(Uint8List blocks, int ox, int oz) {
    for (var z = -_reach; z < sizeZ + _reach; z++) {
      for (var x = -_reach; x < sizeX + _reach; x++) {
        final wx = ox + x, wz = oz + z;
        final h = surfaceHeight(wx, wz);
        final biome = _biomeFor(wx, wz, h);
        final hsh = hash(wx, 7, wz);
        final roll = hsh % 1000;
        final top = h - 1;
        final y = h;
        final inside = x >= 0 && x < sizeX && z >= 0 && z < sizeZ;
        if (inside && blocks[index(x, top, z)] == _air) continue;
        switch (biome) {
          case biomeForest:
            if (roll < 55) {
              _placeOak(blocks, x, y, z, 4 + ((hsh >> 10) % 3));
            } else if (roll < 75) {
              _placeBigOak(blocks, x, y, z);
            } else if (roll < 260) {
              _setIfInside(blocks, x, y, z, _tallGrass);
            } else if (roll < 285) {
              _setIfInside(blocks, x, y, z, _mushroom);
            } else if (roll < 305) {
              _setIfInside(blocks, x, y, z, _flowerRed);
            }
          case biomePlains:
            if (roll < 6) {
              _placeOak(blocks, x, y, z, 4 + ((hsh >> 10) % 3));
            } else if (roll < 150) {
              _setIfInside(blocks, x, y, z, _tallGrass);
            } else if (roll < 172) {
              _setIfInside(blocks, x, y, z, _flowerYellow);
            } else if (roll < 190) {
              _setIfInside(blocks, x, y, z, _flowerRed);
            }
          case biomeSwamp:
            if (roll < 25) {
              _placeOak(blocks, x, y, z, 3 + ((hsh >> 10) % 2));
            } else if (roll < 300) {
              _setIfInside(blocks, x, y, z, _tallGrass);
            } else if (roll < 340) {
              _setIfInside(blocks, x, y, z, _mushroom);
            }
          case biomeSnow:
            if (roll < 30) _placeSpruce(blocks, x, y, z, 6 + ((hsh >> 10) % 4));
          case biomeMountain:
            if (h < 96 && roll < 12) _placeSpruce(blocks, x, y, z, 5 + ((hsh >> 10) % 3));
          case biomeDesert:
            if (roll < 12) {
              final ch = 2 + ((hsh >> 10) % 2);
              for (var i = 0; i < ch; i++) {
                _setIfInside(blocks, x, y + i, z, _cactus);
              }
            } else if (roll < 40) {
              _setIfInside(blocks, x, y, z, _deadBush);
            }
        }
      }
    }
  }

  void _placeOak(Uint8List b, int x, int y, int z, int trunk) {
    final top = y + trunk;
    for (var layer = 0; layer < 2; layer++) {
      final ly = top - 1 - layer;
      for (var dz = -2; dz <= 2; dz++) {
        for (var dx = -2; dx <= 2; dx++) {
          if (dx.abs() == 2 && dz.abs() == 2 && hash(x + dx, ly, z + dz) % 3 == 0) continue;
          _setIfInside(b, x + dx, ly, z + dz, _oakLeaves);
        }
      }
    }
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        _setIfInside(b, x + dx, top, z + dz, _oakLeaves);
      }
    }
    _setIfInside(b, x, top + 1, z, _oakLeaves);
    _setIfInside(b, x + 1, top + 1, z, _oakLeaves);
    _setIfInside(b, x - 1, top + 1, z, _oakLeaves);
    _setIfInside(b, x, top + 1, z + 1, _oakLeaves);
    _setIfInside(b, x, top + 1, z - 1, _oakLeaves);
    for (var i = 0; i < trunk; i++) {
      _setIfInside(b, x, y + i, z, _oakLog);
    }
  }

  void _placeBigOak(Uint8List b, int x, int y, int z) {
    const trunk = 7;
    final top = y + trunk;
    for (var dy = -3; dy <= 1; dy++) {
      final r = dy == 1 ? 1 : (dy == -3 ? 2 : 3);
      for (var dz = -r; dz <= r; dz++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx * dx + dz * dz > r * r + 1) continue;
          _setIfInside(b, x + dx, top + dy, z + dz, _oakLeaves);
        }
      }
    }
    for (var i = 0; i < trunk; i++) {
      _setIfInside(b, x, y + i, z, _oakLog);
    }
  }

  void _placeSpruce(Uint8List b, int x, int y, int z, int trunk) {
    final top = y + trunk;
    for (var dy = 1; dy < trunk; dy++) {
      final fromTop = trunk - dy;
      var r = fromTop <= 1 ? 1 : ((fromTop % 2 == 0) ? 2 : 1);
      if (fromTop > 6) r = 3;
      for (var dz = -r; dz <= r; dz++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx.abs() == r && dz.abs() == r && r > 1) continue;
          _setIfInside(b, x + dx, y + dy, z + dz, _spruceLeaves);
        }
      }
    }
    _setIfInside(b, x, top, z, _spruceLeaves);
    _setIfInside(b, x, top + 1, z, _spruceLeaves);
    for (var i = 0; i < trunk; i++) {
      _setIfInside(b, x, y + i, z, _spruceLog);
    }
  }

  bool _isLeaf(int id) => id == _oakLeaves || id == _spruceLeaves;

  void _setIfInside(Uint8List b, int x, int y, int z, int id) {
    if (x < 0 || x >= sizeX || z < 0 || z >= sizeZ || y < 0 || y >= sizeY) return;
    final i = index(x, y, z);
    if (b[i] == _air || id == 0) {
      b[i] = id;
    } else if (id != 0 && b[i] != 0 && _isLeaf(b[i])) {
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
    } else if (biome != biomeMountain && biome != biomeSwamp) {
      return (x: sx, y: surface, z: sz, type: structVillage);
    }
    return null;
  }

  /// Structures whose region touches the chunk: records of (x, y, z, type).
  List<({int x, int y, int z, int type})> structuresNear(int chunkX, int chunkZ) {
    final list = <({int x, int y, int z, int type})>[];
    final rx = _floorDiv(chunkX, _regionChunks), rz = _floorDiv(chunkZ, _regionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _regionStructure(rx + dx, rz + dz);
        if (s != null) list.add(s);
      }
    }
    final mx = _floorDiv(chunkX, _minorRegionChunks), mz = _floorDiv(chunkZ, _minorRegionChunks);
    for (var dz = -1; dz <= 1; dz++) {
      for (var dx = -1; dx <= 1; dx++) {
        final s = _minorStructure(mx + dx, mz + dz);
        if (s != null) list.add(s);
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
        if (s == null) continue;
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
        if (s == null) continue;
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

  /// Five houses around a well, each levelled onto its own ground height.
  void _village(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    const dx = [-9, 9, 0, -9, 9], dz = [-9, -9, 10, 9, 9];
    for (var i = 0; i < 5; i++) {
      final hx = cx + dx[i], hz = cz + dz[i];
      final hy = surfaceHeight(hx, hz);
      _house(b, ox, oz, hx, hy, hz, i);
    }
    final wy = surfaceHeight(cx, cz);
    for (var x = -1; x <= 1; x++) {
      for (var z = -1; z <= 1; z++) {
        final rim = x.abs() == 1 || z.abs() == 1;
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
  }

  void _house(Uint8List b, int ox, int oz, int cx, int cy, int cz, int variant) {
    final w = 3 + variant % 2;
    const d = 3, h = 4;
    for (var x = -w; x <= w; x++) {
      for (var z = -d; z <= d; z++) {
        for (var y = -2; y <= h + 1; y++) {
          var id = _air;
          final wall = x.abs() == w || z.abs() == d;
          final corner = x.abs() == w && z.abs() == d;
          if (y < 0) {
            id = _stoneBricks;
          } else if (y == 0) {
            id = _planks;
          } else if (y == h) {
            id = _planks;
          } else if (y == h + 1) {
            id = (x.abs() < w && z.abs() < d) ? _spruceLog : _air;
          } else if (corner) {
            id = _oakLog;
          } else if (wall) {
            final door = z == d && x == 0 && y <= 2;
            final window = y == 2 && (x % 2 == 0) && !door;
            id = door ? _air : (window ? _glassId : _planks);
          }
          _put(b, ox, oz, cx + x, cy + y, cz + z, id);
        }
      }
    }
    _put(b, ox, oz, cx - w + 1, cy + 1, cz - d + 1, variant == 0 ? _chest : _lamp);
    if (variant == 2) _put(b, ox, oz, cx + w - 1, cy + 1, cz - d + 1, _craftingTable);
    if (variant == 3) _put(b, ox, oz, cx + w - 1, cy + 1, cz - d + 1, _furnace);
  }

  void _camp(Uint8List b, int ox, int oz, int cx, int cy, int cz) {
    for (var x = -3; x <= 3; x++) {
      for (var z = -2; z <= 2; z++) {
        final roof = 3 - z.abs();
        _put(b, ox, oz, cx + x, cy + roof, cz + z, _planks);
        if (x.abs() == 3) {
          for (var y = 0; y < roof; y++) {
            _put(b, ox, oz, cx + x, cy + y, cz + z, z.abs() == 2 ? _oakLog : _air);
          }
        }
      }
    }
    _put(b, ox, oz, cx, cy, cz, _chest);
    _put(b, ox, oz, cx + 6, cy, cz, _lamp);
    _put(b, ox, oz, cx + 6, cy - 1, cz, _stone);
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
    _put(b, ox, oz, cx + len, fy + 1, cz, _chest);
    if ((h >> 8) % 3 == 0) _put(b, ox, oz, cx + len - 3, fy + 1, cz, _spawnerId);
  }

  /// A sandstone step pyramid, 9x9 at the base and five levels of two blocks each,
  /// with a hollow 3x3x3 chamber at the base holding two chests and a lamp, TNT under
  /// the chamber floor centre, and an entrance corridor on the south (+z) side.
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
    _put(b, ox, oz, cx - 1, cy + 1, cz - 1, _chest);
    _put(b, ox, oz, cx + 1, cy + 1, cz - 1, _chest);
    _put(b, ox, oz, cx, cy + 4, cz, _lamp);
    for (var z = 2; z <= 4; z++) {
      for (var y = 1; y <= 2; y++) {
        _put(b, ox, oz, cx, cy + y, cz + z, _air);
      }
    }
  }
}
