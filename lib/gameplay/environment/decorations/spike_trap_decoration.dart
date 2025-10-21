import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';

/// DONE
class SpikeTrapDecoration extends DFSensorPlayerDecoration {
  final double _damageAmount;
  static const double kSpikeTrapDecorationDamageAmount =
      GameplayConstants.kPropertyAmountMedium;
  static const int kSpikeTrapDecorationPriority = GameplayConstants.kPriority1;

  SpikeTrapDecoration({
    required super.position,
    double damageAmount = kSpikeTrapDecorationDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: DecorationSpriteAnimations.spikeTrapDecoration10(),
         size: GameplayConstants.kTileVector2Default,
       );

  KnightPlayer? _contactedPlayer;

  @override
  void onContact(KnightPlayer player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(KnightPlayer player) {
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
  int get priority =>
      LayerPriority.getComponentPriority(kSpikeTrapDecorationPriority);

  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
