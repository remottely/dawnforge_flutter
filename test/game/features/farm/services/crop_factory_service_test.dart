import 'package:dawnforge/game/features/farm/services/crop_factory_service.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';

void main() {
  late CropFactoryService factory;

  setUp(() async {
    await resetAllManagers();
    factory = CropFactoryService.instance;
  });

  group('CropFactoryService', () {
    test('is initialized by the bootstrap', () {
      expect(factory.isInitialized, isTrue);
    });

    test('initializing twice is a no-op', () async {
      final before = factory.getAllCropIds().length;

      await factory.initialize();

      expect(factory.getAllCropIds().length, before);
    });

    group('createCrop', () {
      test('a known crop id produces a crop', () {
        final crop = factory.createCrop(HandItemId.radish);

        expect(crop, isNotNull);
        expect(crop!.id, HandItemId.radish);
      });

      test('an unknown crop id → null', () {
        expect(factory.createCrop(HandItemId.unknown), isNull);
      });

      test('a non-crop item id → null', () {
        expect(factory.createCrop(HandItemId.shovel), isNull);
      });

      test('the new crop starts unplanted', () {
        final crop = factory.createCrop(HandItemId.radish)!;

        expect(crop.daysPlanted, 0);
        expect(crop.stage, CropStageType.planted);
      });

      test('regrow state is reset on a fresh crop', () {
        final crop = factory.createCrop(HandItemId.strawberry)!;

        expect(crop.regrowData.isRegrowing, isFalse);
        expect(crop.regrowData.daysInStage, 0);
      });

      test('regrow RULES are preserved on a fresh crop', () {
        final crop = factory.createCrop(HandItemId.strawberry)!;

        expect(crop.regrowData.isRegrow, isTrue);
        expect(crop.regrowData.regrowStepDays, greaterThan(0));
      });

      test('each call returns an independent instance', () {
        final first = factory.createCrop(HandItemId.radish)!;
        final second = factory.createCrop(HandItemId.radish)!;

        expect(identical(first, second), isFalse);
      });

      test('growing one instance does not affect the catalogue', () {
        factory.createCrop(HandItemId.radish)!.advanceDay();

        expect(factory.createCrop(HandItemId.radish)!.daysPlanted, 0);
      });
    });

    group('catalogue access', () {
      test('exposes at least one crop id', () {
        expect(factory.getAllCropIds(), isNotEmpty);
      });

      test('getCropData returns the raw template', () {
        expect(factory.getCropData(HandItemId.radish), isNotNull);
      });

      test('getCropData for an unknown id → null', () {
        expect(factory.getCropData(HandItemId.unknown), isNull);
      });
    });

    // COMPORTAMENTO ATUAL, INCORRETO — ver refactoring/01-fase-1 §1.4.
    // `getCropsBySeason` compara `SeasonType` com `String`
    // (`requiredSeason == 'any'`), o que é sempre falso. O analisador aponta
    // como `unrelated_type_equality_checks`. Ao corrigir, o filtro deve
    // devolver as crops da estação mais as de `SeasonType.any`.
    group('getCropsBySeason (broken — compares enum against String)', () {
      test('always returns an empty list, whatever the season', () {
        expect(factory.getCropsBySeason('spring'), isEmpty);
        expect(factory.getCropsBySeason('any'), isEmpty);
        expect(factory.getCropsBySeason('winter'), isEmpty);
      });
    });
  });
}
