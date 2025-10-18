import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/effects_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/core/utils/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/decoration/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Enum para ferramentas agrícolas
enum FarmTool { hand, hoe, wateringCan }

/// Player character PlayerCharacter for the Darkness Dungeon game
/// Following Flutter naming conventions for player entity systems
///
/// This class handles:
/// - Player movement and collision detection
/// - Attack system with melee and ranged attacks
/// - Stamina management with automatic regeneration
/// - Enemy observation and interaction system
/// - Visual effects and lighting configuration
///
/// Usage patterns:
/// ```dart
/// final knight = PlayerCharacter(position);
/// knight.onLoad();
/// ```
class PlayerCharacter extends SimplePlayer
    with Lighting, BlockMovementCollision {
  // Sistema de ferramentas agrícolas
  static const int kMaxEnergy = 100;
  static const int kToolUsageEnergyCost = 2;

  FarmTool currentTool = FarmTool.hand;
  int energy = kMaxEnergy;
  bool isUsingTool = false;

  // Troca de ferramenta
  void switchTool(FarmTool newTool) {
    currentTool = newTool;
    // TODO: feedback visual/sonoro
  }

  // Uso de ferramenta agrícola
  void useTool() {
    if (energy < kToolUsageEnergyCost) return;
    isUsingTool = true;
    // TODO: integração com tiles agrícolas
    energy -= kToolUsageEnergyCost;
    if (energy < 0) energy = 0;
    // TODO: animação de uso de ferramenta
    isUsingTool = false;
  }

  // Restaurar energia (ex: ao dormir)
  void restoreEnergy() {
    energy = kMaxEnergy;
    // TODO: atualizar barra de energia na HUD
  }

  // TODO: integrar valor de energia com HUD
  // 1. Constants (grouped by type)
  static const double kDefaultAttackDamage = 25.0;
  static const double kMaxStamina = 100.0;
  static const double kDefaultLife = 200.0;
  static const int kStaminaRegenerationRate = 10;
  static const Duration kStaminaRegenerationInterval = Duration(
    milliseconds: 100,
  );
  static const int kMeleeAttackStaminaCost = 15;
  static const int kRangedAttackStaminaCost = 10;
  static const int kStaminaIncrement = 2;
  static const double kVisionRadius = GameplayConstants.kCurrentTileSize * 6;
  static const String kEmoteAssetPath = 'emote/emote_exclamacao.png';

  // 2. Private instance variables
  double _attackDamage = kDefaultAttackDamage;
  double _currentStamina = kMaxStamina;
  async.Timer? _staminaRegenerationTimer;
  bool _hasKey = false;
  bool _isObservingEnemy = false;

  // 3. Public getters/setters
  double get attackDamage => _attackDamage;
  double get currentStamina => _currentStamina;
  bool get hasKey => _hasKey;
  bool get isObservingEnemy => _isObservingEnemy;
  set hasKey(bool value) => _hasKey = value;

  // 4. Constructor
  PlayerCharacter(Vector2 position)
    : super(
        animation: PlayerSpriteSheet.playerAnimations(),
        size: Vector2.all(GameplayConstants.kCurrentTileSize),
        position: position,
        life: 200,
        speed: GameplayConstants.kCurrentTileSize * 2.5,
      ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
    _initializeControls();
    _initializeStamina();
  }

  // 5. Lifecycle methods (onLoad, update, onDie)
  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(8),
          TileHelper.valueByTileSize(6),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(4),
          TileHelper.valueByTileSize(9),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _handleStamina();
    _handleMovementEffects();
    super.update(dt);
  }

  @override
  void onDie() {
    removeFromParent();
    gameRef.add(
      DFGameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(position.x, position.y),
        size: Vector2.all(30),
      ),
    );
    super.onDie();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      executeAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      executeAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ &&
        event.event == ActionEvent.DOWN) {
      executeRangedAttack();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      executeRangedAttack();
    }
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: TextStyle(
        fontSize: TileHelper.valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  // 6. Public action methods (execute*, trigger*, handle*)
  /// Executes basic melee attack if player has sufficient stamina
  void executeAttack() {
    if (_currentStamina < kMeleeAttackStaminaCost) {
      return;
    }

    _executeAttack();
    _decrementStamina(kMeleeAttackStaminaCost);
    simpleAttackMelee(
      damage: _attackDamage,
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      size: Vector2.all(GameplayConstants.kCurrentTileSize),
    );
  }

  /// Executes ranged fireball attack if player has sufficient stamina
  void executeRangedAttack() {
    if (_currentStamina < kRangedAttackStaminaCost) {
      return;
    }

    GameplayAudioManager.playAttackRange();
    _decrementStamina(kRangedAttackStaminaCost);
    simpleAttackRange(
      animationRight: EffectsSpriteSheet.fireBallAttackRight(),
      animationDestroy: EffectsSpriteSheet.fireBallExplosion(),
      size: Vector2(
        GameplayConstants.kCurrentTileSize * 0.65,
        GameplayConstants.kCurrentTileSize * 0.65,
      ),
      damage: 10,
      speed: speed * 2.5,
      onDestroy: () {
        GameplayAudioManager.playExplosion();
      },
      collision: RectangleHitbox(
        size: Vector2(
          GameplayConstants.kCurrentTileSize / 3,
          GameplayConstants.kCurrentTileSize / 3,
        ),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: GameplayConstants.kCurrentTileSize * 0.9,
        blurBorder: GameplayConstants.kCurrentTileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  /// Public method for external stamina decrement (backwards compatibility)
  void decrementStamina(int amount) {
    _decrementStamina(amount);
  }

  // 7. Private helper methods (grouped by functionality)

  // Setup/Initialization methods
  /// Sets up player movement controls and joystick configuration
  void _initializeControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }

  /// Initializes stamina regeneration system
  void _initializeStamina() {
    // Stamina regeneration is handled in the update loop
  }

  // Processing/Updates methods
  /// Handles stamina regeneration over time
  /// Regenerates stamina at a constant rate when not at maximum
  void _handleStamina() {
    if (_staminaRegenerationTimer == null) {
      _staminaRegenerationTimer = async.Timer(Duration(milliseconds: 150), () {
        _staminaRegenerationTimer = null;
      });
    } else {
      return;
    }

    _currentStamina += kStaminaIncrement;
    if (_currentStamina > kMaxStamina) {
      _currentStamina = kMaxStamina;
    }
  }

  /// Handles movement-related effects like enemy observation
  void _handleMovementEffects() {
    seeEnemy(
      radiusVision: kVisionRadius,
      notObserved: () {
        _isObservingEnemy = false;
      },
      observed: (enemies) {
        if (_isObservingEnemy) return;
        _isObservingEnemy = true;
        _displayEmoteAbovePlayer();
      },
    );
  }

  /// Executes attack sound effect and visual feedback
  void _executeAttack() {
    GameplayAudioManager.playAttackPlayerMelee();
  }

  // 8. Utility methods
  /// Decrements player stamina by specified amount
  /// Ensures stamina doesn't go below zero
  void _decrementStamina(int amount) {
    _currentStamina -= amount;
    if (_currentStamina < 0) {
      _currentStamina = 0;
    }
  }

  /// Displays animated emote above player character
  /// Used for visual feedback when observing enemies
  void _displayEmoteAbovePlayer({String emotePath = kEmoteAssetPath}) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          emotePath,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        loop: false,
        size: Vector2.all(GameplayConstants.kCurrentTileSize / 2),
        offset: Vector2(18, -6),
      ),
    );
  }
}
