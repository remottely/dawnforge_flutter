import 'package:bonfire/player/player.dart';

class GameplayGameManager {
  static void stopPlayerMovement(Player player) {
    player.idle();
  }
}
