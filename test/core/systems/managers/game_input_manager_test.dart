import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameInputManager', () {
    test('gameplay is enabled with no blockers', () {
      expect(GameInputManager().isGameplayEnabled, isTrue);
    });

    test('nested surfaces compose as a stack (rule 30)', () {
      final input = GameInputManager();
      final menu = Object();
      final dialog = Object();

      input.pushUiBlocker(menu);
      expect(input.isGameplayEnabled, isFalse);

      input
        ..pushUiBlocker(dialog)
        ..popUiBlocker(dialog);
      // The menu underneath still blocks — the dialog knew nothing about it.
      expect(input.isGameplayEnabled, isFalse);

      input.popUiBlocker(menu);
      expect(input.isGameplayEnabled, isTrue);
    });
  });
}
