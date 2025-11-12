import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/hud_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats_hud.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/door_key_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

class HUDView extends GameInterface {
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
          HUDConfig.kKeyIconStartPositionX,
          HUDConfig.kKeyIconStartPositionY,
          HUDConfig.kKeyIconWidth,
          HUDConfig.kKeyIconHeight,
        ),
      );
    }
  }

  bool _hasPlayerWithKey() {
    return gameRef.player != null &&
        (gameRef.player as DDBasePlayerView)
            .model
            .hasKey; // TODO(Kevin): make this more generic, like DDBasePlayerView
  }
}
