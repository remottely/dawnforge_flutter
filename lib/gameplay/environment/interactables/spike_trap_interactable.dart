import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/shared/gameplay_interactable_config.dart';
import 'package:darkness_dungeon/shared/i_dd_game_decoration.dart';

abstract class _SpikeTrapInteractableConfig {
  static const double _kDamageAmount =
      GameplayInteractableConfig.kPropertyAmountMedium;
  static const int _kPriority = 1;

  static final Vector2 _fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final Vector2 _fComponentSize = _fTextureSize;

  static Future<SpriteAnimation> _loadAnimation() => SpriteAnimation.load(
    'gameplay/environment/interactables/spike_trap_interactable_10.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: _fTextureSize,
    ),
  );
}

class SpikeTrapInteractableView extends DDSensorPlayerDecoration {
  final double _damageAmount;
  KnightPlayerView? _contactedPlayer;

  SpikeTrapInteractableView({
    required super.position,
    double damageAmount = _SpikeTrapInteractableConfig._kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: _SpikeTrapInteractableConfig._loadAnimation(),
         size: _SpikeTrapInteractableConfig._fComponentSize,
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
      _triggerDamage();
    }
    super.update(dt);
  }

  @override
  int get priority => LayerPriority.getComponentPriority(
    _SpikeTrapInteractableConfig._kPriority,
  );

  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
