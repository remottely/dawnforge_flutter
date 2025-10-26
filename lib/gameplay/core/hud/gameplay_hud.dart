import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/hud/player_vital_stats_hud.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_ui_constants.dart';

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
    try {
      _drawKeyIcon(canvas);
    } catch (e) {}
    super.render(canvas);
  }

  Future<void> _loadAssets() async {
    _keySprite = await Sprite.load(
      GameplayAnimationConstants.kDoorKeyDecorationAssetPath,
    );
  }

  void _initializeComponents() {
    add(PlayerVitalStatsHUD());
  }

  void _drawKeyIcon(Canvas canvas) {
    if (_hasPlayerWithKey()) {
      _keySprite.renderRect(
        canvas,
        Rect.fromLTWH(
          GameplayUIConstants.kKeyIconX,
          GameplayUIConstants.kKeyIconY,
          GameplayUIConstants.kKeyIconWidth,
          GameplayUIConstants.kKeyIconHeight,
        ),
      );
    }
  }

  bool _hasPlayerWithKey() {
    return gameRef.player != null &&
        (gameRef.player as KnightPlayerView).controller.model.hasKey;
  }
}
