// import 'dart:async' as async;
// // lib/gameplay/core/game_controller.dart (exemplo de uso)
// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/features/characters/player/demo/demo_player_view.dart';
// import 'package:dawnforge/shared/framework/character/character_data.dart';
// import 'package:dawnforge/shared/framework/save/player_save_manager.dart';

// class GameController {
//   late DemoPlayer player;

//   /// Inicializa o jogo (carrega ou cria novo player)
//   Future<void> initializeGame() async {
//     final savedData = await PlayerSaveManager.loadPlayer();

//     if (savedData != null) {
//       // Carregar do save
//       player = DemoPlayer.fromSave(savedData.toJson());
//     } else {
//       // Novo jogo
//       player = DemoPlayer.newGame(Vector2(100, 100));
//     }
//   }

//   /// Salva o estado atual do jogo
//   Future<void> saveGame() async {
//     final success = await PlayerSaveManager.savePlayer(player.data);

//     if (success) {
//       print('✓ Game saved successfully');
//     } else {
//       print('✗ Failed to save game');
//     }
//   }

//   /// Auto-save periódico
//   void startAutoSave() {
//     async.Timer.periodic(Duration(minutes: 5), (_) {
//       saveGame();
//     });
//   }
// }
