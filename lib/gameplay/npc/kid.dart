import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/enemies/boss.dart';
import 'package:darkness_dungeon/presentation/widgets/atoms/animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Kid extends GameDecoration {
  bool conversationWithHero = false;

  Kid(Vector2 position)
    : super.withAnimation(
        animation: NpcSpriteSheet.kidIdleLeft(),
        position: position,
        size: Vector2(
          TileHelper.valueByTileSize(8),
          TileHelper.valueByTileSize(11),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (!conversationWithHero && checkInterval('checkBossDead', 1000, dt)) {
      try {
        gameRef.enemies().firstWhere((e) => e is Boss);
      } catch (e) {
        conversationWithHero = true;
        gameRef.camera.moveToTargetAnimated(
          target: this,
          onComplete: () {
            _startConversation();
          },
        );
      }
    }
  }

  void _startConversation() {
    GameplayAudioManager.playInteraction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_kid_2'))],
          person: AnimatedSpriteWidget(animation: NpcSpriteSheet.kidIdleLeft()),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_4'))],
          person: AnimatedSpriteWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onFinish: () {
        GameplayAudioManager.playInteraction();
        gameRef.camera.moveToPlayerAnimated(
          onComplete: () {
            GameplayUIStateManager.displayVictoryDialog(gameRef.context);
          },
        );
      },
      onChangeTalk: (index) {
        GameplayAudioManager.playInteraction();
      },
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }
}
