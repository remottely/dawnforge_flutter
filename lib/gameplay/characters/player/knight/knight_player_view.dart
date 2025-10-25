import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_data.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

/// View: Responsável por exibir elementos visuais, animações, sons e capturar entradas.
/// Não possui lógica de negócio, apenas feedback visual e interação com o Controller.
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

  //////////////////////////////////////////////////////////////////////////////
  // CICLO DE VIDA
  //////////////////////////////////////////////////////////////////////////////
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
    // GameplayAudioManager.instance.playDamageSound(); // Implementar se necessário
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _showDeathEffect();
    removeFromParent();
    super.onDie();
  }

  //////////////////////////////////////////////////////////////////////////////
  // ANIMAÇÕES & EFEITOS
  //////////////////////////////////////////////////////////////////////////////
  /// Animação de ataque melee
  void playMeleeAttackAnimation(double damage) {
    GameplayAudioManager.instance.playAttackPlayerMelee();
    addParticle(CharacterParticlesAnimations.swordParticles(), position: size);
    simpleAttackMelee(
      damage: damage,
      animationRight: PlayerSpriteAnimations.playerBasicAttackRight3(),
      size: KnightPlayerConfig.spriteSize,
    );
  }

  /// Animação de ataque fireball
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

  /// Animação de uso de ferramenta
  void playToolAnimation() {
    // TODO: Adicionar animação visual da ferramenta
    // Exemplo: simpleAttackMelee(..., animation: toolAnimation, damage: 0);
    // Ao final da animação, defina controller.isUsingTool = false;
  }

  /// Exibe emote de exclamação acima do personagem
  void showExclamationEmote() {
    CharacterEmoteController.displayEmoteAboveCharacter(
      gameRef: gameRef,
      target: this,
      assetPath: CharacterEmoteController.kExclamationEmoteAssetPath,
    );
  }

  /// Exibe dano recebido
  void _showDamageEffect(double damage) {
    showDamage(
      damage,
      config: CharacterParticlesAnimations.playerShowDamageTextStyle,
      gravity: CharacterParticlesAnimations.kShowDamageGravity,
      initVelocityVertical:
          CharacterParticlesAnimations.kShowDamageInitVelocityVertical,
    );
  }

  /// Exibe efeito visual de morte
  void _showDeathEffect() {
    gameRef.add(
      DFGameDecoration.withSprite(
        sprite: KnightPlayerConfig.loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: KnightPlayerConfig.cryptSpriteSize,
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  // CONFIGURAÇÃO
  //////////////////////////////////////////////////////////////////////////////
  void _setupControls() {
    setupMovementByJoystick(intensityEnabled: true);
  }
}
