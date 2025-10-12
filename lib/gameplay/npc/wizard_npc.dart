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
class WizardNpc extends SimpleNpc {
  // Flutter-style constants for NPC configuration
  static const double _kVisionRadius = 2.0;

  // Private state variables
  bool _isShowingConversation = false;

  /// Creates a wizard NPC that provides introductory guidance to players
  /// Following Flutter pattern of descriptive constructors
  WizardNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteSheet.wizardIdleLeft(),
          runRight: NpcSpriteSheet.wizardIdleLeft(),
        ),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize * 0.8,
          GameplayConstants.kCurrentTileSize,
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _checkPlayerProximity();
  }

  /// Checks for player proximity to initiate conversation
  /// Following Flutter pattern of proximity detection methods
  void _checkPlayerProximity() {
    if (gameRef.player != null) {
      this.seeComponent(
        gameRef.player!,
        observed: _onPlayerDetected,
        radiusVision: (_kVisionRadius * GameplayConstants.kCurrentTileSize),
      );
    }
  }

  /// Handles player detection and initiates introduction sequence
  /// Following Flutter pattern of event handler methods
  void _onPlayerDetected(Component player) {
    if (!_isShowingConversation) {
      gameRef.player!.idle();
      _isShowingConversation = true;
      _displayEmoteAboveNPC(emotePath: 'emote/emote_interregacao.png');
      _showIntroduction();
    }
  }

  /// Displays an emotion emote above the NPC
  /// Following Flutter pattern of visual feedback methods
  void _displayEmoteAboveNPC({
    String emotePath = 'emote/emote_exclamacao.png',
  }) {
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
        offset: Vector2(18, -6),
        size: Vector2.all(GameplayConstants.kCurrentTileSize / 2),
      ),
    );
  }

  /// Shows the introductory conversation with the player
  /// Following Flutter pattern of dialogue management methods
  void _showIntroduction() {
    GameplayAudioManager.playInteraction();
    TalkDialog.show(
      gameRef.context,
      _createIntroductionDialogueSequence(),
      onChangeTalk: _onDialogueChanged,
      onFinish: _onConversationFinished,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  /// Creates the introduction dialogue sequence
  /// Following Flutter pattern of data factory methods
  List<Say> _createIntroductionDialogueSequence() {
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

  /// Handles dialogue change events
  /// Following Flutter pattern of event handling methods
  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Handles conversation completion
  /// Following Flutter pattern of callback handling methods
  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
  }
}
