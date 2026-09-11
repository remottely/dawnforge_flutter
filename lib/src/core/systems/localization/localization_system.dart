import 'package:dawnforge/src/core/systems/boot.dart';

/// Every user-facing string goes through [tr] with a translation key
/// (rule 19) — the Dart port of the Godot `tr()` flow, fed by the tables
/// pipeline step 05 emits per locale.
///
/// Registered at boot and never null after (rule 28). A missing key CRASHES
/// (rule 5): step 05's hole check makes that unreachable for shipped content,
/// so reaching it means an unwired key literal — exactly what should explode.
final class LocalizationSystem {
  Map<String, String> _strings = const <String, String>{};
  String _locale = '';

  String get locale => _locale;
  bool get isLoaded => _locale.isNotEmpty;

  /// Adopts one generated locale table (`{"strings": {key: text}}`).
  void loadLocale(String localeCode, Map<String, Object?> table) {
    assert(localeCode.isNotEmpty, '[LocalizationSystem] empty locale');
    final strings = table['strings'];
    if (strings is! Map<String, Object?>) {
      throw StateError('[LocalizationSystem] $localeCode: no strings map');
    }
    _strings = strings.map((key, value) {
      if (value is! String) {
        throw StateError('[LocalizationSystem] $localeCode.$key is not a String');
      }
      return MapEntry(key, value);
    });
    _locale = localeCode;
  }

  /// The translated text for [key]. Crash on a miss (rule 5) and on use
  /// before a locale loads — both are wiring bugs, never content states.
  String tr(String key) {
    assert(isLoaded, '[LocalizationSystem] tr() before loadLocale()');
    final text = _strings[key];
    if (text == null) {
      throw StateError('[LocalizationSystem] $_locale: key not found: $key');
    }
    return text;
  }

  /// [tr] with the holes filled — the port of the spec's `tr(key) % [...]`.
  ///
  /// PORT DELTA — the placeholders are NAMED (`{item}`), not positional
  /// (`%s`). The spec's own tables are the argument: `ui.workstation.
  /// producing_progress` reads `Producing %s: %d/%d` in English and
  /// `Produzindo %s: %d/%d` in Portuguese only because the two languages
  /// happen to agree on the order this time. A translator who needs the count
  /// before the name has no way to say so with `%s`, and gets a sentence with
  /// the pieces in the wrong holes. A name survives being moved.
  ///
  /// Every hole must be filled and every value must be used, both asserted
  /// (rule 5): a leftover `{item}` on screen and a value that reaches no hole
  /// are the same wiring bug seen from its two ends.
  String trFormat(String key, Map<String, Object> values) {
    var text = tr(key);
    for (final entry in values.entries) {
      final hole = '{${entry.key}}';
      assert(
        text.contains(hole),
        '[LocalizationSystem] $key has no $hole to fill',
      );
      text = text.replaceAll(hole, '${entry.value}');
    }
    assert(
      !text.contains('{'),
      '[LocalizationSystem] $key still has a hole after filling: $text',
    );
    return text;
  }

  int get stringCount => _strings.length;
}

/// The project-wide `tr()` (rule 19).
String tr(String key) => locator<LocalizationSystem>().tr(key);

/// The project-wide `tr()` for a string with holes in it (rule 19).
String trFormat(String key, Map<String, Object> values) =>
    locator<LocalizationSystem>().trFormat(key, values);
