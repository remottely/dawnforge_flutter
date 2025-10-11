import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/localization/strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WizardNPC extends SimpleNpc {
  bool _isShowingConversation = false;
  WizardNPC(Vector2 position)
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
    if (gameRef.player != null) {
      this.seeComponent(
        gameRef.player!,
        observed: (player) {
          if (!_isShowingConversation) {
            gameRef.player!.idle();
            _isShowingConversation = true;
            _displayEmoteAboveNPC(emotePath: 'emote/emote_interregacao.png');
            _showIntroduction();
          }
        },
        radiusVision: (2 * GameplayConstants.kCurrentTileSize),
      );
    }
  }

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

  void _showIntroduction() {
    GameplayAudioManager.playInteraction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_wizard_1'))],
          person: AnimatedSpriteWidget(
            animation: NpcSpriteSheet.wizardIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_1'))],
          person: AnimatedSpriteWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_wizard_2'))],
          person: AnimatedSpriteWidget(
            animation: NpcSpriteSheet.wizardIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_2'))],
          person: AnimatedSpriteWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_wizard_3'))],
          person: AnimatedSpriteWidget(
            animation: NpcSpriteSheet.wizardIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
      ],
      onChangeTalk: (index) {
        GameplayAudioManager.playInteraction();
      },
      onFinish: () {
        GameplayAudioManager.playInteraction();
      },
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }
}
