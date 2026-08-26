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
    this.idleFrames = 0,
    this.walkFrames = 0,
    this.backwardFrames = 0,
    this.soundsVolume = 1.0,
    this.groups = const <String>[],
  }) {
    _validate();
  }

  IVisualObjectData.fromReader(JsonReader reader)
      : id = reader.requiredString('id'),
        spritesheetPath = reader.stringOr('spritesheet', ''),
        frameWidth = reader.intOr('frame_width', GameConstants.tileDimension),
        frameHeight = reader.intOr('frame_height', GameConstants.tileDimension),
        animationSpeed = reader.doubleOr('animation_speed', 0.15),
        idleFrames = reader.intOr('idle_frames', 0),
        walkFrames = reader.intOr('walk_frames', 0),
        backwardFrames = reader.intOr('backward_frames', 0),
        soundsVolume = reader.doubleOr('sounds_volume', 1),
        groups = reader.stringListOr('groups') {
    _validate();
  }

  void _validate() {
    assert(id.isNotEmpty, '[$runtimeType] id required');
    assert(frameWidth > 0 && frameHeight > 0, '[$runtimeType($id)] frame size');
    assert(animationSpeed > 0, '[$runtimeType($id)] animation_speed must be > 0');
  }

  /// The content id — always equals the source filename without extension.
  final String id;

  /// Bundled asset key of the spritesheet ('' = not yet authored).
  final String spritesheetPath;
  final int frameWidth;
  final int frameHeight;
  final double animationSpeed;
  final int idleFrames;
  final int walkFrames;
  final int backwardFrames;

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
