import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key/door_key_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class DoorKeyDecorationView extends DDContactDecoration {
  bool _hasBeenCollected = false;

  DoorKeyDecorationView({required super.position})
    : super.withSprite(
        sprite: DoorKeyDecorationDef.loadSprite(),
        size: DoorKeyDecorationDef.componentSize,
      );

  @override
  Future<void> onLoad() {
    add(DoorKeyDecorationDef.createHitbox());
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
    (player as DDBasePlayerView).controller.model
        .obtainKey(); // TODO(Kevin): make this more generic, like DDBasePlayerView
  }

  void _cleanup() {
    removeFromParent();
  }
}
