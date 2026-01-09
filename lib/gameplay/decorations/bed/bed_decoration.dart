import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart' as new_time;
import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/decorations/bed/bed_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/dialog/binary_choice_dialog.dart';

class BedDecorationView extends GameDecoration {
  bool _isUsed = false;
  bool _isShowingChoice = false;

  BedDecorationView({required super.position, required super.size});
    // : super.withSprite(
    //     sprite: BedDecorationDef.loadSpriteIdle(),
    //     size: BedDecorationDef.componentSize,
    //   );

  @override
  Future<void> onLoad() {
    add(BedDecorationDef.createHitbox(this));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is SimplePlayer) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _handlePlayerCollision(SimplePlayer player) {
    if (_isUsed || UIStateManager.instance.isShowingConversation) return;
    _showUseBedFlow(player);
  }

  void _showUseBedFlow(Player player) {
    UIStateManager.instance.isShowingConversation = true;
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: BedDecorationDef.createConversationSequence(),
      onCloseConversation: () {
        UIStateManager.instance.isShowingConversation = false;
        if (_isShowingChoice) return;
        Future.microtask(() {
          if (!_isShowingChoice) {
            _showUseBedConfirmation();
          }
        });
      },
    );
  }

  Future<void> _showUseBedConfirmation() async {
    _isShowingChoice = true;
    final result = await BinaryChoiceDialog.show(
      context: gameRef.context,
      question: 'Use bed to rest?',
      yesLabel: 'Yes',
      noLabel: 'No',
    );

    _isShowingChoice = false;

    if (result == true) {
      // Stardew Valley behavior: advance day and save game
      _triggerBedUse();
      _advanceDayAndSaveGame();
    }
  }


  void _triggerBedUse() {
    _isUsed = true;
    // _playAnimationBedUse();
  }

  void _advanceDayAndSaveGame() {
    // Advance the day
    // Import these if not present:
    // import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
    // import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;
    // import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
    new_time.TimeManager.instance.advanceToNextDay();
    GameSaveController.instance.saveGame();
  }

  // void _playAnimationBedUse() {
  //   playSpriteAnimationOnce(
  //     BedDecorationDef.loadAnimationUse(),
  //     onFinish: _cleanup,
  //     onStart: () {
  //       sprite = null;
  //     },
  //   );
  // }

  // void _cleanup() {
  //   removeFromParent();
  // }
}
