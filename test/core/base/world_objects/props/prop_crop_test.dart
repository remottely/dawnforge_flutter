import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_crop.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_actor_entry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/spawning/procedural_spawn_system.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/generated/component_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.4, the minimal core pulled forward: a wild crop surfaces at a stage,
/// and what it leaves behind is that stage's table on top of its plain one.
/// Until this, no palm in the world gave a log — the logs live in the
/// BUDDING table and nothing read it.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{'id': 't1_item_logs_palm', 'max_stack': 10})
      ..registerJson(<String, Object?>{'id': 't1_item_fiber_vine', 'max_stack': 10})
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
      });
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
    });
    locator<PropRegistry>()
      ..registerJson(<String, Object?>{
        'type': 'prop_crop_data',
        'id': 't1_prop_crop_tree_palm',
        'peak_stage': 'BUDDING',
        'is_immortal': true,
        'is_hand_harvestable': false,
        'allowed_tools': <String>['INNATE', 'AXE'],
        'base_max_health': 1,
        'allows_actor_overlap': true,
        // The plain half: fibre at every stage.
        'drops': <Map<String, Object?>>[
          <String, Object?>{
            'item_id': 't1_item_fiber_vine',
            'chance': 1.0,
            'min_amount': 1,
            'max_amount': 1,
          },
        ],
        // The stage half: logs only once grown.
        'stage_drop_configs': <String, Object?>{
          'BUDDING': <Map<String, Object?>>[
            <String, Object?>{
              'item_id': 't1_item_logs_palm',
              'chance': 1.0,
              'min_amount': 2,
              'max_amount': 2,
            },
          ],
        },
      })
      ..registerJson(<String, Object?>{'id': 't1_prop_rock_probe'});

    final grid = locator<GridManager>();
    for (var x = -4; x <= 20; x++) {
      for (var y = -4; y <= 20; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  PropCrop palmAt(GridPos at, CropStage stage) {
    final palm = PropFactory.create(
      't1_prop_crop_tree_palm',
      locator<GridManager>().gridToWorld(at),
      random: Random(20260910),
    ) as PropCrop
      ..setGrowthStage(stage);
    locator<GridManager>().occupyPropTiles(at, palm);
    return palm;
  }

  List<String> fell(Prop prop) {
    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    final hands = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    expect(prop.takeDamage(1, hands), isTrue);
    return spawned.map((p) => '${p.amount}× ${p.itemData.id}').toList();
  }

  test('the factory routes crop data to a crop host with both drop halves', () {
    final palm = palmAt(const GridPos(2, 2), CropStage.planted);
    expect(palm.hasComponent(ComponentKeys.drop), isTrue);
    expect(palm.hasComponent(ComponentKeys.cropDrop), isTrue);
    expect(PropFactory.create('t1_prop_rock_probe', WorldPos.zero),
        isNot(isA<PropCrop>()));
  });

  test('a grown palm gives its logs ON TOP of its plain table', () {
    final loot = fell(palmAt(const GridPos(2, 2), CropStage.budding));
    expect(loot, <String>['1× t1_item_fiber_vine', '2× t1_item_logs_palm'],
        reason: 'plain half first, then the stage half — two halves that ADD');
  });

  test('a sapling gives only its plain table', () {
    final loot = fell(palmAt(const GridPos(2, 2), CropStage.sprout));
    expect(loot, <String>['1× t1_item_fiber_vine']);
  });

  group('the scatter', () {
    const chunkSize = GameConstants.proceduralChunkSize;

    BiomeData palmForest() => BiomeData(
          id: 'biome_probe_data',
          tier: 1,
          terrainWaterShare: 0.08,
          terrainWallShare: 0.15,
          terrainWallHeight2Share: 0.25,
          terrainWallHeight3Share: 0.08,
          maxPropsPerChunk: 12,
          maxActorsPerChunk: 0,
          densityNoiseFrequency: 0.005,
          propEntries: <BiomePropEntry>[
            BiomePropEntry(
              propId: 't1_prop_crop_tree_palm',
              attemptsPerChunk: 12,
              spawnChance: 1,
              clusterMin: 1,
              clusterMax: 1,
              clusterRadius: 1,
            ),
            BiomePropEntry(
              propId: 't1_prop_rock_probe',
              attemptsPerChunk: 2,
              spawnChance: 1,
              clusterMin: 1,
              clusterMax: 1,
              clusterRadius: 1,
            ),
          ],
          actorEntries: const <BiomeActorEntry>[],
        );

    List<Prop> populate(int seed) {
      final spawned = <Prop>[];
      locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));
      locator<ProceduralSpawnSystem>()
          .initialize(worldSeed: seed, biome: palmForest());
      locator<ChunkStreamingSystem>().chunkLoaded.emit(const GridPos(0, 0));
      return spawned;
    }

    test('surfaces each wild crop at a stage up to its peak, a rock at none', () {
      // chunkSize tiles of terrain were registered in setUp for chunk (0, 0).
      assert(chunkSize <= 20, 'the fixture terrain covers one chunk');
      final spawned = populate(20260910);
      final palms = spawned.whereType<PropCrop>().toList();
      expect(palms, isNotEmpty);
      final stages = palms.map((p) => p.cropData.currentStage).toSet();
      for (final stage in stages) {
        expect(stage.index, lessThanOrEqualTo(CropStage.budding.index));
      }
      expect(stages.length, greaterThan(1),
          reason: 'a forest is not all saplings and not all giants');
      expect(spawned.where((p) => p.data.id == 't1_prop_rock_probe'),
          everyElement(isNot(isA<PropCrop>())));
    });

    test('the same seed surfaces the same stages', () async {
      final first = populate(7)
          .whereType<PropCrop>()
          .map((p) => '${p.position}:${p.cropData.currentStage}')
          .toList();
      await resetCoreSystems();
      registerCoreSystems();
      // Re-register the fixture the reset threw away.
      locator<ItemRegistry>()
        ..registerJson(<String, Object?>{'id': 't1_item_logs_palm'})
        ..registerJson(<String, Object?>{'id': 't1_item_fiber_vine'});
      locator<PropRegistry>()
        ..registerJson(<String, Object?>{
          'type': 'prop_crop_data',
          'id': 't1_prop_crop_tree_palm',
          'peak_stage': 'BUDDING',
          'is_immortal': true,
        })
        ..registerJson(<String, Object?>{'id': 't1_prop_rock_probe'});
      final grid = locator<GridManager>();
      for (var x = 0; x < chunkSize; x++) {
        for (var y = 0; y < chunkSize; y++) {
          grid.registerGroundData(
            GridPos(x, y),
            GroundBuildableData(id: 't1_ground_buildable_terrain'),
          );
        }
      }
      final second = populate(7)
          .whereType<PropCrop>()
          .map((p) => '${p.position}:${p.cropData.currentStage}')
          .toList();
      expect(second, first);
    });
  });
}
