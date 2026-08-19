import 'dart:html' as html;

import 'package:dawnforge/core/utils/game_logger.dart';

void toggleFullscreen() {
  try {
    final doc = html.document.documentElement;
    if (doc == null) return;

    if (html.document.fullscreenElement == null) {
      doc.requestFullscreen();
    } else {
      html.document.exitFullscreen();
    }
  } catch (e) {
    // Silently fail if fullscreen is not supported
    // ignore: avoid_print
    GameLogger.warning('Fullscreen not supported or failed: $e');
  }
}
