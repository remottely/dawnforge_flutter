import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

class LifePotionDecoration extends DFSensorPlayerDecoration {
  static const Duration kHealingDuration = Duration(seconds: 1);
  static const String kAssetPath =
      'gameplay/environment/decorations/life_potion_decoration_1.png';
  static const double kDefaultHealAmount = 50.0;
  static const double kHealAmount = GameplayConstants.kPropertyAmountSmall;

  final Vector2 _initialPosition;
  final double _healAmount;
  bool _hasBeenConsumed = false;

  LifePotionDecoration(this._initialPosition, [double? healAmount])
    : _healAmount = healAmount ?? kDefaultHealAmount,
      super.withSprite(
        sprite: Sprite.load(kAssetPath),
        position: _initialPosition,
        size: GameplayConstants.kTileVector2Default,
      );

  @override
  void onContact(KnightPlayer player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  void _triggerEffect(KnightPlayer player) {
    _healPlayerGradually(player);
  }

  void _healPlayerGradually(Player player) {
    double healingProgress = 0;
    gameRef.add(
      ValueGeneratorComponent(
        kHealingDuration,
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
