import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class DoorKeyInteractableConfig {
  static const String spritePath =
      'gameplay/environment/interactables/door_key_interactable_1.png';

  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;

  static Future<Sprite> _loadSprite() => Sprite.load(spritePath);
}

class DoorKeyInteractableView extends DDSensorPlayerDecoration {
  bool _hasBeenCollected = false;

  DoorKeyInteractableView({required super.position})
    : super.withSprite(
        sprite: DoorKeyInteractableConfig._loadSprite(),
        size: DoorKeyInteractableConfig._spriteSize,
      );

  @override
  void onContact(KnightPlayerView player) {
    if (!_hasBeenCollected) {
      _hasBeenCollected = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  void _triggerEffect(KnightPlayerView player) {
    player.controller.model.hasKey = true;
  }

  void _cleanup() {
    removeFromParent();
  }
}
