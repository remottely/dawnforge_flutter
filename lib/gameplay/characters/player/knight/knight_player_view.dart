import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_effects_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
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
  late final KnightPickaxeController _pickaxeController;
  late final SynchronizedAttackController _attackController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeVisualConfiguration();
    _initializeController();
    add(KnightPlayerConfig.hitbox);
    _pickaxeController = KnightPickaxeController(knight: this);
    final pickaxeView = await _pickaxeController.createView(
      spritePath: KnightPlayerConfig.defaultPickaxeSpritePath,
    );
    gameRef.add(pickaxeView);
    _pickaxeController.update(0);
    _initializeSynchronizedAttackSystem();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    _pickaxeController.updateDirectionFromVelocity(velocity);
    _pickaxeController.update(dt);
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
    _attackController.dispose();
    _pickaxeController.dispose();
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
  /// Configures the attack timing controller with Knight-specific defaults
  /// and wires feedback hooks to the pickaxe view.
  void _initializeSynchronizedAttackSystem() {
    _attackController =
        SynchronizedAttackController(
            config: const SynchronizedAttackConfig(
              baseAttackSpeedMs: 800,
              speedBonusPerLevel: 0.05,
              attackTypeMultipliers: {
                AttackType.melee: 1.0,
                AttackType.ranged: 0.8,
                AttackType.special: 1.5,
                AttackType.combo: 0.6,
              },
            ),
          )
          ..setOnAnimationDurationChangedCallback(
            _pickaxeController.updateAnimationDuration,
          )
          ..setOnAnimationSyncCallback((info) {
            _pickaxeController.startAttack(
              customDuration: info.animationDuration,
            );
          })
          ..setOnAttackExecutedCallback((info) {
            _onAttackExecutedCallback(info.type, info.animationDuration);
          })
          ..setOnAttackDestroyedCallback((info) {
            _onAttackDestroyedCallback(info.type, info.animationDuration);
          })
          ..setOnAttackBlockedCallback((_, __) {
            // _pickaxeController.flashColor(
            //   const Color(0xFFFF4444),
            //   duration: const Duration(milliseconds: 150),
            // );
          });
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

  void _onAttackExecutedCallback(AttackType type, Duration animationDuration) {
    _pickaxeController.updateSprite(
      KnightPlayerConfig.jellySquishStaffSpritePath,
    );
  }

  void _onAttackDestroyedCallback(AttackType type, Duration animationDuration) {
    _pickaxeController.updateSprite(
      KnightPlayerConfig.jellySquishHammerSpritePath,
    );
  }

  // void _flashPickaxeForAttack(AttackType type, Duration animationDuration) {
  // final effectColor = switch (type) {
  //   AttackType.melee => const Color(0xFFFF8800),
  //   AttackType.ranged => const Color(0xFF4488FF),
  //   AttackType.special => const Color(0xFF8844FF),
  //   AttackType.combo => const Color(0xFFFFFF44),
  // };

  // _pickaxeController.flashColor(
  //   effectColor,
  //   duration: Duration(
  //     milliseconds: (animationDuration.inMilliseconds * 0.3).round(),
  //   ),
  // );
  // }

  /// Controller callback implementations
  void _onPlayPrimaryAttack(double damage) {
    _attackController.execute(AttackType.melee, () {
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
    _attackController.execute(AttackType.ranged, () {
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
          GameplayCameraEffectsConfig.fireballExplosionShake(gameRef);
        },
        collision: CharacterFireballAttackConfig.createHitbox(),
        lightingConfig: CharacterFireballAttackConfig.lightingConfig,
      );
      CharacterFireballAttackConfig.playExecutionAudio();
    });
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
