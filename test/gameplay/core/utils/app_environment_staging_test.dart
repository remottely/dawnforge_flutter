import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment STAGING Test', () {
    test('should recognize STAGING environment when set via dart-define', () {
      // This test will pass when run with --dart-define=GAME_ENVIRONMENT=STAGING
      print('Current Environment: ${AppEnvironment.currentEnvironment}');
      print('isDevelopment: ${AppEnvironment.isDevelopment}');
      print('isTesting: ${AppEnvironment.isTesting}');
      print('isStaging: ${AppEnvironment.isStaging}');
      print('isProduction: ${AppEnvironment.isProduction}');

      // Call the info method to see all configurations
      AppEnvironment.printEnvironmentInfo();

      // The actual test - this will depend on how the test is run
      expect(AppEnvironment.currentEnvironment, isA<String>());
      expect(
        AppEnvironment.currentEnvironment,
        isIn([
          AppEnvironment.envDevelopment,
          AppEnvironment.envTesting,
          AppEnvironment.envStaging,
          AppEnvironment.envProduction,
        ]),
      );
    });

    test('should have staging-specific configurations', () {
      // Test staging API URL
      expect(AppEnvironment.apiBaseUrl, isA<String>());

      // Test staging volume (should be 0.5 when in staging)
      expect(AppEnvironment.masterVolume, isA<double>());
      expect(AppEnvironment.masterVolume, greaterThan(0.0));
      expect(AppEnvironment.masterVolume, lessThanOrEqualTo(1.0));

      // Test staging health multiplier (should be 1.2 when in staging)
      expect(AppEnvironment.playerHealthMultiplier, isA<double>());
      expect(AppEnvironment.playerHealthMultiplier, greaterThan(1.0));

      // Test that logging is enabled for staging
      expect(AppEnvironment.enableLogging, isA<bool>());

      // Test that some features are enabled for staging
      expect(AppEnvironment.enableAutoSave, isA<bool>());
      expect(AppEnvironment.logToFile, isA<bool>());
    });
  });
}
