import 'package:dawnforge/game/features/farm/managers/farm_manager.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:dawnforge/game/systems/world/world_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';
import '../../../../helpers/test_data_builders.dart';

void main() {
  late FarmManager manager;

  setUp(() async {
    await resetAllManagers();
    manager = FarmManager.instance;
  });

  group('FarmManager', () {
    group('tile storage', () {
      test('starts with no tiles', () {
        expect(manager.getAllTiles(), isEmpty);
      });

      test('setTile then getTile round-trips by coordinate', () {
        manager.setTile(aFarmTile(x: 3, y: 4));

        expect(manager.getTile(3, 4), isNotNull);
        expect(manager.getTile(4, 3), isNull);
      });

      test('setTile on the same coordinate replaces the tile', () {
        manager
          ..setTile(aFarmTile(soilState: SoilState.untilled))
          ..setTile(aFarmTile(soilState: SoilState.tilled));

        expect(manager.getAllTiles().length, 1);
        expect(
          (manager.getTile(0, 0)!.object! as FarmObject).soilState,
          SoilState.tilled,
        );
      });

      test('negative coordinates are stored like any other', () {
        manager.setTile(aFarmTile(x: -2, y: -5));

        expect(manager.getTile(-2, -5), isNotNull);
      });
    });

    group('waterTile', () {
      test('tilled soil → watered, stamped with the current day', () {
        manager.setTile(aFarmTile(soilState: SoilState.tilled));

        final watered = manager.waterTile(0, 0);

        expect(watered, isTrue);
        final object = manager.getTile(0, 0)!.object! as FarmObject;
        expect(object.soilState, SoilState.watered);
        expect(object.lastWateredDay, WorldStateManager.instance.currentDay);
      });

      test('missing tile → false', () {
        expect(manager.waterTile(0, 0), isFalse);
      });

      test('untilled soil → false', () {
        manager.setTile(aFarmTile());

        expect(manager.waterTile(0, 0), isFalse);
      });

      test('already watered → false', () {
        manager.setTile(aFarmTile(soilState: SoilState.watered));

        expect(manager.waterTile(0, 0), isFalse);
      });
    });

    group('plantSeed', () {
      test('tilled soil accepts a crop', () {
        manager.setTile(aFarmTile(soilState: SoilState.tilled));

        final planted = manager.plantSeed(0, 0, aCrop());

        expect(planted, isTrue);
        expect((manager.getTile(0, 0)!.object! as FarmObject).crop, isNotNull);
      });

      test('untilled soil rejects a crop', () {
        manager.setTile(aFarmTile());

        expect(manager.plantSeed(0, 0, aCrop()), isFalse);
      });

      test('untilled soil accepts a tree', () {
        manager.setTile(aFarmTile());

        expect(manager.plantSeed(0, 0, aTree()), isTrue);
      });

      test('tilled soil rejects a tree', () {
        manager.setTile(aFarmTile(soilState: SoilState.tilled));

        expect(manager.plantSeed(0, 0, aTree()), isFalse);
      });

      test('an occupied tile rejects a second crop', () {
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aCrop(name: 'First'),
          ),
        );

        expect(manager.plantSeed(0, 0, aCrop(name: 'Second')), isFalse);
      });

      test('missing tile → false', () {
        expect(manager.plantSeed(0, 0, aCrop()), isFalse);
      });
    });

    group('harvestCrop', () {
      test('a harvestable crop is returned and taken off the tile', () {
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aCrop(stage: CropStageType.harvestable),
          ),
        );

        final harvested = manager.harvestCrop(0, 0);

        expect(harvested, isNotNull);
        expect((manager.getTile(0, 0)!.object! as FarmObject).crop, isNull);
      });

      test('an unripe crop → null and the crop stays', () {
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aCrop(stage: CropStageType.flowering),
          ),
        );

        expect(manager.harvestCrop(0, 0), isNull);
        expect((manager.getTile(0, 0)!.object! as FarmObject).crop, isNotNull);
      });

      test('an empty tile → null', () {
        manager.setTile(aFarmTile(soilState: SoilState.tilled));

        expect(manager.harvestCrop(0, 0), isNull);
      });

      test('missing tile → null', () {
        expect(manager.harvestCrop(0, 0), isNull);
      });

      test('a regrowing crop stays on the tile, rolled back', () {
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aRegrowingCrop(stage: CropStageType.harvestable),
          ),
        );

        final harvested = manager.harvestCrop(0, 0);

        expect(harvested, isNotNull);
        final remaining = (manager.getTile(0, 0)!.object! as FarmObject).crop;
        expect(remaining, isNotNull);
        expect(remaining!.regrowData.isRegrowing, isTrue);
      });

      test('publishes the harvested crop on lastHarvestedNotifier', () {
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aCrop(stage: CropStageType.harvestable),
          ),
        );

        manager.harvestCrop(0, 0);

        expect(manager.lastHarvestedNotifier.value, isNotNull);
      });
    });

    group('advanceDay', () {
      test('a watered crop grows', () {
        WorldStateManager.instance.advanceDay(); // currentDay 2, dayEnded 1
        manager.setTile(
          aFarmTile(
            soilState: SoilState.watered,
            lastWateredDay: 1,
            crop: aCrop(stage: CropStageType.planted, daysToMature: 6),
          ),
        );

        manager.advanceDay();

        final crop = (manager.getTile(0, 0)!.object! as FarmObject).crop!;
        expect(crop.stage, CropStageType.sprout);
      });

      test('an unwatered crop does not grow', () {
        WorldStateManager.instance.advanceDay();
        manager.setTile(
          aFarmTile(
            soilState: SoilState.tilled,
            crop: aCrop(stage: CropStageType.planted),
          ),
        );

        manager.advanceDay();

        final crop = (manager.getTile(0, 0)!.object! as FarmObject).crop!;
        expect(crop.stage, CropStageType.planted);
      });

      test('every tile is visited', () {
        WorldStateManager.instance.advanceDay();
        for (var x = 0; x < 3; x++) {
          manager.setTile(
            aFarmTile(
              x: x,
              soilState: SoilState.watered,
              lastWateredDay: 1,
              crop: aCrop(stage: CropStageType.planted, daysToMature: 6),
            ),
          );
        }

        manager.advanceDay();

        for (var x = 0; x < 3; x++) {
          final crop = (manager.getTile(x, 0)!.object! as FarmObject).crop!;
          expect(crop.stage, CropStageType.sprout, reason: 'tile $x');
        }
      });

      test('an empty farm is harmless', () {
        expect(manager.advanceDay, returnsNormally);
      });
    });

    group('notifications', () {
      test('notifyChange publishes an unmodifiable snapshot', () {
        manager.setTile(aFarmTile());
        manager.notifyChange();

        expect(
          () => manager.tilesNotifier.value['x'] = aFarmTile(),
          throwsUnsupportedError,
        );
      });

      test('lastTilledNotifier starts null and clears on reset', () {
        expect(manager.lastTilledNotifier.value, isNull);

        manager
          ..lastTilledNotifier.value = aFarmTile()
          ..reset();

        expect(manager.lastTilledNotifier.value, isNull);
      });
    });

    group('clear and reset', () {
      test('clear drops every tile', () {
        manager
          ..setTile(aFarmTile(x: 1))
          ..setTile(aFarmTile(x: 2))
          ..clear();

        expect(manager.getAllTiles(), isEmpty);
      });

      test('reset drops tiles and cross-module notifiers', () {
        manager
          ..setTile(aFarmTile())
          ..lastHarvestedNotifier.value = aCrop()
          ..reset();

        expect(manager.getAllTiles(), isEmpty);
        expect(manager.lastHarvestedNotifier.value, isNull);
      });
    });

    group('serialization', () {
      test('round-trips tiles with soil and crops', () {
        manager
          ..setTile(
            aFarmTile(
              x: 1,
              y: 2,
              soilState: SoilState.watered,
              lastWateredDay: 3,
            ),
          )
          ..setTile(
            aFarmTile(
              x: 4,
              y: 5,
              soilState: SoilState.tilled,
              crop: aCrop(stage: CropStageType.budding, daysPlanted: 2),
            ),
          );

        final json = manager.toJson();
        manager.clear();
        manager.fromJson(json);

        expect(manager.getAllTiles().length, 2);

        final restored = manager.getTile(4, 5)!.object! as FarmObject;
        expect(restored.soilState, SoilState.tilled);
        expect(restored.crop!.stage, CropStageType.budding);
        expect(restored.crop!.daysPlanted, 2);
      });

      test('round-trips tile metadata', () {
        manager.setTile(aFarmTile(x: 1, y: 1, metadata: {'note': 'hello'}));

        final json = manager.toJson();
        manager.clear();
        manager.fromJson(json);

        expect(manager.getTile(1, 1)!.getMetadata<String>('note'), 'hello');
      });

      test('missing tiles key leaves the farm empty', () {
        manager.setTile(aFarmTile());

        manager.fromJson(<String, dynamic>{});

        expect(manager.getAllTiles(), isEmpty);
      });

      test('loading replaces whatever was there before', () {
        manager.setTile(aFarmTile(x: 9, y: 9));
        final json = manager.toJson();

        manager
          ..clear()
          ..setTile(aFarmTile(x: 1, y: 1))
          ..fromJson(json);

        expect(manager.getTile(1, 1), isNull);
        expect(manager.getTile(9, 9), isNotNull);
      });
    });
  });
}
