import 'dart:typed_data';

import 'package:cubeworld_poc/src/core/blocks.dart';
import 'package:cubeworld_poc/src/core/items.dart';
import 'package:cubeworld_poc/src/core/recipes.dart';
import 'package:cubeworld_poc/src/core/species.dart';
import 'package:cubeworld_poc/src/world/chunk_mesher.dart';
import 'package:cubeworld_poc/src/world/terrain_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('block table is byte-sized and air is zero', () {
    expect(Blocks.count <= 256, isTrue);
    expect(Blocks.indexOf('air'), Blocks.air);
    expect(Blocks.indexOf('tall_grass'), 27);
    expect(Blocks.shapeOf(Blocks.indexOf('tall_grass')), BlockShape.cross);
  });

  test('items cover every block and the recipes resolve', () {
    expect(Items.has('oak_planks'), isTrue);
    expect(Items.has('door'), isTrue);
    expect(Items.has('door_x'), isFalse);
    for (final r in Recipes.list) {
      expect(Items.has(r.result), isTrue, reason: r.result);
      for (final k in r.ingredients.keys) {
        expect(Items.has(k), isTrue, reason: k);
      }
    }
    expect(Species.defs.length, 17);
  });

  test('the generator fills a chunk with a surface and the mesher emits faces', () {
    final gen = TerrainGenerator(ids: Blocks.generatorIds(), seed: 1337);
    final blocks = gen.generate(0, 0);
    expect(blocks.length, TerrainGenerator.volume);
    var solid = 0;
    for (final b in blocks) {
      if (b != 0) solid++;
    }
    expect(solid > 16 * 16 * 20, isTrue);
    final h = gen.surfaceHeight(8, 8);
    expect(h >= 6 && h <= 122, isTrue);
    final mesher = ChunkMesher(
      palette: Blocks.palette(),
      shape: Blocks.shapes(),
      opaque: Blocks.opaqueTable(),
      emission: Blocks.emission(),
    );
    final ring = [for (var dz = -1; dz <= 1; dz++) for (var dx = -1; dx <= 1; dx++) gen.generate(dx, dz)];
    // ring order in the world: c, nx, px, nz, pz, nxnz, pxnz, nxpz, pxpz
    Uint8List at(int dx, int dz) => ring[(dz + 1) * 3 + (dx + 1)];
    final r = mesher.build(0, 0, at(0, 0), at(-1, 0), at(1, 0), at(0, -1), at(0, 1), at(-1, -1), at(1, -1), at(-1, 1), at(1, 1));
    expect(r.faces > 200, isTrue);
    expect(r.solid.positions.length % 12, 0);
    expect(r.solid.colors.length, r.solid.vertexCount * 4);
    expect(r.solid.indices.length, r.solid.faceCount * 6);
    for (final i in r.solid.indices) {
      expect(i < r.solid.vertexCount, isTrue);
    }
  });

  test('a flat slab of stone with one tuft meshes into solid and cutout faces', () {
    final c = Uint8List(16 * 16 * 128);
    for (var i = 0; i < 16 * 16 * 40; i++) {
      c[i] = 1;
    }
    c[16 * 16 * 40 + 8 + 16 * 8] = Blocks.indexOf('tall_grass');
    final mesher = ChunkMesher(palette: Blocks.palette(), shape: Blocks.shapes(), opaque: Blocks.opaqueTable(), emission: Blocks.emission());
    final r = mesher.build(0, 0, c, null, null, null, null, null, null, null, null);
    expect(r.cutout.faceCount, 4);
    // top faces + the four open sides (neighbours are air when the ring is missing)
    expect(r.solid.faceCount, 16 * 16 + 4 * 16 * 40);
  });
}
