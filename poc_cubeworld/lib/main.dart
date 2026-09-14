import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' hide Material;
import 'package:path_provider/path_provider.dart';

import 'src/game/game_state.dart';
import 'src/game/net.dart';
import 'src/game/settings.dart';
import 'src/game/sfx.dart';
import 'src/ui/game_view.dart';
import 'src/ui/main_menu.dart';

/// `--k=v` becomes `args['--k='] = v`; a bare `--flag` becomes `args['--flag'] = ''`.
Map<String, String> parseArgs(List<String> raw) {
  final out = <String, String>{};
  for (final a in raw) {
    final eq = a.indexOf('=');
    if (eq > 0) {
      out[a.substring(0, eq + 1)] = a.substring(eq + 1);
    } else {
      out[a] = '';
    }
  }
  return out;
}

Future<void> main(List<String> rawArgs) async {
  WidgetsFlutterBinding.ensureInitialized();
  final args = parseArgs(rawArgs);
  final support = await getApplicationSupportDirectory();
  final saveRoot = '${support.path}/dawnforge_cubeworld_poc';
  // Stage 24: the settings file sits beside worlds/ (Godot's user://settings.cfg).
  Settings.instance.path = '$saveRoot/settings.cfg';
  Settings.instance.loadFile();
  Settings.instance.applyGlobals();
  await Scene.initializeStaticResources();
  // Audio comes up in the background; the game plays silently until it does.
  Sfx.init();
  runApp(CubeworldApp(args: args, saveRoot: saveRoot));
}

class CubeworldApp extends StatelessWidget {
  const CubeworldApp({super.key, required this.args, required this.saveRoot});
  final Map<String, String> args;
  final String saveRoot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawnforge Cubeworld POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: _Launcher(args: args, saveRoot: saveRoot),
    );
  }
}

/// Mirrors the Godot menu's argument handling: --host, --join=ip, --screenshot=,
/// --new, --continue and --seed= skip straight into the game.
class _Launcher extends StatefulWidget {
  const _Launcher({required this.args, required this.saveRoot});
  final Map<String, String> args;
  final String saveRoot;

  @override
  State<_Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<_Launcher> {
  Widget? _child;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final args = widget.args;
    final gs = GameState.instance;
    if (args.containsKey('--class=')) gs.playerClass = args['--class=']!;
    if (args.containsKey('--host')) {
      gs.freshWorld = true;
      gs.worldName = 'host_probe';
      if (args.containsKey('--seed=')) gs.seedValue = int.parse(args['--seed=']!);
      if (await Net.instance.host()) _enter();
      return;
    }
    if (args.containsKey('--join=')) {
      if (args.containsKey('--seed=')) gs.seedValue = int.parse(args['--seed=']!);
      if (!await Net.instance.join(args['--join=']!)) return;
      // Wait for the host's hello before building anything: it carries the seed,
      // and a world built on the wrong seed would put the spawn search on
      // terrain that is about to be replaced.
      final until = DateTime.now().add(const Duration(seconds: 8));
      while (!Net.instance.connected && DateTime.now().isBefore(until)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      _enter();
      return;
    }
    if (args.containsKey('--screenshot=') || args.containsKey('--new') || args.containsKey('--continue') || args.containsKey('--seed=')) {
      if (args.containsKey('--new')) gs.freshWorld = true;
      if (args.containsKey('--seed=')) gs.seedValue = int.parse(args['--seed=']!);
      if (args.containsKey('--world=')) gs.worldName = args['--world=']!;
      _enter();
      return;
    }
    setState(() => _child = MainMenu(args: args, saveRoot: widget.saveRoot));
  }

  void _enter() {
    setState(() => _child = GameView(args: widget.args, saveDir: '${widget.saveRoot}/worlds/${GameState.instance.worldName}'));
  }

  @override
  Widget build(BuildContext context) => _child ?? const Scaffold(backgroundColor: Color.fromRGBO(20, 26, 41, 1));
}
