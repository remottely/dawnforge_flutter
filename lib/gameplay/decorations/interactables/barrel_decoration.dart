import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_pushable_decoration.dart';

final class _BarrelDecorationConfig {
  _BarrelDecorationConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> _loadSprite() =>
      Sprite.load('gameplay/decorations/barrel_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: _componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 6.0,
  );

  static Future<SpriteAnimation> _loadBreakAnimation() async {
    try {
      return await SpriteAnimation.load(
        // 'gameplay/decorations/barrel_decoration_break_6.png',
        'gameplay/decorations/barrel_decoration_AHUSHAU.png', // TODO(Kevin): creates barrel break sprites
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: _textureSize,
        ),
      );
    } catch (_) {
      return CharacterFxSpriteAnimationsConfig.createExplosionRight7(); // TODO(Kevin): creates unique crash helper for these scenarios
    }
  }
}

class BarrelDecorationView extends DDPushableDecoration with Attackable {
  BarrelDecorationView({required super.position})
    : super.withSprite(
        sprite: _BarrelDecorationConfig._loadSprite(),
        size: _BarrelDecorationConfig._componentSize,
      ) {
    receivesAttackFrom = AcceptableAttackOriginEnum.PLAYER_AND_ALLY;
  }

  @override
  Future<void> onLoad() {
    add(_BarrelDecorationConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _playBreakAndRemove();
  }

  void _playBreakAndRemove() {
    // Prevent multiple triggers
    if (sprite == null) return;
    playSpriteAnimationOnce(
      _BarrelDecorationConfig._loadBreakAnimation(),
      onStart: () {
        sprite = null;
      },
      onFinish: () {
        removeFromParent();
      },
    );
  }
}
