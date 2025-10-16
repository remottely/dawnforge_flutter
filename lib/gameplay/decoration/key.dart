import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

/// Interactive decoration Key for the Darkness Dungeon game
/// Following Flutter naming conventions for item interaction systems
///
/// This class handles:
/// - Key collection by the player
/// - Single-use pickup mechanism
/// - Inventory state update for door access
///
/// Usage patterns:
/// ```dart
/// final key = DoorKey(position);
/// key.onLoad();
/// ```
class DoorKey extends GameDecoration with Sensor<PlayerCharacter> {
  // 1. Constantes de configuração
  static const double kDefaultSize = GameplayConstants.kCurrentTileSize;
  static const String kAssetPath = 'items/key_silver.png';

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  bool _hasBeenCollected = false;

  // 3. Construtor
  DoorKey(this._initialPosition)
    : super.withSprite(
        sprite: Sprite.load(kAssetPath),
        position: _initialPosition,
        size: Vector2.all(kDefaultSize),
      );

  // 4. Métodos públicos principais
  @override
  void onContact(PlayerCharacter player) {
    if (!_hasBeenCollected) {
      _hasBeenCollected = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  // 5. Métodos privados auxiliares
  /// Triggers the key collection effect
  void _triggerEffect(PlayerCharacter player) {
    player.hasKey = true;
  }

  /// Cleans up the key after collection
  void _cleanup() {
    removeFromParent();
  }
}
