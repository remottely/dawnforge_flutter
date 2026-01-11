import 'package:bonfire/player/player.dart';
import 'package:dawnforge/gameplay/characters/enemies/boss/boss_enemy_view.dart';
import 'package:dawnforge/gameplay/characters/npcs/kid/kid_npc_def.dart';
import 'package:dawnforge/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_def.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/gameplay/core/modules/ui/ui_state_manager.dart';

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
      conversationSequence: KidNpcDef.createConversationSequence(),
      onChangeConversation: (_) =>
          AudioManager.instance.playConversationInteractionSfx(),
      onFinishConversation: _onFinishConversation,
    );
  }

  void _onFinishConversation() {
    AudioManager.instance.playConversationInteractionSfx();
    AudioManager.instance.playBackgroundMusic(AudioDef.bgMusicGameOverSuccess);
    _view.gameRef.camera.moveToPlayerAnimated(
      onComplete: () =>
          UIStateManager.instance.displayVictoryDialog(_view.gameRef.context),
    );
  }
}
