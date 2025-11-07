import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay_hud_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats_hud.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key_decoration.dart';

class GameplayHUD extends GameInterface {
  late Sprite _keySprite;

  @override
  Future<void> onLoad() async {
    await _loadAssets();
    _initializeComponents();
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    _drawKeyIcon(canvas);
    super.render(canvas);
  }

  Future<void> _loadAssets() async {
    _keySprite =
        await DoorKeyDecorationConfig.loadSprite(); // TODO(Kevin): put this into shared layer, and cache this?
  }

  void _initializeComponents() {
    add(PlayerVitalStatsHUD());
  }

  void _drawKeyIcon(Canvas canvas) {
    if (_hasPlayerWithKey()) {
      _keySprite.renderRect(
        canvas,
        Rect.fromLTWH(
          GameplayHUDConfig.kKeyIconStartPositionX,
          GameplayHUDConfig.kKeyIconStartPositionY,
          GameplayHUDConfig.kKeyIconWidth,
          GameplayHUDConfig.kKeyIconHeight,
        ),
      );
    }
  }

  bool _hasPlayerWithKey() {
    return gameRef.player != null &&
        (gameRef.player as SunnyPlayerView).model.hasKey;
  }
}
