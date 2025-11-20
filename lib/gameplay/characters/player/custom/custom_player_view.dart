import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_to_custom_player_adapter.dart';
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
    double? life,
    double? speed,
    LightingConfig? lightingConfig,
    CustomPlayerHandLoadoutSetup? handLoadout,
  }) : _customHitbox = hitbox,
       _customLightingConfig =
           lightingConfig ?? KnightPlayerConfig.lightingConfig,
       super(
         life: life ?? KnightPlayerConfig.kLife,
         speed: speed ?? KnightPlayerConfig.kSpeed,
         equipmentLoadout:
             handLoadout ??
             EquipmentToCustomPlayerAdapter.instance
                 .createLoadoutFromEquipment(),
       );

  final RectangleHitbox _customHitbox;
  final LightingConfig
  _customLightingConfig; // ============================================================================
  // Factory Methods - Configuration
  // ============================================================================

  @override
  CustomPlayerController createCombatController({
    required CustomPlayerModel model,
    required bool Function(double damage) onPrimaryAttack,
    required bool Function(double damage) onRangedAttack,
    required void Function() onShowExclamation,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  }) {
    return CustomPlayerController(
      model: model,
      onPrimaryAttack: onPrimaryAttack,
      onRangedAttack: onRangedAttack,
      onShowExclamation: onShowExclamation,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );
  }

  @override
  RectangleHitbox createHitbox() => _customHitbox;

  @override
  LightingConfig get lightingConfig => _customLightingConfig;

  @override
  DDDecoration createDeathMarker(Vector2 position) =>
      KnightPlayerConfig.createCryptComponent(position);
}
