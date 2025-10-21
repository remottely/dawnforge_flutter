import 'dart:async' as async;
import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_data.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FarmTool { hand, hoe, wateringCan }

abstract class _KnightPlayerData {
  /// DATA (Constantes e valores estáticos)
  // Geral
  static Vector2 get _spriteSize => GameplayConstants.kTileVector2Standard;
  static const double _kStandardLife = 200.0;
  static const double _kStandardSpeed =
      GameplayConstants.kTileSizeStandard * 2.5;

  // Sistema Agrícola
  static const int _kMaxEnergy = 100;
  static const int _kToolUsageEnergyCost = 2;

  // Combate
  static const double _kStandardAttackDamage = 25.0;
  static const double _kSmallAttackDamage = 10.0;
  static const int _kMeleeAttackStaminaCost = 15;
  static const int _kCharacterFireballAttackStaminaCost = 10;

  // Stamina
  static const double _kMaxStamina = 100.0;
  static const int _kStaminaIncrement = 2;
  static const Duration _kStaminaRegenerationDebounce = Duration(
    milliseconds: 150,
  );

  // Visão
  static const double _kVisionRadius =
      GameplayConstants.kVisionRadiusUltraLarge;

  // Hitbox
  static Vector2 get _hitBoxSize => Vector2(8, 6);
  static Vector2 get _hitBoxPosition => Vector2(4, 9);

  // Morte
  static const String _cryptSpritePath =
      'gameplay/characters/player/player_crypt_1.png';
  static Vector2 get _cryptSpriteSize => Vector2.all(30);

  // UI
  static final TextStyle _kDamageTextStyle = TextStyle(
    fontSize: 5,
    color: Colors.orange,
    fontFamily: 'Normal',
  );

  /// CONFIG (Métodos que criam objetos de configuração)
  static LightingConfig _buildLightingConfig(double width) => LightingConfig(
    radius: width * 1.5,
    blurBorder: width,
    color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
  );

  /// LOAD (Métodos que carregam assets ou adicionam componentes)
  static SimpleDirectionAnimation _loadAnimation() =>
      PlayerSpriteAnimations.knightPlayerAnimation();

  static FutureOr<void> _buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(position: _hitBoxPosition, size: _hitBoxSize));

  static Future<Sprite> _loadCryptSprite() => Sprite.load(_cryptSpritePath);
}

class KnightPlayer extends SimplePlayer with Lighting, BlockMovementCollision {
  // Sistema de ferramentas agrícolas
  FarmTool currentTool = FarmTool.hand;
  int energy = _KnightPlayerData._kMaxEnergy;
  bool isUsingTool = false;

  // Variáveis de estado
  double _attackDamage = _KnightPlayerData._kStandardAttackDamage;
  double _currentStamina = _KnightPlayerData._kMaxStamina;
  async.Timer? _staminaRegenerationTimer;
  bool _hasKey = false;
  bool _isObservingEnemy = false;

  // Getters & Setters
  double get attackDamage => _attackDamage;
  double get currentStamina => _currentStamina;
  bool get hasKey => _hasKey;
  bool get isObservingEnemy => _isObservingEnemy;
  set hasKey(bool value) => _hasKey = value;

  KnightPlayer(Vector2 position)
    : super(
        animation: _KnightPlayerData._loadAnimation(),
        size: _KnightPlayerData._spriteSize,
        position: position,
        life: _KnightPlayerData._kStandardLife,
        speed: _KnightPlayerData._kStandardSpeed,
      ) {
    setupLighting(_KnightPlayerData._buildLightingConfig(width));
    _initializeControls();
  }

  // Troca de ferramenta
  void switchTool(FarmTool newTool) {
    currentTool = newTool;
    // TODO: feedback visual/sonoro
  }

  // Uso de ferramenta agrícola
  void useTool() {
    if (energy < _KnightPlayerData._kToolUsageEnergyCost) return;
    isUsingTool = true;
    // TODO: integração com tiles agrícolas
    energy -= _KnightPlayerData._kToolUsageEnergyCost;
    if (energy < 0) energy = 0;
    // TODO: animação de uso de ferramenta
    isUsingTool = false;
  }

  // Restaurar energia (ex: ao dormir)
  void restoreEnergy() {
    energy = _KnightPlayerData._kMaxEnergy;
    // TODO: atualizar barra de energia na HUD
  }
  // TODO: integrar valor de energia com HUD

  @override
  Future<void> onLoad() {
    _KnightPlayerData._buildHitBox(this);
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
        sprite: _KnightPlayerData._loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: _KnightPlayerData._cryptSpriteSize,
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
      _executeCharacterFireballAttack(_KnightPlayerData._kSmallAttackDamage);
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      _executeCharacterFireballAttack(_KnightPlayerData._kSmallAttackDamage);
    }
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamage(damage, config: _KnightPlayerData._kDamageTextStyle);
    super.onReceiveDamage(attacker, damage, id);
  }

  void executeAttack() {
    if (_currentStamina < _KnightPlayerData._kMeleeAttackStaminaCost) {
      return;
    }

    GameplayAudioManager.playAttackPlayerMelee();
    _decrementStamina(_KnightPlayerData._kMeleeAttackStaminaCost);
    simpleAttackMelee(
      damage: _attackDamage,
      animationRight: PlayerSpriteAnimations.playerBasicAttackRight3(),
      size: _KnightPlayerData._spriteSize,
    );
  }

  void _executeCharacterFireballAttack(double damage) {
    if (_currentStamina <
        _KnightPlayerData._kCharacterFireballAttackStaminaCost) {
      return;
    }

    _decrementStamina(_KnightPlayerData._kCharacterFireballAttackStaminaCost);

    simpleAttackRange(
      animationRight: CharacterFireballAttackData.loadAttackAnimation(),
      animationDestroy: CharacterFireballAttackData.loadExplosionAnimation(),
      size: CharacterFireballAttackData.spriteSize,
      damage: damage,
      speed: speed * CharacterFireballAttackData.kSpeedMultiplier,
      onDestroy: () => CharacterFireballAttackData.playExplosionAudio(),
      collision: CharacterFireballAttackData.buildHitbox(),
      lightingConfig: CharacterFireballAttackData.buildLightingConfig(),
    );
    CharacterFireballAttackData.playExecutionAudio();
  }

  void decrementStamina(int amount) {
    _decrementStamina(amount);
  }

  void _initializeControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }

  void _handleStamina() {
    if (_staminaRegenerationTimer == null) {
      _staminaRegenerationTimer = async.Timer(
        _KnightPlayerData._kStaminaRegenerationDebounce,
        () {
          _staminaRegenerationTimer = null;
        },
      );
    } else {
      return;
    }

    _currentStamina += _KnightPlayerData._kStaminaIncrement;
    if (_currentStamina > _KnightPlayerData._kMaxStamina) {
      _currentStamina = _KnightPlayerData._kMaxStamina;
    }
  }

  void _handleMovementEffects() {
    seeEnemy(
      radiusVision: _KnightPlayerData._kVisionRadius,
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
