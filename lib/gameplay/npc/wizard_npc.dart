import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [WizardNpc] responsible for providing introductory conversation and tutorials
/// Following Flutter naming conventions for NPC character systems
///
/// This NPC handles:
/// - Initial player interaction and introduction dialogue
/// - Tutorial guidance and game orientation
/// - Visual feedback through emote animations
class WizardNpc extends SimpleNpc {
  // 1. Constantes de configuração
  static const double kVisionRadius = 2.0;
  static const String kInteractionKey = 'talk_wizard';
  static const String kEmoteQuestionPath = 'emote/emote_interregacao.png';
  static const String kEmoteExclamationPath = 'emote/emote_exclamacao.png';
  static const double kNpcSizeMultiplierX = 0.8;
  static const double kNpcSizeMultiplierY = 1.0;
  static const double kEmoteOffsetX = 18.0;
  static const double kEmoteOffsetY = -6.0;

  // 2. Variáveis de instância privadas
  bool _isShowingConversation = false;

  // 3. Construtor
  /// Creates a wizard NPC that provides introductory guidance to players
  WizardNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteSheet.wizardIdleLeft(),
          runRight: NpcSpriteSheet.wizardIdleLeft(),
        ),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize * kNpcSizeMultiplierX,
          GameplayConstants.kCurrentTileSize * kNpcSizeMultiplierY,
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
        radiusVision: (kVisionRadius * GameplayConstants.kCurrentTileSize),
      );
    }
  }

  /// Handles player detection and initiates introduction sequence
  void _onPlayerDetected(Component player) {
    if (!_isShowingConversation) {
      gameRef.player!.idle();
      _isShowingConversation = true;
      _displayEmoteAboveNPC(emotePath: kEmoteQuestionPath);
      _initializeDialogue();
    }
  }

  /// Initializes the dialogue system and shows conversation
  void _initializeDialogue() {
    GameplayAudioManager.playInteraction();
    TalkDialog.show(
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
        person: AppAnimatedSpriteWidget(
          animation: NpcSpriteSheet.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_1'))],
        person: AppAnimatedSpriteWidget(
          animation: PlayerSpriteSheet.idleRight(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_wizard_2'))],
        person: AppAnimatedSpriteWidget(
          animation: NpcSpriteSheet.wizardIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_2'))],
        person: AppAnimatedSpriteWidget(
          animation: PlayerSpriteSheet.idleRight(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_wizard_3'))],
        person: AppAnimatedSpriteWidget(
          animation: NpcSpriteSheet.wizardIdleLeft(),
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

  /// Displays an emotion emote above the NPC
  void _displayEmoteAboveNPC({String emotePath = kEmoteExclamationPath}) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          emotePath,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        loop: false,
        target: this,
        offset: Vector2(kEmoteOffsetX, kEmoteOffsetY),
        size: Vector2.all(GameplayConstants.kCurrentTileSize / 2),
      ),
    );
  }
}
