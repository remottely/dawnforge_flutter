import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_equippable_player/dd_equippable_player_view.dart';

/// Visual representation and input handler for the Knight player character.
///
/// This view implements the equippable player specialization, providing Knight
/// with hybrid combat capabilities (melee + ranged) through a dual-hand
/// equipment system.
///
/// Combat System:
/// - Equipment-based attack routing
/// - Dual-hand management (left/right slots)
/// - Customizable loadouts
/// - Item-specific combat behaviors
///
/// Note: Unlike Sunny, Knight does not have run mechanics and uses standard
/// movement speed only.
class CustomPlayerView
    extends DDEquippablePlayerView<CustomPlayerController, CustomPlayerModel> {
  CustomPlayerView({
    required super.position,
    required super.model,
    required super.animation,
    required super.size,
    required RectangleHitbox hitbox,
    required double life,
    required double speed,
    required LightingConfig lightingConfig,
    required CustomPlayerHandLoadoutSetup handLoadout,
  }) : _hitbox = hitbox,
       _lightingConfig = lightingConfig,
       super(life: life, speed: speed, equipmentLoadout: handLoadout);

  final RectangleHitbox _hitbox;
  final LightingConfig
  _lightingConfig; // ============================================================================
  // Factory Methods - Configuration
  // ============================================================================

  @override
  CustomPlayerController createCombatController({
    required CustomPlayerModel model,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  }) {
    return CustomPlayerController(
      model: model,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );
  }

  @override
  RectangleHitbox getHitbox() => _hitbox;

  @override
  LightingConfig getLightingConfig() => _lightingConfig;

  @override
  DDDecoration getDeathMarker(Vector2 position) =>
      KnightPlayerConfig.createCryptComponent(position);
}
