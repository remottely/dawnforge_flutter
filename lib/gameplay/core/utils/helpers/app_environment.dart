import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Game environment configuration system
/// Allows switching between different execution modes (debug, release, profile)
/// to facilitate development and customize behaviors
class AppEnvironment {
  // Main configuration based on Flutter build mode
  static bool get isDebugMode => kDebugMode;
  static bool get isReleaseMode => kReleaseMode;
  static bool get isProfileMode => kProfileMode;

  // Game-specific configurations
  static const String _envKey = 'GAME_ENVIRONMENT';

  /// Enum for different custom environments
  static const String envDevelopment = 'DEVELOPMENT';
  static const String envTesting = 'TESTING';
  static const String envStaging = 'STAGING';
  static const String envProduction = 'PRODUCTION';

  // Current configuration (can be overridden via dart-define)
  static String get currentEnvironment =>
      const String.fromEnvironment(_envKey, defaultValue: envDevelopment);

  // Environment checks
  static bool get isDevelopment => currentEnvironment == envDevelopment;
  static bool get isTesting => currentEnvironment == envTesting;
  static bool get isStaging => currentEnvironment == envStaging;
  static bool get isProduction => currentEnvironment == envProduction;

  // Combined environment and build mode checks (for backward compatibility)
  static bool get isDevelopmentOrDebug => isDevelopment || isDebugMode;
  static bool get isProductionOrRelease => isProduction || isReleaseMode;

  /// Debug/Development Settings
  static bool get showDebugInfo => isDevelopment;
  static bool get enableLogging => isDevelopment || isTesting || isStaging;
  static bool get showFPS => isDevelopment;
  static bool get enableCheatCodes => isDevelopment;
  static bool get skipIntro => isDevelopment;
  static bool get showCollisionBoxes => isDevelopment || isTesting;
  static bool get enableGodMode => isDevelopment;
  static bool get showCoordinates => isDevelopment;

  /// Performance Settings
  static bool get enablePerformanceOverlay => isDevelopment;
  static bool get enableMemoryProfile => isDevelopment || isTesting;
  static double get gameSpeed => isTesting ? 1.0 : 1.0;
  static int get maxParticles => isProduction ? 50 : 100;
  static bool get enableShadows => isProduction || isStaging;
  static bool get enableBloom => isProduction || isStaging;

  /// Audio Settings
  static double get masterVolume {
    if (isDevelopment) return 0.3;
    if (isTesting) return 0.1;
    if (isStaging) return 0.5;
    return 0.7; // Production
  }
  // static bool get enableAudio => isProduction ? true : isDevelopment;
  // static bool get enableBackgroundMusic => isTesting ? false : true;
  // static bool get enableSoundEffects => true;

  /// Network/API Settings
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case envDevelopment:
        return 'https://dev-api.darknessdungeon.com';
      case envTesting:
        return 'https://test-api.darknessdungeon.com';
      case envStaging:
        return 'https://staging-api.darknessdungeon.com';
      case envProduction:
        return 'https://api.darknessdungeon.com';
      default:
        return 'https://dev-api.darknessdungeon.com';
    }
  }

  static Duration get apiTimeout {
    if (isDevelopment) return const Duration(seconds: 30);
    if (isTesting) return const Duration(seconds: 60);
    if (isStaging) return const Duration(seconds: 15);
    return const Duration(seconds: 10); // Production
  }

  /// Sprites and Graphics Settings
  static String get defaultSpriteSize => isDevelopment ? 'large' : 'tiny';
  static bool get enableSpriteDebug => isDevelopment;
  static double get spriteScale => isDevelopment ? 1.2 : 1.0;

  /// Gameplay Settings
  static double get playerHealthMultiplier {
    if (isDevelopment) return 2.0;
    if (isTesting) return 1.5;
    if (isStaging) return 1.2;
    return 1.0; // Production
  }

  static double get enemyDamageMultiplier {
    if (isDevelopment) return 0.5;
    if (isTesting) return 0.7;
    if (isStaging) return 0.9;
    return 1.0; // Production
  }

  static int get startingLives {
    if (isDevelopment) return 5;
    if (isTesting) return 4;
    if (isStaging) return 3;
    return 3; // Production
  }

  static bool get enableAutoSave => isProduction || isStaging;
  static Duration get autoSaveInterval => const Duration(minutes: 2);

  /// UI Settings
  static bool get showVersionInfo => !isProduction;
  static bool get showEnvironmentBadge => !isProduction;
  static bool get enableDevMenu => isDevelopment;
  static bool get showTooltips => isDevelopment || isStaging;

  /// Logging Settings
  static bool get enableVerboseLogging => isDevelopment;
  static bool get logToFile => isProduction || isStaging;
  static String get logLevel {
    if (isDevelopment) return 'debug';
    if (isTesting) return 'info';
    if (isStaging) return 'warning';
    return 'error'; // Production
  }

  /// Utility methods
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

  /// Execute code only in debug mode
  static void debugOnly(VoidCallback callback) {
    if (isDevelopment) {
      callback();
    }
  }

  /// Execute code only in production
  static void productionOnly(VoidCallback callback) {
    if (isProduction) {
      callback();
    }
  }

  /// Return value based on environment
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

  /// Advanced configurations for different builds
  static Map<String, dynamic> get buildConfig => {
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
