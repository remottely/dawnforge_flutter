import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fullscreen_helper_stub.dart'
    if (dart.library.js_interop) 'fullscreen_helper_web.dart';

/// Fullscreen toggle button overlay (only visible on web)
class FullscreenButtonOverlay extends StatelessWidget {
  final double? size;

  const FullscreenButtonOverlay({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final buttonSize = size ?? 50.0;

    return GestureDetector(
      onTap: _toggleFullscreen,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(buttonSize * 0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.fullscreen,
          size: buttonSize * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  void _toggleFullscreen() {
    if (kIsWeb) {
      toggleFullscreen();
    }
  }
}
