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

  int get stringCount => _strings.length;
}

/// The project-wide `tr()` (rule 19).
String tr(String key) => locator<LocalizationSystem>().tr(key);
