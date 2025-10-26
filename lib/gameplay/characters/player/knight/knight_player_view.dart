import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_basic_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final KnightPlayerController controller = KnightPlayerController(
    model: KnightPlayerModel(),
  );

  KnightPlayerView(Vector2 position)
    : super(
        animation: KnightPlayerConfig.buildDirectionalAnimation,
        size: KnightPlayerConfig.componentSize,
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
      animationRight: CharacterBasicAttackConfig.loadPlayerExecutionAnimation(),
      size: KnightPlayerConfig.componentSize,
    );
  }

  void playFireballAttackAnimation(double damage) {
    addParticle(
      CharacterParticlesAnimations.fireballParticles(),
      position: size,
    );
    simpleAttackRange(
      animationRight: CharacterFireballAttackConfig.loadExecutionAnimation(),
      animationDestroy: CharacterFireballAttackConfig.loadDestroyAnimation(),
      size: CharacterFireballAttackConfig.componentSize,
      damage: damage,
      speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
      onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
      collision: CharacterFireballAttackConfig.buildHitbox(),
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
    );
    CharacterFireballAttackConfig.playExecutionAudio();
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
      config: CharacterParticlesAnimations.kPlayerShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  void _showDeathEffect() {
    gameRef.add(
      DDGameDecoration.withSprite(
        sprite: KnightPlayerConfig.loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: KnightPlayerConfig.cryptComponentSize,
      ),
    );
  }

  void _setupControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }
}
