/// Base of every registry: the auto-discovery database over one data type
/// (rule 2 — gameplay code never parses content files; it asks a registry).
///
/// FP1 ships registration + typed lookup with fail-fast semantics; FP2 adds
/// the asset-bundle scan that populates registries from the pipeline's JSON
/// output (`ContentPaths`), mirroring the Godot `DirectoryScanner` boot.
abstract class RegistryBase<T> {
  final Map<String, T> _entries = <String, T>{};

  /// A human-readable name for crash messages, e.g. `ActorRegistry`.
  String get registryName => runtimeType.toString();

  /// Registers [entry] under [id]. A duplicate id is invalid content — crash
  /// at load, not at use (fail fast, Godot repo §5).
  void register(String id, T entry) {
    assert(id.isNotEmpty, '[$registryName] empty id');
    assert(!_entries.containsKey(id), '[$registryName] duplicate id: $id');
    _entries[id] = entry;
  }

  /// The entry under [id]. Throws on a miss — no nulls in normal operation
  /// (rule 5); save-compat fuzzy matching is `FallbackRegistry`'s job alone.
  T get(String id) {
    final entry = _entries[id];
    if (entry == null) {
      throw StateError('[$registryName] ID not found: $id');
    }
    return entry;
  }

  bool has(String id) => _entries.containsKey(id);

  /// All ids, sorted — deterministic iteration for tools and tests.
  List<String> get ids => _entries.keys.toList()..sort();

  int get count => _entries.length;
}
