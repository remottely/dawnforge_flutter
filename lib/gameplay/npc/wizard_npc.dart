import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_animated_sprite_widget.dart';
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
          GameplayTileConstants.kCurrentTileSize * 0.8,
          GameplayTileConstants.kCurrentTileSize,
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
        radiusVision: (2 * GameplayTileConstants.kCurrentTileSize),
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
        size: Vector2.all(GameplayTileConstants.kCurrentTileSize / 2),
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
