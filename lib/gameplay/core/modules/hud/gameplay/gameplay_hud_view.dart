import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay/gameplay_hud_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inventory/inventory_hud_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_hud_view.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/door_key_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

class GameplayHUDView extends GameInterface {
  late Sprite _keySprite;
  final inventoryHUD = InventoryHUDView();

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
    add(PlayerVitalStatsHUDView());
    add(inventoryHUD);
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
        (gameRef.player as DDBasePlayerView)
            .model
            .hasKey; // TODO(Kevin): make this more generic, like DDBasePlayerView
  }
}
