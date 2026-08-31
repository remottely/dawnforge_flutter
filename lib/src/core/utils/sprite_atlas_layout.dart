import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';

/// One resolved row of an animated sheet: what the animation is called, how
/// many frames it has, and whether it loops.
final class SpriteAtlasRow {
  const SpriteAtlasRow(this.name, this.frames, {required this.loop});

  final String name;
  final int frames;
  final bool loop;
}

/// The order of the rows in every animated sheet in the game, written down
/// once — the Dart port of `SpriteAtlasLayout.cs`.
///
/// A body, a cosmetic layer and an armor piece are three pictures of the same
/// character drawn on top of each other, so they are cut into the SAME rows in
/// the SAME order. **A row is RESERVED when its frame count is greater than
/// zero, and by no other condition** — the layout is a function of the sheet,
/// never of a runtime decision (the Godot repo learned that the hard way).
///
/// Slice delta: the flight rows (`fly_*`, `take_off`, `landing` — IActorData
/// fields) are omitted until the flight system is ported; every current pack
/// entry authors them 0, so no sheet reserves them yet. The four groups keep
/// the canonical order: young, grown, young-void, grown-void.
abstract final class SpriteAtlasLayout {
  /// The rows [data]'s sheet is cut into, top to bottom. A row the data counts
  /// zero frames for is absent: it takes up no space in the .png.
  static List<SpriteAtlasRow> rowsFor(IVisualObjectData data) {
    final canonical = <SpriteAtlasRow>[
      // — young —
      SpriteAtlasRow('juvenile_idle', data.juvenileIdleFrames, loop: true),
      SpriteAtlasRow('juvenile_walk', data.juvenileWalkFrames, loop: true),
      SpriteAtlasRow(
        'juvenile_walk_backward',
        data.juvenileBackwardFrames,
        loop: true,
      ),
      // — grown —
      SpriteAtlasRow('idle', data.idleFrames, loop: true),
      SpriteAtlasRow('walk', data.walkFrames, loop: true),
      SpriteAtlasRow('walk_backward', data.backwardFrames, loop: true),
      // — young, void —
      SpriteAtlasRow(
        'void_juvenile_idle',
        data.voidJuvenileIdleFrames,
        loop: true,
      ),
      SpriteAtlasRow(
        'void_juvenile_walk',
        data.voidJuvenileWalkFrames,
        loop: true,
      ),
      SpriteAtlasRow(
        'void_juvenile_walk_backward',
        data.voidJuvenileBackwardFrames,
        loop: true,
      ),
      // — grown, void —
      SpriteAtlasRow('void_idle', data.voidIdleFrames, loop: true),
      SpriteAtlasRow('void_walk', data.voidWalkFrames, loop: true),
      SpriteAtlasRow('void_walk_backward', data.voidBackwardFrames, loop: true),
    ];
    return canonical.where((row) => row.frames > 0).toList();
  }

  /// The zero-based ROW INDEX of animation [name] in [data]'s sheet, or `null`
  /// when the sheet reserves no such row — the caller decides what a missing
  /// animation means (a static prop has none and that is legal).
  static int? rowIndexOf(IVisualObjectData data, String name) {
    final rows = rowsFor(data);
    for (var index = 0; index < rows.length; index++) {
      if (rows[index].name == name) return index;
    }
    return null;
  }
}
