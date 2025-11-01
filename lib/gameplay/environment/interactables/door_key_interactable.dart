import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/framework/dd_game_decoration.dart';

final class DoorKeyInteractableConfig {
  DoorKeyInteractableConfig._();

  static final Vector2 _fComponentSize = GameplayTileConfig.fTileSizeStandard;

  static Future<Sprite> loadSprite() => Sprite.load(
    'gameplay/environment/interactables/door_key_interactable_1.png',
  );
}

class DoorKeyInteractableView extends DDSensorPlayerDecoration {
  bool _hasBeenCollected = false;

  DoorKeyInteractableView({required super.position})
    : super.withSprite(
        sprite: DoorKeyInteractableConfig.loadSprite(),
        size: DoorKeyInteractableConfig._fComponentSize,
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
