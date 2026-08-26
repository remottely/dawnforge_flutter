import 'package:dawnforge/src/core/render/dawnforge_game.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// The FP3.6 proof instrument — the study's AIDebugMonitor equivalent: FPS
/// and worst frame against the 60fps line, streaming cost against its
/// budget, and the chunk counts that must stay bounded. Lives in the
/// camera's VIEWPORT (screen space), above everything.
///
/// Developer-facing instrumentation, deliberately outside rule 19's `tr()`
/// contract — these strings are never player content (the Godot debug
/// monitors are not localized either); an FP5 settings surface will hide
/// the overlay before anything ships.
///
/// Always on for now: half the FP3 gate is a human watching these numbers
/// on a device.
final class DebugOverlay extends PositionComponent
    with HasGameReference<DawnforgeGame> {
  DebugOverlay() : super(priority: 1 << 30, position: Vector2.all(8));

  static final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 10,
      color: Color(0xFFFFFFFF),
      fontFamily: 'monospace',
    ),
  );
  static const double _lineHeight = 12;
  static final Paint _backdrop = Paint()..color = const Color(0x99000000);

  /// Exponential moving average over the render dt.
  double _smoothedFps = 60;

  /// Worst frame inside the current one-second window, published each time
  /// the window closes — a single hitch must survive long enough to be read.
  double _windowWorstMs = 0;
  double _windowElapsed = 0;
  double _publishedWorstMs = 0;

  List<String> _lines = const <String>[];

  /// The published lines — what the gate test asserts against.
  List<String> get lines => _lines;

  @override
  void update(double dt) {
    if (dt > 0) {
      _smoothedFps = _smoothedFps * 0.95 + (1 / dt) * 0.05;
      final frameMs = dt * 1000;
      if (frameMs > _windowWorstMs) _windowWorstMs = frameMs;
      _windowElapsed += dt;
      if (_windowElapsed >= 1) {
        _publishedWorstMs = _windowWorstMs;
        _windowWorstMs = 0;
        _windowElapsed = 0;
      }
    }

    final streaming = locator<ChunkStreamingSystem>();
    final ground = game.groundLayer;
    final fps = _smoothedFps.toStringAsFixed(0);
    final worst = _publishedWorstMs.toStringAsFixed(1);
    const budget = EngineConstants.proceduralStreamFrameBudgetUsec;
    final queues =
        '${streaming.loadQueueDepth}+${streaming.unloadQueueDepth}';
    final bakes =
        '${ground.bakedChunkCount} baked  ${ground.pendingBakeCount} pending';
    _lines = <String>[
      'fps $fps  worst ${worst}ms',
      'stream ${streaming.lastUpdateMicroseconds}us / ${budget}us  q $queues',
      'chunks ${streaming.residentChunkCount} resident  $bakes',
    ];
  }

  @override
  void render(Canvas canvas) {
    var widest = 0.0;
    for (final line in _lines) {
      final width = _textPaint.getLineMetrics(line).width;
      if (width > widest) widest = width;
    }
    canvas.drawRect(
      Rect.fromLTWH(-4, -4, widest + 8, _lines.length * _lineHeight + 8),
      _backdrop,
    );
    for (var i = 0; i < _lines.length; i++) {
      _textPaint.render(canvas, _lines[i], Vector2(0, i * _lineHeight));
    }
  }
}
