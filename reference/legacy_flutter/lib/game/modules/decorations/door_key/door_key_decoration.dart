import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/decorations/door_key/door_key_decoration_config.dart';
import 'package:dawnforge/shared/framework/decorations/dd_contact_decoration.dart';
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';

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
  void onContact(SimplePlayer _player) {
    if (!_hasBeenCollected) {
      if (_tryCollectKey()) {
        _hasBeenCollected = true;
        _cleanup();
      }
    }
  }

  bool _tryCollectKey() {
    // TODO(Kevin): add some VFX and SFX here
    final added = getIt<AddItemUseCase>()(DoorKeyDecorationDef.kItemId, 1);
    return added;
  }

  void _cleanup() {
    removeFromParent();
  }
}
