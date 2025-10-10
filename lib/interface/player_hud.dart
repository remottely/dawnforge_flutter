import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/interface/health_stamina_bar.dart';
import 'package:darkness_dungeon/player/knight.dart';

class PlayerHUD extends GameInterface {
  late Sprite keySprite;

  @override
  Future<void> onLoad() async {
    keySprite = await Sprite.load('items/key_silver.png');
    add(HealthStaminaBar());
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    try {
      _drawKey(canvas);
    } catch (e) {}
    super.render(canvas);
  }

  void _drawKey(Canvas c) {
    if (gameRef.player != null && (gameRef.player as Knight).hasKey) {
      keySprite.renderRect(c, Rect.fromLTWH(150, 20, 35, 30));
    }
  }
}
