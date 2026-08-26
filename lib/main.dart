import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter/material.dart';

/// Tessera-Dart boot shell. FP3 replaces the placeholder body with the Flame
/// `GameWidget`; until then the app proves exactly one thing — the core
/// systems register and the tree builds.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerCoreSystems();
  runApp(const DawnforgeApp());
}

class DawnforgeApp extends StatelessWidget {
  const DawnforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dawnforge',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            // Boot placeholder, not player-facing content — replaced in FP3.
            'Tessera-Dart — FP1',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
