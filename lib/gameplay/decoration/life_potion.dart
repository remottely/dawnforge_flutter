import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

/// [LifePotion] responsible for healing the player when collected
/// Following Flutter naming conventions for decoration systems
///
/// This decoration handles:
/// - Player healing through gradual health restoration
/// - Single-use consumption mechanism
/// - Visual feedback through removal after use
class LifePotion extends GameDecoration with Sensor<Knight> {
  // 1. Constantes de configuração
  static const double kDefaultSize = GameplayConstants.kCurrentTileSize;
  static const Duration kHealingDuration = Duration(seconds: 1);
  static const String kAssetPath = 'items/potion_red.png';
  static const double kDefaultHealAmount = 50.0;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  final double _healAmount;
  bool _hasBeenConsumed = false;

  // 3. Construtor
  LifePotion(this._initialPosition, [double? healAmount])
    : _healAmount = healAmount ?? kDefaultHealAmount,
      super.withSprite(
        sprite: Sprite.load(kAssetPath),
        position: _initialPosition,
        size: Vector2.all(kDefaultSize),
      );

  // 4. Métodos públicos principais
  @override
  void onContact(Knight player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  // 5. Métodos privados auxiliares
  /// Triggers the healing effect on the player
  void _triggerEffect(Knight player) {
    _healPlayerGradually(player);
  }

  /// Heals the player gradually over time
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

  /// Cleans up the potion after consumption
  void _cleanup() {
    removeFromParent();
  }
}
