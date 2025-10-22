import 'dart:developer';

import 'package:flutter/foundation.dart';

class AppEnvironment {
  static const bool isDebugMode = kDebugMode;
  static const bool isReleaseMode = kReleaseMode;
  static const bool isProfileMode = kProfileMode;

  static const String _envKey = 'GAME_ENVIRONMENT';

  static const String envDevelopment = 'DEVELOPMENT';
  static const String envTesting = 'TESTING';
  static const String envStaging = 'STAGING';
  static const String envProduction = 'PRODUCTION';

  static final String currentEnvironment = const String.fromEnvironment(
    _envKey,
    defaultValue: envDevelopment,
  );

  static final bool isDevelopment = currentEnvironment == envDevelopment;
  static final bool isTesting = currentEnvironment == envTesting;
  static final bool isStaging = currentEnvironment == envStaging;
  static final bool isProduction = currentEnvironment == envProduction;

  static final bool isDevelopmentOrDebug = isDevelopment || isDebugMode;
  static final bool isProductionOrRelease = isProduction || isReleaseMode;

  static T byEnvironment<T>({
    required T development,
    T? testing,
    T? staging,
    required T production,
  }) {
    switch (currentEnvironment) {
      case envDevelopment:
        return development;
      case envTesting:
        return testing ?? development;
      case envStaging:
        return staging ?? production;
      case envProduction:
        return production;
      default:
        return development;
    }
  }

  static final bool showDebugInfo = isDevelopment;
  static final bool enableLogging = isDevelopment || isTesting || isStaging;
  static final bool showFPS = isDevelopment;
  static final bool enableCheatCodes = isDevelopment;
  static final bool skipIntro = isDevelopment;
  static final bool showCollisionBoxes = isDevelopment || isTesting;
  static final bool enableGodMode = isDevelopment;
  static final bool showCoordinates = isDevelopment;

  static final bool enablePerformanceOverlay = isDevelopment;
  static final bool enableMemoryProfile = isDevelopment || isTesting;
  static final double gameSpeed = byEnvironment(
    development: 1.0,
    testing: 4.0,
    production: 1.0,
  );
  static final int maxParticles = byEnvironment(
    development: 100,
    production: 50,
  );
  static final bool enableShadows = isProduction || isStaging;
  static final bool enableBloom = isProduction || isStaging;

  static final double masterVolume = byEnvironment(
    development: 0.3,
    testing: 0.1,
    staging: 0.5,
    production: 0.7,
  );
  static final bool enableAudio = true; // Habilitado para todos
  static final bool enableBackgroundMusic = byEnvironment(
    development: true,
    testing: false,
    production: true,
  );
  static final bool enableSoundEffects = true; // Habilitado para todos

  static final String apiBaseUrl = byEnvironment(
    development: 'https://dev-api.darknessdungeon.com',
    testing: 'https://test-api.darknessdungeon.com',
    staging: 'https://staging-api.darknessdungeon.com',
    production: 'https://api.darknessdungeon.com',
  );

  static final Duration apiTimeout = (() {
    if (isDevelopment) return const Duration(seconds: 30);
    if (isTesting) return const Duration(seconds: 60);
    if (isStaging) return const Duration(seconds: 15);
    return const Duration(seconds: 10); // Production
  })();

  static final String defaultSpriteSize = byEnvironment(
    development: 'large',
    production: 'tiny',
  );
  static final bool enableSpriteDebug = isDevelopment;
  static final double spriteScale = byEnvironment(
    development: 1.2,
    production: 1.0,
  );

  static final double playerHealthMultiplier = byEnvironment(
    development: 2.0,
    testing: 1.5,
    staging: 1.2,
    production: 1.0,
  );
  static final double enemyDamageMultiplier = byEnvironment(
    development: 0.5,
    testing: 0.7,
    staging: 0.9,
    production: 1.0,
  );
  static final int startingLives = byEnvironment(
    development: 5,
    testing: 4,
    staging: 3,
    production: 3,
  );
  static final bool enableAutoSave = isProduction || isStaging;
  static final Duration autoSaveInterval = const Duration(minutes: 2);

  static final bool showVersionInfo = !isProduction;
  static final bool showEnvironmentBadge = !isProduction;
  static final bool enableDevMenu = isDevelopment;
  static final bool showTooltips = isDevelopment || isStaging;

  static final bool enableVerboseLogging = isDevelopment;
  static final bool logToFile = isProduction || isStaging;
  static final String logLevel = byEnvironment(
    development: 'debug',
    testing: 'info',
    staging: 'warning',
    production: 'error',
  );

  static void printEnvironmentInfo() {
    if (enableLogging) {
      log('=== DARKNESS DUNGEON ENVIRONMENT INFO ===');
      log('Environment: $currentEnvironment');
      log('isDevelopment: $isDevelopment');
      log('isTesting: $isTesting');
      log('isStaging: $isStaging');
      log('isProduction: $isProduction');
      log('---');
      log('Build Mode - Debug: $isDebugMode');
      log('Build Mode - Release: $isReleaseMode');
      log('Build Mode - Profile: $isProfileMode');
      log('---');
      log('API URL: $apiBaseUrl');
      log('API Timeout: ${apiTimeout.inSeconds}s');
      log('Game Speed: ${gameSpeed}x');
      log('Master Volume: ${(masterVolume * 100).toInt()}%');
      log('Player Health Multiplier: ${playerHealthMultiplier}x');
      log('Enemy Damage Multiplier: ${enemyDamageMultiplier}x');
      log('Starting Lives: $startingLives');
      log('Log Level: $logLevel');
      log('Show Debug Info: $showDebugInfo');
      log('Enable Cheat Codes: $enableCheatCodes');
      log('Show Collision Boxes: $showCollisionBoxes');
      log('==========================================');
    }
  }

  static void debugOnly(VoidCallback callback) {
    if (isDevelopment) {
      callback();
    }
  }

  static void productionOnly(VoidCallback callback) {
    if (isProduction) {
      callback();
    }
  }

  static final Map<String, dynamic> buildConfig = {
    'environment': currentEnvironment,
    'debug_mode': isDebugMode,
    'version': const String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    ),
    'build_number': const String.fromEnvironment(
      'BUILD_NUMBER',
      defaultValue: '1',
    ),
    'git_hash': const String.fromEnvironment(
      'GIT_HASH',
      defaultValue: 'unknown',
    ),
    'build_time': const String.fromEnvironment(
      'BUILD_TIME',
      defaultValue: 'unknown',
    ),
  };
}
