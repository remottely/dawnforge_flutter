import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:flutter_test/flutter_test.dart';

final class _ProbeRegistry extends RegistryBase<String> {}

void main() {
  group('RegistryBase', () {
    test('get returns the registered entry', () {
      final registry = _ProbeRegistry()..register('t1_item_stone', 'stone');
      expect(registry.get('t1_item_stone'), 'stone');
      expect(registry.has('t1_item_stone'), isTrue);
      expect(registry.count, 1);
    });

    test('get on a missing id throws — no nulls in normal operation (rule 5)', () {
      final registry = _ProbeRegistry();
      expect(() => registry.get('t9_item_ghost'), throwsStateError);
    });

    test('ids are sorted for deterministic iteration', () {
      final registry = _ProbeRegistry()
        ..register('b', '2')
        ..register('a', '1');
      expect(registry.ids, ['a', 'b']);
    });
  });
}
