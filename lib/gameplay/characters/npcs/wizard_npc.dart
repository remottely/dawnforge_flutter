import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_animations.dart';
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

abstract class _WizardNpcData {
  // static const String interactionKey = 'talk_wizard';
  static const double sizeMultiplierX = 0.8;
  static const double sizeMultiplierY = 1.0;
  static final Vector2 size = Vector2(
    GameplayConstants.kTileSizeStandard * sizeMultiplierX,
    GameplayConstants.kTileSizeStandard * sizeMultiplierY,
  );
  static SimpleDirectionAnimation get _buildDirectionAnimation =>
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.wizardIdleLeft(),
        runRight: NpcSpriteAnimations.wizardIdleLeft(),
      );
  static final double visionRadius = GameplayConstants.kVisionRadiusSmall;
}

class WizardNpc extends SimpleNpc {
  bool _isShowingConversation = false;

  WizardNpc(Vector2 position)
    : super(
        animation: _WizardNpcData._buildDirectionAnimation,
        position: position,
        size: _WizardNpcData.size,
      );

  @override
  void update(double dt) {
    super.update(dt);
    _checkPlayerProximity();
  }

  void _checkPlayerProximity() {
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: _onPlayerDetected,
        radiusVision: _WizardNpcData.visionRadius,
      );
    }
  }

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

  List<Say> _createDialogueSequence() {
    return [
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_wizard_1'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_player_1'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: PlayerAnimations.knightPlayerIdleRight6(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_wizard_2'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_player_2'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: PlayerAnimations.knightPlayerIdleRight6(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [
          TextSpan(
            text: GameplayStringsLocation.instance.getString('talk_wizard_3'),
          ),
        ],
        person: DFAnimatedSpriteWidget(
          animation: NpcSpriteAnimations.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
    ];
  }

  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
  }
}
