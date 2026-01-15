import 'dart:developer' as developer;

import 'package:dawnforge/game/utils/app_environment.dart';

/// GameLogger: Logger condicional para debug e produção
/// Ativa logs apenas em builds de debug, ignora em release.

class GameLogger {
  static const bool _enableLogs = AppEnvironment.kIsDevToolsMode;
  
  static void log(String message, {String? tag}) {
    if (_enableLogs) {
      // ignore: avoid_print
      developer.log('[${tag ?? 'GAME'}] $message');
    }
  }

  static void debug(String message) => log(message, tag: 'DEBUG');
  static void info(String message) => log(message, tag: 'INFO');
  static void warning(String message) => log(message, tag: 'WARNING');
  static void error(String message) => log(message, tag: 'ERROR');
  static void time(String message) => log(message, tag: 'TIME');
}

/// Exemplo de uso:
/// GameLogger.debug('Mensagem de debug');
/// GameLogger.error('Erro crítico!');
