// lib/shared/framework/character/behavior/mining_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';

class MiningConfig {
  final double pickaxeStaminaCost;
  final double pickaxeDamageToRock; // Dano ao minério
  final DDAnimationDirectionalFactory pickaxeAnimationFactory;
  
  const MiningConfig({
    required this.pickaxeStaminaCost,
    required this.pickaxeDamageToRock,
    required this.pickaxeAnimationFactory,
  });
}

class MiningBehavior extends CharacterBehavior {
  final MiningConfig config;
  
  late DDAnimationDirectional _pickaxeAnimation;
  bool _isActionPlaying = false;
  
  MiningBehavior(this.config);
  
  @override
  void onAttach() {
    super.onAttach();
    _loadAnimations();
  }
  
  Future<void> _loadAnimations() async {
    _pickaxeAnimation = await DDCharacterActionSpriteAnimationHelper
        .loadAnimationDirectionalFromFactory(config.pickaxeAnimationFactory);
  }
  
  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;
    
    final equipment = character.data.equippedItemId;
    
    // Mine (pickaxe)
    if (InputDef.isPrimaryAction(event.id) && 
        equipment == HandItemId.pickaxe.name) {
      return _executeMine();
    }
    
    return false;
  }
  
  bool _executeMine() {
    GameLogger.info('[MiningBehavior] Executing mine');
    
    if (_isActionPlaying) return false;
    
    if (!character.data.tryConsumeStamina(config.pickaxeStaminaCost)) {
      OverlayMessageDef.showNoStamina();
      return false;
    }
    
    character.beginStaminaConsumingAction();
    
    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _pickaxeAnimation.right,
      animationLeft: _pickaxeAnimation.left,
      animationUp: _pickaxeAnimation.up,
      animationDown: _pickaxeAnimation.down,
      animationRightUp: _pickaxeAnimation.rightUp,
      animationRightDown: _pickaxeAnimation.rightDown,
      animationLeftUp: _pickaxeAnimation.leftUp,
      animationLeftDown: _pickaxeAnimation.leftDown,
      currentAnimation: character.animation,
      target: character,
      onActionStart: () {
        _isActionPlaying = true;
        character.lockAction();
      },
      onActionEnd: () {
        _isActionPlaying = false;
        character.unlockAction();
        character.endStaminaConsumingAction();
      },
      onExecutionFrames: () => _performMineAction(),
    );
    
    return true;
  }
  
  void _performMineAction() {
    // Detecta rochas/minérios na frente do player
    final miningArea = _getMiningArea();
    
    // Aplica dano em GameDecorations que sejam mineráveis
    character.gameRef.visibleDecorations().forEach((decoration) {
      if (_isMineable(decoration) && 
          miningArea.contains(Offset(decoration.position.x, decoration.position.y))) {
        
        _damageMineable(decoration);
      }
    });
    
    GameLogger.info('[MiningBehavior] Mine action executed');
  }
  
  Rect _getMiningArea() {
    final direction = character.lastDirection;
    final offset = _directionToOffset(direction) * 32;
    
    return Rect.fromCenter(
      center: Offset(
        character.position.x + offset.dx,
        character.position.y + offset.dy,
      ),
      width: 32,
      height: 32,
    );
  }
  
  Offset _directionToOffset(Direction dir) {
    switch (dir) {
      case Direction.up: return Offset(0, -1);
      case Direction.down: return Offset(0, 1);
      case Direction.left: return Offset(-1, 0);
      case Direction.right: return Offset(1, 0);
      default: return Offset.zero;
    }
  }
  
  bool _isMineable(GameDecoration decoration) {
    // Verifica se o decoration tem propriedade "mineable"
    // ou se é uma instância de Rock/Ore
    return decoration.toString().contains('Rock') ||
           decoration.toString().contains('Ore');
  }
  
  void _damageMineable(GameDecoration decoration) {
    // Se o decoration implementa Damageable
    if (decoration is Attackable) {
      decoration.receiveDamage(
        AttackOriginEnum.PLAYER_OR_ALLY,
        config.pickaxeDamageToRock,
        'pickaxe',
      );
    }
    
    // Spawn partículas de mining
    _spawnMiningParticles(decoration.position);
  }
  
  void _spawnMiningParticles(Vector2 position) {
    // Adiciona partículas de pedra quebrando
    // character.gameRef.add(RockParticles(position: position));
  }
}
