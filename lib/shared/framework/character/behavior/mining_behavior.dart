// lib/shared/framework/character/behavior/mining_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/systems/overlay/message/message_overlay_def.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';

class MiningConfig {
  final double pickaxeStaminaCost;
  final double pickaxeDamageToRock;
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
    _pickaxeAnimation =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.pickaxeAnimationFactory,
        );
  }

  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;

    final equipment = character.data.equippedItemId;

    // Mine (pickaxe)
    if (InputDef.isPrimaryAction(event.id)) {
      if (equipment?.isPickaxe ?? false) {
        return _executeMine();
      }
    }

    return false;
  }

  bool _executeMine() {
    GameLogger.info('[MiningBehavior] Executing mine');

    if (_isActionPlaying) return false;

    if (!character.data.tryConsumeStamina(config.pickaxeStaminaCost)) {
      MessageOverlayDef.showNoStamina();
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
      executionStartFrame: 3,
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
    final miningArea = _getMiningArea();

    // ✅ CORREÇÃO: Verifica se tem gameRef e usa decorations() do Bonfire 3.16.1
    if (character.hasGameRef) {
      final decorations = character.gameRef.decorations(onlyVisible: true);

      for (final decoration in decorations) {
        if (_isMineable(decoration) &&
            miningArea.contains(
              Offset(decoration.position.x, decoration.position.y),
            )) {
          _damageMineable(decoration);
        }
      }
    }

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
      case Direction.up:
        return const Offset(0, -1);
      case Direction.down:
        return const Offset(0, 1);
      case Direction.left:
        return const Offset(-1, 0);
      case Direction.right:
        return const Offset(1, 0);
      case Direction.upLeft:
        return const Offset(-0.7, -0.7);
      case Direction.upRight:
        return const Offset(0.7, -0.7);
      case Direction.downLeft:
        return const Offset(-0.7, 0.7);
      case Direction.downRight:
        return const Offset(0.7, 0.7);
      default:
        return Offset.zero;
    }
  }

  bool _isMineable(GameDecoration decoration) {
    // Verifica pelo nome/tipo do decoration
    final decorationName = decoration.runtimeType.toString().toLowerCase();

    return decorationName.contains('rock') ||
        decorationName.contains('ore') ||
        decorationName.contains('stone') ||
        decorationName.contains('mineral');
  }

  void _damageMineable(GameDecoration decoration) {
    // ✅ CORREÇÃO: Usa handleAttack do Attackable mixin (Bonfire 3.16.1)
    if (decoration is Attackable) {
      final attackable = decoration as Attackable;

      attackable.handleAttack(
        AttackOriginEnum.PLAYER_OR_ALLY,
        config.pickaxeDamageToRock,
        'pickaxe',
      );

      GameLogger.info(
        '[MiningBehavior] ⛏️ Hit ${decoration.runtimeType} for ${config.pickaxeDamageToRock} damage',
      );
    }

    _spawnMiningParticles(decoration.position);
  }

  void _spawnMiningParticles(Vector2 position) {
    // TODO: Adicionar partículas de pedra quebrando
    // Exemplo:
    // if (character.hasGameRef) {
    //   character.gameRef.add(
    //     AnimatedObjectOnce(
    //       animation: SpriteAnimation.load(...),
    //       position: position,
    //       size: Vector2.all(32),
    //     ),
    //   );
    // }

    GameLogger.info(
      '[MiningBehavior] ✨ Spawning mining particles at $position',
    );
  }
}
