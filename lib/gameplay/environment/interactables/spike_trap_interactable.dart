import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _SpikeTrapInteractableConfig {
  static const double kDamageAmount = GameplayConstants.kPropertyAmountMedium;
  static const int kPriority = GameplayConstants.kPriority1;
  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;

  static Future<SpriteAnimation> _loadAnimation() => SpriteAnimation.load(
    'gameplay/environment/interactables/spike_trap_interactable_10.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: 10,
      textureSize: GameplayConstants.kTileSizeStandard,
    ),
  );
}

class SpikeTrapInteractableView extends DDSensorPlayerDecoration {
  final double _damageAmount;
  KnightPlayerView? _contactedPlayer;

  SpikeTrapInteractableView({
    required super.position,
    double damageAmount = _SpikeTrapInteractableConfig.kDamageAmount,
  }) : _damageAmount = damageAmount,
       super.withAnimation(
         animation: _SpikeTrapInteractableConfig._loadAnimation(),
         size: _SpikeTrapInteractableConfig._spriteSize,
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
    _SpikeTrapInteractableConfig.kPriority,
  );

  void _triggerDamage() {
    _contactedPlayer?.handleAttack(AttackOriginEnum.ENEMY, _damageAmount, 0);
  }
}
