import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/presets/knight_pickaxe_hand_preset.dart';
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
  final Map<KnightHandSlot, KnightHandItemController> _handControllers = {};
  KnightHandItemController get _primaryWeaponHand =>
      _handControllers[_primaryWeaponSlot]!;
  KnightHandSlot _primaryWeaponSlot = KnightHandSlot.right;
  late final SynchronizedAttackController _attackController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeVisualConfiguration();
    _initializeController();
    add(KnightPlayerConfig.hitbox);
    await _initializeHandLoadout();
    _initializeSynchronizedAttackSystem();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    for (final handController in _handControllers.values) {
      handController.updateDirectionFromVelocity(velocity);
      handController.update(dt);
    }
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
    for (final handController in _handControllers.values) {
      handController.dispose();
    }
    _handControllers.clear();
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
            config: SynchronizedAttackConfig(
              baseAttackSpeedMs: 800,
              speedBonusPerLevel: 0.05,
              attackTypeMultipliers: const {
                AttackType.melee: 1.0,
                AttackType.ranged: 0.8,
                AttackType.special: 1.5,
                AttackType.combo: 0.6,
              },
            ),
          )
          ..setOnAnimationDurationChangedCallback(
            _primaryWeaponHand.updateAnimationDuration,
          )
          ..setOnAnimationSyncCallback((info) {
            _primaryWeaponHand.startAttack(
              customDuration: info.animationDuration,
            );
          })
          ..setOnAttackExecutedCallback((info) {
            _flashHandForAttack(
              _primaryWeaponSlot,
              info.type,
              info.animationDuration,
            );
          })
          ..setOnAttackDestroyedCallback((_) {
            _primaryWeaponHand.stopAttack();
          })
          ..setOnAttackBlockedCallback((_, __) {
            _primaryWeaponHand.flashColor(
              const Color(0xFFFF4444),
              duration: const Duration(milliseconds: 150),
            );
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

  Future<void> _initializeHandLoadout() async {
    final pickaxeConfig = KnightPickaxeHandPreset.create();

    await equipHandItem(
      slot: KnightHandSlot.right,
      config: pickaxeConfig,
      setAsPrimaryWeapon: true,
    );

    await equipHandItem(slot: KnightHandSlot.left, config: pickaxeConfig);
  }

  Future<KnightHandItemController> equipHandItem({
    required KnightHandSlot slot,
    required KnightHandItemConfig config,
    bool setAsPrimaryWeapon = false,
  }) async {
    _handControllers.remove(slot)?.dispose();

    final controller = KnightHandItemController(
      owner: this,
      slot: slot,
      config: config,
    );
    final view = await controller.createView();
    gameRef.add(view);
    _handControllers[slot] = controller;
    controller.update(0);

    if (setAsPrimaryWeapon) {
      _primaryWeaponSlot = slot;
    }

    return controller;
  }

  KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
      _handControllers[slot];

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

  void _flashHandForAttack(
    KnightHandSlot slot,
    AttackType type,
    Duration animationDuration,
  ) {
    final controller = _handControllers[slot];
    if (controller == null) return;

    final effectColor = switch (type) {
      AttackType.melee => const Color(0xFFFF8800),
      AttackType.ranged => const Color(0xFF4488FF),
      AttackType.special => const Color(0xFF8844FF),
      AttackType.combo => const Color(0xFFFFFF44),
    };

    controller.flashColor(
      effectColor,
      duration: Duration(
        milliseconds: (animationDuration.inMilliseconds * 0.3).round(),
      ),
    );
  }

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
