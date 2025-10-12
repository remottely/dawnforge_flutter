import 'dart:developer';

import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';

/// Environment-based logging system
/// Allows conditional logging and different levels based on configuration
class AppLogger {
  static const String _tag = '[DarknessDungeon]';

  /// Debug log (only in development)
  static void debug(String message, [String? tag]) {
    if (AppEnvironment.enableVerboseLogging) {
      log('$_tag [DEBUG] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// Info log
  static void info(String message, [String? tag]) {
    if (AppEnvironment.enableLogging) {
      log('$_tag [INFO] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// Warning log
  static void warning(String message, [String? tag]) {
    if (AppEnvironment.enableLogging) {
      log('$_tag [WARNING] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// Error log (always active)
  static void error(
    String message, [
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    log('$_tag [ERROR] ${tag != null ? '[$tag]' : ''} $message');
    if (error != null) {
      log('$_tag [ERROR] Exception: $error');
    }
    if (stackTrace != null && AppEnvironment.enableVerboseLogging) {
      log('$_tag [ERROR] StackTrace: $stackTrace');
    }
  }

  /// Gameplay-specific log
  static void gameplay(String message) {
    debug(message, 'GAMEPLAY');
  }

  /// Sprite-specific log
  static void sprite(String message) {
    debug(message, 'SPRITE');
  }

  /// Audio-specific log
  static void audio(String message) {
    debug(message, 'AUDIO');
  }

  /// Performance-specific log
  static void performance(String message) {
    if (AppEnvironment.enablePerformanceOverlay) {
      info(message, 'PERFORMANCE');
    }
  }

  /// Network/API log
  static void network(String message) {
    debug(message, 'NETWORK');
  }

  /// Simple benchmark
  static void benchmark(String operation, Duration duration) {
    if (AppEnvironment.enablePerformanceOverlay) {
      info('$operation took ${duration.inMilliseconds}ms', 'BENCHMARK');
    }
  }

  /// Conditional logging based on environment
  static void conditionalLog(
    String message, {
    bool onlyInDev = false,
    bool onlyInProd = false,
    String? tag,
  }) {
    if (onlyInDev && !AppEnvironment.isDevelopment) return;
    if (onlyInProd && !AppEnvironment.isProduction) return;

    info(message, tag);
  }
}
