import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/barrel/barrel_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_pushable_decoration.dart';

class BarrelDecorationView extends DDPushableDecoration with Attackable {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: BarrelDecorationConfig.loadSprite(),
        size: BarrelDecorationConfig.componentSize,
      ) {
    receivesAttackFrom = AcceptableAttackOriginEnum.PLAYER_AND_ALLY;
  }

  @override
  Future<void> onLoad() {
    add(BarrelDecorationConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _playBreakAndRemove();
  }

  void _playBreakAndRemove() {
    if (sprite == null) return;
    playSpriteAnimationOnce(
      BarrelDecorationConfig.loadAnimationBreak(),
      onStart: () {
        sprite = null;
      },
      onFinish: () {
        removeFromParent();
      },
    );
  }
}
