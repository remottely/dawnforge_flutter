import 'package:bonfire/player/player.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';

class KidNpcController {
  bool _hasStartedConversationWithHero = false;
  late KidNpcView _view;

  void attachView(KidNpcView view) => _view = view;

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
      _view.gameRef.enemies().firstWhere((enemy) => enemy is BossEnemyView);
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
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      _view.gameRef.context,
      player: player,
      conversationSequence: KidNpcConfig.createConversationSequence(),
      onChangeTalk: _onConversationChanged,
      onFinish: _onConversationFinished,
      logicalKeyboardKeysToNext: [KeyboardSetup.kPrimaryAttackKey],
    );
  }

  void _onConversationChanged(int index) {
    AudioManager.instance.playConversationInteractionSfx();
  }

  void _onConversationFinished() {
    AudioManager.instance.playConversationInteractionSfx();
    _view.gameRef.camera.moveToPlayerAnimated(
      onComplete: () =>
          UIStateManager.instance.displayVictoryDialog(_view.gameRef.context),
    );
  }
}
