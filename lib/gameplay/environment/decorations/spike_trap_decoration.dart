import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_character.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/sprites/decoration_sprite_animations.dart';

/// DONE
class SpikeTrapDecoration extends DFSensorPlayerDecoration {
  final double _damageAmount;

  SpikeTrapDecoration({
    required super.position,
    double damageAmount =
        GameplayConstants.kDefaultSpikeTrapDecorationDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: DecorationSpriteAnimations.spikeTrapDecoration10(),
         size: GameplayConstants.kCurrentVectorSize,
       );

  KnightCharacter? _contactedPlayer;

  @override
  void onContact(KnightCharacter player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(KnightCharacter player) {
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
  int get priority => LayerPriority.getComponentPriority(
    GameplayConstants.kLayerSpikeTrapDecorationPriority,
  );

  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
