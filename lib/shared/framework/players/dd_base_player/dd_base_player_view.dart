import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_model.dart';

/// Abstract base view for all player characters.
///
/// Provides the foundational structure and common functionality for player
/// character views following the MVC pattern. This class handles:
/// - Lifecycle management (load, update, removal)
/// - Visual effects (damage, death)
/// - Input routing
/// - Controller coordination
///
/// Type Parameters:
/// - [C] The specific controller type extending DDBasePlayerController
/// - [M] The specific model type extending DDBasePlayerModel
abstract class DDBasePlayerView<
  C extends DDBasePlayerController<M>,
  M extends DDBasePlayerModel
>
    extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final M _playerModel;
  late final C _playerController;

  /// Creates a base player with the specified configuration.
  ///
  /// [position] The initial world position for the player character.
  /// [model] The data model containing player state and statistics.
  /// [animation] The directional animation set for the character.
  /// [size] The rendered size of the player component.
  /// [life] Maximum health points.
  /// [speed] Base movement speed in pixels per second.
  DDBasePlayerView({
    required super.position,
    required M model,
    required super.animation,
    required super.size,
    required super.life,
    required super.speed,
  }) : _playerModel = model {
    anchor = Anchor.center;
  }

  /// Provides read-only access to the player's data model.
  M get model => _playerController.model;

  /// Provides access to the player controller for subclasses.
  C get controller => _playerController;

  // ============================================================================
  // Abstract Factory Methods - Must be implemented by subclasses
  // ============================================================================

  /// Creates the controller instance for this player.
  ///
  /// Subclasses must implement this to instantiate their specific controller
  /// type with all required callbacks wired to the view.
  C createController(M model);

  /// Creates the collision hitbox for this player.
  ///
  /// Subclasses must implement this to define their collision boundaries.
  RectangleHitbox createHitbox();

  /// Returns the lighting configuration for this player.
  LightingConfig get lightingConfig;

  /// Creates the crypt decoration displayed on player death.
  ///
  /// [position] The world position for the death marker.
  DDDecoration createDeathMarker(Vector2 position);

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    configureVisualEffects();
    _playerController = createController(_playerModel);
    add(createHitbox());

    // Restaurar vida do model depois que Bonfire inicializou
    _restoreLifeFromModel();
  }

  /// Restaura a vida salva no model aplicando dano proporcional.
  ///
  /// Como o Bonfire não permite setar life diretamente, aplicamos
  /// o dano necessário para ajustar para o valor salvo.
  void _restoreLifeFromModel() {
    final savedLife = _playerModel.life;
    if (savedLife != null && savedLife < life) {
      final damageToApply = life - savedLife;
      handleAttack(AttackOriginEnum.WORLD, damageToApply, 'restore_from_save');
    }
  }

  @override
  void update(double dt) {
    if (isDead) return;

    _syncLifeToModel();
    _playerController.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
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

    displayDamageVisualEffects(damage);
    super.onReceiveDamage(attacker, damage, id);
    _syncLifeToModel();
  }

  @override
  void onDie() {
    // Resetar vida no model para vida máxima (evita loop de morte)
    // _playerModel.updateLife(maxLife);

    displayDeathVisualEffects();
    removeFromParent();
    super.onDie();
  }

  // ============================================================================
  // Visual Effects - Customizable by subclasses
  // ============================================================================

  /// Configures visual effects such as lighting and movement controls.
  void configureVisualEffects() {
    setupLighting(lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  /// Displays damage number and particle effects when the player takes damage.
  ///
  /// Can be overridden by subclasses for custom damage display behavior.
  void displayDamageVisualEffects(double damage) {
    showDamage(
      damage,
      config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
    );
  }

  /// Displays death effects including death marker placement.
  ///
  /// Can be overridden by subclasses for custom death effects.
  void displayDeathVisualEffects() {
    gameRef.add(createDeathMarker(position));
  }

  // ============================================================================
  // Common Utility Methods - Available to all player types
  // ============================================================================

  /// Displays an exclamation emote above the character's head.
  void displayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        asset: EmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  /// Evaluates enemy visibility within the specified radius.
  void handleDetectEnemyInLongVisionRadius({
    required double longVisionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  }) {
    seeEnemy(
      radiusVision: longVisionRadius,
      notObserved: notObserved,
      observed: observed,
    );
  }

  // ============================================================================
  // Internal Synchronization
  // ============================================================================

  /// Synchronizes the Bonfire life value to the player model.
  ///
  /// This ensures the model always reflects the current life state,
  /// which is crucial for persistence between map transitions.
  void _syncLifeToModel() {
    if (_playerModel.life != life) {
      _playerModel.updateLife(life);
    }
  }
}
