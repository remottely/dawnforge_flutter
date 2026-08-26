import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventSignal', () {
    test('emit delivers the payload to every listener, in order', () {
      final signal = EventSignal<int>();
      final received = <int>[];

      signal
        ..connect(received.add)
        ..connect((value) => received.add(value * 10))
        ..emit(3);

      expect(received, [3, 30]);
    });

    test('the returned disconnect function unsubscribes', () {
      final signal = EventSignal<int>();
      var calls = 0;

      final disconnect = signal.connect((_) => calls++);
      signal.emit(1);
      disconnect();
      signal.emit(2);

      expect(calls, 1);
      expect(signal.hasListeners, isFalse);
    });

    test('a listener disconnecting mid-emit does not skip others', () {
      final signal = EventSignal<int>();
      final received = <String>[];
      void Function()? disconnectFirst;

      disconnectFirst = signal.connect((_) {
        received.add('first');
        disconnectFirst!();
      });
      signal
        ..connect((_) => received.add('second'))
        ..emit(1)
        ..emit(2);

      expect(received, ['first', 'second', 'second']);
    });
  });
}
