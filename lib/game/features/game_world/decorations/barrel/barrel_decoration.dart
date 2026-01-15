import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/decorations/barrel/barrel_decoration_def.dart';
import 'package:dawnforge/shared/framework/decorations/dd_pushable_decoration.dart';

class BarrelDecorationView extends DDPushableDecoration with Attackable {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: BarrelDecorationDef.loadSprite(),
        size: BarrelDecorationDef.componentSize,
      ) {
    receivesAttackFrom = AcceptableAttackOriginEnum.PLAYER_AND_ALLY;
  }

  @override
  Future<void> onLoad() {
    add(BarrelDecorationDef.createHitbox());
    return super.onLoad();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _playBreakAndRemove();
  }

  void _playBreakAndRemove() {
    if (sprite == null) return;
    playSpriteAnimationOnce(
      BarrelDecorationDef.loadAnimationBreak(),
      onStart: () {
        sprite = null;
      },
      onFinish: () {
        removeFromParent();
      },
    );
  }
}
