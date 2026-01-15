// lib/gameplay/characters/player/demo/demo_player_def.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/lightning_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/character/behavior/mining_behavior.dart';
import 'package:dawnforge/shared/framework/character/character_config.dart';
import 'package:dawnforge/shared/framework/character/behavior/combat_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/farming_behavior.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';

final class DemoPlayerDef {
  DemoPlayerDef._();

  // ============================================================================
  // STATS
  // ============================================================================

  static const double _kMaxLife = CharacterConstants.kLifeExtraLarge;
  static const double _kBaseSpeed = CharacterConstants.kSpeedFast;
  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const double _kStaminaRegenRate = 1.0; // por segundo
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const double _kRunSpeedMultiplier = 1.4;

  // ============================================================================
  // COMBAT STATS
  // ============================================================================

  static const double _kPrimaryAttackDamage = 25.0;
  static const double _kPrimaryAttackStaminaCost = 1.0;
  static const double _kRangedAttackDamage = 10.0;
  static const double _kRangedAttackStaminaCost = 2.0;

  // ============================================================================
  // FARMING STATS
  // ============================================================================

  static const double _kDigStaminaCost = 5.0;
  static const double _kWateringCanStaminaCost = 5.0;
  static const double _kSeedStaminaCost = 5.0;
  static const double _kHarvestStaminaCost = 5.0;

  // ============================================================================
  // VISUALS
  // ============================================================================

  static final Vector2 textureSize = TileConstants.tileSizeSmallburg;
  static final Vector2 _componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: _componentSize,
    left: 26,
    top: 33,
    right: 27,
    bottom: 22,
  );

  static final LightingConfig _lighting = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  // ============================================================================
  // ASSET PATHS
  // ============================================================================

  static const String _idleAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/idle/character_body/character_idle_body_light_2.png';
  static const String _walkAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/walk/character_body/character_walk_body_light_6.png';
  static const String _runAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/run/character_body/character_run_body_light_with_dust_specs_4.png';
  static const String _digAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_shovel/character_body/character_tools_shovel_body_light_6.png';
  static const String _wateringAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_watercan/character_body/character_tools_watercan_body_light_10.png';
  static const String _placeSeedAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/place_seed/character_body/character_place_seed_body_light_6.png';
  static const String _harvestAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_hoe/character_body/character_tools_hoe_body_light_7.png';
  static const String _attack1AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/slash_1/character_demo/character_slash_1_light_full_6.png';
  static const String _attack2AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/slash_2/character_demo/character_slash_2_light_full_6.png';
  static const String _attack3AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/super_slash/character_demo/character_super_slash_light_full_6.png';

  // ============================================================================
  // ANIMATION CONSTANTS
  // ============================================================================

  static const int _x2 = 2;
  static const int _x4 = 4;
  static const int _x6 = 6;
  static const int _x7 = 7;
  static const int _x10 = 10;

  static const double _frameRightY = 0;
  static const double _frameLeftY = TileConstants.kCharacterDimensionSmallburg * 1;
  static const double _frameDownY = TileConstants.kCharacterDimensionSmallburg * 2;
  static const double _frameUpY = TileConstants.kCharacterDimensionSmallburg * 3;

  // ============================================================================
  // ANIMATIONS - IDLE
  // ============================================================================

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  // ============================================================================
  // ANIMATIONS - WALK
  // ============================================================================

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final SimpleDirectionAnimation _animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: _loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: loadAnimationIdleDown,
        runLeft: _loadAnimationWalkLeft,
        runRight: _loadAnimationWalkRight,
        runUp: _loadAnimationWalkUp,
        runDown: _loadAnimationWalkDown,
      );

  // ============================================================================
  // ANIMATIONS - RUN
  // ============================================================================

  static final Future<SpriteAnimation> _loadAnimationRunRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final SimpleDirectionAnimation _animationRunDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: _loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: loadAnimationIdleDown,
        runLeft: _loadAnimationRunLeft,
        runRight: _loadAnimationRunRight,
        runUp: _loadAnimationRunUp,
        runDown: _loadAnimationRunDown,
      );

  // ============================================================================
  // ANIMATIONS - ATTACKS
  // ============================================================================

  static Future<SpriteAnimation> _loadAnimationAttack1Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack1DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack1Right,
        loadLeft: _loadAnimationAttack1Left,
        loadUp: _loadAnimationAttack1Up,
        loadDown: _loadAnimationAttack1Down,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack2DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack2Right,
        loadLeft: _loadAnimationAttack2Left,
        loadUp: _loadAnimationAttack2Up,
        loadDown: _loadAnimationAttack2Down,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack3DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack3Right,
        loadLeft: _loadAnimationAttack3Left,
        loadUp: _loadAnimationAttack3Up,
        loadDown: _loadAnimationAttack3Down,
      );

  // ============================================================================
  // ANIMATIONS - FARMING
  // ============================================================================

  static final Future<SpriteAnimation> _loadAnimationDigRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationDigDirectionalFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationDigRight,
    loadLeft: _loadAnimationDigLeft,
    loadUp: _loadAnimationDigUp,
    loadDown: _loadAnimationDigDown,
  );

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _wateringAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _wateringAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _wateringAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _wateringAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationWateringDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationWateringRight,
        loadLeft: _loadAnimationWateringLeft,
        loadUp: _loadAnimationWateringUp,
        loadDown: _loadAnimationWateringDown,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationPlaceSeedDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationPlaceSeedRight,
        loadLeft: _loadAnimationPlaceSeedLeft,
        loadUp: _loadAnimationPlaceSeedUp,
        loadDown: _loadAnimationPlaceSeedDown,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationHarvestDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestRight,
        loadLeft: _loadAnimationHarvestLeft,
        loadUp: _loadAnimationHarvestUp,
        loadDown: _loadAnimationHarvestDown,
      );

  // ============================================================================
  // DEATH MARKER
  // ============================================================================

  static final Vector2 _cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> _loadSpriteCrypt() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');

  static GameDecoration _createDeathMarker(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: _loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  // ============================================================================
  // PUBLIC CONFIGS
  // ============================================================================

  /// Configuração principal do character
  static final CharacterConfig config = CharacterConfig.player(
    size: _componentSize,
    hitbox: _hitbox,
    lighting: _lighting,
    getDeathMarker: _createDeathMarker,
    maxLife: _kMaxLife,
    baseSpeed: _kBaseSpeed,
    maxStamina: _kMaxStamina,
    maxEnergy: _kMaxEnergy,
    staminaRegenRate: _kStaminaRegenRate,
    visionRadius: _kLongVisionRadius * 0.7,
    longVisionRadius: _kLongVisionRadius,
  );

  /// Configuração de combate
  static final CombatConfig combatConfig = CombatConfig(
    primaryAttackDamage: _kPrimaryAttackDamage,
    primaryAttackStaminaCost: _kPrimaryAttackStaminaCost,
    rangedAttackDamage: _kRangedAttackDamage,
    rangedAttackStaminaCost: _kRangedAttackStaminaCost,
    attackAnimationFactory: _animationAttack1DirectionalFactory,
    comboAttackAnimationFactories: [
      _animationAttack1DirectionalFactory,
      _animationAttack2DirectionalFactory,
      _animationAttack3DirectionalFactory,
    ],
  );

  /// Configuração de farming
  static final FarmingConfig farmingConfig = FarmingConfig(
    digStaminaCost: _kDigStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
    digAnimationFactory: _animationDigDirectionalFactory,
    wateringCanAnimationFactory: _animationWateringDirectionalFactory,
    seedAnimationFactory: _animationPlaceSeedDirectionalFactory,
    harvestAnimationFactory: _animationHarvestDirectionalFactory,
  );

  /// Animações de movimento (para compatibilidade com Bonfire)
  static SimpleDirectionAnimation get walkAnimation =>
      _animationWalkDirectional;
  static SimpleDirectionAnimation get runAnimation => _animationRunDirectional;

  // lib/gameplay/characters/player/demo/demo_player_def.dart (ADICIONAR)

  // Adicione essas constantes no DemoPlayerDef:

  static const double _kMiningStaminaCost = 5.0;
  static const double _kPickaxeDamageToRock = 10.0;

  // Adicione esse asset path:
  static const String _miningAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_pickaxe/character_body/character_tools_pickaxe_body_light_7.png';

  // Adicione essas animações:
  static final Future<SpriteAnimation> _loadAnimationMiningRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _miningAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationMiningLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _miningAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationMiningUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _miningAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationMiningDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: _miningAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationMiningDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationMiningRight,
        loadLeft: _loadAnimationMiningLeft,
        loadUp: _loadAnimationMiningUp,
        loadDown: _loadAnimationMiningDown,
      );

  // Adicione no final do arquivo:
  static const double runSpeedMultiplier = 1.4;

  /// Configuração de mining
  static final MiningConfig miningConfig = MiningConfig(
    pickaxeStaminaCost: _kMiningStaminaCost,
    pickaxeDamageToRock: _kPickaxeDamageToRock,
    pickaxeAnimationFactory: _animationMiningDirectionalFactory,
  );
}
