import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_basic_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class DungeonMiniBossEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final DungeonMiniBossEnemyController _controller =
      DungeonMiniBossEnemyController();
  bool _seePlayerClose = false;
  double _attackDamage = DungeonMiniBossEnemyConfig.attackDamage;

  DungeonMiniBossEnemyView(Vector2 position)
    : super(
        animation: DungeonMiniBossEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: DungeonMiniBossEnemyConfig.componentSize,
        speed: DungeonMiniBossEnemyConfig.speed,
        life: DungeonMiniBossEnemyConfig.life,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    DungeonMiniBossEnemyConfig.buildHitBox(this);
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
      observed: (player) {
        _seePlayerClose = true;
        seeAndMoveToPlayer(
          closePlayer: (player) {
            playMeleeAttackAnimation();
          },
          radiusVision: DungeonMiniBossEnemyConfig.closeVisionRadius,
        );
      },
      radiusVision: DungeonMiniBossEnemyConfig.closeVisionRadius,
    );
    if (!_seePlayerClose) {
      seeAndMoveToAttackRange(
        positioned: (p) {
          playFireballAttackAnimation();
        },
        radiusVision: DungeonMiniBossEnemyConfig.longVisionRadius,
      );
    }
  }

  void playMeleeAttackAnimation() {
    GameplayAudioManager.instance.playAttackEnemyMelee();
    addParticle(CharacterParticlesAnimations.swordParticles(), position: size);
    simpleAttackMelee(
      size: Vector2.all(DungeonMiniBossEnemyConfig.attackEffectSize),
      damage: _attackDamage / DungeonMiniBossEnemyConfig.meleeDamageReduction,
      interval: DungeonMiniBossEnemyConfig.meleeAttackInterval,
      animationRight: CharacterBasicAttackConfig.loadEnemyExecutionAnimation(),
    );
  }

  void playFireballAttackAnimation() {
    addParticle(
      CharacterParticlesAnimations.fireballParticles(),
      position: size,
    );
    simpleAttackRange(
      animation: CharacterFireballAttackConfig.loadExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadDestroyAnimation(),
      size: CharacterFireballAttackConfig.componentSize,
      damage: _attackDamage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      execute: CharacterFireballAttackConfig.playExecutionAudio,
      onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
      collision: CharacterFireballAttackConfig.hitbox,
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
    );
  }

  void showDamageEffect(double damage) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.enemyShowDamageTextStyle,
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
        size: GameplayConstants.kTileSizeStandard,
        loop: false,
      ),
    );
  }
}
