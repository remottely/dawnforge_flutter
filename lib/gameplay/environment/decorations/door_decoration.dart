import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_character.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/sprites/decoration_sprite_animations.dart';
import 'package:flutter/cupertino.dart';

class DoorDecoration extends DFGameDecoration {
  static const String kClosedDoorAsset =
      'gameplay/environment/decorations/door_decoration_locked_1.png';
  static const String kRequiredKeyMessage = 'door_without_key';
  static const double kHitboxHeightRatio = 0.25;
  static const double kHitboxPositionRatio = 0.75;

  DoorDecoration({required super.position, required super.size})
    : super.withSprite(sprite: Sprite.load(kClosedDoorAsset));

  bool _isOpen = false;
  bool _isShowingDialog = false;

  @override
  Future<void> onLoad() {
    _setupHitbox();
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is KnightCharacter) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _setupHitbox() {
    add(
      RectangleHitbox(
        size: Vector2(width, height * kHitboxHeightRatio),
        position: Vector2(0, height * kHitboxPositionRatio),
      ),
    );
  }

  void _handlePlayerCollision(KnightCharacter player) {
    if (!_isOpen) {
      if (player.hasKey == true) {
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage();
      }
    }
  }

  void _triggerDoorOpening(KnightCharacter player) {
    _isOpen = true;
    player.hasKey = false;
    _playOpeningAnimation();
  }

  void _playOpeningAnimation() {
    playSpriteAnimationOnce(
      DecorationSpriteAnimations.doorDecorationOpening14(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  void _showKeyRequiredMessage() {
    if (!_isShowingDialog) {
      _isShowingDialog = true;
      _showKeyRequiredDialog();
    }
  }

  void _showKeyRequiredDialog() {
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString(kRequiredKeyMessage))],
          person: PlayerSpriteSheet.idleRight().asWidget(),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onClose: () {
        _isShowingDialog = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
