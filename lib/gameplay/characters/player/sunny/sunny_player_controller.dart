import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_controller.dart';

/// Controller for the Sunny player character.
///
/// Implements mobile player controller to provide Sunny-specific input
/// mapping and configuration while inheriting all hybrid combat and
/// mobility management functionality.
class SunnyPlayerController<M extends SunnyPlayerModel>
    extends DDFarmPlayerController<M> {
  SunnyPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteShovel,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvestBasket,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  // ============================================================================
  // Configuration Overrides
  // ============================================================================

  @override
  Duration get staminaRegenDebounce => SunnyPlayerConfig.kStaminaRegenDebounce;
}
