import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP2.4 gate: `tr()` resolves against the REAL tables step 05 emitted.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  Map<String, Object?> readLocale(String locale) => jsonDecode(
        File(
          '${ContentPaths.localesRoot(GameConstants.gameName)}/$locale.json',
        ).readAsStringSync(),
      )! as Map<String, Object?>;

  const tomatoKey =
      'forge_almanac.03_farm.t2.t2_item_consumable_vegetable_tomato'
      '.display_name';

  test('tr() resolves a generated key per locale', () {
    final system = locator<LocalizationSystem>()
      ..loadLocale('pt_BR', readLocale('pt_BR'));
    expect(tr(tomatoKey), 'Tomate');

    system.loadLocale('en', readLocale('en'));
    expect(tr(tomatoKey), 'Tomato');
    expect(system.stringCount, greaterThan(0));
  });

  test('a missing key crashes — an unwired literal, never a content state', () {
    locator<LocalizationSystem>().loadLocale('en', readLocale('en'));
    expect(() => tr('no.such.key'), throwsStateError);
  });
}
