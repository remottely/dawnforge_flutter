import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

final class DemoPlayerDef {
  DemoPlayerDef._();

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double _kRunSpeedMultiplier = 1.4;

  static const int _kPrimaryAttackStaminaCost = 15;
  static const int _kFireballAttackStaminaCost = 10;
  static const double _kPrimaryAttackDamage = 25.0;
  static const double _kFireballAttackDamage = 10.0;

  static const int _kDigStaminaCost = 5;
  static const int _kWateringCanStaminaCost = 5;
  static const int _kSeedStaminaCost = 5;
  static const int _kHarvestStaminaCost = 5;

  static const modelConfig = DDFarmPlayerModelConfig(
    maxStamina: _kMaxStamina,
    maxEnergy: _kMaxEnergy,
    staminaRegenIncrement: _kStaminaIncrement,
    longVisionRadius: _kLongVisionRadius,
    staminaRegenDebounce: _kStaminaRegenDebounce,
    runSpeedMultiplier: _kRunSpeedMultiplier,
    primaryAttackStaminaCost: _kPrimaryAttackStaminaCost,
    rangedAttackStaminaCost: _kFireballAttackStaminaCost,
    primaryAttackDamage: _kPrimaryAttackDamage,
    rangedAttackDamage: _kFireballAttackDamage,
    digStaminaCost: _kDigStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
  );

  static const double _kLife = CharacterConstants.kLifeExtraLarge;
  static double _kBaseSpeed = CharacterConstants.kSpeedFast;

  static final Vector2 textureSize = TileConstants.tileSizeDemo;
  static final Vector2 _componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: _componentSize,
    left: 16,
    top: 23,
    right: 16,
    bottom: 16,
  );

  // static String idleAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_idle_full_light_demo_2.png';
  // static String walkAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_walk_full_light_demo.png';
  // static String runAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_run_full_light_with_dust_specs_demo.png';
  // static String digAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_shovel_full_light_demo.png';
  // static String wateringAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_watercan_full_light_demo.png';
  // static String harvestAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_hoe_full_light_demo.png';

  static String idleAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/idle/character_body/character_idle_body_light_2.png';
  static String placeSeedAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/place_seed/character_body/character_place_seed_body_light_6.png';
  static String runAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/run/character_body/character_run_body_light_with_dust_specs_4.png';
  static String chopAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_axe/character_body/character_tools_axe_body_light_7.png';
  static String harvestAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_hoe/character_body/character_tools_hoe_body_light_7.png';
  static String mineAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_pickaxe/character_body/character_tools_pickaxe_body_light_7.png';
  static String digAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_shovel/character_body/character_tools_shovel_body_light_6.png';
  static String wateringAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_watercan/character_body/character_tools_watercan_body_light_10.png';
  static String walkAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/walk/character_body/character_walk_body_light_6.png';

  static const int _x2 = 2;
  static const int _x4 = 4;
  static const int _x6 = 6;
  static const int _x7 = 7;
  static const int _x10 = 10;
  static const double _frameRightY = 0;
  static const double _frameLeftY = TileConstants.kCharacterDimensionDemo * 1;
  static const double _frameDownY = TileConstants.kCharacterDimensionDemo * 2;
  static const double _frameUpY = TileConstants.kCharacterDimensionDemo * 3;

  static const int _x9 = 9;
  static const double _frameRightX9 = _x9 * 0;
  static const double _frameUpX9 = _x9 * 1;
  static const double _frameLeftX9 = _x9 * 2;
  static const double _frameDownX9 = _x9 * 3;

  static const double _frameRightX10 = _x10 * 0;
  static const double _frameUpX10 = _x10 * 1;
  static const double _frameLeftX10 = _x10 * 2;
  static const double _frameDownX10 = _x10 * 3;

  static const double _frameHarvestY = 6;
  static const double _framePlaceSeedY = _frameHarvestY;
  static const double _frameChoppingY = 18;
  static const double _frameAttackY = _frameChoppingY;

  static const int _skipFirstFramesX6 = 6;

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
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

  static final Future<SpriteAnimation> _loadAnimationRunRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
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
        // TODO(Kevin): NOW - create run animations
        runLeft: _loadAnimationRunLeft,
        runRight: _loadAnimationRunRight,
        runUp: _loadAnimationRunUp,
        runDown: _loadAnimationRunDown,
        // runLeft: _loadAnimationHarvestLeft,
        // runRight: _loadAnimationHarvestRight,
        // runUp: _loadAnimationHarvestUp,
        // runDown: _loadAnimationHarvestDown,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
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

  static final Future<SpriteAnimation> _loadAnimationChoppingRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameRightX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameLeftX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameUpX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameDownX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -8,
      );

  static final _animationChoppingDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationChoppingRight,
        loadLeft: _loadAnimationChoppingLeft,
        loadUp: _loadAnimationChoppingUp,
        loadDown: _loadAnimationChoppingDown,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameRightX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameLeftX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameUpX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameDownX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -8,
      );

  static final _animationAttackDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttackRight,
        loadLeft: _loadAnimationAttackLeft,
        loadUp: _loadAnimationAttackUp,
        loadDown: _loadAnimationAttackDown,
      );

  static final Future<SpriteAnimation> _loadAnimationDigRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationDigDirectionalFactory = DDAnimationDirectionalFactory(
    // executionStartFrame: 4,
    loadRight: _loadAnimationDigRight,
    loadLeft: _loadAnimationDigLeft,
    loadUp: _loadAnimationDigUp,
    loadDown: _loadAnimationDigDown,
  );

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationWateringDirectionalFactory =
      DDAnimationDirectionalFactory(
        // executionStartFrame: 14,
        // TODO(Kevin): change all waterincan names to watering
        loadRight: _loadAnimationWateringRight,
        loadLeft: _loadAnimationWateringLeft,
        loadUp: _loadAnimationWateringUp,
        loadDown: _loadAnimationWateringDown,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
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

  static final LightingConfig _lighting = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 _cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> _loadSpriteCrypt() => Sprite.load(
    'gameplay/characters/player/player_crypt_1.png',
  ); // TODO(Kevin): add demo death animation playonce // - new/Player/death/

  static GameDecoration _createDeathMarker(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: _loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  static final viewConfig = DDFarmPlayerViewConfig(
    size: _componentSize,
    life: _kLife,
    baseSpeed: _kBaseSpeed,
    hitbox: _hitbox,
    lighting: _lighting,
    getDeathMarker: (position) => _createDeathMarker(position),
    animationWalkDirectional: _animationWalkDirectional,
    animationRunDirectional: _animationRunDirectional,
    animationAttackDirectionalFactory: _animationAttackDirectionalFactory,
    animationDigFactory: _animationDigDirectionalFactory,
    animationWateringCanFactory: _animationWateringDirectionalFactory,
    animationPlaceSeedFactory: _animationPlaceSeedDirectionalFactory,
    animationHarvestFactory: _animationHarvestDirectionalFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
