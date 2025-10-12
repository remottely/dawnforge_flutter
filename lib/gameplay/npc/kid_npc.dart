import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_animated_sprite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [KidNpc] responsible for providing end-game victory conversation
/// Following Flutter naming conventions for NPC character systems
class KidNpc extends SimpleNpc {
  // Flutter-style constants for NPC configuration
  static const String _kBossCheckInterval = 'checkBossDead';
  static const int _kBossCheckRate = 1000;

  // Private state variables
  bool _conversationWithHero = false;

  /// Creates a kid NPC that triggers victory sequence after boss defeat
  /// Following Flutter pattern of descriptive constructors
  KidNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteSheet.kidIdleLeft(),
          runRight: NpcSpriteSheet.kidIdleLeft(),
        ),
        position: position,
        size: Vector2(
          TileHelper.valueByTileSize(8),
          TileHelper.valueByTileSize(11),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _checkForBossDefeat(dt);
  }

  /// Checks if the boss has been defeated to trigger victory sequence
  /// Following Flutter pattern of private utility methods
  void _checkForBossDefeat(double dt) {
    if (!_conversationWithHero &&
        checkInterval(_kBossCheckInterval, _kBossCheckRate, dt)) {
      if (_isBossDefeated()) {
        _initiateVictorySequence();
      }
    }
  }

  /// Checks if the dungeon boss has been defeated
  /// Following Flutter pattern of boolean query methods
  bool _isBossDefeated() {
    try {
      gameRef.enemies().firstWhere((enemy) => enemy is DungeonBossEnemy);
      return false; // Boss still exists
    } catch (e) {
      return true; // Boss not found, must be defeated
    }
  }

  /// Initiates the victory sequence with camera movement and conversation
  /// Following Flutter pattern of sequence coordination methods
  void _initiateVictorySequence() {
    _conversationWithHero = true;
    gameRef.camera.moveToTargetAnimated(
      target: this,
      onComplete: _startConversation,
    );
  }

  /// Starts the victory conversation with the player
  /// Following Flutter pattern of conversation management methods
  void _startConversation() {
    GameplayAudioManager.playInteraction();
    TalkDialog.show(
      gameRef.context,
      _createVictoryDialogueSequence(),
      onFinish: _onConversationFinished,
      onChangeTalk: _onDialogueChanged,
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  /// Creates the victory dialogue sequence
  /// Following Flutter pattern of data factory methods
  List<Say> _createVictoryDialogueSequence() {
    return [
      Say(
        text: [TextSpan(text: getString('talk_kid_2'))],
        person: AppAnimatedSpriteWidget(
          animation: NpcSpriteSheet.kidIdleLeft(),
        ),
        personSayDirection: PersonSayDirection.RIGHT,
      ),
      Say(
        text: [TextSpan(text: getString('talk_player_4'))],
        person: AppAnimatedSpriteWidget(
          animation: PlayerSpriteSheet.idleRight(),
        ),
        personSayDirection: PersonSayDirection.LEFT,
      ),
    ];
  }

  /// Handles conversation completion and victory screen display
  /// Following Flutter pattern of callback handling methods
  void _onConversationFinished() {
    GameplayAudioManager.playInteraction();
    gameRef.camera.moveToPlayerAnimated(onComplete: _displayVictoryScreen);
  }

  /// Handles dialogue change events
  /// Following Flutter pattern of event handling methods
  void _onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Displays the final victory screen
  /// Following Flutter pattern of UI display methods
  void _displayVictoryScreen() {
    GameplayUIManager.displayVictoryDialog(gameRef.context);
  }
}
