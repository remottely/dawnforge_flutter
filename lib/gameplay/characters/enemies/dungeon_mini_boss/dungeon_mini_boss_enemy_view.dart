import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_basic_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class DungeonMiniBossEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final DungeonMiniBossEnemyController _controller =
      DungeonMiniBossEnemyController();
  bool _seePlayerClose = false;
  double _primaryAttackDamage = DungeonMiniBossEnemyConfig.kPrimaryAttackDamage;

  DungeonMiniBossEnemyView(Vector2 position)
    : super(
        animation: DungeonMiniBossEnemyConfig.fDirectionalSpriteAnimation,
        position: position,
        size: DungeonMiniBossEnemyConfig.fComponentSize,
        speed: DungeonMiniBossEnemyConfig.kSpeed,
        life: DungeonMiniBossEnemyConfig.kLife,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    add(DungeonMiniBossEnemyConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _controller.onReceiveDamage(attacker, damage, id);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _controller.onDie();
    removeFromParent();
    super.onDie();
  }

  void seePlayerAndAct() {
    _seePlayerClose = false;
    seePlayer(
      observed: (_) {
        _seePlayerClose = true;
        seeAndMoveToPlayer(
          closePlayer: (_) {
            playPrimaryAttackAnimation();
          },
          radiusVision: DungeonMiniBossEnemyConfig.kCloseVisionRadius,
        );
      },
      radiusVision: DungeonMiniBossEnemyConfig.kCloseVisionRadius,
    );
    if (!_seePlayerClose) {
      seeAndMoveToAttackRange(
        positioned: (p) {
          playFireballAttackAnimation();
        },
        radiusVision: DungeonMiniBossEnemyConfig.kLongVisionRadius,
      );
    }
  }

  void playPrimaryAttackAnimation() {
    GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
    simpleAttackMelee(
      size: Vector2.all(DungeonMiniBossEnemyConfig.kAttackEffectSize),
      damage:
          _primaryAttackDamage /
          DungeonMiniBossEnemyConfig.kPrimaryDamageReduction,
      interval: DungeonMiniBossEnemyConfig.kPrimaryAttackInterval,
      animationRight:
          CharacterPrimaryAttackConfig.loadEnemyExecutionAnimation(),
    );
  }

  void playFireballAttackAnimation() {
    simpleAttackRange(
      animation: CharacterFireballAttackConfig.loadExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadDestroyAnimation(),
      size: CharacterFireballAttackConfig.fComponentSize,
      damage: _primaryAttackDamage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      execute: CharacterFireballAttackConfig.playExecutionAudio,
      onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
      collision: CharacterFireballAttackConfig.createHitbox(),
      lightingConfig: CharacterFireballAttackConfig.fLightingConfig,
    );
  }

  void showDamageEffect(double damage) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.kEnemyShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  void handleDeathEffects() {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterEffectSpriteAnimations.characterExplosionSmokeRight5(),
        position: position,
        size: GameplayTileConfig.fTileSizeStandard,
        loop: false,
      ),
    );
  }
}
