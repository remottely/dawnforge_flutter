import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/environment_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:flutter/cupertino.dart';

class Door extends GameDecoration {
  bool isOpen = false;
  bool isShowingDialog = false;

  Door(Vector2 position, Vector2 size)
    : super.withSprite(
        sprite: Sprite.load('items/door_closed.png'),
        position: position,
        size: size,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(width, height / 4),
        position: Vector2(0, height * 0.75),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Knight) {
      if (!isOpen) {
        Knight player = other;
        if (player.hasKey == true) {
          isOpen = true;
          player.hasKey = false;

          playSpriteAnimationOnce(
            EnvironmentSpriteSheet.openTheDoor(),
            onFinish: removeFromParent,
            onStart: () {
              sprite = null;
            },
          );
        } else {
          if (!isShowingDialog) {
            isShowingDialog = true;
            _showKeyRequiredDialog();
          }
        }
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _showKeyRequiredDialog() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('door_without_key'))],
          person: PlayerSpriteSheet.idleRight().asWidget(),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onClose: () {
        isShowingDialog = false;
      },
    );
  }
}
