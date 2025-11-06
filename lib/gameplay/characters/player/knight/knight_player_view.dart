import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/presets/knight_default_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  KnightPlayerView(
    Vector2 position, {
    required KnightPlayerModel model,
    KnightHandLoadoutConfig? handLoadout,
  }) : _model = model,
       _handLoadout = handLoadout ?? createDefaultKnightHandLoadout(),
       super(
         animation: KnightPlayerConfig.animation,
         size: KnightPlayerConfig.componentSize,
         position: position,
         life: KnightPlayerConfig.kLife,
         speed: KnightPlayerConfig.kSpeed,
       );

  final KnightPlayerModel _model;
  final KnightHandLoadoutConfig _handLoadout;
  late final KnightPlayerController _controller;
  final Map<KnightHandSlot, KnightHandItemController> _handControllers = {};
  final Map<KnightHandSlot, SynchronizedAttackController>
  _handAttackControllers = {};
  final Map<KnightHandSlot, KnightHandAttackConfig> _handAttackBindings = {};
  final Map<KnightAttackTrigger, KnightHandSlot> _triggerToSlot = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeVisualConfiguration();
    _initializeController();
    add(KnightPlayerConfig.hitbox);
    await _initializeHandLoadout();
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
    for (final attackController in _handAttackControllers.values) {
      attackController.dispose();
    }
    _handAttackControllers.clear();
    _handAttackBindings.clear();
    _triggerToSlot.clear();
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
    for (final entry in _handLoadout.entries) {
      await _applyHandLoadoutEntry(entry);
    }
  }

  Future<void> _applyHandLoadoutEntry(KnightHandLoadoutEntry entry) async {
    final handController = await equipHandItem(
      slot: entry.slot,
      config: entry.itemConfig,
    );

    final attackBinding = entry.attack;
    if (attackBinding != null) {
      _handAttackControllers.remove(entry.slot)?.dispose();
      _handAttackBindings[entry.slot] = attackBinding;
      _triggerToSlot[attackBinding.trigger] = entry.slot;
      _handAttackControllers[entry.slot] = _createAttackController(
        slot: entry.slot,
        handController: handController,
        attackBinding: attackBinding,
      );
    } else {
      _handAttackBindings.remove(entry.slot);
      _handAttackControllers.remove(entry.slot)?.dispose();
      _triggerToSlot.removeWhere((_, slot) => slot == entry.slot);
    }
  }

  SynchronizedAttackController _createAttackController({
    required KnightHandSlot slot,
    required KnightHandItemController handController,
    required KnightHandAttackConfig attackBinding,
  }) {
    return SynchronizedAttackController(config: attackBinding.syncConfig)
      ..setOnAnimationDurationChangedCallback(
        handController.updateAnimationDuration,
      )
      ..setOnAnimationSyncCallback((info) {
        handController.startAttack(customDuration: info.animationDuration);
      })
      ..setOnAttackExecutedCallback((info) {
        _flashHandForAttack(slot, info.type, info.animationDuration);
      })
      ..setOnAttackDestroyedCallback((_) {
        handController.stopAttack();
      })
      ..setOnAttackBlockedCallback((_, __) {
        handController.flashColor(
          const Color(0xFFFF4444),
          duration: const Duration(milliseconds: 150),
        );
      });
  }

  Future<KnightHandItemController> equipHandItem({
    required KnightHandSlot slot,
    required KnightHandItemConfig config,
  }) async {
    _handAttackControllers.remove(slot)?.dispose();
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

    return controller;
  }

  KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
      _handControllers[slot];

  void _executeAttackForTrigger(KnightAttackTrigger trigger, double damage) {
    final slot = _triggerToSlot[trigger];
    if (slot == null) return;

    final attackBinding = _handAttackBindings[slot];
    final attackController = _handAttackControllers[slot];
    final handController = _handControllers[slot];
    if (attackBinding == null ||
        attackController == null ||
        handController == null) {
      return;
    }

    attackController.execute(
      attackBinding.attackType,
      () => attackBinding.execute(
        KnightAttackExecutionContext(
          player: this,
          slot: slot,
          handController: handController,
        ),
        damage,
      ),
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
  void _onPlayPrimaryAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.primary, damage);

  void _onPlayFireballAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.fireball, damage);

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
