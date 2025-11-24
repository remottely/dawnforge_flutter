import 'dart:convert';

import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/database/crop_database.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_stage_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/soil_state_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Carregar asset manualmente para teste
    const crops = '''
{
  "carrot": {
    "name": "Carrot",
    "description": "A nutritious root vegetable",
    "daysToMature": 4,
    "yieldAmount": 3,
    "harvestItemId": "carrot_item",
    "requiredSeason": "any",
    "iconPath": "assets/images/crops/carrot.png"
  },
  "potato": {
    "name": "Potato",
    "description": "Versatile tuber",
    "daysToMature": 6,
    "yieldAmount": 5,
    "harvestItemId": "potato_item",
    "requiredSeason": "spring",
    "iconPath": "assets/images/crops/potato.png"
  }
}
''';

    // Mock do rootBundle
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'assets/crops/crops_database.json') {
            return ByteData.sublistView(utf8.encode(crops));
          }
          return null;
        });

    // Inicializar CropDatabase antes dos testes
    await CropDatabase.initialize();
  });

  setUp(() {
    // Limpar farm antes de cada teste
    FarmManager.instance.clearAll();
  });

  group('FarmManager - Till Soil', () {
    test('should till soil successfully', () {
      final success = FarmManager.instance.tillSoil(0, 0);

      expect(success, isTrue);
      final tile = FarmManager.instance.getTile(0, 0);
      expect(tile, isNotNull);
      expect(tile!.soilState, equals(SoilStateModel.tilled));
    });

    test('should not till already tilled soil', () {
      FarmManager.instance.tillSoil(0, 0);
      final success = FarmManager.instance.tillSoil(0, 0);

      expect(success, isFalse);
    });
  });

  group('FarmManager - Water Tile', () {
    test('should water tilled soil successfully', () {
      FarmManager.instance.tillSoil(0, 0);
      final success = FarmManager.instance.waterTile(0, 0);

      expect(success, isTrue);
      final tile = FarmManager.instance.getTile(0, 0);
      expect(tile!.soilState, equals(SoilStateModel.watered));
      expect(tile.lastWateredDay, isNotNull);
    });

    test('should not water untilled soil', () {
      final success = FarmManager.instance.waterTile(0, 0);

      expect(success, isFalse);
    });
  });

  group('FarmManager - Plant Seed', () {
    test('should plant seed on tilled soil', () {
      FarmManager.instance.tillSoil(0, 0);
      final success = FarmManager.instance.plantSeed(0, 0, 'carrot');

      expect(success, isTrue);
      final tile = FarmManager.instance.getTile(0, 0);
      expect(tile!.crop, isNotNull);
      expect(tile.crop!.cropId, equals('carrot'));
      expect(tile.crop!.stage, equals(CropStageModel.seed));
    });

    test('should not plant on untilled soil', () {
      final success = FarmManager.instance.plantSeed(0, 0, 'carrot');

      expect(success, isFalse);
    });

    test('should not plant on occupied tile', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');
      final success = FarmManager.instance.plantSeed(0, 0, 'potato');

      expect(success, isFalse);
    });
  });

  group('FarmManager - Harvest Crop', () {
    test('should harvest mature crop', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');

      // Avançar dias até maturar (carrot = 4 dias)
      for (var i = 0; i < 4; i++) {
        // Water on the current day so the crop can grow when the day ends
        final watered = FarmManager.instance.waterTile(0, 0);
        expect(watered, isTrue);
        WorldStateManager.instance.advanceDay();
        FarmManager.instance.advanceDay();
      }

      final crop = FarmManager.instance.harvestCrop(0, 0);

      expect(crop, isNotNull);
      expect(crop!.cropId, equals('carrot'));
      expect(crop.stage, equals(CropStageModel.mature));

      // Tile deve estar vazio após colheita
      final tile = FarmManager.instance.getTile(0, 0);
      expect(tile!.crop, isNull);
      expect(tile.soilState, equals(SoilStateModel.untilled));
    });

    test('should not harvest immature crop', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');

      final crop = FarmManager.instance.harvestCrop(0, 0);

      expect(crop, isNull);
    });
  });

  group('FarmManager - Advance Day', () {
    test('should advance crops one day', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');

      final tileBefore = FarmManager.instance.getTile(0, 0);
      expect(tileBefore!.crop!.daysPlanted, equals(0));

      // Water then advance world day so crop grows
      expect(FarmManager.instance.waterTile(0, 0), isTrue);
      WorldStateManager.instance.advanceDay();
      FarmManager.instance.advanceDay();

      final tileAfter = FarmManager.instance.getTile(0, 0);
      expect(tileAfter!.crop!.daysPlanted, equals(1));
    });

    test('should advance multiple tiles', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');
      FarmManager.instance.tillSoil(1, 0);
      FarmManager.instance.plantSeed(1, 0, 'potato');

      // Water both tiles and advance
      expect(FarmManager.instance.waterTile(0, 0), isTrue);
      expect(FarmManager.instance.waterTile(1, 0), isTrue);
      WorldStateManager.instance.advanceDay();
      FarmManager.instance.advanceDay();

      final tile1 = FarmManager.instance.getTile(0, 0);
      final tile2 = FarmManager.instance.getTile(1, 0);

      expect(tile1!.crop!.daysPlanted, equals(1));
      expect(tile2!.crop!.daysPlanted, equals(1));
    });
  });

  group('FarmManager - Serialization', () {
    test('should serialize and deserialize correctly', () {
      FarmManager.instance.tillSoil(0, 0);
      FarmManager.instance.plantSeed(0, 0, 'carrot');
      // Water and advance so crop grows (new rule requires watering)
      expect(FarmManager.instance.waterTile(0, 0), isTrue);
      WorldStateManager.instance.advanceDay();
      FarmManager.instance.advanceDay();

      final json = FarmManager.instance.toJson();

      FarmManager.instance.clearAll();
      expect(FarmManager.instance.getAllTiles(), isEmpty);

      FarmManager.instance.fromJson(json);

      final tile = FarmManager.instance.getTile(0, 0);
      expect(tile, isNotNull);
      expect(tile!.crop, isNotNull);
      expect(tile.crop!.cropId, equals('carrot'));
      expect(tile.crop!.daysPlanted, equals(1));
    });
  });
}
