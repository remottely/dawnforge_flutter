import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';

/// Base of every data class with visual properties — the Dart port of
/// `IVisualObjectData.cs`, a faithful SLICE: fields are added as the systems
/// that read them are ported, with the same names and the same declared
/// defaults. *Data that exists is valid data*: invariants are asserted in the
/// constructor (Godot repo §4.4).
///
/// Each hierarchy level reads its own JSON slice in a `fromReader` constructor
/// and chains to `super.fromReader` — one reader walks the whole chain, so a
/// field is read exactly where it is declared.
abstract class IVisualObjectData {
  IVisualObjectData({
    required this.id,
    this.spritesheetPath = '',
    this.frameWidth = GameConstants.tileDimension,
    this.frameHeight = GameConstants.tileDimension,
    this.animationSpeed = 0.15,
    this.juvenileIdleFrames = 0,
    this.juvenileWalkFrames = 0,
    this.juvenileBackwardFrames = 0,
    this.idleFrames = 0,
    this.walkFrames = 0,
    this.backwardFrames = 0,
    this.voidJuvenileIdleFrames = 0,
    this.voidJuvenileWalkFrames = 0,
    this.voidJuvenileBackwardFrames = 0,
    this.voidIdleFrames = 0,
    this.voidWalkFrames = 0,
    this.voidBackwardFrames = 0,
    this.soundsVolume = 1.0,
    this.groups = const <String>[],
  }) {
    _validate();
  }

  IVisualObjectData.fromReader(JsonReader reader)
      : id = reader.requiredString('id'),
        spritesheetPath = reader.stringOr('spritesheet', ''),
        // frame_size is authored in TILES (same convention pipeline step 02
        // crops by: `w = frame_size[0] * TILE_DIMENSION * frames_grid[0]`),
        // so the pixel size is derived, never the raw pair — a 2-tile-wide
        // frame is 32px at a 16px tile, not "2px".
        frameWidth = reader
                .intPairOr('frame_size', (1, 1))
                .$1 *
            GameConstants.tileDimension,
        frameHeight = reader
                .intPairOr('frame_size', (1, 1))
                .$2 *
            GameConstants.tileDimension,
        animationSpeed = reader.doubleOr('animation_speed', 0.15),
        juvenileIdleFrames = reader.intOr('juvenile_idle_frames', 0),
        juvenileWalkFrames = reader.intOr('juvenile_walk_frames', 0),
        juvenileBackwardFrames = reader.intOr('juvenile_backward_frames', 0),
        idleFrames = reader.intOr('idle_frames', 0),
        walkFrames = reader.intOr('walk_frames', 0),
        backwardFrames = reader.intOr('backward_frames', 0),
        voidJuvenileIdleFrames = reader.intOr('void_juvenile_idle_frames', 0),
        voidJuvenileWalkFrames = reader.intOr('void_juvenile_walk_frames', 0),
        voidJuvenileBackwardFrames =
            reader.intOr('void_juvenile_backward_frames', 0),
        voidIdleFrames = reader.intOr('void_idle_frames', 0),
        voidWalkFrames = reader.intOr('void_walk_frames', 0),
        voidBackwardFrames = reader.intOr('void_backward_frames', 0),
        soundsVolume = reader.doubleOr('sounds_volume', 1),
        groups = reader.stringListOr('groups') {
    _validate();
  }

  void _validate() {
    assert(id.isNotEmpty, '[$runtimeType] id required');
    assert(frameWidth > 0 && frameHeight > 0, '[$runtimeType($id)] frame size');
    // 0 is legal: a static object simply never animates.
    assert(animationSpeed >= 0, '[$runtimeType($id)] animation_speed negative');
  }

  /// The content id — always equals the source filename without extension.
  final String id;

  /// Bundled asset key of the spritesheet ('' = not yet authored).
  final String spritesheetPath;
  final int frameWidth;
  final int frameHeight;
  final double animationSpeed;

  // Animation frame counts per canonical sheet row (SpriteAtlasLayout): a row
  // exists in the .png exactly when its count is above zero. Ground rows only
  // in this slice — the flight rows are IActorData fields, all currently
  // authored 0, and arrive with the flight system.
  final int juvenileIdleFrames;
  final int juvenileWalkFrames;
  final int juvenileBackwardFrames;
  final int idleFrames;
  final int walkFrames;
  final int backwardFrames;
  final int voidJuvenileIdleFrames;
  final int voidJuvenileWalkFrames;
  final int voidJuvenileBackwardFrames;
  final int voidIdleFrames;
  final int voidWalkFrames;
  final int voidBackwardFrames;

  /// Multiplies every sound this object plays.
  final double soundsVolume;
  final List<String> groups;

  /// A deep copy. Every runtime instance owns its own state (rule 3):
  /// factories inject `data.clone()`, never the registry's shared instance.
  IVisualObjectData clone();

  /// Mutable state only — never config the content pack already carries
  /// (Godot repo §7). What this returns is what the save file stores.
  Map<String, Object?> serialize() => <String, Object?>{};
}
