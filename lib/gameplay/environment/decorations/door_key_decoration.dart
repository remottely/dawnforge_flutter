import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _DoorKeyDecorationConfig {
  static const String _spritePath =
      GameplayAnimationConstants.kDoorKeyDecorationAssetPath;
  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;

  static Future<Sprite> _loadSprite() => Sprite.load(_spritePath);
}

class DoorKeyDecorationView extends DDSensorPlayerDecoration {
  bool _hasBeenCollected = false;

  DoorKeyDecorationView({required super.position})
    : super.withSprite(
        sprite: _DoorKeyDecorationConfig._loadSprite(),
        size: _DoorKeyDecorationConfig._spriteSize,
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
