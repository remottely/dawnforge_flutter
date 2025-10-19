import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/core/components/df_animated_sprite_widget.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// NPC character Kid for the Darkness Dungeon game
/// Following Flutter naming conventions for NPC interaction systems
///
/// This class handles:
/// - End-game victory sequence after boss defeat
/// - Final conversation with the player
/// - Victory screen display and game completion
///
/// Usage patterns:
/// ```dart
/// final kid = KidNpc(position);
/// kid.onLoad();
/// ```
class KidNpc extends SimpleNpc {
  // 1. Constantes de configuração
  static const String kBossCheckInterval = 'checkBossDead';
  static const int kBossCheckRate = 1000;
  static const String kInteractionKey = 'talk_kid';
  static const double kNpcSizeMultiplierX = 8.0;
  static const double kNpcSizeMultiplierY = 11.0;

  // 2. Variáveis de instância privadas
  bool _conversationWithHero = false;

  // 3. Construtor
  /// Creates a kid NPC that triggers victory sequence after boss defeat
  KidNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteSheet.kidIdleLeft(),
          runRight: NpcSpriteSheet.kidIdleLeft(),
        ),
        position: position,
        size: Vector2(kNpcSizeMultiplierX, kNpcSizeMultiplierY),
      );

  // 4. Métodos públicos principais
  @override
  void update(double dt) {
    super.update(dt);
    _checkForBossDefeat(dt);
  }

  // 5. Métodos privados auxiliares
  /// Checks if the boss has been defeated to trigger victory sequence
  void _checkForBossDefeat(double dt) {
    if (!_conversationWithHero &&
        checkInterval(kBossCheckInterval, kBossCheckRate, dt)) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  /// Checks if the dungeon boss has been defeated
  bool _isBossDefeated() {
    try {
      gameRef.enemies().firstWhere((enemy) => enemy is DungeonBossEnemy);
      return false; // Boss still exists
    } catch (e) {
      return true; // Boss not found, must be defeated
    }
  }

  /// Initiates the victory sequence with camera movement and conversation
  void _initiateVictorySequence() {
    _conversationWithHero = true;
    gameRef.camera.moveToTargetAnimated(
      target: this,
      onComplete: _initializeDialogue,
    );
  }

  /// Initializes the dialogue system and shows victory conversation
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

  /// Creates the victory dialogue sequence
  List<Say> _createDialogueSequence() {
    return [
      Say(
        text: [TextSpan(text: getString('talk_kid_2'))],
        person: DFAnimatedSpriteWidget(animation: NpcSpriteSheet.kidIdleLeft()),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_4'))],
        person: DFAnimatedSpriteWidget(
          animation: PlayerSpriteSheet.idleRight(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
    ];
  }

  /// Handles dialogue change events with audio feedback
  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Handles conversation completion and triggers victory screen
  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
    gameRef.camera.moveToPlayerAnimated(onComplete: _displayVictoryScreen);
  }

  // 6. Métodos utilitários específicos
  /// Displays the final victory screen to complete the game
  void _displayVictoryScreen() {
    GameplayUIManager.displayVictoryDialog(gameRef.context);
  }
}
