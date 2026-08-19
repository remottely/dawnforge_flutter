import 'package:dawnforge/game/features/farm/managers/farm_manager.dart';
import 'package:dawnforge/game/features/farm/services/crop_factory_service.dart';
import 'package:dawnforge/game/features/farm/usecases/harvest_crop_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/load_farm_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/plant_seed_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/save_farm_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/till_soil_use_case.dart';
import 'package:dawnforge/game/features/farm/usecases/water_tile_use_case.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/remove_item_use_case.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';
import '../../../../helpers/test_data_builders.dart';

void main() {
  late FarmManager farm;
  late InventoryManager inventory;
  late AddItemUseCase addItem;
  late RemoveItemUseCase removeItem;

  setUp(() async {
    await resetAllManagers();
    farm = FarmManager.instance;
    inventory = InventoryManager.instance;
    addItem = AddItemUseCase(inventory, ItemFactoryService.instance);
    removeItem = RemoveItemUseCase(inventory);
  });

  SoilState soilAt(int x, int y) =>
      (farm.getTile(x, y)!.object! as FarmObject).soilState;

  group('TillSoilUseCase', () {
    late TillSoilUseCase useCase;

    setUp(() => useCase = TillSoilUseCase(farm));

    test('an empty coordinate creates a tilled tile', () {
      final tilled = useCase.call(2, 3);

      expect(tilled, isTrue);
      expect(soilAt(2, 3), SoilState.tilled);
    });

    test('negative coordinates are rejected', () {
      expect(useCase.call(-1, 0), isFalse);
      expect(useCase.call(0, -1), isFalse);
    });

    test('already tilled soil → false', () {
      useCase.call(0, 0);

      expect(useCase.call(0, 0), isFalse);
    });

    test('watered soil cannot be tilled again', () {
      farm.setTile(aFarmTile(soilState: SoilState.watered));

      expect(useCase.call(0, 0), isFalse);
    });

    test('publishes the tilled tile on lastTilledNotifier', () {
      useCase.call(1, 1);

      expect(farm.lastTilledNotifier.value, isNotNull);
      expect(farm.lastTilledNotifier.value!.x, 1);
    });
  });

  group('WaterTileUseCase', () {
    late WaterTileUseCase useCase;

    setUp(() => useCase = WaterTileUseCase(farm));

    test('tilled soil is watered', () {
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      expect(useCase.call(0, 0), isTrue);
      expect(soilAt(0, 0), SoilState.watered);
    });

    test('negative coordinates are rejected', () {
      expect(useCase.call(-1, 0), isFalse);
    });

    test('a tile that does not exist → false', () {
      expect(useCase.call(5, 5), isFalse);
    });

    test('untilled soil → false', () {
      farm.setTile(aFarmTile());

      expect(useCase.call(0, 0), isFalse);
    });

    test('already watered → false', () {
      farm.setTile(aFarmTile(soilState: SoilState.watered));

      expect(useCase.call(0, 0), isFalse);
    });
  });

  group('PlantSeedUseCase', () {
    late PlantSeedUseCase useCase;

    setUp(() {
      useCase = PlantSeedUseCase(
        farm,
        removeItem,
        addItem,
        CropFactoryService.instance,
      );
    });

    test('with the seed in hand and tilled soil → planted', () {
      addItem.call(HandItemId.radish_seed_bag, 1);
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      final planted = useCase.call(0, 0, HandItemId.radish_seed_bag);

      expect(planted, isTrue);
      expect((farm.getTile(0, 0)!.object! as FarmObject).crop, isNotNull);
    });

    test('consumes exactly one seed from the inventory', () {
      addItem.call(HandItemId.radish_seed_bag, 3);
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      useCase.call(0, 0, HandItemId.radish_seed_bag);

      expect(inventory.getItemQuantity('radish_seed_bag'), 2);
    });

    test('without the seed → false and nothing is planted', () {
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      final planted = useCase.call(0, 0, HandItemId.radish_seed_bag);

      expect(planted, isFalse);
      expect((farm.getTile(0, 0)!.object! as FarmObject).crop, isNull);
    });

    test('unprepared soil → seed is refunded', () {
      addItem.call(HandItemId.radish_seed_bag, 1);
      farm.setTile(aFarmTile()); // untilled

      final planted = useCase.call(0, 0, HandItemId.radish_seed_bag);

      expect(planted, isFalse);
      expect(
        inventory.getItemQuantity('radish_seed_bag'),
        1,
        reason: 'the seed must go back to the inventory',
      );
    });

    test('an occupied tile → seed is refunded', () {
      addItem.call(HandItemId.radish_seed_bag, 1);
      farm.setTile(aFarmTile(soilState: SoilState.tilled, crop: aCrop()));

      final planted = useCase.call(0, 0, HandItemId.radish_seed_bag);

      expect(planted, isFalse);
      expect(inventory.getItemQuantity('radish_seed_bag'), 1);
    });

    // ⚠️ Caminho SEM compensação: quando o tile não existe, o use case sai
    // antes de devolver a semente. Ver refactoring/03-fase-3 §3.3.
    test('a tile that does not exist → seed is LOST (no refund path)', () {
      addItem.call(HandItemId.radish_seed_bag, 1);

      final planted = useCase.call(9, 9, HandItemId.radish_seed_bag);

      expect(planted, isFalse);
      expect(inventory.getItemQuantity('radish_seed_bag'), 0);
    });

    test('a tree seed plants on untilled soil', () {
      addItem.call(HandItemId.apple_seed_bag, 1);
      farm.setTile(aFarmTile());

      final planted = useCase.call(0, 0, HandItemId.apple_seed_bag);

      expect(planted, isTrue);
      expect((farm.getTile(0, 0)!.object! as FarmObject).crop!.isTree, isTrue);
    });

    test('a tree seed on tilled soil → refused and refunded', () {
      addItem.call(HandItemId.apple_seed_bag, 1);
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      expect(useCase.call(0, 0, HandItemId.apple_seed_bag), isFalse);
      expect(inventory.getItemQuantity('apple_seed_bag'), 1);
    });

    test('the planted crop starts at day zero', () {
      addItem.call(HandItemId.radish_seed_bag, 1);
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      useCase.call(0, 0, HandItemId.radish_seed_bag);

      final crop = (farm.getTile(0, 0)!.object! as FarmObject).crop!;
      expect(crop.daysPlanted, 0);
      expect(crop.stage, CropStageType.planted);
    });
  });

  group('HarvestCropUseCase', () {
    late HarvestCropUseCase useCase;

    setUp(() => useCase = HarvestCropUseCase(farm, addItem));

    test('a ripe crop is harvested into the inventory', () {
      farm.setTile(
        aFarmTile(
          soilState: SoilState.tilled,
          crop: aCrop(
            stage: CropStageType.harvestable,
            yieldAmount: 3,
            harvestItemId: HandItemId.radish_loot_item,
          ),
        ),
      );

      final harvested = useCase.call(0, 0);

      expect(harvested, isTrue);
      expect(inventory.getItemQuantity('radish_loot_item'), 3);
    });

    test('the tile is emptied after harvesting', () {
      farm.setTile(
        aFarmTile(
          soilState: SoilState.tilled,
          crop: aCrop(stage: CropStageType.harvestable),
        ),
      );

      useCase.call(0, 0);

      expect((farm.getTile(0, 0)!.object! as FarmObject).crop, isNull);
    });

    test('an unripe crop → false and nothing enters the inventory', () {
      farm.setTile(
        aFarmTile(
          soilState: SoilState.tilled,
          crop: aCrop(stage: CropStageType.flowering),
        ),
      );

      expect(useCase.call(0, 0), isFalse);
      expect(inventory.isEmpty, isTrue);
    });

    test('an empty tile → false', () {
      farm.setTile(aFarmTile(soilState: SoilState.tilled));

      expect(useCase.call(0, 0), isFalse);
    });

    test('a tile that does not exist → false', () {
      expect(useCase.call(9, 9), isFalse);
    });

    test('a regrowing crop yields loot and stays planted', () {
      farm.setTile(
        aFarmTile(
          soilState: SoilState.tilled,
          crop: aRegrowingCrop(stage: CropStageType.harvestable),
        ),
      );

      final harvested = useCase.call(0, 0);

      expect(harvested, isTrue);
      expect(inventory.getItemQuantity('strawberry_loot_item'), greaterThan(0));
      expect((farm.getTile(0, 0)!.object! as FarmObject).crop, isNotNull);
    });

    // ⚠️ COMPORTAMENTO ATUAL, PERIGOSO — ver refactoring/03-fase-3 §3.8.
    // A colheita remove a crop do tile ANTES de tentar guardar o loot. Com o
    // inventário cheio, o item é perdido sem compensação — o próprio código
    // reconhece isso num comentário. Ao corrigir, o use case deve checar
    // espaço antes e devolver `false` com a crop intacta.
    test('inventory full → crop is consumed and the loot is LOST', () {
      // Preenche todos os slots com ferramentas não-empilháveis.
      addItem.addItemEntity(aNonStackableItem(), inventory.maxSlots);
      farm.setTile(
        aFarmTile(
          soilState: SoilState.tilled,
          crop: aCrop(
            stage: CropStageType.harvestable,
            harvestItemId: HandItemId.radish_loot_item,
          ),
        ),
      );

      final harvested = useCase.call(0, 0);

      expect(harvested, isFalse);
      expect(inventory.getItemQuantity('radish_loot_item'), 0);
      expect(
        (farm.getTile(0, 0)!.object! as FarmObject).crop,
        isNull,
        reason: 'the crop is gone even though the player got nothing',
      );
    });
  });

  group('Save/LoadFarmUseCase', () {
    late SaveFarmUseCase save;
    late LoadFarmUseCase load;

    setUp(() {
      save = SaveFarmUseCase(farm);
      load = LoadFarmUseCase(farm, CropFactoryService.instance);
    });

    test('save produces a versioned, timestamped payload', () {
      final data = save.call();

      expect(data['version'], 1);
      expect(data['timestamp'], isA<String>());
      expect(data['farm'], isA<Map<String, dynamic>>());
    });

    test('round-trips tiles and crops', () {
      farm
        ..setTile(aFarmTile(x: 1, y: 1, soilState: SoilState.watered))
        ..setTile(
          aFarmTile(
            x: 2,
            y: 2,
            soilState: SoilState.tilled,
            crop: aCrop(stage: CropStageType.budding),
          ),
        );

      final data = save.call();
      farm.clear();
      load.call(data);

      expect(farm.getAllTiles().length, 2);
      expect(soilAt(1, 1), SoilState.watered);
      expect(
        (farm.getTile(2, 2)!.object! as FarmObject).crop!.stage,
        CropStageType.budding,
      );
    });

    test('an empty farm round-trips as empty', () {
      final data = save.call();

      load.call(data);

      expect(farm.getAllTiles(), isEmpty);
    });

    test('a future save version is rejected', () {
      expect(
        () => load.call(<String, dynamic>{
          'version': 99,
          'farm': <String, dynamic>{},
        }),
        throwsException,
      );
    });

    test('a payload without farm data is rejected', () {
      expect(() => load.call(<String, dynamic>{'version': 1}), throwsException);
    });

    test('a missing version is treated as version 1', () {
      farm.setTile(aFarmTile(x: 1, y: 1, soilState: SoilState.tilled));
      final farmData = farm.toJson();
      farm.clear();

      load.call(<String, dynamic>{'farm': farmData});

      expect(farm.getAllTiles().length, 1);
    });
  });
}
