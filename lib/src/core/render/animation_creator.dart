import 'dart:ui' show Image;

import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';
import 'package:dawnforge/src/core/utils/sprite_atlas_layout.dart';
import 'package:flame/components.dart';

/// Builds Flame [SpriteAnimation]s from a data soul's sheet — the Dart port of
/// the Godot `AnimationCreator`. The sheet's row order is
/// [SpriteAtlasLayout.rowsFor]'s business, never guessed here (rule: one SSOT
/// for the layout); this class only turns rows into playable animations.
abstract final class AnimationCreator {
  /// Every animation [data]'s sheet reserves, keyed by canonical row name
  /// (`idle`, `walk`, `void_idle`, …). Frames run along the row's columns;
  /// `animationSpeed` is the per-frame step time in seconds.
  static Map<String, SpriteAnimation> createAnimations(
    IVisualObjectData data,
    Image sheet,
  ) {
    final rows = SpriteAtlasLayout.rowsFor(data);
    final frameSize =
        Vector2(data.frameWidth.toDouble(), data.frameHeight.toDouble());
    final animations = <String, SpriteAnimation>{};
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      animations[row.name] = SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: row.frames,
          stepTime: data.animationSpeed,
          textureSize: frameSize,
          texturePosition: Vector2(0, rowIndex * frameSize.y),
          loop: row.loop,
        ),
      );
    }
    return animations;
  }

  /// A single static sprite: frame [column] of row [rowIndex] — what a crop
  /// stage or a plain prop shows.
  static Sprite createStill(
    IVisualObjectData data,
    Image sheet, {
    int rowIndex = 0,
    int column = 0,
  }) {
    final frameSize =
        Vector2(data.frameWidth.toDouble(), data.frameHeight.toDouble());
    return Sprite(
      sheet,
      srcPosition: Vector2(column * frameSize.x, rowIndex * frameSize.y),
      srcSize: frameSize,
    );
  }
}
