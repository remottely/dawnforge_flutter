import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// KidNpcController
/// ---------------------------------------------------------------------------
/// Orchestrates logic, timers, and communication between Model (data) and View (Bonfire component).
class KidNpcController {
  bool _conversationWithHero = false;
  late KidNpcView _view;

  /// Attach the View to the Controller
  void attachView(KidNpcView view) {
    _view = view;
  }

  /// Called every game tick by the View
  void onUpdate(double dt) {
    _checkForBossDefeat(dt);
  }

  /// Checks if the boss is defeated and triggers the victory sequence
  void _checkForBossDefeat(double dt) {
    if (!_conversationWithHero &&
        _view.checkInterval('checkBossDead', 1000, dt)) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  /// Returns true if the boss is defeated
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

  /// Initiates the victory sequence (dialogue and victory screen)
  void _initiateVictorySequence() {
    _conversationWithHero = true;
    _view.gameRef.camera.moveToTargetAnimated(
      target: _view,
      onComplete: _initializeDialogue,
    );
  }

  /// Initializes the dialogue sequence with the player
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

  /// Creates the sequence of Say objects for the conversation
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

  /// Called when the dialogue changes (player advances conversation)
  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Called when the conversation finishes
  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
    _view.gameRef.camera.moveToPlayerAnimated(
      onComplete: _displayVictoryScreen,
    );
  }

  /// Displays the victory screen
  void _displayVictoryScreen() {
    GameplayUIManager.displayVictoryDialog(_view.gameRef.context);
  }
}
