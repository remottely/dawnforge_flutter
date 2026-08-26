import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// Boots the registries from the pipeline's generated almanac (step 04) — the
/// Dart twin of the Godot `DirectoryScanner` startup scan, driven by the
/// emitted `manifest.json` instead of a directory walk so it works identically
/// over a bundled asset tree and a test filesystem.
///
/// The caller supplies `readEntry` — rootBundle in the app, `dart:io` in tests
/// — so this class stays free of any I/O choice, and free of content folder
/// names (rule 29: the manifest's paths are data, not literals).
final class AlmanacLoader {
  const AlmanacLoader();

  /// Routes every manifest entry into its typed registry by type family
  /// (`actor_*` / `prop_*` / `ground_*` / `item_*` — the pack's `type:` is the
  /// snake_case concrete class name). An unknown family is invalid content:
  /// crash, so the loader gains the new registry in the same commit that
  /// introduces the family (rule 5).
  void loadFromManifest(
    Map<String, Object?> manifest,
    Map<String, Object?> Function(String relativePath) readEntry,
  ) {
    final entries = manifest['entries'];
    if (entries is! List) {
      throw StateError('[AlmanacLoader] manifest has no entries list');
    }
    for (final raw in entries) {
      if (raw is! Map<String, Object?>) {
        throw StateError('[AlmanacLoader] malformed manifest entry: $raw');
      }
      final type = raw['type'];
      final path = raw['path'];
      if (type is! String || path is! String) {
        throw StateError('[AlmanacLoader] malformed manifest entry: $raw');
      }
      final json = readEntry(path);
      if (type.startsWith('actor_')) {
        locator<ActorRegistry>().registerJson(json);
      } else if (type.startsWith('prop_')) {
        locator<PropRegistry>().registerJson(json);
      } else if (type.startsWith('ground_')) {
        locator<GroundRegistry>().registerJson(json);
      } else if (type.startsWith('item_')) {
        locator<ItemRegistry>().registerJson(json);
      } else {
        throw StateError(
          '[AlmanacLoader] unknown type family "$type" ($path) — '
          'port its registry before shipping content for it',
        );
      }
    }
  }
}
