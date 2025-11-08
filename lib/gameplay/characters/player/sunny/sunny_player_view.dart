import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_profile.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_utils.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

class SunnyPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  SunnyPlayerView(Vector2 position, {required SunnyPlayerModel model})
    : _model = model,
      super(
        animation: SunnyPlayerProfile.animation,
        size: SunnyPlayerProfile.componentSize,
        position: position,
        life: SunnyPlayerProfile.kLife,
        speed: SunnyPlayerProfile.kSpeed,
      ) {
    anchor = Anchor.center;
  }

  final SunnyPlayerModel _model;
  late final SunnyPlayerController _controller;
  late final SynchronizedAttackController _attackController1;
  late final SynchronizedAttackController _attackController2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeVisualConfiguration();
    _initializeController();
    add(SunnyPlayerProfile.hitbox);
    _initializeSynchronizedAttackSystem();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    _updateSpriteDirection();
    super.update(dt);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;
    _controller.handleInputAction(event);
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    _showDamageFx(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _showDeathFx();
    removeFromParent();
    super.onDie();
  }

  @override
  void onRemove() {
    _attackController1.dispose();
    _attackController2.dispose();
    _controller.dispose();
    super.onRemove();
  }

  // Public API for external interaction
  // void useTool() => _controller.useTool();
  // void switchTool(FarmTool newTool) => _controller.switchTool(newTool);
  // void restoreEnergy() => _controller.restoreEnergy();
  SunnyPlayerModel get model => _controller.model;

  void _updateSpriteDirection() {
    // Quando o personagem se move para a esquerda (velocidade negativa em X),
    // flipamos horizontalmente o sprite
    if (velocity.x < 0 && !isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    }
  }

  /// **Synchronized Attack System Initialization**
  void _initializeSynchronizedAttackSystem() {
    _attackController1 = SynchronizedAttackController(
      spec: const SynchronizedAttackSpec(
        baseAttackSpeedMs: 800,
        speedBonusPerLevel: 0.05,
        attackTypeMultipliers: {
          AttackType.melee: 1.0,
          AttackType.ranged: 0.8,
          AttackType.special: 1.5,
          AttackType.combo: 0.6,
        },
      ),
    );
    _attackController2 = SynchronizedAttackController(
      spec: const SynchronizedAttackSpec(
        baseAttackSpeedMs: 800,
        speedBonusPerLevel: 0.05,
        attackTypeMultipliers: {
          AttackType.melee: 1.0,
          AttackType.ranged: 0.8,
          AttackType.special: 1.5,
          AttackType.combo: 0.6,
        },
      ),
    );
  }

  void _initializeVisualConfiguration() {
    setupLighting(SunnyPlayerProfile.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  void _initializeController() {
    _controller = SunnyPlayerController(
      model: _model,
      onPrimaryAttack: _onPlayPrimaryAttack,
      onFireballAttack: _onPlayFireballAttack,
      onToolUse: _onPlayToolAnimation,
      onShowExclamation: _onShowExclamationEmote,
      onCheckEnemyVision: _onCheckEnemyVision,
    );
  }

  /// Private helper methods
  void _showDamageFx(double damage) => showDamage(
    damage,
    config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
    gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
    initVelocityVertical:
        CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
  );

  void _showDeathFx() =>
      gameRef.add(SunnyPlayerProfile.createCryptComponent(position));

  /// Controller callback implementations
  bool _onPlayPrimaryAttack(double damage) {
    final executed = _attackController1.execute(AttackType.melee, () {
      GameplayCameraEffectsUtils.primaryAttackShake(gameRef);
      GameplayAudioManager.instance.playPlayerPrimaryAttackSfx();
      addParticle(
        CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
        position: size,
      );
      simpleAttackMelee(
        size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
        damage: damage,
        animationRight:
            CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
      );
    });

    if (executed == null) {
      return false;
    }
    return true;
  }

  bool _onPlayFireballAttack(double damage) {
    final executed = _attackController2.execute(AttackType.ranged, () {
      addParticle(
        CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
        position: size,
      );
      simpleAttackRange(
        animationRight:
            CharacterFireballAttackConfig.createExecutionAnimation(),
        animationDestroy:
            CharacterFireballAttackConfig.createDestroyAnimation(),
        size: CharacterFireballAttackConfig.componentSize,
        damage: damage,
        speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
        onDestroy: () {
          CharacterFireballAttackConfig.playDestroyAudio();
          GameplayCameraEffectsUtils.fireballExplosionShake(gameRef);
        },
        collision: CharacterFireballAttackConfig.createHitbox(),
        lightingConfig: CharacterFireballAttackConfig.lightingConfig,
      );
      CharacterFireballAttackConfig.playExecutionAudio();
    });

    if (executed == null) {
      return false;
    }
    return true;
  }

  void _onPlayToolAnimation() {
    // TODO: Implementar animação de ferramenta
  }

  void _onShowExclamationEmote() {
    add(
      CharacterEmoteManager.displayEmoteAboveCharacter(
        asset: CharacterEmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  void _onCheckEnemyVision({
    required double visionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  }) {
    seeEnemy(
      radiusVision: visionRadius,
      notObserved: notObserved,
      observed: observed,
    );
  }
}
