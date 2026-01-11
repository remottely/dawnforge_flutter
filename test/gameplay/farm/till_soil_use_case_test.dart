// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:dawnforge/gameplay/farm/managers/farm_manager.dart';
// import 'package:dawnforge/gameplay/farm/usecases/till_soil_use_case.dart';

// class MockFarmManager extends Mock implements FarmManager {}

// void main() {
//   late MockFarmManager mockManager;
//   late TillSoilUseCase useCase;

//   setUp(() {
//     mockManager = MockFarmManager();
//     useCase = TillSoilUseCase(mockManager);
//   });

//   group('TillSoilUseCase', () {
//     test('should till soil successfully when coordinates are valid', () {
//       // Arrange
//       when(() => mockManager.tillSoil(any(), any())).thenReturn(true);

//       // Act
//       final result = useCase.call(0, 0);

//       // Assert
//       expect(result, true);
//       verify(() => mockManager.tillSoil(0, 0)).called(1);
//     });

//     test('should fail if tile is already tilled', () {
//       // Arrange
//       when(() => mockManager.tillSoil(any(), any())).thenReturn(false);

//       // Act
//       final result = useCase.call(0, 0);

//       // Assert
//       expect(result, false);
//       verify(() => mockManager.tillSoil(0, 0)).called(1);
//     });

//     test('should return false for negative x coordinate', () {
//       // Act
//       final result = useCase.call(-1, 0);

//       // Assert
//       expect(result, false);
//       verifyNever(() => mockManager.tillSoil(any(), any()));
//     });

//     test('should return false for negative y coordinate', () {
//       // Act
//       final result = useCase.call(0, -5);

//       // Assert
//       expect(result, false);
//       verifyNever(() => mockManager.tillSoil(any(), any()));
//     });

//     test('should work with large coordinates', () {
//       // Arrange
//       when(() => mockManager.tillSoil(any(), any())).thenReturn(true);

//       // Act
//       final result = useCase.call(100, 200);

//       // Assert
//       expect(result, true);
//       verify(() => mockManager.tillSoil(100, 200)).called(1);
//     });
//   });
// }
