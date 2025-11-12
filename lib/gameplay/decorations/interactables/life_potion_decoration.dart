import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/gameplay/decorations/shared/decoration_constants.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

final class LifePotionConfig {
  LifePotionConfig._();

  static const Duration _kHealingDuration = Duration(seconds: 1);
  static const double _kStandardHealAmount = 50.0;
  static const double kHealAmount = DecorationConstants.kStatsAmountLarge;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/decorations/life_potion_decoration_1.png');

  static _createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: _componentSize,
    hitboxStartPositionX: 3.0,
    hitboxStartPositionY: 3.0,
  );
}

class LifePotionDecorationView extends DDContactDecoration {
  final double _healAmount;
  bool _hasBeenConsumed = false;

  LifePotionDecorationView({required super.position, double? healAmount})
    : _healAmount = healAmount ?? LifePotionConfig._kStandardHealAmount,
      super.withSprite(
        sprite: LifePotionConfig._loadSprite(),
        size: LifePotionConfig._componentSize,
      );

  @override
  Future<void> onLoad() {
    add(LifePotionConfig._createHitbox());
    return super.onLoad();
  }

  @override
  void onContact(SimplePlayer player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  void _triggerEffect(SimplePlayer player) {
    _healPlayerGradually(player);
  }

  void _healPlayerGradually(Player player) {
    double healingProgress = 0.0;
    gameRef.add(
      ValueGeneratorComponent(
        LifePotionConfig._kHealingDuration,
        onChange: (value) {
          if (healingProgress < _healAmount) {
            double currentHealAmount = _healAmount * value - healingProgress;
            healingProgress += currentHealAmount;
            player.addLife(currentHealAmount);
          }
        },
      ),
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
