import 'package:dawnforge/game/database/smallburg/smallburg_crop_entity_database_def.dart';
import 'package:dawnforge/game/database/smallburg/smallburg_farm_consumable_item_database_def.dart';
import 'package:dawnforge/game/database/smallburg/smallburg_material_item_database_def.dart';
import 'package:dawnforge/game/database/smallburg/smallburg_seed_bag_item_database_def.dart';
import 'package:dawnforge/game/database/smallburg/smallburg_tool_item_database_def.dart';
import 'package:dawnforge/game/database/smallburg/smallburg_weapon_item_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/hand_item.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invariantes do catálogo de conteúdo.
///
/// Não medimos cobertura aqui — validamos **consistência de dados**. Estes
/// testes pegam em milissegundos o tipo de erro que só apareceria jogando:
/// item apontando para um id inexistente, planta que nunca amadurece, chave do
/// mapa divergindo do id da entidade.
///
/// Ver ADR-0002 (catálogo em constantes Dart) e refactoring/02-fase-2 §2.6.
void main() {
  final itemCatalogs = <String, Map<HandItemId, HandItem>>{
    'weapons': SmallBurgWeaponItemDatabaseDef.weaponsItemList,
    'tools': SmallBurgToolItemDatabaseDef.toolItemList,
    'harvest loot': SmallBurgHarvestLootItemDatabaseDef.harvestLootItemList,
    'materials': SmallBurgMaterialItemDatabaseDef.materialItemList,
    'seed bags': SmallBurgSeedBagItemDatabaseDef.seedBagList,
  };

  const crops = SmallBurgCropEntityDatabaseDef.cropEntityList;

  group('item catalogs', () {
    itemCatalogs.forEach((catalogName, catalog) {
      group(catalogName, () {
        test('is not empty', () {
          expect(catalog, isNotEmpty);
        });

        test('every map key matches the id of its item', () {
          catalog.forEach((key, item) {
            expect(item.id, key, reason: 'key $key holds item ${item.id}');
          });
        });

        test('no entry is keyed as unknown', () {
          expect(catalog.containsKey(HandItemId.unknown), isFalse);
        });

        test('every item has a non-empty name', () {
          for (final item in catalog.values) {
            expect(item.name.trim(), isNotEmpty, reason: '${item.id}');
          }
        });

        test('every item has a positive stack size', () {
          for (final item in catalog.values) {
            expect(item.maxStackSize, greaterThan(0), reason: '${item.id}');
          }
        });

        test('no item has a negative base value', () {
          for (final item in catalog.values) {
            expect(
              item.baseValue,
              greaterThanOrEqualTo(0),
              reason: '${item.id}',
            );
          }
        });

        test('every icon points at a spritesheet with positive dimensions', () {
          for (final item in catalog.values) {
            final icon = item.iconData;

            expect(
              icon.spritesheetPath.trim(),
              isNotEmpty,
              reason: '${item.id}',
            );
            expect(icon.spriteWidth, greaterThan(0), reason: '${item.id}');
            expect(icon.spriteHeight, greaterThan(0), reason: '${item.id}');
            expect(
              icon.spriteRowIndex,
              greaterThanOrEqualTo(0),
              reason: '${item.id}',
            );
            expect(
              icon.spriteColumnIndex,
              greaterThanOrEqualTo(0),
              reason: '${item.id}',
            );
          }
        });
      });
    });

    test('no item id is registered in more than one catalog', () {
      final seen = <HandItemId, String>{};

      itemCatalogs.forEach((catalogName, catalog) {
        for (final id in catalog.keys) {
          expect(
            seen.containsKey(id),
            isFalse,
            reason: '$id is in both "${seen[id]}" and "$catalogName"',
          );
          seen[id] = catalogName;
        }
      });
    });

    test('tools are single-slot items', () {
      for (final tool in SmallBurgToolItemDatabaseDef.toolItemList.values) {
        expect(tool.isStackable, isFalse, reason: '${tool.id}');
      }
    });

    test('seed bags are stackable', () {
      for (final seed in SmallBurgSeedBagItemDatabaseDef.seedBagList.values) {
        expect(seed.isStackable, isTrue, reason: '${seed.id}');
      }
    });
  });

  group('crop catalog', () {
    test('is not empty', () {
      expect(crops, isNotEmpty);
    });

    test('every map key matches the id of its crop', () {
      crops.forEach((key, crop) {
        expect(crop.id, key, reason: 'key $key holds crop ${crop.id}');
      });
    });

    test('every crop matures in a positive number of days', () {
      for (final crop in crops.values) {
        expect(crop.daysToMature, greaterThan(0), reason: '${crop.id}');
      }
    });

    test('every crop yields at least one item', () {
      for (final crop in crops.values) {
        expect(crop.yieldAmount, greaterThan(0), reason: '${crop.id}');
      }
    });

    test('every crop harvests into a known item id', () {
      for (final crop in crops.values) {
        expect(
          crop.harvestItemId,
          isNot(HandItemId.unknown),
          reason: '${crop.id}',
        );
      }
    });

    test('every harvest item exists in some item catalog', () {
      final allItemIds = itemCatalogs.values
          .expand((catalog) => catalog.keys)
          .toSet();

      for (final crop in crops.values) {
        expect(
          allItemIds,
          contains(crop.harvestItemId),
          reason:
              '${crop.id} harvests into ${crop.harvestItemId}, '
              'which is not registered anywhere',
        );
      }
    });

    test('every crop template starts with zero days planted', () {
      for (final crop in crops.values) {
        expect(crop.daysPlanted, 0, reason: '${crop.id}');
      }
    });

    // INCONSISTÊNCIA DE CONTEÚDO — ver PROGRESS.md.
    // `CropFactoryService.createCrop` zera `daysPlanted` mas **preserva o
    // `stage` do template**. Radish e strawberry começam em `planted`;
    // tomato e apple começam em `seedling`, ou seja, nascem 2 estágios à
    // frente e amadurecem antes do que `daysToMature` sugere.
    // Para a árvore (apple) isso pode ser proposital — um "sapling". Para o
    // tomate, quase certamente não é. Decidir antes de balancear o jogo.
    test('crop starting stages diverge across the catalog', () {
      final startingStages = {
        for (final entry in crops.entries) entry.key: entry.value.stage,
      };

      expect(startingStages[HandItemId.radish], CropStageType.planted);
      expect(startingStages[HandItemId.strawberry], CropStageType.planted);
      expect(startingStages[HandItemId.tomato], CropStageType.seedling);
      expect(startingStages[HandItemId.apple], CropStageType.seedling);
    });

    test('no crop template starts already harvestable', () {
      for (final crop in crops.values) {
        expect(
          crop.stage,
          isNot(CropStageType.harvestable),
          reason: '${crop.id} could be harvested the moment it is planted',
        );
      }
    });

    test('every crop has a renderable spritesheet definition', () {
      for (final crop in crops.values) {
        expect(crop.spritesheetPath.trim(), isNotEmpty, reason: '${crop.id}');
        expect(crop.spriteWidth, greaterThan(0), reason: '${crop.id}');
        expect(crop.spriteHeight, greaterThan(0), reason: '${crop.id}');
        expect(crop.framesCount, greaterThan(0), reason: '${crop.id}');
        expect(
          crop.spriteRowIndex,
          greaterThanOrEqualTo(0),
          reason: '${crop.id}',
        );
        expect(
          crop.skipFirstFrames,
          greaterThanOrEqualTo(0),
          reason: '${crop.id}',
        );
      }
    });

    test('a regrowing crop defines a positive regrow step', () {
      for (final crop in crops.values) {
        if (!crop.regrowData.isRegrow) continue;

        expect(
          crop.regrowData.regrowStepDays,
          greaterThan(0),
          reason: '${crop.id} regrows but never advances',
        );
        expect(
          crop.regrowData.regrowStageRollback,
          greaterThan(0),
          reason: '${crop.id} regrows but rolls back zero stages',
        );
      }
    });

    test('catalogue crops are never mid-regrow', () {
      for (final crop in crops.values) {
        expect(crop.regrowData.isRegrowing, isFalse, reason: '${crop.id}');
        expect(crop.regrowData.daysInStage, 0, reason: '${crop.id}');
      }
    });

    test('every crop can actually reach the harvestable stage', () {
      for (final crop in crops.values) {
        var current = crop;

        // Limite generoso: 200 dias é muito além de qualquer plantação real.
        for (var day = 0; day < 200; day++) {
          if (current.stage == CropStageType.harvestable) break;
          current = current.advanceDay();
        }

        expect(
          current.stage,
          CropStageType.harvestable,
          reason: '${crop.id} never reaches harvest within 200 days',
        );
      }
    });
  });

  group('seed → crop wiring', () {
    test('every seed bag points at a crop that exists in the catalog', () {
      final seeds = SmallBurgSeedBagItemDatabaseDef.seedBagList;

      expect(seeds, isNotEmpty);
      for (final entry in seeds.entries) {
        expect(
          crops.containsKey(entry.value.cropId),
          isTrue,
          reason:
              '${entry.key} points at crop ${entry.value.cropId}, '
              'which is not in the crop catalog',
        );
      }
    });

    // O PlantSeedUseCase deriva o id da crop removendo o sufixo `_seed_bag`.
    // Se o nome do seed bag não seguir essa regra, o plantio falha em runtime.
    test('every seed bag name maps onto its crop by dropping the suffix', () {
      for (final entry in SmallBurgSeedBagItemDatabaseDef.seedBagList.entries) {
        final derived = HandItemId.fromString(
          entry.key.name.replaceAll('_seed_bag', ''),
        );

        expect(
          derived,
          entry.value.cropId,
          reason:
              '${entry.key} derives to $derived but declares '
              '${entry.value.cropId} — PlantSeedUseCase would plant the wrong '
              'crop or nothing at all',
        );
      }
    });

    test('every catalog crop is reachable through some seed bag', () {
      final plantableCropIds = SmallBurgSeedBagItemDatabaseDef
          .seedBagList
          .values
          .map((seed) => seed.cropId)
          .toSet();

      for (final cropId in crops.keys) {
        expect(
          plantableCropIds,
          contains(cropId),
          reason: '$cropId exists but no seed bag can plant it',
        );
      }
    });
  });
}
