import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/environment_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/decoration/decoration.dart';
import 'package:darkness_dungeon/gameplay/player/player_character.dart';

/// [SpikeTrapDecoration] responsible for dealing damage to players on contact
/// Following Flutter naming conventions for decoration systems
///
/// This decoration handles:
/// - Player damage through spike trap mechanism
/// - Animation-based damage timing system
/// - Continuous contact damage monitoring
class SpikeTrapDecoration extends DFSensorPlayerDecoration {
  // 1. Constantes de configuração
  static const double kDefaultSize = GameplayConstants.kCurrentTileSize;
  static const double kDefaultDamageAmount = 60.0;
  static const int kLayerPriority = 1;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  final double _damageAmount;
  PlayerCharacter? _contactedPlayer;

  // 3. Construtor
  SpikeTrapDecoration(this._initialPosition, {double? damageAmount})
    : _damageAmount = damageAmount ?? kDefaultDamageAmount,
      super.withAnimation(
        animation: EnvironmentSpriteSheet.spikeTrapDecoration(),
        position: _initialPosition,
        size: Vector2.all(kDefaultSize),
      );

  // 4. Métodos públicos principais
  @override
  void onContact(PlayerCharacter player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(PlayerCharacter player) {
    _contactedPlayer = null;
  }

  @override
  void update(double dt) {
    if (isAnimationLastFrame) {
      _triggerDamage();
    }
    super.update(dt);
  }

  @override
  int get priority => LayerPriority.getComponentPriority(kLayerPriority);

  // 5. Métodos privados auxiliares
  /// Triggers damage on the contacted player
  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
