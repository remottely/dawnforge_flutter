import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP2.6 gate: the registries boot from the REAL pipeline output on disk
/// (`dawnforge.py import` over the imported pack slice) — not from fixtures.
void main() {
  final almanacDir =
      Directory(ContentPaths.almanacRoot(GameConstants.gameName));

  Map<String, Object?> readJson(String relativePath) =>
      jsonDecode(File('${almanacDir.path}/$relativePath').readAsStringSync())!
          as Map<String, Object?>;

  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  test('registries boot from the generated almanac (FP2.6 gate)', () {
    final manifest = readJson('manifest.json');
    const AlmanacLoader().loadFromManifest(manifest, readJson);

    // Every manifest entry landed in exactly one registry.
    final entries = (manifest['entries']! as List).cast<Map<String, Object?>>();
    int countOf(String family) =>
        entries.where((e) => (e['type']! as String).startsWith(family)).length;

    expect(locator<ActorRegistry>().count, countOf('actor_'));
    expect(locator<PropRegistry>().count, countOf('prop_'));
    expect(locator<GroundRegistry>().count, countOf('ground_'));
    expect(locator<ItemRegistry>().count, countOf('item_'));
    expect(entries, isNotEmpty);
  });

  test('a known item parses with its authored values', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final tomato = locator<ItemRegistry>()
        .getItem('t2_item_consumable_vegetable_tomato');
    expect(tomato.maxStack, 100);
    expect(tomato.materialType, MaterialType.fabric);
  });

  test('a known crop prop parses through the world-object hierarchy', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final clover =
        locator<PropRegistry>().getProp('t1_prop_crop_bush_clover');
    expect(clover.hidesActors, isTrue);
    expect(clover.allowsActorOverlap, isTrue);
    expect(clover.currentHealth, clover.maxHealth);
  });

  test('the procedural terrain ground parses with its authored knobs (FP3.4)',
      () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final terrain =
        locator<GroundRegistry>().getGround('t1_ground_buildable_terrain');
    expect(terrain.isDenseTerrain, isTrue);
    expect(terrain.farmPropId, 't1_prop_soil');
    expect(terrain.farmTools, [ToolType.shovel]);
    expect(terrain.allowsActorOverlap, isFalse);
    expect(terrain.spritesheetPath, isNotEmpty,
        reason: 'the chunk renderer bakes this tile from its sprite');
  });

  test('the biome manifest boots the BiomeRegistry (FP3.4, step 11)', () {
    final biomesDir =
        Directory(ContentPaths.worldBiomesRoot(GameConstants.gameName));
    Map<String, Object?> readBiome(String relativePath) =>
        jsonDecode(File('${biomesDir.path}/$relativePath').readAsStringSync())!
            as Map<String, Object?>;

    final manifest = readBiome('manifest.json');
    const AlmanacLoader().loadFromManifest(manifest, readBiome);

    final entries = (manifest['entries']! as List).cast<Map<String, Object?>>();
    expect(locator<BiomeRegistry>().count, entries.length);
    expect(entries, isNotEmpty);

    // The forest's densities as procedural_forest.md authors them — shares of
    // the world, converted to noise cuts by the ProceduralWorldManager.
    final forest = locator<BiomeRegistry>().getBiome('biome_forest_data');
    expect(forest.tier, 1);
    expect(forest.terrainWaterShare, 0.08);
    expect(forest.terrainWallShare, 0.15);
    expect(forest.terrainWallHeight2Share, 0.25);
    expect(forest.terrainWallHeight3Share, 0.08);
  });
}
