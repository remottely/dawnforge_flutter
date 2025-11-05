import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

final class DoorKeyDecorationConfig {
  DoorKeyDecorationConfig._();

  static final Vector2 _textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> loadSprite() =>
      Sprite.load('gameplay/decorations/door_key_decoration_1.png');
}

class DoorKeyDecorationView extends DDContactDecoration {
  bool _hasBeenCollected = false;

  DoorKeyDecorationView({required super.position})
    : super.withSprite(
        sprite: DoorKeyDecorationConfig.loadSprite(),
        size: DoorKeyDecorationConfig._componentSize,
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
    // TODO(Kevin): add some FX here
    player.model.obtainKey();
  }

  void _cleanup() {
    removeFromParent();
  }
}
