import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_loadout.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/presets/knight_hand_loadout_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
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
class KnightPlayerView
    extends DDEquippablePlayerView<KnightPlayerController, KnightPlayerModel> {
  KnightPlayerView({
    required super.position,
    required super.model,
    KnightHandLoadoutSetup? handLoadout,
  }) : super(
         animation: KnightPlayerConfig.animation,
         size: KnightPlayerConfig.componentSize,
         life: KnightPlayerConfig.kLife,
         speed: KnightPlayerConfig.kSpeed,
         equipmentLoadout:
             handLoadout ??
             KnightHandLoadoutConfig.createDefaultKnightHandLoadout(),
       );

  // ============================================================================
  // Factory Methods - Configuration
  // ============================================================================

  @override
  KnightPlayerController createCombatController({
    required KnightPlayerModel model,
    required bool Function(double damage) onPrimaryAttack,
    required bool Function(double damage) onRangedAttack,
    required void Function() onShowExclamation,
    required void Function({
      required double visionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onCheckEnemyVision,
  }) {
    return KnightPlayerController(
      model: model,
      onPrimaryAttack: onPrimaryAttack,
      onRangedAttack: onRangedAttack,
      onShowExclamation: onShowExclamation,
      onCheckEnemyVision: onCheckEnemyVision,
    );
  }

  @override
  RectangleHitbox createHitbox() => KnightPlayerConfig.hitbox;

  @override
  LightingConfig get lightingConfig => KnightPlayerConfig.lightingConfig;

  @override
  GameDecoration createDeathMarker(Vector2 position) =>
      KnightPlayerConfig.createCryptComponent(position);
}
