import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KidNpcController {
  bool _conversationWithHero = false;
  late KidNpcView _view;

  void attachView(dynamic view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _checkForBossDefeat(dt);
  }

  void _checkForBossDefeat(double dt) {
    if (!_conversationWithHero &&
        _view.checkInterval('checkBossDead', 1000, dt)) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  bool _isBossDefeated() {
    try {
      _view.gameRef.enemies().firstWhere((enemy) => enemy is DungeonBossEnemy);
      return false;
    } catch (e) {
      return true;
    }
  }

  void _initiateVictorySequence() {
    _conversationWithHero = true;
    _view.gameRef.camera.moveToTargetAnimated(
      target: _view,
      onComplete: _initializeDialogue,
    );
  }

  void _initializeDialogue() {
    GameplayAudioManager.playInteraction();
    GameplayUIManager.displayConversationDialog(
      _view.gameRef.context,
      _createDialogueSequence(),
      onFinish: _onConversationFinished,
      onChangeTalk: _onDialogueChanged,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  List<Say> _createDialogueSequence() {
    return [
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_kid_2'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.kidIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_player_4'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
    ];
  }

  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
    _view.gameRef.camera.moveToPlayerAnimated(
      onComplete: _displayVictoryScreen,
    );
  }

  void _displayVictoryScreen() {
    GameplayUIManager.displayVictoryDialog(_view.gameRef.context);
  }
}
