import 'dart:io';

import 'package:flutter/material.dart';

import '../game/game_state.dart';
import '../game/net.dart';
import '../player/player.dart';
import 'game_view.dart';

/// Title screen: new world (seed + class), continue, host / join, quit.
class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.args, required this.saveRoot});
  final Map<String, String> args;
  final String saveRoot;

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _name = TextEditingController(text: 'default');
  late final TextEditingController _seed;
  final TextEditingController _ip = TextEditingController(text: '127.0.0.1');
  String _class = 'warrior';
  String _status = '';
  bool _busy = false;

  static const Map<String, String> _desc = {
    'warrior': 'Strong and tough. Starts with a sword. Ability: Whirlwind hits everything around you.',
    'ranger': 'Fast bow shots. Starts with 48 arrows. Ability: Arrow Volley fires eight arrows at once.',
    'mage': 'Fire bolts that cost mana. Ability: Fire Nova burns every enemy near you.',
    'rogue': 'Quick daggers with bonus hits. Ability: Shadow Dash leaps you forward.',
  };

  @override
  void initState() {
    super.initState();
    _seed = TextEditingController(text: '${DateTime.now().millisecondsSinceEpoch % 100000}');
    _pickClass('warrior');
  }

  String _validName() {
    final n = _name.text.trim().replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return n.isEmpty ? 'default' : n;
  }

  bool _hasSave() => File('${widget.saveRoot}/worlds/${_validName()}/player.json').existsSync();

  int _seedValue() => int.tryParse(_seed.text) ?? _seed.text.hashCode;

  void _pickClass(String id) {
    final c = Player.classes[id]!;
    setState(() {
      _class = id;
      _status = '${c.name} — HP ${c.hp.toInt()}, stamina ${c.stamina.toInt()}, mana ${c.mana.toInt()}\n${_desc[id]}';
    });
  }

  void _start() {
    final gs = GameState.instance;
    final args = Map<String, String>.of(widget.args);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => GameView(args: args, saveDir: '${widget.saveRoot}/worlds/${gs.worldName}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gs = GameState.instance;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(20, 26, 41, 1),
      body: Center(
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DAWNFORGE CUBEWORLD', style: TextStyle(fontSize: 44, color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('a Cube World + Minecraft clone — proof of concept (Flutter + flutter_scene)',
                    style: TextStyle(color: Color.fromRGBO(179, 179, 204, 1))),
                const SizedBox(height: 18),
                Row(children: [
                  const Text('World name', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  SizedBox(width: 200, child: TextField(controller: _name, onChanged: (_) => setState(() {}), style: const TextStyle(color: Colors.white))),
                  const SizedBox(width: 16),
                  const Text('Seed', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  SizedBox(width: 120, child: TextField(controller: _seed, style: const TextStyle(color: Colors.white))),
                ]),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text('Class', style: TextStyle(color: Colors.white))),
                Row(
                  children: [
                    for (final e in Player.classes.entries)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: SizedBox(
                            height: 44,
                            child: _class == e.key
                                ? FilledButton(onPressed: () => _pickClass(e.key), child: Text(e.value.name))
                                : OutlinedButton(onPressed: () => _pickClass(e.key), child: Text(e.value.name)),
                          ),
                        ),
                      ),
                  ],
                ),
                Text(_status, style: const TextStyle(fontSize: 13, color: Color.fromRGBO(191, 191, 204, 1))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      gs.worldName = _validName();
                      gs.seedValue = _seedValue();
                      gs.playerClass = _class;
                      gs.freshWorld = true;
                      _start();
                    },
                    child: const Text('New World'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _hasSave()
                        ? () {
                            gs.worldName = _validName();
                            gs.freshWorld = false;
                            _start();
                          }
                        : null,
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  SizedBox(
                    height: 40,
                    child: FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () async {
                              gs.worldName = _validName();
                              gs.seedValue = _seedValue();
                              gs.playerClass = _class;
                              gs.freshWorld = !_hasSave();
                              setState(() => _busy = true);
                              if (await Net.instance.host()) {
                                _start();
                              } else {
                                setState(() {
                                  _busy = false;
                                  _status = 'Could not open port ${Net.port}';
                                });
                              }
                            },
                      child: Text('Host (port ${Net.port})'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 160, child: TextField(controller: _ip, style: const TextStyle(color: Colors.white))),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () async {
                              gs.playerClass = _class;
                              setState(() => _busy = true);
                              if (await Net.instance.join(_ip.text.trim())) {
                                gs.seedValue = _seedValue();
                                _start();
                              } else {
                                setState(() {
                                  _busy = false;
                                  _status = 'Bad address';
                                });
                              }
                            },
                      child: const Text('Join'),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SizedBox(height: 40, width: double.infinity, child: OutlinedButton(onPressed: () => exit(0), child: const Text('Quit'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
