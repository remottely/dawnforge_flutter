import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_character.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

/// Interactive decoration LifePotionDecoration for the Darkness Dungeon game
/// Following Flutter naming conventions for item interaction systems
///
/// This class handles:
/// - Player healing through gradual health restoration
/// - Single-use consumption mechanism
/// - Visual feedback through removal after use
///
/// Usage patterns:
/// ```dart
/// final potion = LifePotionDecoration(position);
/// potion.onLoad();
/// ```
class LifePotionDecoration extends DFSensorPlayerDecoration {
  // 1. Constantes de configuração
  static const Duration kHealingDuration = Duration(seconds: 1);
  static const String kAssetPath =
      'gameplay/environment/decorations/life_potion_decoration_1.png';
  static const double kDefaultHealAmount = 50.0;
  static const double kHealAmount = GameplayConstants.kPropertyAmountSmall;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  final double _healAmount;
  bool _hasBeenConsumed = false;

  // 3. Construtor
  LifePotionDecoration(this._initialPosition, [double? healAmount])
    : _healAmount = healAmount ?? kDefaultHealAmount,
      super.withSprite(
        sprite: Sprite.load(kAssetPath),
        position: _initialPosition,
        size: GameplayConstants.kTileVector2Default,
      );

  // 4. Métodos públicos principais
  @override
  void onContact(KnightCharacter player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  // 5. Métodos privados auxiliares
  /// Triggers the healing effect on the player
  void _triggerEffect(KnightCharacter player) {
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
