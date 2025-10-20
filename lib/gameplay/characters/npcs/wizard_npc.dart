import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// NPC character Wizard for the Darkness Dungeon game
/// Following Flutter naming conventions for NPC interaction systems
///
/// This class handles:
/// - Initial player interaction and introduction dialogue
/// - Tutorial guidance and game orientation
/// - Visual feedback through emote animations
///
/// Usage patterns:
/// ```dart
/// final wizard = WizardNpc(position);
/// wizard.onLoad();
/// ```
class WizardNpc extends SimpleNpc {
  // 1. Constantes de configuração
  static const String kInteractionKey = 'talk_wizard';
  static const double kNpcSizeMultiplierX = 0.8;
  static const double kNpcSizeMultiplierY = 1.0;

  // 2. Variáveis de instância privadas
  bool _isShowingConversation = false;

  // 3. Construtor
  /// Creates a wizard NPC that provides introductory guidance to players
  WizardNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteAnimations.wizardIdleLeft(),
          runRight: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        position: position,
        size: Vector2(
          GameplayConstants.kTileSizeDefault * kNpcSizeMultiplierX,
          GameplayConstants.kTileSizeDefault * kNpcSizeMultiplierY,
        ),
      );

  // 4. Métodos públicos principais
  @override
  void update(double dt) {
    super.update(dt);
    _checkPlayerProximity();
  }

  // 5. Métodos privados auxiliares
  /// Checks for player proximity to initiate conversation
  void _checkPlayerProximity() {
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: _onPlayerDetected,
        radiusVision: GameplayConstants.kVisionRadiusSmall,
      );
    }
  }

  /// Handles player detection and initiates introduction sequence
  void _onPlayerDetected(Component player) {
    if (!_isShowingConversation) {
      gameRef.player!.idle();
      _isShowingConversation = true;
      CharacterEmoteController.displayEmoteAboveCharacter(
        gameRef: gameRef,
        target: this,
        assetPath: CharacterEmoteController.kQuestionEmoteAssetPath,
      );
      _initializeDialogue();
    }
  }

  /// Initializes the dialogue system and shows conversation
  void _initializeDialogue() {
    GameplayAudioManager.playInteraction();
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      _createDialogueSequence(),
      onChangeTalk: _onDialogueChanged,
      onFinish: _onConversationFinished,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  /// Creates the dialogue sequence for the wizard introduction
  List<Say> _createDialogueSequence() {
    return [
      Say(
        text: [TextSpan(text: getString('talk_wizard_1'))],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_1'))],
        person: DFAnimatedSpriteWidget(
          animation: PlayerSpriteAnimations.knightIdleRight6(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_wizard_2'))],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_2'))],
        person: DFAnimatedSpriteWidget(
          animation: PlayerSpriteAnimations.knightIdleRight6(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_wizard_3'))],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
    ];
  }

  /// Handles dialogue change events with audio feedback
  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Handles conversation completion
  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
  }
}
