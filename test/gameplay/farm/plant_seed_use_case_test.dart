// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:darkness_dungeon/gameplay/farm/entities/crop.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/crop_stage.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/farm_tile.dart';
// import 'package:darkness_dungeon/gameplay/farm/entities/soil_state.dart';
// import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
// import 'package:darkness_dungeon/gameplay/farm/services/crop_factory_service.dart';
// import 'package:darkness_dungeon/gameplay/farm/usecases/plant_seed_use_case.dart';
// import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';

// class MockFarmManager extends Mock implements FarmManager {}

// class MockInventoryManager extends Mock implements InventoryManager {}

// class MockCropFactoryService extends Mock implements CropFactoryService {}

// // Fallback value for Crop
// class FakeCrop extends Fake implements Crop {}

// void main() {
//   late MockFarmManager mockFarmManager;
//   late MockInventoryManager mockInventoryManager;
//   late MockCropFactoryService mockCropFactory;
//   late PlantSeedUseCase useCase;

//   setUpAll(() {
//     // Register fallback values for any() matchers
//     registerFallbackValue(FakeCrop());
//   });

//   setUp(() {
//     mockFarmManager = MockFarmManager();
//     mockInventoryManager = MockInventoryManager();
//     mockCropFactory = MockCropFactoryService();
//     useCase = PlantSeedUseCase(
//       mockFarmManager,
//       mockInventoryManager,
//       mockCropFactory,
//     );
//   });

//   group('PlantSeedUseCase', () {
//     const seedItemId = 'strawberry_seed_bag';
//     const cropId = 'strawberry';
//     const x = 0;
//     const y = 0;

//     final testCrop = Crop(
//       cropId: cropId,
//       name: 'Strawberry',
//       description: 'A sweet berry',
//       stage: CropStage.seed,
//       daysPlanted: 0,
//       daysToMature: 5,
//       yieldAmount: 3,
//       harvestItemId: 'strawberry',
//       spritesheetPath: 'images/crops/strawberry.png',
//       spriteWidth: 32,
//       spriteHeight: 32,
//       spriteRowIndex: 0,
//       framesCount: 8,
//       skipFirstFrames: 0,
//       ySortingFromStage: CropStage.growing2,
//     );

//     final tilledTile = FarmTile(
//       x: x,
//       y: y,
//       soilState: SoilState.tilled,
//       crop: null,
//     );

//     test('should plant seed successfully when all conditions are met', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(cropId)).thenReturn(testCrop);
//       when(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .thenReturn(true);
//       when(() => mockFarmManager.plantSeed(x, y, any())).thenReturn(true);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, true);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockCropFactory.createCrop(cropId)).called(1);
//       verify(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .called(1);
//       verify(() => mockFarmManager.plantSeed(x, y, testCrop)).called(1);
//     });

//     test('should fail when player does not have seed in inventory', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(false);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verifyNever(() => mockFarmManager.getTile(any(), any()));
//       verifyNever(() => mockCropFactory.createCrop(any()));
//       verifyNever(() => mockInventoryManager.removeItem(any(), quantity: any(named: 'quantity')));
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should fail when tile does not exist', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(null);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockCropFactory.createCrop(any()));
//       verifyNever(() => mockInventoryManager.removeItem(any(), quantity: any(named: 'quantity')));
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should fail when tile is not tilled (untilled soil)', () {
//       // Arrange
//       final untilledTile = FarmTile(
//         x: x,
//         y: y,
//         soilState: SoilState.untilled,
//         crop: null,
//       );

//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(untilledTile);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockCropFactory.createCrop(any()));
//       verifyNever(() => mockInventoryManager.removeItem(any(), quantity: any(named: 'quantity')));
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should fail when tile already has a crop', () {
//       // Arrange
//       final occupiedTile = FarmTile(
//         x: x,
//         y: y,
//         soilState: SoilState.tilled,
//         crop: testCrop,
//       );

//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(occupiedTile);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verifyNever(() => mockCropFactory.createCrop(any()));
//       verifyNever(() => mockInventoryManager.removeItem(any(), quantity: any(named: 'quantity')));
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should fail when crop factory cannot create crop', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(cropId)).thenReturn(null);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockCropFactory.createCrop(cropId)).called(1);
//       verifyNever(() => mockInventoryManager.removeItem(any(), quantity: any(named: 'quantity')));
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should fail when seed removal from inventory fails', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(cropId)).thenReturn(testCrop);
//       when(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .thenReturn(false);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.hasItem(seedItemId)).called(1);
//       verify(() => mockFarmManager.getTile(x, y)).called(1);
//       verify(() => mockCropFactory.createCrop(cropId)).called(1);
//       verify(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .called(1);
//       verifyNever(() => mockFarmManager.plantSeed(any(), any(), any()));
//     });

//     test('should rollback seed removal when planting fails', () {
//       // Arrange
//       when(() => mockInventoryManager.hasItem(seedItemId)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(cropId)).thenReturn(testCrop);
//       when(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .thenReturn(true);
//       when(() => mockFarmManager.plantSeed(x, y, any())).thenReturn(false);
//       when(() => mockInventoryManager.addItem(seedItemId, quantity: 1))
//           .thenReturn(true);

//       // Act
//       final result = useCase.call(x, y, seedItemId);

//       // Assert
//       expect(result, false);
//       verify(() => mockInventoryManager.removeItem(seedItemId, quantity: 1))
//           .called(1);
//       verify(() => mockFarmManager.plantSeed(x, y, testCrop)).called(1);
//       verify(() => mockInventoryManager.addItem(seedItemId, quantity: 1))
//           .called(1);
//     });

//     test('should extract crop id from seed_bag suffix', () {
//       // Arrange
//       const tomatoSeedBag = 'tomato_seed_bag';
//       const tomatoCropId = 'tomato';

//       when(() => mockInventoryManager.hasItem(tomatoSeedBag)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(tomatoCropId)).thenReturn(testCrop);
//       when(() => mockInventoryManager.removeItem(tomatoSeedBag, quantity: 1))
//           .thenReturn(true);
//       when(() => mockFarmManager.plantSeed(x, y, any())).thenReturn(true);

//       // Act
//       final result = useCase.call(x, y, tomatoSeedBag);

//       // Assert
//       expect(result, true);
//       verify(() => mockCropFactory.createCrop(tomatoCropId)).called(1);
//     });

//     test('should extract crop id from seed suffix', () {
//       // Arrange
//       const potatoSeed = 'potato_seed';
//       const potatoCropId = 'potato';

//       when(() => mockInventoryManager.hasItem(potatoSeed)).thenReturn(true);
//       when(() => mockFarmManager.getTile(x, y)).thenReturn(tilledTile);
//       when(() => mockCropFactory.createCrop(potatoCropId)).thenReturn(testCrop);
//       when(() => mockInventoryManager.removeItem(potatoSeed, quantity: 1))
//           .thenReturn(true);
//       when(() => mockFarmManager.plantSeed(x, y, any())).thenReturn(true);

//       // Act
//       final result = useCase.call(x, y, potatoSeed);

//       // Assert
//       expect(result, true);
//       verify(() => mockCropFactory.createCrop(potatoCropId)).called(1);
//     });
//   });
// }
