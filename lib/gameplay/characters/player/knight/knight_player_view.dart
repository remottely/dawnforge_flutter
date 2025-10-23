import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_data.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

/// A View (Componente Bonfire)
/// Responsável apenas por exibir elementos visuais, animações, sons
/// e capturar entradas, delegando toda a lógica para o Controller.
class KnightPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final KnightPlayerController controller;

  KnightPlayerView(Vector2 position, {required this.controller})
    : super(
        animation: KnightPlayerConfig.buildDirectionalAnimation,
        size: KnightPlayerConfig.spriteSize,
        position: position,
        life: KnightPlayerConfig.kStandardLife,
        speed: KnightPlayerConfig.kStandardSpeed,
      ) {
    setupLighting(KnightPlayerConfig.buildLightingConfig(width));
    _initializeControls();
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
    showDamage(
      damage,
      config: CharacterParticlesAnimations.playerShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
    // TODO: GameplayAudioManager.playDamageSound();
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    // Lógica puramente visual da morte
    removeFromParent();
    gameRef.add(
      DFGameDecoration.withSprite(
        sprite: KnightPlayerConfig.loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: KnightPlayerConfig.cryptSpriteSize,
      ),
    );
    super.onDie();
  }

  // --- Métodos de Ação (Chamados pelo Controller) ---

  void playMeleeAttackAnimation(double damage) {
    GameplayAudioManager.playAttackPlayerMelee();
    addParticle(CharacterParticlesAnimations.swordParticles(), position: size);
    simpleAttackMelee(
      damage: damage,
      animationRight: PlayerSpriteAnimations.playerBasicAttackRight3(),
      size: KnightPlayerConfig.spriteSize,
    );
  }

  void playFireballAttackAnimation(double damage) {
    addParticle(
      CharacterParticlesAnimations.fireballParticles(),
      position: size,
    );
    simpleAttackRange(
      animationRight: CharacterFireballAttackData.loadAttackAnimation(),
      animationDestroy: CharacterFireballAttackData.loadExplosionAnimation(),
      size: CharacterFireballAttackData.spriteSize,
      damage: damage,
      speed: speed * CharacterFireballAttackData.kSpeedMultiplier,
      onDestroy: CharacterFireballAttackData.playExplosionAudio,
      collision: CharacterFireballAttackData.hitbox,
      lightingConfig: CharacterFireballAttackData.lightingConfig,
    );
    CharacterFireballAttackData.playAttackAudio();
  }

  void playToolAnimation() {
    // TODO: Adicionar a animação de uso da ferramenta
    // Ex: simpleAttackMelee(..., animation: toolAnimation, damage: 0);
    // Ao final da animação, lembre-se de definir controller.isUsingTool = false;
  }

  void showExclamationEmote() {
    CharacterEmoteController.displayEmoteAboveCharacter(
      gameRef: gameRef,
      target: this,
      assetPath: CharacterEmoteController.kExclamationEmoteAssetPath,
    );
  }

  // --- Configuração ---

  void _initializeControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }
}
