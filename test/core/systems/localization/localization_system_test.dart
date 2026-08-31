import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP2.4 gate: `tr()` resolves against the REAL tables step 05 emitted.
///
/// Since FP4.2b the step has two sources, and both land in one table per
/// locale: what the content says (an item's name, keyed off its own document)
/// and what the interface says (`ui.*`, keyed by itself, from the pack's
/// `ui/` root). A surface has nowhere to put its text until the second source
/// exists, so rule 19 is only satisfiable with both.
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

  const inventoryTabKey = 'ui.menu.tab.inventory';

  test('tr() resolves an interface key per locale', () {
    final system = locator<LocalizationSystem>()
      ..loadLocale('pt_BR', readLocale('pt_BR'));
    expect(tr(inventoryTabKey), 'Inventário');

    system.loadLocale('en', readLocale('en'));
    expect(tr(inventoryTabKey), 'Inventory');
  });

  test('every locale carries every key — a hole would crash one locale only',
      () {
    final keysByLocale = <String, Set<String>>{
      for (final locale in const ['en', 'pt_BR', 'es'])
        locale: (readLocale(locale)['strings']! as Map<String, Object?>)
            .keys
            .toSet(),
    };
    // Compared as sets rather than counts: two locales can hold the same
    // NUMBER of strings and still disagree about which, and the locale that
    // is missing one is the only one that crashes on it.
    for (final entry in keysByLocale.entries) {
      expect(entry.value, keysByLocale['en'],
          reason: '${entry.key} does not carry the same keys as en');
    }
    expect(keysByLocale['en'], contains(inventoryTabKey));
  });

  test('a missing key crashes — an unwired literal, never a content state', () {
    locator<LocalizationSystem>().loadLocale('en', readLocale('en'));
    expect(() => tr('no.such.key'), throwsStateError);
  });
}
