import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// WizardNpcView
/// ---------------------------------------------------------------------------
/// Responsible for rendering and visual interaction of the Wizard NPC.
/// No business logic, only visual feedback and interaction with the Controller.
class WizardNpcView extends SimpleNpc {
  final WizardNpcController _controller = WizardNpcController(
    model: WizardNpcModel(),
  );

  WizardNpcView(Vector2 position)
    : super(
        animation: WizardNpcConfig.buildDirectionalAnimation,
        position: position,
        size: WizardNpcConfig.spriteSize,
      );

  //////////////////////////////////////////////////////////////////////////////
  // LIFECYCLE
  //////////////////////////////////////////////////////////////////////////////
  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  //////////////////////////////////////////////////////////////////////////////
  // PLAYER PROXIMITY DETECTION
  //////////////////////////////////////////////////////////////////////////////
  /// Checks if the player is near the wizard and triggers controller logic
  void checkPlayerProximity() {
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: _controller.onPlayerDetected,
        radiusVision: WizardNpcConfig.kVisionRadius,
      );
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  // PLAYER FEEDBACK
  //////////////////////////////////////////////////////////////////////////////
  /// Sets the player to idle state (visual only)
  void idlePlayer() {
    gameRef.player?.idle();
  }

  //////////////////////////////////////////////////////////////////////////////
  // DIALOGUE & CONVERSATION
  //////////////////////////////////////////////////////////////////////////////
  /// Initializes the dialogue sequence with the player
  void initializeDialogue() {
    GameplayAudioManager.playInteraction();
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      _createDialogueSequence(),
      onChangeTalk: _controller.onDialogueChanged,
      onFinish: _controller.onConversationFinished,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  /// Creates the sequence of Say objects for the conversation
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
          animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
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
          animation: PlayerSpriteAnimations.knightPlayerIdleRight6(),
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
}
