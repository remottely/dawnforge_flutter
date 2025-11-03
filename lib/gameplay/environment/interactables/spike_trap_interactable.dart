import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/shared/gameplay_interactable_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_contact_decoration.dart';

final class _SpikeTrapInteractableConfig {
  _SpikeTrapInteractableConfig._();

  static const double _kDamageAmount =
      GameplayInteractableConfig.kStatsAmountMedium;
  static const int _kPriority = 1;

  static final Vector2 _textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _loadSpriteAnimation() => SpriteAnimation.load(
    'gameplay/environment/interactables/spike_trap_interactable_10.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: _textureSize,
    ),
  );
}

class SpikeTrapInteractableView extends DDContactDecoration {
  final double _damageAmount;
  KnightPlayerView? _contactedPlayer;
  bool _hasDealtDamageThisCycle = false;

  SpikeTrapInteractableView({
    required super.position,
    double damageAmount = _SpikeTrapInteractableConfig._kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: _SpikeTrapInteractableConfig._loadSpriteAnimation(),
         size: _SpikeTrapInteractableConfig._componentSize,
       );

  @override
  void onContact(KnightPlayerView player) {
    _contactedPlayer = player;
  }

  @override
  void onContactExit(KnightPlayerView player) {
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
  int get priority => LayerPriority.getComponentPriority(
    _SpikeTrapInteractableConfig._kPriority,
  );

  void _triggerEffect(KnightPlayerView player) {
    player.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
