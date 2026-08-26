import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP2.6 gate: the registries boot from the REAL pipeline output on disk
/// (`dawnforge.py import` over the imported pack slice) — not from fixtures.
void main() {
  final almanacDir =
      Directory(ContentPaths.almanacRoot(GameConstants.gameName));

  Map<String, Object?> readJson(String relativePath) =>
      jsonDecode(File('${almanacDir.path}/$relativePath').readAsStringSync())!
          as Map<String, Object?>;

  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  test('registries boot from the generated almanac (FP2.6 gate)', () {
    final manifest = readJson('manifest.json');
    const AlmanacLoader().loadFromManifest(manifest, readJson);

    // Every manifest entry landed in exactly one registry.
    final entries = (manifest['entries']! as List).cast<Map<String, Object?>>();
    int countOf(String family) =>
        entries.where((e) => (e['type']! as String).startsWith(family)).length;

    expect(locator<ActorRegistry>().count, countOf('actor_'));
    expect(locator<PropRegistry>().count, countOf('prop_'));
    expect(locator<GroundRegistry>().count, countOf('ground_'));
    expect(locator<ItemRegistry>().count, countOf('item_'));
    expect(entries, isNotEmpty);
  });

  test('a known item parses with its authored values', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final tomato = locator<ItemRegistry>()
        .getItem('t2_item_consumable_vegetable_tomato');
    expect(tomato.maxStack, 100);
    expect(tomato.materialType, MaterialType.fabric);
  });

  test('a known crop prop parses through the world-object hierarchy', () {
    const AlmanacLoader().loadFromManifest(readJson('manifest.json'), readJson);

    final clover =
        locator<PropRegistry>().getProp('t1_prop_crop_bush_clover');
    expect(clover.hidesActors, isTrue);
    expect(clover.allowsActorOverlap, isTrue);
    expect(clover.currentHealth, clover.maxHealth);
  });
}
