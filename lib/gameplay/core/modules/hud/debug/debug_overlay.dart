import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DebugOverlay extends StatefulWidget {
  final dynamic player;
  final bool showFps;
  final bool showPosition;
  final bool showEntities;

  const DebugOverlay({
    super.key,
    required this.player,
    this.showFps = true,
    this.showPosition = true,
    this.showEntities = true,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  final List<Duration> _frameTimes = [];
  double _fps = 0;
  static const int _windowSize = 60;
  Duration? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!mounted) return;

    if (_lastFrameTime != null) {
      final frameDuration = timestamp - _lastFrameTime!;
      _frameTimes.add(frameDuration);

      if (_frameTimes.length > _windowSize) {
        _frameTimes.removeAt(0);
      }

      if (_frameTimes.isNotEmpty) {
        final avgMicroseconds =
            _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
            _frameTimes.length;
        _fps = avgMicroseconds > 0 ? 1000000 / avgMicroseconds : 0;
      }
    }

    _lastFrameTime = timestamp;

    if (mounted) {
      setState(() {});
      SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  @override
  void dispose() {
    _lastFrameTime = null;
    super.dispose();
  }

  Color _getFpsColor() {
    if (_fps >= 55) return const Color(0xFF00FF00);
    if (_fps >= 30) return const Color(0xFFFFFF00);
    return const Color(0xFFFF0000);
  }

  @override
  Widget build(BuildContext context) {
    // if (!AppEnvironment.kIsDevToolsMode) { // TODO(Kevin): NOW - put it back
    //   return const SizedBox.shrink();
    // }

    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showFps)
              Text(
                'FPS:${_fps.toStringAsFixed(0)}',
                style: TextStyle(
                  color: _getFpsColor(),
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            if (widget.showPosition && widget.player != null) ...[
              const SizedBox(height: 4),
              Text(
                'x:${widget.player.x.toInt()}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              Text(
                'y:${widget.player.y.toInt()}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
            // Note: showEntities removed as we can't easily access game.visibles() from Flutter widget
          ],
        ),
      ),
    );
  }
}
