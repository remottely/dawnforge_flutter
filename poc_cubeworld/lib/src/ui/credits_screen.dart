import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Stage 30: the credits — engine, fonts, audio, lineage, then every stage of
/// the roadmap — scrolling up from the bottom. Esc (or the button) closes it.
///
/// Godot reads `res://ROADMAP.md` through `FileAccess`. A Flutter app has no
/// project folder at runtime, so this project's `ROADMAP.md` is declared as a
/// plain asset in `pubspec.yaml` (no build hook) and read with
/// `rootBundle.loadString`; the unit test parses the same file from disk.
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key, required this.onClosed, this.startSeconds = 0.0});
  final VoidCallback onClosed;

  /// A probe capture starts part-way through the scroll.
  final double startSeconds;

  static const String roadmapAsset = 'ROADMAP.md';
  static const double speed = 42.0; // px per second

  /// Every `| N | title ...` row of the roadmap's stage table, as
  /// "Stage N — title": the bold lead when the row has one, else the stage cell
  /// cut at its first sentence.
  static List<String> parseStages(String text) {
    final row = RegExp(r'^\|\s*(\d+[ab]?)\s*\|\s*(.+?)\s*\|');
    final bold = RegExp(r'^\*\*(.+?)\*\*');
    final out = <String>[];
    for (final line in text.split('\n')) {
      final m = row.firstMatch(line);
      if (m == null) continue;
      final cell = m.group(2)!;
      final b = bold.firstMatch(cell);
      var title = b != null ? b.group(1)! : cell.split('. ').first.split(' (').first;
      if (title.endsWith('.')) title = title.substring(0, title.length - 1);
      out.add('Stage ${m.group(1)} — $title');
    }
    return out;
  }

  static Future<List<String>> loadStages() async => parseStages(await rootBundle.loadString(roadmapAsset));

  static List<String> creditsLines(List<String> stages) => [
        'CUBEWORLD POC', '', 'a Cube World + Minecraft clone, built to be played', '',
        'Engine', 'Flutter + flutter_scene 0.23 (Flutter GPU / Impeller), Dart ${Platform.version.split(' ').first}',
        'Dart for the game, a pool of isolates for chunk generation and meshing', '',
        'Fonts', 'the system fallback font (no font files)', '',
        'Music and sound', 'music and footsteps from Dawnforge (the 2D game): the Cozy Games pack and "Rites of Passage"', 'every other sound procedural, rendered in Dart, all played through SoLoud', '',
        'Lineage', 'the Godot POC (GDScript + C#), ported file by file; before it, the dev_3d_spike probe', '',
        'Stages',
        ...stages,
        '', '', 'Thanks for playing.', '', 'Esc closes',
      ];

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final GlobalKey _text = GlobalKey();
  final FocusNode _focus = FocusNode(debugLabel: 'credits');
  List<String> _lines = CreditsScreen.creditsLines(const []);
  double _seconds = 0.0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _seconds = widget.startSeconds;
    CreditsScreen.loadStages().then((stages) {
      if (mounted) setState(() => _lines = CreditsScreen.creditsLines(stages));
    });
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      setState(() => _seconds += dt);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (node, e) {
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
          widget.onClosed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        color: const Color.fromRGBO(8, 10, 20, 0.92),
        child: LayoutBuilder(builder: (context, box) {
          final textHeight = _text.currentContext?.size?.height ?? 2000.0;
          // Up from the bottom edge; once the last line has left the top, again.
          final travel = box.maxHeight + textHeight;
          final y = box.maxHeight - (_seconds * CreditsScreen.speed) % travel;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: y,
                child: Text(
                  _lines.join('\n'),
                  key: _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, height: 1.45, color: Colors.white),
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: SizedBox(width: 120, height: 36, child: FilledButton(onPressed: widget.onClosed, child: const Text('Back (Esc)'))),
              ),
            ],
          );
        }),
      ),
    );
  }
}
