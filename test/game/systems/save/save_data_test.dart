import 'package:dawnforge/game/systems/save/save_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Timestamp fixo — `DateTime.now()` tornaria as asserções instáveis.
  final timestamp = DateTime.utc(2026, 8, 19, 12);

  SaveData aSaveData({
    int version = SaveData.kCurrentVersion,
    DateTime? at,
    Map<String, dynamic>? playerData,
    Map<String, dynamic>? worldData,
    Map<String, dynamic>? inventoryData,
    Map<String, dynamic>? farmData,
  }) {
    return SaveData(
      version: version,
      timestamp: at ?? timestamp,
      playerData: playerData ?? const {'life': 100},
      worldData: worldData ?? const {'currentDay': 1},
      inventoryData: inventoryData ?? const {'maxSlots': 12},
      farmData: farmData,
    );
  }

  group('SaveData', () {
    group('isValid', () {
      test('a well-formed save is valid', () {
        expect(aSaveData().isValid(), isTrue);
      });

      test('empty playerData → invalid (nothing to restore)', () {
        expect(aSaveData(playerData: {}).isValid(), isFalse);
      });

      test('a timestamp far in the future → invalid (clock tampering)', () {
        final future = DateTime.now().add(const Duration(days: 1));

        expect(aSaveData(at: future).isValid(), isFalse);
      });

      test('a timestamp slightly ahead is tolerated (clock skew)', () {
        final skewed = DateTime.now().add(const Duration(minutes: 2));

        expect(aSaveData(at: skewed).isValid(), isTrue);
      });

      test('version below 1 → invalid', () {
        expect(aSaveData(version: 0).isValid(), isFalse);
      });

      test(
        'version above the current one → invalid (save from the future)',
        () {
          expect(
            aSaveData(version: SaveData.kCurrentVersion + 1).isValid(),
            isFalse,
          );
        },
      );
    });

    group('serialization', () {
      test('round-trips every block', () {
        final data = aSaveData(farmData: const {'tiles': []});

        expect(SaveData.fromJson(data.toJson()), data);
      });

      test('farmData is omitted from the JSON when absent', () {
        expect(aSaveData().toJson().containsKey('farmData'), isFalse);
      });

      test('a null farmData round-trips as null', () {
        final restored = SaveData.fromJson(aSaveData().toJson());

        expect(restored.farmData, isNull);
      });

      test('the timestamp is written in ISO-8601', () {
        expect(aSaveData().toJson()['timestamp'], timestamp.toIso8601String());
      });

      test('missing blocks default to empty maps', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'version': 1,
          'timestamp': timestamp.toIso8601String(),
        });

        expect(restored.playerData, isEmpty);
        expect(restored.worldData, isEmpty);
        expect(restored.inventoryData, isEmpty);
      });

      test('a missing version defaults to 1', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'timestamp': timestamp.toIso8601String(),
          'playerData': const {'life': 100},
        });

        expect(restored.version, 1);
      });
    });

    // ⚠️ COMPORTAMENTO ATUAL, PERIGOSO — ver refactoring/03-fase-3 §3.1.
    // `fromJson` envolve tudo num try/catch que engole a exceção e devolve um
    // SaveData vazio com `DateTime.now()`. Um save corrompido vira "save novo
    // e vazio" em silêncio, em vez de falhar de forma visível. O objeto
    // resultante é inválido (playerData vazio), o que é a única coisa que hoje
    // impede o dano — mas o erro nunca chega a quem chamou.
    group('fromJson with corrupt input (swallows the error)', () {
      test('a missing timestamp → empty save instead of throwing', () {
        final restored = SaveData.fromJson(<String, dynamic>{'version': 1});

        expect(restored.playerData, isEmpty);
        expect(restored.isValid(), isFalse);
      });

      test('an unparseable timestamp → empty save instead of throwing', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'version': 1,
          'timestamp': 'not a date',
          'playerData': const {'life': 100},
        });

        expect(restored.playerData, isEmpty);
        expect(restored.isValid(), isFalse);
      });

      test('a wrongly typed block → empty save instead of throwing', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'version': 1,
          'timestamp': timestamp.toIso8601String(),
          'playerData': 'should have been a map',
        });

        expect(restored.playerData, isEmpty);
      });

      test('the salvaged save always carries the current version', () {
        final restored = SaveData.fromJson(<String, dynamic>{'garbage': true});

        expect(restored.version, SaveData.kCurrentVersion);
      });
    });

    group('migration', () {
      test('a version-0 save is migrated up to the current version', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'version': 0,
          'timestamp': timestamp.toIso8601String(),
          'playerData': const {'life': 100},
        });

        expect(restored.version, SaveData.kCurrentVersion);
      });

      test('migration fills in the blocks that did not exist yet', () {
        final restored = SaveData.fromJson(<String, dynamic>{
          'version': 0,
          'timestamp': timestamp.toIso8601String(),
          'playerData': const {'life': 100},
        });

        expect(restored.worldData, isEmpty);
        expect(restored.inventoryData, isEmpty);
        expect(restored.isValid(), isTrue);
      });

      test('a current-version save is not migrated', () {
        final data = aSaveData();

        expect(SaveData.fromJson(data.toJson()).version, data.version);
      });
    });

    group('copyWith', () {
      test('replaces only what is given', () {
        final data = aSaveData();
        final newStamp = timestamp.add(const Duration(hours: 1));

        final updated = data.copyWith(timestamp: newStamp);

        expect(updated.timestamp, newStamp);
        expect(updated.playerData, data.playerData);
      });
    });

    group('equality', () {
      test('identical content → equal, with matching hash codes', () {
        expect(aSaveData(), aSaveData());
        expect(aSaveData().hashCode, aSaveData().hashCode);
      });

      test('different playerData → not equal', () {
        expect(
          aSaveData(playerData: const {'life': 100}),
          isNot(aSaveData(playerData: const {'life': 50})),
        );
      });

      test('one has farmData and the other does not → not equal', () {
        expect(aSaveData(farmData: const {'tiles': []}), isNot(aSaveData()));
      });

      test('both have equivalent farmData → equal', () {
        expect(
          aSaveData(farmData: const {'count': 1}),
          aSaveData(farmData: const {'count': 1}),
        );
      });

      test('a different block size → not equal', () {
        expect(
          aSaveData(worldData: const {'a': 1}),
          isNot(aSaveData(worldData: const {'a': 1, 'b': 2})),
        );
      });
    });

    test('toString names every block without dumping its contents', () {
      final text = aSaveData().toString();

      expect(text, contains('version'));
      expect(text, contains('playerData'));
      expect(text, isNot(contains('life')));
    });
  });
}
