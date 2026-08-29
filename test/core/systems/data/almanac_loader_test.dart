import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
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
    int countOf(List<String> spellings) => entries
        .where((e) => spellings.any((s) => (e['type']! as String).startsWith(s)))
        .length;

    // The actor family has two spellings: the pack authors a BASE class
    // directly where the hierarchy has no leaf for it, and the player
    // (`i_actor_biological_data`) is the case.
    final actors = countOf(<String>['actor_', 'i_actor_']);
    final props = countOf(<String>['prop_']);
    final grounds = countOf(<String>['ground_']);
    final items = countOf(<String>['item_']);

    expect(locator<ActorRegistry>().count, actors);
    expect(locator<PropRegistry>().count, props);
    expect(locator<GroundRegistry>().count, grounds);
    expect(locator<ItemRegistry>().count, items);
    expect(entries, isNotEmpty);

    // The partition is the real invariant: an entry that reached NO registry
    // would leave the per-family counts above agreeing with each other and the
    // game short one object. A new family has to be routed, not absorbed.
    expect(actors + props + grounds + items, entries.length,
        reason: 'a manifest entry landed outside every registry');
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

  test('buildable items route to their class and resolve their blueprints '
      '(FP4.3b)', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final items = locator<ItemRegistry>();
    final buildables = items.ids
        .map(items.getItem)
        .whereType<ItemBuildableData>()
        .toList();
    expect(buildables, isNotEmpty,
        reason: 'the pack authors item_buildable_data documents');

    // Every blueprint in the real pack points at something authored. This is
    // the whole seam of the slice: the id crosses from an ITEM document to a
    // world-object one, and nothing but this check reads both ends.
    for (final item in buildables) {
      expect(() => item.blueprint, returnsNormally,
          reason: '${item.id} builds ${item.blueprintId}');
      expect(item.isPropBlueprint ^ item.isGroundBlueprint, isTrue,
          reason: '${item.id} builds exactly one kind of world object');
    }

    // The two kinds, each by name, so the routing cannot quietly collapse into
    // one of them.
    final smelter =
        items.getItem('t1_item_buildable_workstation_smelter')
            as ItemBuildableData;
    expect(smelter.isPropBlueprint, isTrue);
    expect(smelter.blueprint.gridWidth, 2, reason: 'the smelter is 2x1');
    expect(smelter.maxStack, 1, reason: 'a workstation does not stack');

    final bridge = items.getItem('t1_item_buildable_ground_bridge_palm')
        as ItemBuildableData;
    expect(bridge.isGroundBlueprint, isTrue);
    expect(
      (bridge.blueprint as GroundBuildableData).floatsOnWater,
      isTrue,
      reason: 'a bridge is the ground that goes over water',
    );
    expect(bridge.actionRange, 1.0);
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
    final grounds = locator<GroundRegistry>();

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

    // GROUND tables joined the subset at FP4.3b. Their ids are the buildable
    // ITEMS a destroyed tile hands back, and until the blueprints were imported
    // none of them existed to resolve — so the loop that guards every other
    // loot table had to skip the one family whose entries were dangling. What
    // rolls those tables is still FP7's verb; what makes them checkable is the
    // blueprint import, and an id going missing should fail here rather than in
    // the commit that finally rolls them.
    for (final groundId in grounds.ids) {
      for (final entry in grounds.getGround(groundId).drops) {
        expect(() => items.getItem(entry.itemId), returnsNormally,
            reason: '$groundId drops ${entry.itemId}');
      }
    }
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
