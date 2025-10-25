import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

abstract class LifePotionConfig {
  static const String _spritePath =
      'gameplay/environment/decorations/life_potion_decoration_1.png';
  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;
  static const Duration _healingDuration = Duration(seconds: 1);
  static const double _defaultHealAmount = 50.0;
  static const double healAmount = GameplayConstants.kPropertyAmountSmall;

  static Future<Sprite> _loadSprite() => Sprite.load(_spritePath);
}

class LifePotionDecorationView extends DFSensorPlayerDecoration {
  final double _healAmount;
  bool _hasBeenConsumed = false;

  LifePotionDecorationView({required Vector2 position, double? healAmount})
    : _healAmount = healAmount ?? LifePotionConfig._defaultHealAmount,
      super.withSprite(
        sprite: LifePotionConfig._loadSprite(),
        position: position,
        size: LifePotionConfig._spriteSize,
      );

  @override
  void onContact(KnightPlayerView player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  void _triggerEffect(KnightPlayerView player) {
    _healPlayerGradually(player);
  }

  void _healPlayerGradually(Player player) {
    double healingProgress = 0;
    gameRef.add(
      ValueGeneratorComponent(
        LifePotionConfig._healingDuration,
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
