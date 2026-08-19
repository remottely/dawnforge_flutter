import 'package:dawnforge/core/utils/app_environment.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment', () {
    // O ambiente vem de `--dart-define=GAME_ENVIRONMENT` e é `const`, o que
    // permite ao compilador remover o código de debug em release. Os testes
    // rodam sem a define, ou seja, em PRODUCTION — então validamos a coerência
    // entre as flags, não valores absolutos que mudariam com a define.
    test('debug mode implies devtools mode', () {
      if (AppEnvironment.kIsDebugMode) {
        expect(AppEnvironment.kIsDevToolsMode, isTrue);
      }
    });

    test('collision debug rendering is tied to debug mode', () {
      expect(AppEnvironment.kShowCollisionArea, AppEnvironment.kIsDebugMode);
    });

    test('background music and debug mode are mutually exclusive', () {
      if (AppEnvironment.kPlayBackgroundMusic) {
        expect(AppEnvironment.kIsDebugMode, isFalse);
      }
    });

    test('the game speed multiplier is positive', () {
      expect(AppEnvironment.kGameSpeedMultiplier, greaterThan(0));
    });

    test('defaults to production when no define is given', () {
      expect(AppEnvironment.kIsDebugMode, isFalse);
      expect(AppEnvironment.kIsDevToolsMode, isFalse);
      expect(AppEnvironment.kPlayBackgroundMusic, isTrue);
    });
  });

  group('GameLogger', () {
    test('every level accepts a message without throwing', () {
      expect(() => GameLogger.log('plain'), returnsNormally);
      expect(() => GameLogger.debug('debug'), returnsNormally);
      expect(() => GameLogger.info('info'), returnsNormally);
      expect(() => GameLogger.warning('warning'), returnsNormally);
      expect(() => GameLogger.error('error'), returnsNormally);
      expect(() => GameLogger.time('time'), returnsNormally);
    });

    test('an empty message is harmless', () {
      expect(() => GameLogger.info(''), returnsNormally);
    });

    test('a custom tag is accepted', () {
      expect(() => GameLogger.log('message', tag: 'CUSTOM'), returnsNormally);
    });

    test('a very long message is harmless', () {
      expect(() => GameLogger.info('x' * 10000), returnsNormally);
    });
  });
}
