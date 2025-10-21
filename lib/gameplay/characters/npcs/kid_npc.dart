import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class _KidNpcData {
  static const String bossCheckInterval = 'checkBossDead';
  static const int bossCheckRate = 1000;
  static const double sizeMultiplierX = 8.0;
  static const double sizeMultiplierY = 11.0;
  static Vector2 get size => Vector2(sizeMultiplierX, sizeMultiplierY);
  static SimpleDirectionAnimation get animation => SimpleDirectionAnimation(
    idleRight: NpcSpriteAnimations.kidIdleLeft(),
    runRight: NpcSpriteAnimations.kidIdleLeft(),
  );
}

class KidNpc extends SimpleNpc {
  bool _conversationWithHero = false;

  KidNpc(Vector2 position)
    : super(
        animation: _KidNpcData.animation,
        position: position,
        size: _KidNpcData.size,
      );

  @override
  void update(double dt) {
    super.update(dt);
    _checkForBossDefeat(dt);
  }

  void _checkForBossDefeat(double dt) {
    if (!_conversationWithHero &&
        checkInterval(
          _KidNpcData.bossCheckInterval,
          _KidNpcData.bossCheckRate,
          dt,
        )) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  bool _isBossDefeated() {
    try {
      gameRef.enemies().firstWhere((enemy) => enemy is DungeonBossEnemy);
      return false;
    } catch (e) {
      return true;
    }
  }

  void _initiateVictorySequence() {
    _conversationWithHero = true;
    gameRef.camera.moveToTargetAnimated(
      target: this,
      onComplete: _initializeDialogue,
    );
  }

  void _initializeDialogue() {
    GameplayAudioManager.playInteraction();
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      _createDialogueSequence(),
      onFinish: _onConversationFinished,
      onChangeTalk: _onDialogueChanged,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  List<Say> _createDialogueSequence() {
    return [
      Say(
        text: [TextSpan(text: getString('talk_kid_2'))],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.kidIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_4'))],
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
    gameRef.camera.moveToPlayerAnimated(onComplete: _displayVictoryScreen);
  }

  void _displayVictoryScreen() {
    GameplayUIManager.displayVictoryDialog(gameRef.context);
  }
}
