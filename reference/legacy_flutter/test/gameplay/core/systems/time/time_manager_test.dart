// import 'package:dawnforge/features/core/modules/time/time_constants.dart';
// import 'package:dawnforge/features/core/modules/time/time_manager.dart';
// import 'package:dawnforge/features/core/modules/time/time_of_day.dart';
// import 'package:dawnforge/features/core/modules/world/world_state_manager.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   late TimeManager manager;

//   setUp(() {
//     // Get singleton instance and reset before each test
//     manager = TimeManager.instance;
//     manager.reset();

//     // Also reset world state manager for clean tests
//     WorldStateManager.instance.reset();
//   });

//   group('TimeManager Tests', () {
//     test('test_singleton_returns_same_instance', () {
//       // Arrange & Act
//       final instance1 = TimeManager.instance;
//       final instance2 = TimeManager.instance;

//       // Assert
//       expect(instance1, equals(instance2));
//       expect(identical(instance1, instance2), isTrue);
//     });

//     test('test_update_advances_time', () {
//       // Arrange
//       manager.setTime(0); // Set to midnight
//       expect(manager.currentTime, equals(0));

//       // Act - Update with 1 second delta
//       manager.update(1.0);

//       // Assert - Time should advance by timeScale * dt
//       expect(manager.currentTime, greaterThan(0));

//       // With default time scale (72x), 1 real second = 72 game seconds
//       expect(manager.currentTime, closeTo(TimeConstants.defaultTimeScale, 0.1));
//     });

//     test('test_time_of_day_changes_correctly', () {
//       // Test Morning
//       manager.setTime(TimeConstants.morningStartTime); // 6:00
//       expect(manager.currentTimeOfDay, equals(TimeOfDay.morning));

//       // Test Noon
//       manager.setTime(TimeConstants.noonStartTime); // 12:00
//       expect(manager.currentTimeOfDay, equals(TimeOfDay.noon));

//       // Test Evening
//       manager.setTime(TimeConstants.eveningStartTime); // 18:00
//       expect(manager.currentTimeOfDay, equals(TimeOfDay.evening));

//       // Test Night
//       manager.setTime(TimeConstants.nightStartTime); // 21:00
//       expect(manager.currentTimeOfDay, equals(TimeOfDay.night));

//       // Test Night continues past midnight
//       manager.setTime(0); // 00:00
//       expect(manager.currentTimeOfDay, equals(TimeOfDay.night));
//     });

//     test('test_callbacks_fire_on_time_change', () {
//       // Arrange
//       TimeOfDay? callbackReceived;
//       int callbackCount = 0;

//       void listener(TimeOfDay timeOfDay) {
//         callbackReceived = timeOfDay;
//         callbackCount++;
//       }

//       manager.addTimeOfDayListener(listener);
//       manager.setTime(TimeConstants.morningStartTime); // Start at morning

//       // Act - Change to noon
//       manager.setTime(TimeConstants.noonStartTime);

//       // Assert
//       expect(callbackCount, equals(1));
//       expect(callbackReceived, equals(TimeOfDay.noon));

//       // Act - Change to evening
//       manager.setTime(TimeConstants.eveningStartTime);

//       // Assert
//       expect(callbackCount, equals(2));
//       expect(callbackReceived, equals(TimeOfDay.evening));

//       // Cleanup
//       manager.removeTimeOfDayListener(listener);
//     });

//     test('test_pause_stops_time', () {
//       // Arrange
//       manager.setTime(1000);
//       final initialTime = manager.currentTime;

//       // Act - Pause and update
//       manager.pause();
//       manager.update(10.0); // Large delta

//       // Assert - Time should not advance
//       expect(manager.isPaused, isTrue);
//       expect(manager.currentTime, equals(initialTime));

//       // Resume and verify time advances again
//       manager.resume();
//       expect(manager.isPaused, isFalse);
//       manager.update(1.0);
//       expect(manager.currentTime, greaterThan(initialTime));
//     });

//     test('test_time_scale_affects_speed', () {
//       // Arrange
//       manager.setTime(0);
//       manager.setTimeScale(2.0); // Double speed (just 2x, not 2 * defaultScale)

//       // Act
//       manager.update(1.0);

//       // Assert - With 2x scale, time should advance 2 seconds
//       expect(manager.currentTime, closeTo(2.0, 0.1));

//       // Test half speed
//       manager.setTime(0);
//       manager.setTimeScale(0.5);
//       manager.update(1.0);

//       expect(manager.currentTime, closeTo(0.5, 0.1));
//     });

//     test('test_new_day_triggers_world_manager', () {
//       // Arrange
//       final worldManager = WorldStateManager.instance;
//       expect(worldManager.currentDay, equals(1));

//       // Set time to just before midnight
//       manager.setTime(TimeConstants.secondsPerDay - 1);

//       // Act - Advance time past midnight
//       manager.update(1.0); // This should trigger new day

//       // Assert - World manager should advance day
//       // Note: Due to time scale, we might need multiple updates or adjust scale
//       manager.setTimeScale(1.0); // Disable time scale for precise control
//       manager.setTime(TimeConstants.secondsPerDay - 1);
//       manager.update(2.0); // Cross midnight

//       // The day should have advanced
//       expect(worldManager.currentDay, greaterThan(1));
//     });

//     test('test_time_wraps_at_midnight', () {
//       // Arrange
//       manager.setTime(
//         TimeConstants.secondsPerDay - 10,
//       ); // 10 seconds before midnight

//       // Act
//       manager.setTimeScale(1.0); // 1:1 time scale for predictability
//       manager.update(20.0); // Cross midnight

//       // Assert - Time should wrap
//       expect(manager.currentTime, lessThan(TimeConstants.secondsPerDay));
//       expect(
//         manager.currentTime,
//         closeTo(10.0, 1.0),
//       ); // Should be ~10 seconds after midnight
//     });

//     test('test_serialization_roundtrip', () {
//       // Arrange - Setup state
//       manager.setTime(50000); // ~14:00
//       manager.setTimeScale(2.5);
//       manager.pause();

//       // Act - Serialize
//       final json = manager.toJson();

//       // Reset and deserialize
//       manager.reset();
//       expect(
//         manager.currentTime,
//         equals(TimeConstants.morningStartTime),
//       ); // Verify reset

//       manager.fromJson(json);

//       // Assert - Verify state restored
//       expect(manager.currentTime, closeTo(50000, 1.0));
//       expect(manager.timeScale, equals(2.5));
//       expect(manager.isPaused, isTrue);
//     });

//     test('test_get_progress_returns_correct_value', () {
//       // Test midnight (0%)
//       manager.setTime(0);
//       expect(manager.getProgress(), equals(0.0));

//       // Test noon (50%)
//       manager.setTime(TimeConstants.secondsPerDay / 2);
//       expect(manager.getProgress(), closeTo(0.5, 0.01));

//       // Test almost midnight (99%)
//       manager.setTime(TimeConstants.secondsPerDay - 1);
//       expect(manager.getProgress(), greaterThan(0.99));
//     });

//     test('test_multiple_listeners_all_called', () {
//       // Arrange
//       int listener1Calls = 0;
//       int listener2Calls = 0;
//       int listener3Calls = 0;

//       manager.addTimeOfDayListener((time) => listener1Calls++);
//       manager.addTimeOfDayListener((time) => listener2Calls++);
//       manager.addTimeOfDayListener((time) => listener3Calls++);

//       manager.setTime(TimeConstants.morningStartTime);

//       // Act
//       manager.setTime(TimeConstants.noonStartTime);

//       // Assert
//       expect(listener1Calls, equals(1));
//       expect(listener2Calls, equals(1));
//       expect(listener3Calls, equals(1));

//       // Cleanup
//       manager.clearListeners();
//     });
//   });
// }
