import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_effects_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/shared/framework/dd_game_decoration.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final KnightPlayerController controller = KnightPlayerController(
    model: KnightPlayerModel(),
  );

  KnightPlayerView(Vector2 position)
    : super(
        animation: KnightPlayerConfig.fDirectionalSpriteAnimation,
        size: KnightPlayerConfig.fComponentSize,
        position: position,
        life: KnightPlayerConfig.kStandardLife,
        speed: KnightPlayerConfig.kStandardSpeed,
      ) {
    setupLighting(KnightPlayerConfig.fLightingConfig);
    _setupControls();
  }

  @override
  Future<void> onLoad() {
    controller.attachView(this);
    add(KnightPlayerConfig.fHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    controller.onUpdate(dt);
    super.update(dt);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;
    controller.onInputAction(event);
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    _showDamageEffect(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _showDeathEffect();
    removeFromParent();
    super.onDie();
  }

  void playPrimaryAttackAnimation(double damage) {
    GameplayAudioManager.instance.playPlayerPrimaryAttackSfx();
    addParticle(
      CharacterEffectsParticlesAnimationsConfig.createPrimaryAttackParticles(),
      position: size,
    );
    simpleAttackMelee(
      damage: damage,
      animationRight:
          CharacterPrimaryAttackConfig.loadPlayerExecutionAnimation(),
      size: KnightPlayerConfig.fComponentSize,
    );
  }

  void playFireballAttackAnimation(double damage) {
    addParticle(
      CharacterEffectsParticlesAnimationsConfig.createFireballAttackParticles(),
      position: size,
    );
    simpleAttackRange(
      animationRight: CharacterFireballAttackConfig.loadExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadDestroyAnimation(),
      size: CharacterFireballAttackConfig.fComponentSize,
      damage: damage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
      collision: CharacterFireballAttackConfig.createHitbox(),
      lightingConfig: CharacterFireballAttackConfig.fLightingConfig,
    );
    CharacterFireballAttackConfig.playExecutionAudio();
  }

  void playToolAnimation() {}

  void showExclamationEmote() {
    add(
      CharacterEmoteManager.displayEmoteAboveCharacter(
        asset: CharacterEmoteManager.kExclamationEmoteAsset,
        target: this,
      ),
    );
  }

  void _showDamageEffect(double damage) => showDamage(
    damage,
    config:
        CharacterEffectsParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
    gravity: CharacterEffectsParticlesAnimationsConfig.kShowDamageGravity,
    initVelocityVertical: CharacterEffectsParticlesAnimationsConfig
        .kShowDamageInitVelocityVertical,
  );

  void _showDeathEffect() => gameRef.add(
    DDGameDecoration.withSprite(
      sprite: KnightPlayerConfig.loadCryptSprite(),
      position: Vector2(position.x, position.y),
      size: KnightPlayerConfig.fCryptComponentSize,
    ),
  );

  void _setupControls() => setupMovementByJoystick(intensityEnabled: true);
}
