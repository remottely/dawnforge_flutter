/// A typed signal: the Dart port of one `signal` declaration on the Godot `Events`
/// bus. Synchronous, ordered, and side-effect-friendly — listeners run inline on
/// `emit`, matching Godot signal semantics so ported logic keeps its ordering
/// assumptions.
final class EventSignal<T> {
  final List<void Function(T payload)> _listeners =
      <void Function(T payload)>[];

  /// Subscribe. The returned function unsubscribes — hold it and call it on
  /// teardown; a listener outliving its owner is a leak *and* a use-after-free.
  void Function() connect(void Function(T payload) listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  bool get hasListeners => _listeners.isNotEmpty;

  void emit(T payload) {
    // Iterate over a copy: a listener may disconnect (itself or another) mid-emit.
    for (final listener in List<void Function(T payload)>.of(_listeners)) {
      listener(payload);
    }
  }
}

/// A signal that carries no payload.
final class EventSignal0 {
  final List<void Function()> _listeners = <void Function()>[];

  void Function() connect(void Function() listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  bool get hasListeners => _listeners.isNotEmpty;

  void emit() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}
