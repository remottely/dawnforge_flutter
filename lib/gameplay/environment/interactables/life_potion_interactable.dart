import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class LifePotionConfig {
  static const _kSpritePath =
      'gameplay/environment/interactables/life_potion_interactable_1.png';
  static final Vector2 _componentSize = GameplayConstants.kTileSizeStandard;
  static const _kHealingDuration = Duration(seconds: 1);
  static const _kStandardHealAmount = 50.0;
  static const kHealAmount = GameplayConstants.kPropertyAmountSmall;

  static Future<Sprite> _loadSprite() => Sprite.load(_kSpritePath);
}

class LifePotionDecorationView extends DDSensorPlayerDecoration {
  final double _healAmount;
  bool _hasBeenConsumed = false;

  LifePotionDecorationView({required Vector2 position, double? healAmount})
    : _healAmount = healAmount ?? LifePotionConfig._kStandardHealAmount,
      super.withSprite(
        sprite: LifePotionConfig._loadSprite(),
        position: position,
        size: LifePotionConfig._componentSize,
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
