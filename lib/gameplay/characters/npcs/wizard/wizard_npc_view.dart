import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/shared/components/df_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// WizardNpcView
/// ---------------------------------------------------------------------------
/// Responsável pela renderização e interação visual do Wizard NPC.
class WizardNpcView extends SimpleNpc {
  final WizardNpcController _controller;

  WizardNpcView(Vector2 position, {required WizardNpcController controller})
    : _controller = controller,
      super(
        animation: WizardNpcConfig.buildDirectionalAnimation,
        position: position,
        size: WizardNpcConfig.spriteSize,
      ) {
    _controller.attachView(this);
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  void checkPlayerProximity() {
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: _controller.onPlayerDetected,
        radiusVision: WizardNpcConfig.kVisionRadius,
      );
    }
  }

  void idlePlayer() {
    gameRef.player?.idle();
  }

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
