import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_basic_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final KnightPlayerController controller = KnightPlayerController(
    model: KnightPlayerModel(),
  );

  KnightPlayerView(Vector2 position)
    : super(
        animation: KnightPlayerConfig.buildDirectionalAnimation,
        size: KnightPlayerConfig.spriteSize,
        position: position,
        life: KnightPlayerConfig.kStandardLife,
        speed: KnightPlayerConfig.kStandardSpeed,
      ) {
    setupLighting(KnightPlayerConfig.buildLightingConfig(width));
    _setupControls();
  }

  @override
  Future<void> onLoad() {
    controller.attachView(this);
    KnightPlayerConfig.buildHitBox(this);
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
    controller.onJoystickAction(event);
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

  void playMeleeAttackAnimation(double damage) {
    GameplayAudioManager.instance.playAttackPlayerMelee();
    addParticle(CharacterParticlesAnimations.swordParticles(), position: size);
    simpleAttackMelee(
      damage: damage,
      animationRight: CharacterBasicAttackConfig.playerBasicAttackRight3(),
      size: KnightPlayerConfig.spriteSize,
    );
  }

  void playFireballAttackAnimation(double damage) {
    addParticle(
      CharacterParticlesAnimations.fireballParticles(),
      position: size,
    );
    simpleAttackRange(
      animationRight: CharacterFireballAttackConfig.loadAttackAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadExplosionAnimation(),
      size: CharacterFireballAttackConfig.spriteSize,
      damage: damage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      onDestroy: CharacterFireballAttackConfig.playExplosionAudio,
      collision: CharacterFireballAttackConfig.hitbox,
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
    );
    CharacterFireballAttackConfig.playAttackAudio();
  }

  void playToolAnimation() {}

  void showExclamationEmote() {
    CharacterEmoteController.displayEmoteAboveCharacter(
      gameRef: gameRef,
      target: this,
      assetPath: CharacterEmoteController.kExclamationEmoteAssetPath,
    );
  }

  void _showDamageEffect(double damage) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.playerShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  void _showDeathEffect() {
    gameRef.add(
      DFGameDecoration.withSprite(
        sprite: KnightPlayerConfig.loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: KnightPlayerConfig.cryptSpriteSize,
      ),
    );
  }

  void _setupControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }
}
