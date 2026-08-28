import 'dart:ui' as ui;

import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Color, Paint, Rect;

/// The chunked ground layer — the Flame replacement for what Godot's
/// `TileMapLayer` gave for free (FP3.4, study risk #1). One component owns
/// every chunk's bake, mirroring "one node owns all cells":
///
/// BAKE: when a chunk finishes streaming ([ChunkStreamingSystem.chunkLoaded])
/// it enters the bake queue; each frame bakes at most
/// [EngineConstants.groundBakeChunksPerFrame] chunks (the Godot map view's
/// budget pattern) — each bake records the chunk's 8x8 tile sprites into a
/// [ui.Picture] and rasterizes it once via `toImageSync`, so drawing a
/// resident chunk costs ONE image blit per frame thereafter.
///
/// WHAT IS DRAWN: tiles whose data carries a spritesheet (terrain). Water
/// and cliff empties draw nothing — water IS the world background (the
/// Godot side never paints water cells either), a hole shows it through.
/// Elevation is painted INTO the bake as a per-height darkening over the
/// wall tile — the engine-side placeholder until the elevation visual
/// system (cumulative cliff layers, y-sorted occlusion) is ported.
///
/// Render-only: it never mutates grid state; the sim never knows it exists.
final class GroundChunkRenderer extends Component
    with HasGameReference<DawnforgeGame> {
  /// Below every world object — the ground is the floor of the paint order.
  GroundChunkRenderer() : super(priority: -1 << 30);

  static const int _chunkSize = GameConstants.proceduralChunkSize;
  static const int _tile = GameConstants.tileDimension;
  static const int _chunkPx = _chunkSize * _tile;

  /// Wall darkening per height 1..3 — deeper is higher. Placeholder visual
  /// (see class doc); the alpha steps just have to READ as steps.
  static const List<Color> _wallTints = [
    Color(0x33000000),
    Color(0x59000000),
    Color(0x80000000),
  ];

  final Map<GridPos, ui.Image> _bakedChunks = <GridPos, ui.Image>{};
  final List<GridPos> _bakeQueue = <GridPos>[];

  /// Ground sprites by spritesheet path, preloaded at [onLoad] so a bake
  /// never awaits — `toImageSync` keeps the whole bake synchronous.
  final Map<String, ui.Image> _tileSheets = <String, ui.Image>{};

  final List<void Function()> _disconnects = <void Function()>[];

  final Paint _pixelPaint = Paint()
    ..filterQuality = ui.FilterQuality.none
    ..isAntiAlias = false;

  /// Surfaced by the FP3.6 debug overlay next to the resident chunk count.
  int get bakedChunkCount => _bakedChunks.length;
  int get pendingBakeCount => _bakeQueue.length;

  @override
  Future<void> onLoad() async {
    // Every ground sprite the pack ships, upfront: there are a handful of
    // ground ids for the whole game, and a bake must never await.
    final grounds = locator<GroundRegistry>();
    for (final id in grounds.ids) {
      final path = grounds.getGround(id).spritesheetPath;
      if (path.isEmpty) continue; // empties draw nothing — see class doc
      _tileSheets[path] = await SpriteLoader.loadSheet(path);
    }

    final streaming = locator<ChunkStreamingSystem>();
    // Seed with everything already materialized (the spawn force-load and
    // any boot frames that ran before this component mounted), THEN listen.
    _bakeQueue.addAll(streaming.loadedChunks);
    _disconnects
      ..add(streaming.chunkLoaded.connect(_bakeQueue.add))
      ..add(streaming.chunkUnloadStarted.connect(_dropChunk));
  }

  void _dropChunk(GridPos chunk) {
    _bakeQueue.remove(chunk);
    _bakedChunks.remove(chunk)?.dispose();
  }

  @override
  void update(double dt) {
    var budget = EngineConstants.groundBakeChunksPerFrame;
    while (budget > 0 && _bakeQueue.isNotEmpty) {
      final chunk = _bakeQueue.removeAt(0);
      _bakedChunks.remove(chunk)?.dispose(); // a re-bake replaces its image
      _bakedChunks[chunk] = _bakeChunk(chunk);
      budget--;
    }
  }

  /// One chunk's ground rasterized to a single image: 64 sprite draws paid
  /// once, one blit per frame forever after.
  ui.Image _bakeChunk(GridPos chunk) {
    final grid = locator<GridManager>();
    final origin = GridPos(chunk.x * _chunkSize, chunk.y * _chunkSize);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    for (var x = 0; x < _chunkSize; x++) {
      for (var y = 0; y < _chunkSize; y++) {
        final data = grid.getGroundDataAt(GridPos(origin.x + x, origin.y + y));
        if (data == null || data.spritesheetPath.isEmpty) continue;
        final destination = Rect.fromLTWH(
          (x * _tile).toDouble(),
          (y * _tile).toDouble(),
          _tile.toDouble(),
          _tile.toDouble(),
        );
        canvas.drawImageRect(
          _sheetOf(data),
          Rect.fromLTWH(0, 0, _tile.toDouble(), _tile.toDouble()),
          destination,
          _pixelPaint,
        );
        final height = grid.getElevationAt(GridPos(origin.x + x, origin.y + y));
        if (height > 0) {
          canvas.drawRect(
            destination,
            Paint()..color = _wallTints[height - 1],
          );
        }
      }
    }

    final picture = recorder.endRecording();
    final image = picture.toImageSync(_chunkPx, _chunkPx);
    picture.dispose();
    return image;
  }

  ui.Image _sheetOf(GroundBuildableData data) {
    final sheet = _tileSheets[data.spritesheetPath];
    if (sheet == null) {
      throw StateError(
        '[GroundChunkRenderer] ${data.id} spritesheet was not preloaded — '
        'a ground id reached the grid without passing the registry (rule 2)',
      );
    }
    return sheet;
  }

  @override
  void render(ui.Canvas canvas) {
    // One tile of slack so a chunk sliding in at the edge never pops.
    final visible = game.camera.visibleWorldRect.inflate(_tile.toDouble());
    _bakedChunks.forEach((chunk, image) {
      final left = (chunk.x * _chunkPx).toDouble();
      final top = (chunk.y * _chunkPx).toDouble();
      if (!visible.overlaps(
        Rect.fromLTWH(left, top, _chunkPx.toDouble(), _chunkPx.toDouble()),
      )) {
        return;
      }
      canvas.drawImage(image, ui.Offset(left, top), _pixelPaint);
    });
  }

  @override
  void onRemove() {
    for (final disconnect in _disconnects) {
      disconnect();
    }
    for (final image in _bakedChunks.values) {
      image.dispose();
    }
    _bakedChunks.clear();
    super.onRemove();
  }
}
