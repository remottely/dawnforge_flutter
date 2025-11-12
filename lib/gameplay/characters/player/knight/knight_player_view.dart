import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_hand_loadout_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';

/// Visual representation and input handler for the Knight player character.
///
/// This view component manages rendering, animations, player input, combat mechanics,
/// and the dual-hand equipment system for the knight character. It follows the MVC
/// pattern as the View layer, delegating business logic to the controller while
/// handling all presentation concerns.
///
/// Key Features:
/// - Dual-hand equipment system (left/right hand management)
/// - Dynamic lighting effects
/// - Collision detection and movement blocking
/// - Combat system with stamina management
/// - Input handling (joystick and keyboard)
/// - Visual effects (damage, death, particles)
/// - Customizable hand loadout configuration
class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final KnightPlayerModel _playerModel;
  final KnightHandLoadoutSetup _equipmentLoadout;
  late final KnightPlayerController _playerController;
  late final KnightHandManager _handEquipmentManager = KnightHandManager(owner: this);

  /// Creates a Knight player view with the specified position, model, and optional equipment.
  ///
  /// [position] The initial world position for the player character.
  /// [model] The data model containing player state and statistics.
  /// [handLoadout] Optional equipment loadout. If not provided, uses default configuration.
  KnightPlayerView({
    required super.position,
    required KnightPlayerModel model,
    KnightHandLoadoutSetup? handLoadout,
  })  : _playerModel = model,
        _equipmentLoadout =
            handLoadout ?? KnightHandLoadoutConfig.createDefaultKnightHandLoadout(),
        super(
          animation: KnightPlayerConfig.animation,
          size: KnightPlayerConfig.componentSize,
          life: KnightPlayerConfig.kLife,
          speed: KnightPlayerConfig.kSpeed,
        );

  /// Provides read-only access to the player's data model.
  KnightPlayerModel get model => _playerController.model;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _configureVisualEffects();
    _initializePlayerController();
    _initializeEquipmentSystem();

    add(KnightPlayerConfig.hitbox);
    await _handEquipmentManager.applyLoadout(_equipmentLoadout);
  }

  @override
  void update(double dt) {
    if (isDead) return;

    _playerController.update(dt);
    _handEquipmentManager.update(dt, velocity);
    super.update(dt);
  }

  @override
  void onRemove() {
    _handEquipmentManager.dispose();
    _playerController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Input Handling
  // ============================================================================

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;

    _playerController.handleInputAction(event);
    super.onJoystickAction(event);
  }

  // ============================================================================
  // Combat & Damage Handling
  // ============================================================================

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;

    _displayDamageVisualEffects(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _displayDeathVisualEffects();
    removeFromParent();
    super.onDie();
  }

  // ============================================================================
  // Public API - Equipment Management
  // ============================================================================

  /// Retrieves the hand item controller for the specified hand slot.
  ///
  /// Allows external systems to interact with or query equipped items
  /// in either the left or right hand.
  ///
  /// [slot] The hand slot to query (left or right).
  ///
  /// Returns the controller for the equipped item, or `null` if the slot is empty.
  KnightHandItemController? handControllerFor(KnightHandSlot slot) =>
      _handEquipmentManager.handControllerFor(slot);

  // ============================================================================
  // Initialization Methods
  // ============================================================================

  /// Configures visual effects such as lighting and joystick-based movement.
  void _configureVisualEffects() {
    setupLighting(KnightPlayerConfig.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  /// Initializes the player controller with all required callback handlers.
  void _initializePlayerController() {
    _playerController = KnightPlayerController(
      model: _playerModel,
      onPrimaryAttack: _executePrimaryAttack,
      onFireballAttack: _executeRangedAttack,
      onToolUse: _executeToolAction,
      onShowExclamation: _displayExclamationEmote,
      onCheckEnemyVision: _evaluateEnemyVisibility,
    );
  }

  /// Initializes the equipment system manager.
  ///
  /// Currently a placeholder for future initialization logic.
  void _initializeEquipmentSystem() {
    // Equipment system is already initialized via late final field
    // This method reserved for future setup logic
  }

  // ============================================================================
  // Visual Effects
  // ============================================================================

  /// Displays damage number and particle effects when the player takes damage.
  ///
  /// [damage] The amount of damage received.
  void _displayDamageVisualEffects(double damage) => showDamage(
        damage,
        config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
        gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
        initVelocityVertical:
            CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
      );

  /// Displays death effects including crypt sprite placement.
  void _displayDeathVisualEffects() =>
      gameRef.add(KnightPlayerConfig.createCryptComponent(position));

  // ============================================================================
  // Controller Callback Implementations - Combat Actions
  // ============================================================================

  /// Executes the primary attack through the equipment system.
  ///
  /// Delegates to the hand manager which determines which equipped item
  /// should handle the primary attack trigger based on current loadout.
  ///
  /// [damage] The amount of damage to inflict on hit targets.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown
  /// or no valid equipment is available.
  bool _executePrimaryAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.primary, damage);

  /// Executes the ranged/fireball attack through the equipment system.
  ///
  /// Delegates to the hand manager which determines which equipped item
  /// should handle the fireball attack trigger based on current loadout.
  ///
  /// [damage] The amount of damage to inflict on hit targets.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown
  /// or no valid equipment is available.
  bool _executeRangedAttack(double damage) =>
      _executeAttackForTrigger(KnightAttackTrigger.fireball, damage);

  /// Routes attack execution to the appropriate equipped item via the hand manager.
  ///
  /// This method serves as the central routing point for all attack triggers,
  /// allowing the equipment system to determine which hand/item should respond
  /// to each trigger type.
  ///
  /// [trigger] The type of attack being triggered.
  /// [damage] The damage value to apply.
  ///
  /// Returns `true` if any equipped item successfully handled the attack.
  bool _executeAttackForTrigger(KnightAttackTrigger trigger, double damage) {
    return _handEquipmentManager.executeAttack(trigger, damage);
  }

  // ============================================================================
  // Controller Callback Implementations - Utility Actions
  // ============================================================================

  /// Executes the tool action animation and logic.
  ///
  /// TODO: Implement tool-specific animations and effects for knight character.
  void _executeToolAction() {
    // Future implementation: Tool-specific animations and game logic for knight
  }

  /// Displays an exclamation emote above the character's head.
  ///
  /// Typically used when detecting enemies or interactive objects.
  void _displayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        asset: EmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  /// Evaluates enemy visibility within the specified radius.
  ///
  /// Provides an abstraction layer between the controller and the
  /// Bonfire framework's enemy detection system.
  ///
  /// [visionRadius] The detection radius in world units.
  /// [notObserved] Callback invoked when no enemies are in range.
  /// [observed] Callback invoked when enemies are detected, providing the list.
  void _evaluateEnemyVisibility({
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
