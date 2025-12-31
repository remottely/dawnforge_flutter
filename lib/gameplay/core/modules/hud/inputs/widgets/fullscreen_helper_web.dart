import 'dart:html' as html;

void toggleFullscreen() {
  final doc = html.document.documentElement;
  if (html.document.fullscreenElement == null) {
    doc?.requestFullscreen();
  } else {
    html.document.exitFullscreen();
  }
}
