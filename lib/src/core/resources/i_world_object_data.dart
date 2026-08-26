/// Base of every world-object data class — the Dart port of the self-validating
/// Godot `Resource` layer (§4.4): *data that exists is valid data*. Subclasses
/// assert their invariants in their constructors, so an instance you can hold
/// is an instance you can trust.
///
/// Mutable game state lives HERE and only here (rule 8); hosts and components
/// read through their `data` reference and never cache into locals.
abstract class IWorldObjectData {
  IWorldObjectData({required this.id}) {
    assert(id.isNotEmpty, '[$runtimeType] id required');
  }

  /// The content id — always equals the source filename without extension.
  final String id;

  /// A deep copy. Every runtime instance owns its own state (rule 3):
  /// factories inject `data.clone()`, never the registry's shared instance.
  IWorldObjectData clone();

  /// Mutable state only — never config the content pack already carries
  /// (Godot repo §7). What this returns is what the save file stores.
  Map<String, Object?> serialize();
}
