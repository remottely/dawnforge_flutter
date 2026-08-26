import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
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

  test('empty grounds route to GroundEmptyData with their flags (FP3.4)', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final grounds = locator<GroundRegistry>();
    expect(grounds.getGround('t1_ground_empty_water'), isA<GroundEmptyData>());
    expect(grounds.getGround('t1_ground_empty_cliff'), isA<GroundEmptyData>());
    final water = grounds.getGround('t1_ground_empty_water') as GroundEmptyData;
    final cliff = grounds.getGround('t1_ground_empty_cliff') as GroundEmptyData;
    expect(water.isWater, isTrue);
    expect(water.isPassable, isFalse);
    expect(cliff.isWater, isFalse);
    expect(cliff.isPassable, isFalse);
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

  test('loot tables parse and survive the clone (FP4.1a)', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final rock = locator<PropRegistry>().getProp('t1_prop_rock_moss');
    expect(rock.drops, hasLength(1));
    expect(rock.drops.single.itemId, 't1_item_stone_moss');
    expect(rock.drops.single.chance, 1.0);
    expect(rock.drops.single.minAmount, 1);
    expect(rock.drops.single.maxAmount, 1);

    // The clone a factory injects carries the table too (rule 3).
    expect(rock.clone().drops.single.itemId, 't1_item_stone_moss');
  });

  test('the biome population tables parse (FP4.1a, step 11)', () {
    final biomesDir =
        Directory(ContentPaths.worldBiomesRoot(GameConstants.gameName));
    Map<String, Object?> readBiome(String relativePath) =>
        jsonDecode(File('${biomesDir.path}/$relativePath').readAsStringSync())!
            as Map<String, Object?>;
    const AlmanacLoader().loadFromManifest(readBiome('manifest.json'),
        readBiome);

    final forest = locator<BiomeRegistry>().getBiome('biome_forest_data');
    expect(forest.maxPropsPerChunk, 24);
    expect(forest.maxActorsPerChunk, 1);
    expect(forest.densityNoiseFrequency, 0.005);
    expect(forest.propEntries, hasLength(10));
    expect(forest.actorEntries, hasLength(3));

    // Grass, as procedural_forest.md authors it.
    final grass = forest.propEntries
        .singleWhere((e) => e.propId == 't1_prop_grass_wild');
    expect(grass.attemptsPerChunk, 4);
    expect(grass.spawnChance, 0.6);
    expect(grass.clusterMin, 3);
    expect(grass.clusterMax, 8);
    expect(grass.clusterRadius, 3);
    expect(grass.densityInfluence, 0.0,
        reason: 'omitted in the .md — the declared default is an even spread');

    // Ore opts into the richness field; vegetation does not.
    final coal = forest.propEntries
        .singleWhere((e) => e.propId == 't1_prop_rock_coal');
    expect(coal.densityInfluence, 0.5);

    final boar = forest.actorEntries
        .singleWhere((e) => e.actorId == 't1_actor_creature_boar');
    expect(boar.packChance, 0.07);
    expect(boar.packMin, 2);
    expect(boar.packMax, 3);
    expect(boar.packRadius, 2);
  });

  test('every population and loot id resolves in the real content (FP4.1a '
      'seam)', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);
    final biomesDir =
        Directory(ContentPaths.worldBiomesRoot(GameConstants.gameName));
    Map<String, Object?> readBiome(String relativePath) =>
        jsonDecode(File('${biomesDir.path}/$relativePath').readAsStringSync())!
            as Map<String, Object?>;
    const AlmanacLoader().loadFromManifest(readBiome('manifest.json'),
        readBiome);

    final biomes = locator<BiomeRegistry>();
    final props = locator<PropRegistry>();
    final actors = locator<ActorRegistry>();
    final items = locator<ItemRegistry>();

    for (final biomeId in biomes.ids) {
      final biome = biomes.getBiome(biomeId);
      for (final entry in biome.propEntries) {
        expect(() => props.getProp(entry.propId), returnsNormally,
            reason: '$biomeId spawns ${entry.propId}');
      }
      for (final entry in biome.actorEntries) {
        expect(() => actors.getActor(entry.actorId), returnsNormally,
            reason: '$biomeId spawns ${entry.actorId}');
      }
    }

    // Prop and actor loot only: a ground's table rolls on ground destruction,
    // which is FP7's verb — its ids (buildable grounds) join the subset there.
    for (final propId in props.ids) {
      for (final entry in props.getProp(propId).drops) {
        expect(() => items.getItem(entry.itemId), returnsNormally,
            reason: '$propId drops ${entry.itemId}');
      }
    }
    for (final actorId in actors.ids) {
      for (final entry in actors.getActor(actorId).drops) {
        expect(() => items.getItem(entry.itemId), returnsNormally,
            reason: '$actorId drops ${entry.itemId}');
      }
    }
  });
}
