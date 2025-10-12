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
  static const String envDevelopment = 'development';
  static const String envTesting = 'testing';
  static const String envStaging = 'staging';
  static const String envProduction = 'production';

  // Current configuration (can be overridden via dart-define)
  static String get currentEnvironment =>
      const String.fromEnvironment(_envKey, defaultValue: envDevelopment);

  // Environment checks
  static bool get isDevelopment =>
      currentEnvironment == envDevelopment || isDebugMode;
  static bool get isTesting => currentEnvironment == envTesting;
  static bool get isStaging => currentEnvironment == envStaging;
  static bool get isProduction =>
      currentEnvironment == envProduction || isReleaseMode;

  /// Debug/Development Settings
  static bool get showDebugInfo => isDevelopment;
  static bool get enableLogging => isDevelopment || isTesting;
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
  static bool get enableShadows => isProduction ? true : false;
  static bool get enableBloom => isProduction ? true : false;

  /// Audio Settings
  static double get masterVolume => isDevelopment ? 0.3 : 0.7;
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

  static Duration get apiTimeout =>
      isDevelopment ? const Duration(seconds: 30) : const Duration(seconds: 10);

  /// Sprites and Graphics Settings
  static String get defaultSpriteSize => isDevelopment ? 'large' : 'tiny';
  static bool get enableSpriteDebug => isDevelopment;
  static double get spriteScale => isDevelopment ? 1.2 : 1.0;

  /// Gameplay Settings
  static double get playerHealthMultiplier => isDevelopment ? 2.0 : 1.0;
  static double get enemyDamageMultiplier => isDevelopment ? 0.5 : 1.0;
  static int get startingLives => isDevelopment ? 5 : 3;
  static bool get enableAutoSave => isProduction;
  static Duration get autoSaveInterval => const Duration(minutes: 2);

  /// UI Settings
  static bool get showVersionInfo => !isProduction;
  static bool get showEnvironmentBadge => !isProduction;
  static bool get enableDevMenu => isDevelopment;
  static bool get showTooltips => isDevelopment;

  /// Logging Settings
  static bool get enableVerboseLogging => isDevelopment;
  static bool get logToFile => isProduction;
  static String get logLevel {
    if (isDevelopment) return 'debug';
    if (isTesting) return 'info';
    if (isStaging) return 'warning';
    return 'error';
  }

  /// Utility methods
  static void printEnvironmentInfo() {
    if (enableLogging) {
      log('=== DARKNESS DUNGEON ENVIRONMENT INFO ===');
      log('Environment: $currentEnvironment');
      log('Debug Mode: $isDebugMode');
      log('Release Mode: $isReleaseMode');
      log('Profile Mode: $isProfileMode');
      log('API URL: $apiBaseUrl');
      log('Game Speed: ${gameSpeed}x');
      log('Master Volume: ${masterVolume * 100}%');
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
