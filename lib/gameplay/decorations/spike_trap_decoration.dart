import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/decorations/shared/decoration_constants.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

final class _SpikeTrapDecorationConfig {
  _SpikeTrapDecorationConfig._();

  static const double _kDamageAmount = DecorationConstants.kStatsAmountMedium;
  static const int _kPriority = 1;

  static final Vector2 _textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/decorations/spike_trap_decoration_10.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: _textureSize,
    ),
  );
}

class SpikeTrapDecorationView extends DDContactDecoration {
  final double _damageAmount;
  SunnyPlayerView? _contactedPlayer;
  bool _hasDealtDamageThisCycle = false;

  SpikeTrapDecorationView({
    required super.position,
    double damageAmount = _SpikeTrapDecorationConfig._kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: _SpikeTrapDecorationConfig._loadSpriteAnimation(),
         size: _SpikeTrapDecorationConfig._componentSize,
       );

  @override
  void onContact(SunnyPlayerView player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(SunnyPlayerView player) {
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
      LayerPriority.getComponentPriority(_SpikeTrapDecorationConfig._kPriority);

  void _triggerEffect(SunnyPlayerView player) {
    player.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
