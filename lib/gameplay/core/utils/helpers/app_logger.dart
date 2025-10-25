import 'dart:developer';

import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';

class AppLogger {
  static const String _tag = '[DarknessDungeon]';

  static void debug(String message, [String? tag]) {
    if (AppEnvironment.enableVerboseLogging) {
      log('$_tag [DEBUG] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void info(String message, [String? tag]) {
    if (AppEnvironment.enableLogging) {
      log('$_tag [INFO] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (AppEnvironment.enableLogging) {
      log('$_tag [WARNING] ${tag != null ? '[$tag]' : ''} $message');
    }
  }

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

  static void gameplay(String message) {
    debug(message, 'GAMEPLAY');
  }

  static void sprite(String message) {
    debug(message, 'SPRITE');
  }

  static void audio(String message) {
    debug(message, 'AUDIO');
  }

  static void performance(String message) {
    if (AppEnvironment.enablePerformanceOverlay) {
      info(message, 'PERFORMANCE');
    }
  }

  static void network(String message) {
    debug(message, 'NETWORK');
  }

  static void benchmark(String operation, Duration duration) {
    if (AppEnvironment.enablePerformanceOverlay) {
      info('$operation took ${duration.inMilliseconds}ms', 'BENCHMARK');
    }
  }

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
