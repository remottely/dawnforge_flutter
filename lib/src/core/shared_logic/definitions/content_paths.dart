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
}
