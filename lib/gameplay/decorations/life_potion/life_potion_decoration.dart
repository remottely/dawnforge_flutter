import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/life_potion/life_potion_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

class LifePotionDecorationView extends DDContactDecoration {
  final double _healAmount;
  bool _hasBeenConsumed = false;

  LifePotionDecorationView({required super.position, double? healAmount})
    : _healAmount = healAmount ?? LifePotionDef.kStandardHealAmount,
      super.withSprite(
        sprite: LifePotionDef.loadSprite(),
        size: LifePotionDef.componentSize,
      );

  @override
  Future<void> onLoad() {
    add(LifePotionDef.createHitbox());
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
        LifePotionDef.kHealingDuration,
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
