import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/spike_trap/spike_trap_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

class SpikeTrapDecorationView extends DDContactDecoration {
  final double _damageAmount;
  SimplePlayer? _contactedPlayer;
  bool _hasDealtDamageThisCycle = false;

  SpikeTrapDecorationView({
    required super.position,
    double damageAmount = SpikeTrapDecorationConfig.kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: SpikeTrapDecorationConfig.loadSpriteAnimation(),
         size: SpikeTrapDecorationConfig.componentSize,
       );

  @override
  void onContact(SimplePlayer player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(SimplePlayer player) {
    _contactedPlayer = null;
  }

  @override
  void update(double dt) {
    if (isAnimationLastFrame) {
      if (!_hasDealtDamageThisCycle && _contactedPlayer != null) {
        _triggerEffect(_contactedPlayer!);
        _hasDealtDamageThisCycle = true;
      }
    } else {
      _hasDealtDamageThisCycle = false;
    }
    super.update(dt);
  }

  @override
  int get priority =>
      LayerPriority.getComponentPriority(SpikeTrapDecorationConfig.kPriority);

  void _triggerEffect(SimplePlayer player) {
    player.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
