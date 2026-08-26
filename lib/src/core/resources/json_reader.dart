/// Strict, typed readers over one content-JSON object.
///
/// The `*Or` readers take the field's DECLARED default — the same default the
/// Godot `[Export]` declaration carries — because generated JSON, like `.tres`
/// before it, omits fields at their default. That is the data class being the
/// SSOT of its own defaults, not a fallback (rule 5): a field that is *present
/// but of the wrong type* is invalid content and crashes.
final class JsonReader {
  const JsonReader(this._json, this._owner);

  final Map<String, Object?> _json;

  /// For crash messages: `ClassName[id]`.
  final String _owner;

  Never _wrongType(String key, String expected) => throw StateError(
        '[$_owner] field "$key" is not $expected: ${_json[key]}',
      );

  String requiredString(String key) {
    final value = _json[key];
    if (value is! String || value.isEmpty) {
      _wrongType(key, 'a non-empty String');
    }
    return value;
  }

  String stringOr(String key, String declaredDefault) {
    final value = _json[key];
    if (value == null) return declaredDefault;
    if (value is! String) _wrongType(key, 'a String');
    return value;
  }

  bool boolOr(String key, {required bool declaredDefault}) {
    final value = _json[key];
    if (value == null) return declaredDefault;
    if (value is! bool) _wrongType(key, 'a bool');
    return value;
  }

  int intOr(String key, int declaredDefault) {
    final value = _json[key];
    if (value == null) return declaredDefault;
    if (value is! int) _wrongType(key, 'an int');
    return value;
  }

  double doubleOr(String key, double declaredDefault) {
    final value = _json[key];
    if (value == null) return declaredDefault;
    if (value is! num) _wrongType(key, 'a number');
    return value.toDouble();
  }

  /// Enums travel as their int index — the same wire format `.tres` used.
  T enumOr<T extends Enum>(String key, List<T> values, T declaredDefault) {
    final value = _json[key];
    if (value == null) return declaredDefault;
    if (value is! int || value < 0 || value >= values.length) {
      _wrongType(key, 'an index into $T');
    }
    return values[value];
  }

  List<T> enumListOr<T extends Enum>(String key, List<T> values) {
    final value = _json[key];
    if (value == null) return <T>[];
    if (value is! List) _wrongType(key, 'a list of $T indices');
    return value.map((entry) {
      if (entry is! int || entry < 0 || entry >= values.length) {
        _wrongType(key, 'an index into $T');
      }
      return values[entry];
    }).toList();
  }

  List<String> stringListOr(String key) {
    final value = _json[key];
    if (value == null) return <String>[];
    if (value is! List) _wrongType(key, 'a list of Strings');
    return value.map((entry) {
      if (entry is! String) _wrongType(key, 'a list of Strings');
      return entry;
    }).toList();
  }
}
