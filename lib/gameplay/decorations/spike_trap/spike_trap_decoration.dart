import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/decorations/spike_trap/spike_trap_decoration_config.dart';
import 'package:dawnforge/shared/framework/decorations/dd_contact_decoration.dart';

class SpikeTrapDecorationView extends DDContactDecoration {
  final double _damageAmount;
  SimplePlayer? _contactedPlayer;
  bool _hasDealtDamageThisCycle = false;

  SpikeTrapDecorationView({
    required super.position,
    double damageAmount = SpikeTrapDecorationDef.kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: SpikeTrapDecorationDef.loadAnimation(),
         size: SpikeTrapDecorationDef.componentSize,
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
      LayerPriority.getComponentPriority(SpikeTrapDecorationDef.kPriority);

  void _triggerEffect(SimplePlayer player) {
    player.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
