import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_config.dart';
import 'package:darkness_dungeon/new/pickaxe_controller_mixin.dart';
import 'package:darkness_dungeon/new/synchronized_attack_system.dart';
import 'package:flutter/widgets.dart';

class KnightPlayerView extends SimplePlayer
    with
        Lighting,
        BlockMovementCollision,
        PickaxeControllerMixin,
        SynchronizedAttackSystem {
  KnightPlayerView(Vector2 position, {required KnightPlayerModel model})
    : _model = model,
      super(
        animation: KnightPlayerConfig.animation,
        size: KnightPlayerConfig.componentSize,
        position: position,
        life: KnightPlayerConfig.kLife,
        speed: KnightPlayerConfig.kSpeed,
      );

  final KnightPlayerModel _model;
  late final KnightPlayerController _controller;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeVisualConfiguration();
    _initializeController();
    add(KnightPlayerConfig.hitbox);
  }

  @override
  void onMount() {
    super.onMount();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeSynchronizedAttackSystem();
      updatePickaxeDirection();
    });
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    updatePickaxeDirection();
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
    disposeSynchronizedAttackSystem();
    _controller.dispose();
    super.onRemove();
  }

  // Public API for external interaction
  // void useTool() => _controller.useTool();
  // void switchTool(FarmTool newTool) => _controller.switchTool(newTool);
  // void restoreEnergy() => _controller.restoreEnergy();
  KnightPlayerModel get model => _controller.model;

  /// **Synchronized Attack System Initialization**
  ///
  /// Configures the advanced attack timing system with:
  /// - Configurable base attack speed (800ms = 1.25 attacks/sec)
  /// - Progressive speed bonuses per level (5% faster each level)
  /// - Attack type multipliers for gameplay variety
  /// - Visual feedback and debug logging support
  Future<void> _initializeSynchronizedAttackSystem() async {
    await initializeIntegratedAttackSystem(
      baseAttackSpeedMs: 800,
      pickaxeSpritePath: KnightPlayerConfig.defaultPickaxeSpritePath,
      speedBonusPerLevel: 0.05,
      enableVisualFeedback: true,
      enableDebugLogging: true,
      attackTypeMultipliers: {
        AttackType.melee: 1.0, // Normal speed - balanced
        AttackType.ranged: 0.8, // 20% faster - responsive
        AttackType.special: 1.5, // 50% slower - powerful
        AttackType.combo: 0.6, // 40% faster - fluid
      },
    );
  }

  void _initializeVisualConfiguration() {
    setupLighting(KnightPlayerConfig.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  void _initializeController() {
    _controller = KnightPlayerController(
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
      gameRef.add(KnightPlayerConfig.createCryptComponent(position));

  /// Controller callback implementations
  void _onPlayPrimaryAttack(double damage) {
    executeSynchronizedAttack(AttackType.melee, () {
      GameplayCameraEffectsConfig.primaryAttackShake(gameRef);
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
  }

  void _onPlayFireballAttack(double damage) {
    addParticle(
      CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
      position: size,
    );
    simpleAttackRange(
      animationRight: CharacterFireballAttackConfig.createExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.createDestroyAnimation(),
      size: CharacterFireballAttackConfig.componentSize,
      damage: damage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      onDestroy: () {
        CharacterFireballAttackConfig.playDestroyAudio();
        GameplayCameraEffectsConfig.fireballExplosionShake(gameRef);
      },
      collision: CharacterFireballAttackConfig.createHitbox(),
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
    );
    CharacterFireballAttackConfig.playExecutionAudio();
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
