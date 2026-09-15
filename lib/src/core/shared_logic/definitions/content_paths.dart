/// The runtime name table for content locations — the ONLY place `lib/src/core/`
/// may spell a content folder (rule 29). A hand-written content path fails silently
/// when a folder is renamed; that is why there is exactly one of it. This is a name
/// table only: no scanning, no resolution, no caching.
///
/// Twin of `scripts/lib/project_paths.py` on the automation side.
abstract final class ContentPaths {
  /// Root of all pipeline-generated JSON, as bundled asset keys.
  static const String generatedRoot = 'assets/generated';

  /// The generated tree of one game: `assets/generated/<game>/`.
  static String gameRoot(String gameName) => '$generatedRoot/$gameName';

  /// The almanac content of one game (world objects, items, biomes …).
  static String almanacRoot(String gameName) =>
      '${gameRoot(gameName)}/forge_almanac';

  /// Generated translation tables of one game.
  static String localesRoot(String gameName) => '${gameRoot(gameName)}/locales';

  /// Generated biome terrain configs of one game (pipeline step 11).
  static String worldBiomesRoot(String gameName) =>
      '${gameRoot(gameName)}/world/biomes';

  /// The generated loadouts (pipeline step 26) —
  /// `scripts/lib/project_paths.py`'s `PROGRESSION_GENERATED_ROOT`.
  static String progressionRoot(String gameName) =>
      '${gameRoot(gameName)}/progression';

  /// The pack's internal URI scheme, shared verbatim with the Godot engine.
  static const String resPrefix = 'res://data/';

  /// Maps a `res://data/…` path the pack authors (spritesheets, audio) to the
  /// bundled asset key this engine serves it from. THE one mapping (rule 29):
  /// pipeline steps 02/03 write to the same place.
  static String resolveRes(String gameName, String resPath) {
    if (!resPath.startsWith(resPrefix)) {
      throw StateError(
        '[ContentPaths] not a pack resource path: $resPath '
        '(expected $resPrefix…)',
      );
    }
    return '${gameRoot(gameName)}/${resPath.substring(resPrefix.length)}';
  }
}
