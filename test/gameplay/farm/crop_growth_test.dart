// import 'package:darkness_dungeon/gameplay/farm/models/crop_model.dart';
// import 'package:darkness_dungeon/gameplay/farm/models/crop_stage_model.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   group('Crop Growth', () {
//     test('crop advances stages correctly', () {
//       var crop = const CropModel(
//         cropId: 'test_crop',
//         name: 'Test Crop',
//         description: 'Test',
//         stage: CropStageModel.seed,
//         daysPlanted: 0,
//         daysToMature: 9,
//         yieldAmount: 1,
//         harvestItemId: 'test_item',
//         iconPath: 'test.png',
//       );

//       // Dia 0-2: Seed (0-33%)
//       expect(crop.stage, equals(CropStageModel.seed));

//       // Dia 3-5: Sprout (33-66%)
//       crop = crop.advanceDay().advanceDay().advanceDay();
//       expect(crop.stage, equals(CropStageModel.sprout));
//       expect(crop.daysPlanted, equals(3));

//       // Dia 6-8: Growing (66-100%)
//       crop = crop.advanceDay().advanceDay().advanceDay();
//       expect(crop.stage, equals(CropStageModel.growing));
//       expect(crop.daysPlanted, equals(6));

//       // Dia 9+: Mature
//       crop = crop.advanceDay().advanceDay().advanceDay();
//       expect(crop.stage, equals(CropStageModel.mature));
//       expect(crop.daysPlanted, equals(9));
//       expect(crop.isMature, isTrue);
//       expect(crop.canHarvest, isTrue);
//     });

//     test('crop becomes mature after correct days', () {
//       var crop = const CropModel(
//         cropId: 'carrot',
//         name: 'Carrot',
//         description: 'Test',
//         stage: CropStageModel.seed,
//         daysPlanted: 0,
//         daysToMature: 4,
//         yieldAmount: 3,
//         harvestItemId: 'carrot_item',
//         iconPath: 'carrot.png',
//       );

//       expect(crop.isMature, isFalse);

//       // Avançar 4 dias
//       for (var i = 0; i < 4; i++) {
//         crop = crop.advanceDay();
//       }

//       expect(crop.daysPlanted, equals(4));
//       expect(crop.isMature, isTrue);
//       expect(crop.stage, equals(CropStageModel.mature));
//     });

//     test('growth progress calculates correctly', () {
//       const crop = CropModel(
//         cropId: 'test',
//         name: 'Test',
//         description: 'Test',
//         stage: CropStageModel.growing,
//         daysPlanted: 5,
//         daysToMature: 10,
//         yieldAmount: 1,
//         harvestItemId: 'test',
//         iconPath: 'test.png',
//       );

//       expect(crop.growthProgress, equals(0.5));
//     });
//   });

//   group('Crop Serialization', () {
//     test('toJson and fromJson roundtrip', () {
//       const original = CropModel(
//         cropId: 'carrot',
//         name: 'Carrot',
//         description: 'Crunchy vegetable',
//         stage: CropStageModel.growing,
//         daysPlanted: 2,
//         daysToMature: 4,
//         yieldAmount: 3,
//         harvestItemId: 'carrot_item',
//         requiredSeason: 'spring',
//         iconPath: 'carrot.png',
//       );

//       final json = original.toJson();
//       final restored = CropModel.fromJson(json);

//       expect(restored.cropId, equals(original.cropId));
//       expect(restored.name, equals(original.name));
//       expect(restored.description, equals(original.description));
//       expect(restored.stage, equals(original.stage));
//       expect(restored.daysPlanted, equals(original.daysPlanted));
//       expect(restored.daysToMature, equals(original.daysToMature));
//       expect(restored.yieldAmount, equals(original.yieldAmount));
//       expect(restored.harvestItemId, equals(original.harvestItemId));
//       expect(restored.requiredSeason, equals(original.requiredSeason));
//       expect(restored.iconPath, equals(original.iconPath));
//     });
//   });
// }
