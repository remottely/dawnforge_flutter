import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';

// -----------------------------------------------------------------------------
//  DATA CLASS (Seguindo o padrão de barrel_decoration.dart)
// -----------------------------------------------------------------------------

abstract class _SpikeTrapDecorationData {
  /// DATA
  static const double kDamageAmount = GameplayConstants.kPropertyAmountMedium;
  static const int kPriority = GameplayConstants.kPriority1;
  static Vector2 get _spriteSize => GameplayConstants.kTileVector2Default;

  /// LOAD
  static Future<SpriteAnimation> _loadAnimation() =>
      DecorationSpriteAnimations.spikeTrapDecoration10();
}

// -----------------------------------------------------------------------------
//  CLASSE PRINCIPAL (Refatorada para usar _SpikeTrapDecorationData)
// -----------------------------------------------------------------------------

/// DONE
class SpikeTrapDecoration extends DFSensorPlayerDecoration {
  final double _damageAmount;
  KnightPlayer? _contactedPlayer;

  SpikeTrapDecoration({
    required super.position,
    double damageAmount = _SpikeTrapDecorationData.kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: _SpikeTrapDecorationData._loadAnimation(),
         size: _SpikeTrapDecorationData._spriteSize,
       );

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
      LayerPriority.getComponentPriority(_SpikeTrapDecorationData.kPriority);

  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
