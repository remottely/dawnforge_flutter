// // lib/main.dart ou seu game screen
// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';
// import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
// import 'package:dawnforge/shared/framework/save/player_save_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class GameScreen extends StatefulWidget {
//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   DemoPlayer? _player;
//   bool _isLoading = true;
  
//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }
  
//   Future<void> _initializePlayer() async {
//     final savedData = await PlayerSaveManager.loadPlayer();
    
//     setState(() {
//       if (savedData != null) {
//         _player = DemoPlayer.fromSave(savedData.toJson());
//       } else {
//         _player = DemoPlayer.newGame(Vector2(100, 100));
//       }
//       _isLoading = false;
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading || _player == null) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
    
//     return BonfireWidget(
//       joystick: Joystick(
//         directional: JoystickDirectional(),
//         actions: [
//           JoystickAction(
//             actionId: 1, // Primary action
//             margin: EdgeInsets.all(50),
//           ),
//         ],
//       ),
//       player: _player!,
//       map: WorldMapByTiled(
//         WorldMapReader.fromAsset('map.json'),
//         forceTileSize: Vector2(16, 16),
//       ),
//       cameraConfig: CameraConfig(
//         moveOnlyMapArea: true,
//         zoom: 2.0,
//       ),
//       lightingColorGame: Colors.black.withOpacity(0.7),
//       onDispose: () {
//         // Auto-save ao sair
//         PlayerSaveManager.savePlayer(_player!.data);
//       },
//     );
//   }
// }