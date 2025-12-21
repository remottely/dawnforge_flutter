import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay/gameplay_hud_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_hud_view.dart';
import 'package:darkness_dungeon/gameplay/decorations/door_key/door_key_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class GameplayHUDView extends GameInterface {
  late Sprite _keySprite;
  final playerVitalStatsHUD = PlayerVitalStatsHUDView();

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
        await DoorKeyDecorationDef.loadSprite(); // TODO(Kevin): put this into shared layer, and cache this?
  }

  void _initializeComponents() {
    add(playerVitalStatsHUD);
  }

  void _drawKeyIcon(Canvas canvas) {
    if (_hasPlayerWithKey()) {
      _keySprite.renderRect(
        canvas,
        Rect.fromLTWH(
          GameplayHUDDef.kKeyIconStartPositionX,
          GameplayHUDDef.kKeyIconStartPositionY,
          GameplayHUDDef.kKeyIconWidth,
          GameplayHUDDef.kKeyIconHeight,
        ),
      );
    }
  }

  bool _hasPlayerWithKey() {
    return gameRef.player != null &&
        (gameRef.player as DDBasePlayerView)
            .controller
            .model
            .hasKey; // TODO(Kevin): make this more generic, like DDBasePlayerView
  }
}
