import 'package:bonfire/player/player.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';

class KidNpcController {
  bool _hasStartedConversationWithHero = false;
  late KidNpcView _view;

  void attachView(KidNpcView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _checkForBossDefeat(dt);
  }

  void _checkForBossDefeat(double dt) {
    if (!_hasStartedConversationWithHero &&
        _view.checkInterval('checkBossDead', 1000, dt)) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  bool _isBossDefeated() {
    try {
      _view.gameRef.enemies().firstWhere(
        (enemy) => enemy is DungeonBossEnemyView,
      );
      return false;
    } catch (e) {
      return true;
    }
  }

  void _initiateVictorySequence() {
    _hasStartedConversationWithHero = true;
    _view.gameRef.camera.moveToTargetAnimated(
      target: _view,
      onComplete: () => _showConversation(_view.gameRef.player!),
    );
  }

  void _showConversation(Player player) {
    GameplayAudioManager.instance.playInteraction();
    GameplayUIManager.instance.showConversation(
      _view.gameRef.context,
      player: player,
      conversationSequence: KidNpcConfig.createConversationSequence(),
      onFinish: _onConversationFinished,
      onChangeTalk: _onConversationChanged,
      logicalKeyboardKeysToNext: [
        GameplayInputActionsConfig.kKeyboardMeleeAttack,
      ],
    );
  }

  void _onConversationChanged(int index) {
    GameplayAudioManager.instance.playInteraction();
  }

  void _onConversationFinished() {
    GameplayAudioManager.instance.playInteraction();
    _view.gameRef.camera.moveToPlayerAnimated(
      onComplete: _displayVictoryScreen,
    );
  }

  void _displayVictoryScreen() {
    GameplayUIManager.instance.displayVictoryDialog(_view.gameRef.context);
  }
}
