import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  late final KnightPlayerController _controller;

  KnightPlayerView(Vector2 position, {required KnightPlayerModel model})
    : super(
        animation: KnightPlayerConfig.animation,
        size: KnightPlayerConfig.componentSize,
        position: position,
        life: KnightPlayerConfig.kLife,
        speed: KnightPlayerConfig.kSpeed,
      ) {
    setupLighting(KnightPlayerConfig.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
    _initializeController(model);
  }

  void _initializeController(KnightPlayerModel model) {
    _controller = KnightPlayerController(
      model: model,
      onPrimaryAttack: _onPlayPrimaryAttack,
      onFireballAttack: _onPlayFireballAttack,
      onToolUse: _onPlayToolAnimation,
      onShowExclamation: _onShowExclamationEmote,
      onCheckEnemyVision: _onCheckEnemyVision,
    );
  }

  @override
  Future<void> onLoad() {
    add(KnightPlayerConfig.hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
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
    _controller.dispose();
    super.onRemove();
  }

  // Public API for external interaction
  // void useTool() => _controller.useTool();
  // void switchTool(FarmTool newTool) => _controller.switchTool(newTool);
  // void restoreEnergy() => _controller.restoreEnergy();
  KnightPlayerModel get model => _controller.model;

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
      onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
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
