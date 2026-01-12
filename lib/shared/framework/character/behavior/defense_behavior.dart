// lib/shared/framework/character/behavior/defense_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class DefenseConfig {
  final double blockDamageReduction; // Percentual de redução (0.0 - 1.0)
  final double blockStaminaCostPerHit;
  final double parryWindowMs; // Janela de tempo para parry perfeito
  final double parryDamageReflection; // Percentual de dano refletido no parry
  
  const DefenseConfig({
    this.blockDamageReduction = 0.5, // 50% de redução
    this.blockStaminaCostPerHit = 5.0,
    this.parryWindowMs = 200.0, // 200ms para parry perfeito
    this.parryDamageReflection = 0.3, // 30% de dano refletido
  });
}

class DefenseBehavior extends CharacterBehavior {
  final DefenseConfig config;
  
  bool _isBlocking = false;
  int _blockStartTime = 0;
  
  DefenseBehavior(this.config);
  
  @override
  bool onInput(JoystickActionEvent event) {
    final equipment = character.data.equippedItemId;
    
    // Shield block (segurar botão)
    if (InputDef.isSecondaryAction(event.id) && 
        equipment == HandItemId.shield.name) {
      
      if (event.event == ActionEvent.DOWN) {
        _startBlocking();
        return true;
      } else if (event.event == ActionEvent.UP) {
        _stopBlocking();
        return true;
      }
    }
    
    return false;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Se está bloqueando, reduz velocidade
    if (_isBlocking) {
      character.speed = character.config.baseSpeed * 0.3; // 70% mais lento
    }
  }
  
  @override
  void onReceiveDamage(double damage) {
    super.onReceiveDamage(damage);
    
    if (!_isBlocking) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceBlockStart = now - _blockStartTime;
    
    // Parry perfeito (bloqueou no tempo certo)
    if (timeSinceBlockStart <= config.parryWindowMs) {
      _executeParry(damage);
    }
    // Block normal
    else {
      _executeBlock(damage);
    }
  }
  
  void _startBlocking() {
    if (_isBlocking) return;
    
    _isBlocking = true;
    _blockStartTime = DateTime.now().millisecondsSinceEpoch;
    
    character.lockAction(); // Impede atacar enquanto bloqueia
    
    // VFX de shield levantado
    _displayBlockStartEffect();
    
    GameLogger.info('[DefenseBehavior] ✓ Blocking started');
  }
  
  void _stopBlocking() {
    if (!_isBlocking) return;
    
    _isBlocking = false;
    
    character.unlockAction();
    character.speed = character.config.baseSpeed; // Restaura velocidade
    
    // VFX de shield abaixado
    _displayBlockEndEffect();
    
    GameLogger.info('[DefenseBehavior] ✓ Blocking stopped');
  }
  
  void _executeBlock(double incomingDamage) {
    // Reduz dano
    final reducedDamage = incomingDamage * (1.0 - config.blockDamageReduction);
    final blockedDamage = incomingDamage - reducedDamage;
    
    // Consome stamina
    if (!character.data.tryConsumeStamina(config.blockStaminaCostPerHit)) {
      // Sem stamina = quebra o block
      _stopBlocking();
      GameLogger.warning('[DefenseBehavior] Block broken (no stamina)');
      return;
    }
    
    // Aplica dano reduzido
    character.life = (character.life - reducedDamage).clamp(0, character.config.maxLife);
    character.data.updateLife(character.life);
    
    // VFX de block
    _displayBlockEffect(blockedDamage);
    
    GameLogger.info(
      '[DefenseBehavior] ✓ Blocked! Incoming: $incomingDamage, '
      'Reduced: $reducedDamage, Blocked: $blockedDamage',
    );
  }
  
  void _executeParry(double incomingDamage) {
    GameLogger.info('[DefenseBehavior] ⚡ PARRY! Perfect timing!');
    
    // Parry perfeito: nega TODO o dano e reflete parte
    final reflectedDamage = incomingDamage * config.parryDamageReflection;
    
    // Não consome stamina no parry perfeito (recompensa pela skill)
    
    // Reflete dano no atacante (precisa detectar quem atacou)
    _reflectDamageToAttacker(reflectedDamage);
    
    // VFX de parry (brilho dourado, slow motion, etc)
    _displayParryEffect();
  }
  
  void _reflectDamageToAttacker(double damage) {
    // Detecta inimigos próximos e aplica dano
    character.seeEnemy(
      radiusVision: 64,
      observed: (List<Enemy> enemies) {
        if (enemies.isNotEmpty) {
          final nearestEnemy = enemies.first;
          
          if (nearestEnemy is Attackable) {
            nearestEnemy.receiveDamage(
              AttackOriginEnum.PLAYER_OR_ALLY,
              damage,
              'parry_reflection',
            );
          }
        }
      },
      notObserved: () {},
    );
  }
  
  void _displayBlockStartEffect() {
    // Adiciona sprite de shield na frente do player
    // character.add(ShieldSprite());
  }
  
  void _displayBlockEndEffect() {
    // Remove sprite de shield
  }
  
  void _displayBlockEffect(double blockedDamage) {
    // Partículas de shield impact
    // character.addParticle(ShieldImpactParticles(damage: blockedDamage));
  }
  
  void _displayParryEffect() {
    // VFX especial de parry perfeito
    // - Flash dourado
    // - Slow motion
    // - Partículas de estrela
    // character.addParticle(ParrySuccessParticles());
    
    // Som especial
    // AudioManager.instance.playParrySound();
  }
  
  @override
  void dispose() {
    if (_isBlocking) {
      _stopBlocking();
    }
    super.dispose();
  }
}
