import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key/door_key_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

class DoorKeyDecorationView extends DDContactDecoration {
  bool _hasBeenCollected = false;

  DoorKeyDecorationView({required super.position})
    : super.withSprite(
        sprite: DoorKeyDecorationConfig.loadSprite(),
        size: DoorKeyDecorationConfig.componentSize,
      );

  @override
  Future<void> onLoad() {
    add(DoorKeyDecorationConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void onContact(SimplePlayer player) {
    if (!_hasBeenCollected) {
      _hasBeenCollected = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  void _triggerEffect(SimplePlayer player) {
    // TODO(Kevin): add some VFX and SFX here
    (player as DDBasePlayerView).model
        .obtainKey(); // TODO(Kevin): make this more generic, like DDBasePlayerView
  }

  void _cleanup() {
    removeFromParent();
  }
}
