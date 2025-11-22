import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_controller.dart';

/// Controller for the Sunny player character.
///
/// Implements mobile player controller to provide Sunny-specific input
/// mapping and configuration while inheriting all hybrid combat and
/// mobility management functionality.
class SunnyPlayerController extends DDFarmPlayerController<SunnyPlayerModel> {
  SunnyPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteShovel,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
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

  @override
  bool isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.model.equipment == WeaponType.ironSword;

  @override
  bool isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kSecondaryActionId ||
          actionId == KeyboardSetup.kSecondaryActionKey) &&
      player.model.equipment == WeaponType.staff;

  @override
  bool isShovelAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.model.equipment == WeaponType.shovel;

  @override
  bool isWateringCanAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.model.equipment == WeaponType.wateringCan;

  @override
  bool isSeedAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.model.equipment == WeaponType.seeds;

  @override
  bool isRunAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) => actionId == JoystickSetup.kRunId || actionId == KeyboardSetup.kRunKey;
}
