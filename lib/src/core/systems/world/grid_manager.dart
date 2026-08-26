import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// All grid ↔ world coordinate conversion goes through here — never raw
/// vector arithmetic at call sites (Godot repo §6 Grid System).
///
/// Registered once at boot and never null after (rule 28).
final class GridManager {
  static const int _tile = GameConstants.tileDimension;

  /// The world-space position of the CENTER of tile [gridPos].
  WorldPos gridToWorld(GridPos gridPos) => WorldPos(
        gridPos.x * _tile + _tile / 2,
        gridPos.y * _tile + _tile / 2,
      );

  /// The world-space position of the top-left CORNER of tile [gridPos] —
  /// what a tile renderer anchors at.
  WorldPos gridToWorldCorner(GridPos gridPos) =>
      WorldPos((gridPos.x * _tile).toDouble(), (gridPos.y * _tile).toDouble());

  /// The tile containing world-space [worldPos].
  GridPos worldToGrid(WorldPos worldPos) =>
      GridPos((worldPos.x / _tile).floor(), (worldPos.y / _tile).floor());
}
