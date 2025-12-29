// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:darkness_dungeon/gameplay/farm/entities/crop.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/crop_stage.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/farm_tile.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/soil_state.dart';
// import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
// import 'package:darkness_dungeon/gameplay/farm/usecases/harvest_crop_use_case.dart';
// import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';

// class MockFarmManager extends Mock implements FarmManager {}

// class MockInventoryManager extends Mock implements InventoryManager {}

// void main() {
//   late MockFarmManager mockFarmManager;
//   late MockInventoryManager mockInventoryManager;
//   late HarvestCropUseCase useCase;

//   setUp(() {
//     mockFarmManager = MockFarmManager();
//     mockInventoryManager = MockInventoryManager();
//     useCase = HarvestCropUseCase(
//       mockFarmManager,
//       mockInventoryManager,
//     );
//   });

//   group('HarvestCropUseCase', () {
//     const x = 0;
//     const y = 0;
//     const harvestItemId = 'strawberry';
//     const harvestQuantity = 3;

//     final matureCrop = Crop(
//       cropId: 'strawberry',
//       name: 'Strawberry',
//       description: 'A sweet berry',
//       stage: CropStage.mature,
//       daysPlanted: 5,
//       daysToMature: 5,
//       yieldAmount: harvestQuantity,
//       harvestItemId: harvestItemId,
//       spritesheetPath: 'images/crops/strawberry.png',
//       spriteWidth: 32,
//       spriteHeight: 32,
//       spriteRowIndex: 0,
//       framesCount: 8,
//       skipFirstFrames: 0,
//       ySortingFromStage: CropStage.growing2,
//     );

//     final immatureCrop = Crop(
//       cropId: 'strawberry',
//       name: 'Strawberry',
//       description: 'A sweet berry',
//       stage: CropStage.growing1,
//       daysPlanted: 2,
//       daysToMature: 5,
//       yieldAmount: harvestQuantity,
//       harvestItemId: harvestItemId,
//       spritesheetPath: 'images/crops/strawberry.png',
//       spriteWidth: 32,
//       spriteHeight: 32,
//       spriteRowIndex: 0,
//       framesCount: 8,
//       skipFirstFrames: 0,
//       ySortingFromStage: CropStage.growing2,
//     );

//     final tileWithMatureCrop = FarmTile(
//       x: x,
//       y: y,
//       soilState: SoilState.tilled,
//       crop: matureCrop,
//     );

//     final tileWithImmatureCrop = FarmTile(
//       x: x,
//       y: y,
//       soilState: SoilState.tilled,
//       crop: immatureCrop,
//     );

//     final emptyTile = FarmTile(
//       x: x,
//       y: y,
//       soilState: SoilState.tilled,
//       crop: null,
//     );

//     test('should harvest crop successfully when crop is mature', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tileWithMatureCrop);
//       when(() => mockFarmManager.harvestCrop(x, y)).thenReturn(matureCrop);
//       when(() => mockInventoryManager.addItem(harvestItemId, quantity: harvestQuantity))
//           .thenReturn(true);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, true);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockFarmManager.harvestCrop(x, y)).called(1);
//       verify(() => mockInventoryManager.addItem(harvestItemId, quantity: harvestQuantity))
//           .called(1);
//     });

//     test('should fail when tile does not exist', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(null);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, false);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockFarmManager.harvestCrop(any(), any()));
//       verifyNever(() => mockInventoryManager.addItem(any(), quantity: any(named: 'quantity')));
//     });

//     test('should fail when tile has no crop', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(emptyTile);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, false);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockFarmManager.harvestCrop(any(), any()));
//       verifyNever(() => mockInventoryManager.addItem(any(), quantity: any(named: 'quantity')));
//     });

//     test('should fail when crop is not mature', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tileWithImmatureCrop);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, false);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockFarmManager.harvestCrop(any(), any()));
//       verifyNever(() => mockInventoryManager.addItem(any(), quantity: any(named: 'quantity')));
//     });

//     test('should fail when manager harvest returns null', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tileWithMatureCrop);
//       when(() => mockFarmManager.harvestCrop(x, y)).thenReturn(null);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, false);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockFarmManager.harvestCrop(x, y)).called(1);
//       verifyNever(() => mockInventoryManager.addItem(any(), quantity: any(named: 'quantity')));
//     });

//     test('should fail when adding item to inventory fails', () {
//       // Arrange
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tileWithMatureCrop);
//       when(() => mockFarmManager.harvestCrop(x, y)).thenReturn(matureCrop);
//       when(() => mockInventoryManager.addItem(harvestItemId, quantity: harvestQuantity))
//           .thenReturn(false);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, false);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockFarmManager.harvestCrop(x, y)).called(1);
//       verify(() => mockInventoryManager.addItem(harvestItemId, quantity: harvestQuantity))
//           .called(1);
//     });

//     test('should use correct harvest item id and quantity from crop', () {
//       // Arrange
//       const customHarvestItemId = 'golden_strawberry';
//       const customHarvestQuantity = 10;

//       final customCrop = Crop(
//         cropId: 'golden_strawberry',
//         name: 'Golden Strawberry',
//         description: 'A rare golden berry',
//         stage: CropStage.mature,
//         daysPlanted: 7,
//         daysToMature: 7,
//         yieldAmount: customHarvestQuantity,
//         harvestItemId: customHarvestItemId,
//         spritesheetPath: 'images/crops/golden_strawberry.png',
//         spriteWidth: 32,
//         spriteHeight: 32,
//         spriteRowIndex: 0,
//         framesCount: 8,
//         skipFirstFrames: 0,
//         ySortingFromStage: CropStage.growing2,
//       );

//       final tileWithCustomCrop = FarmTile(
//         x: x,
//         y: y,
//         soilState: SoilState.tilled,
//         crop: customCrop,
//       );

//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tileWithCustomCrop);
//       when(() => mockFarmManager.harvestCrop(x, y)).thenReturn(customCrop);
//       when(() => mockInventoryManager.addItem(
//             customHarvestItemId,
//             quantity: customHarvestQuantity,
//           )).thenReturn(true);

//       // Act
//       final result = useCase.call(x, y);

//       // Assert
//       expect(result, true);
//       verify(() => mockInventoryManager.addItem(
//             customHarvestItemId,
//             quantity: customHarvestQuantity,
//           )).called(1);
//     });

//     test('should work with different tile coordinates', () {
//       // Arrange
//       const testX = 15;
//       const testY = 23;

//       final testTile = FarmTile(
//         x: testX,
//         y: testY,
//         soilState: SoilState.tilled,
//         crop: matureCrop,
//       );

//       when(() => mockFarmManager.getTile(testX, testY)).thenReturn(testTile);
//       when(() => mockFarmManager.harvestCrop(testX, testY)).thenReturn(matureCrop);
//       when(() => mockInventoryManager.addItem(harvestItemId, quantity: harvestQuantity))
//           .thenReturn(true);

//       // Act
//       final result = useCase.call(testX, testY);

//       // Assert
//       expect(result, true);
//       verify(() => mockFarmManager.getTile(testX, testY)).called(1);
//       verify(() => mockFarmManager.harvestCrop(testX, testY)).called(1);
//     });
//   });
// }
