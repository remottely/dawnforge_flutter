import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effect_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FarmTool { hand, hoe, wateringCan }

class KnightCharacter extends SimplePlayer
    with Lighting, BlockMovementCollision {
  // Sistema de ferramentas agrícolas
  static const int kMaxEnergy = 100;
  static const int kToolUsageEnergyCost = 2;

  FarmTool currentTool = FarmTool.hand;
  int energy = kMaxEnergy;
  bool isUsingTool = false;

  static const double kRangedAttackSize =
      GameplayConstants.kTileSizeDefault * 0.65;

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
  static const double kSmallAttackDamage = 10;
  static const double kMaxStamina = 100.0;
  static const double kDefaultLife = 200.0;
  static const int kStaminaRegenerationRate = 10;
  static const Duration kStaminaRegenerationInterval = Duration(
    milliseconds: 100,
  );
  static const int kMeleeAttackStaminaCost = 15;
  static const int kRangedAttackStaminaCost = 10;
  static const int kStaminaIncrement = 2;
  static const double kVisionRadius = GameplayConstants.kVisionRadiusUltraLarge;

  double _attackDamage = kDefaultAttackDamage;
  double _currentStamina = kMaxStamina;
  async.Timer? _staminaRegenerationTimer;
  bool _hasKey = false;
  bool _isObservingEnemy = false;

  double get attackDamage => _attackDamage;
  double get currentStamina => _currentStamina;
  bool get hasKey => _hasKey;
  bool get isObservingEnemy => _isObservingEnemy;
  set hasKey(bool value) => _hasKey = value;

  KnightCharacter(Vector2 position)
    : super(
        animation: PlayerSpriteAnimations.knightPlayerAnimation(),
        size: GameplayConstants.kTileVector2Default,
        position: position,
        life: 200,
        speed: GameplayConstants.kTileSizeDefault * 2.5,
      ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
      ),
    );
    _initializeControls();
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: Vector2(8, 6), position: Vector2(4, 9)));
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
        sprite: Sprite.load('gameplay/characters/player/player_crypt_1.png'),
        position: Vector2(position.x, position.y),
        size: Vector2.all(30), // TODO: NOW
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
      _executeRangedAttack(kSmallAttackDamage);
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      _executeRangedAttack(kSmallAttackDamage);
    }
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: TextStyle(
        fontSize: 5,
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void executeAttack() {
    if (_currentStamina < kMeleeAttackStaminaCost) {
      return;
    }

    GameplayAudioManager.playAttackPlayerMelee();
    _decrementStamina(kMeleeAttackStaminaCost);
    simpleAttackMelee(
      damage: _attackDamage,
      animationRight: PlayerSpriteAnimations.playerMeleeAttackEffectRight3(),
      size: GameplayConstants.kTileVector2Default,
    );
  }

  void _executeRangedAttack(double damage) {
    if (_currentStamina < kRangedAttackStaminaCost) {
      return;
    }

    _decrementStamina(kRangedAttackStaminaCost);

    GameplayAudioManager.playAttackRange();
    simpleAttackRange(
      animationRight: CharacterEffectSpriteAnimations.fireBallAttackRight3(),
      animationDestroy:
          CharacterEffectSpriteAnimations.fireBallExplosionRight6(),
      size: Vector2.all(kRangedAttackSize),
      damage: damage,
      speed: speed * 2.5,
      onDestroy: () {
        GameplayAudioManager.playExplosion();
      },
      collision: RectangleHitbox(
        size: Vector2(
          GameplayConstants.kTileSizeDefault / 3,
          GameplayConstants.kTileSizeDefault / 3,
        ),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: GameplayConstants.kTileSizeDefault * 0.9,
        blurBorder: GameplayConstants.kTileSizeDefault,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
      ),
    );
  }

  void decrementStamina(int amount) {
    _decrementStamina(amount);
  }

  void _initializeControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }

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

  void _handleMovementEffects() {
    seeEnemy(
      radiusVision: kVisionRadius,
      notObserved: () {
        _isObservingEnemy = false;
      },
      observed: (enemies) {
        if (_isObservingEnemy) return;
        _isObservingEnemy = true;
        CharacterEmoteController.displayEmoteAboveCharacter(
          gameRef: gameRef,
          target: this,
          assetPath: CharacterEmoteController.kExclamationEmoteAssetPath,
        );
      },
    );
  }

  void _decrementStamina(int amount) {
    _currentStamina -= amount;
    if (_currentStamina < 0) {
      _currentStamina = 0;
    }
  }
}
