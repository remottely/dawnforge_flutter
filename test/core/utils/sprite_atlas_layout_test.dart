import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/utils/sprite_atlas_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteAtlasLayout', () {
    test('rows exist iff their count is above zero, in canonical order', () {
      // The boar's authored shape: an 8x8 sheet of 8 reserved rows.
      final boar = IActorData.fromJson(<String, Object?>{
        'id': 't1_actor_creature_boar',
        'juvenile_idle_frames': 8,
        'juvenile_walk_frames': 4,
        'idle_frames': 8,
        'walk_frames': 3,
        'void_juvenile_idle_frames': 8,
        'void_juvenile_walk_frames': 4,
        'void_idle_frames': 8,
        'void_walk_frames': 3,
      });

      final rows = SpriteAtlasLayout.rowsFor(boar);
      expect(rows.map((r) => r.name), [
        'juvenile_idle',
        'juvenile_walk',
        'idle',
        'walk',
        'void_juvenile_idle',
        'void_juvenile_walk',
        'void_idle',
        'void_walk',
      ]);
      expect(SpriteAtlasLayout.rowIndexOf(boar, 'idle'), 2);
      expect(SpriteAtlasLayout.rowIndexOf(boar, 'walk'), 3);
      // A zero-count row takes no space and has no index.
      expect(SpriteAtlasLayout.rowIndexOf(boar, 'walk_backward'), isNull);
    });

    test('a static object reserves no rows at all', () {
      final still = IActorData.fromJson(<String, Object?>{'id': 't1_actor_x'});
      expect(SpriteAtlasLayout.rowsFor(still), isEmpty);
    });
  });

  group('ContentPaths.resolveRes', () {
    test('maps the pack URI scheme onto this engine asset tree', () {
      expect(
        ContentPaths.resolveRes(
          'dawnforge',
          'res://data/forge_almanac/03_farm/t1/sprites/t1_prop_soil.png',
        ),
        'assets/generated/dawnforge/forge_almanac/03_farm/t1/sprites/'
        't1_prop_soil.png',
      );
    });

    test('a non-pack path is a wiring bug — crash', () {
      expect(
        () => ContentPaths.resolveRes('dawnforge', 'res://tessera/x.png'),
        throwsStateError,
      );
    });
  });
}
