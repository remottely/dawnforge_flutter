import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/lightning_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/core/utils/app_environment.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class FarmerPlayerDef {
  FarmerPlayerDef._();

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double _kRunSpeedMultiplier = 1.4;

  static const int _kPrimaryAttackStaminaCost = 1;
  static const int _kFireballAttackStaminaCost = 2;
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

  static final Vector2 textureSize = TileConstants.tileSizeFarmer;
  static final Vector2 _componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: _componentSize,
    left: 16,
    top: 23,
    right: 16,
    bottom: 16,
  );

  static String assetPath =
      'tiled/Modern_Farm_v1.2/Characters/Farmer_1_16x16.png';

  static const int _x6 = 6;
  static const double _kFrameRightX6 = _x6 * 0;
  static const double _kFrameUpX6 = _x6 * 1;
  static const double _kFrameLeftX6 = _x6 * 2;
  static const double _kFrameDownX6 = _x6 * 3;

  static const int _x9 = 9;
  static const double _kFrameRightX9 = _x9 * 0;
  static const double _kFrameUpX9 = _x9 * 1;
  static const double _kFrameLeftX9 = _x9 * 2;
  static const double _kFrameDownX9 = _x9 * 3;

  static const int _x10 = 10;
  static const double _kFrameRightX10 = _x10 * 0;
  static const double _kFrameUpX10 = _x10 * 1;
  static const double _kFrameLeftX10 = _x10 * 2;
  static const double _kFrameDownX10 = _x10 * 3;

  static const int _x14 = 14;
  static const double _kFrameRightX14 = _x14 * 0;
  static const double _kFrameUpX14 = _x14 * 1;
  static const double _kFrameLeftX14 = _x14 * 2;
  static const double _kFrameDownX14 = _x14 * 3;

  static const double _kFrameIdleY = 2;
  static const double _kFrameWalkY = 4;
  static const double _kFrameHarvestY = 6;
  static const double _kFramePlaceSeedY = _kFrameHarvestY;
  static const double _kFrameDigY = 10;
  static const double _kFrameWateringY = 14;
  static const double _kFrameChoppingY = 18;
  static const double _kFrameAttackY = _kFrameChoppingY;

  static const int _kSkipFirstFramesX6 = 6;

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameRightX6,
        framePositionY: _kFrameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameLeftX6,
        framePositionY: _kFrameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameUpX6,
        framePositionY: _kFrameIdleY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameDownX6,
        framePositionY: _kFrameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameLeftX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameRightX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameUpX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameDownX6,
        framePositionY: _kFrameWalkY,
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

  ///
  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameLeftX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameRightX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _kFrameUpX6,
        framePositionY: _kFrameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 6,
        framePositionX: _kFrameDownX6,
        framePositionY: _kFrameWalkY,
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
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameRightX9,
        framePositionY: _kFrameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameLeftX9,
        framePositionY: _kFrameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameUpX9,
        framePositionY: _kFrameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameDownX9,
        framePositionY: _kFrameHarvestY,
        framePositionYPadding: -1,
      );

  static final _animationHarvestDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestRight,
        loadLeft: _loadAnimationHarvestLeft,
        loadUp: _loadAnimationHarvestUp,
        loadDown: _loadAnimationHarvestDown,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _kFrameRightX10,
        framePositionY: _kFrameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _kFrameLeftX10,
        framePositionY: _kFrameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _kFrameUpX10,
        framePositionY: _kFrameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _kFrameDownX10,
        framePositionY: _kFrameChoppingY,
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
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _kSkipFirstFramesX6,
        framePositionX: _kFrameRightX10,
        framePositionY: _kFrameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _kSkipFirstFramesX6,
        framePositionX: _kFrameLeftX10,
        framePositionY: _kFrameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _kSkipFirstFramesX6,
        framePositionX: _kFrameUpX10,
        framePositionY: _kFrameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _kSkipFirstFramesX6,
        framePositionX: _kFrameDownX10,
        framePositionY: _kFrameAttackY,
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
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameRightX9,
        framePositionY: _kFrameDigY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameLeftX9,
        framePositionY: _kFrameDigY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameUpX9,
        framePositionY: _kFrameDigY,
        framePositionXPadding: -8,
        framePositionYPadding: -2,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _kFrameDownX9,
        framePositionY: _kFrameDigY,
        framePositionXPadding: -8,
        framePositionYPadding: -7,
      );

  static final _animationDigDirectionalFactory = DDAnimationDirectionalFactory(
    // executionStartFrame: 4,
    loadRight: _loadAnimationDigRight,
    loadLeft: _loadAnimationDigLeft,
    loadUp: _loadAnimationDigUp,
    loadDown: _loadAnimationDigDown,
  );

  // static final Future<SpriteAnimation> _loadAnimationWateringRight =
  //     SpriteAnimationConfigHelper.loadAnimationFromTextureAtlas(
  //       assetPath: assetPath,
  //       textureSize: textureSize + Vector2(4, 0),
  //       totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
  //       framePositionX: _kFrameRightX14 +4 ,
  //       framePositionY: _kFrameWateringY,
  //       framePositionXPadding: -8 - 4,
  //       framePositionYPadding: -1,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationWateringLeft =
  //     SpriteAnimationConfigHelper.loadAnimationFromTextureAtlas(
  //       assetPath: assetPath,
  //       textureSize: textureSize + Vector2(4, 0),
  //       totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
  //       framePositionX: _kFrameLeftX14 + 4,
  //       framePositionY: _kFrameWateringY,
  //       framePositionXPadding: 8 - 4,
  //       framePositionYPadding: -1,
  //     );

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
        framePositionX: _kFrameRightX14,
        framePositionY: _kFrameWateringY,
        framePositionXPadding: -8,
        framePositionYPadding: -1,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
        framePositionX: _kFrameLeftX14,
        framePositionY: _kFrameWateringY,
        framePositionXPadding: 8,
        framePositionYPadding: -1,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
        framePositionX: _kFrameUpX14,
        framePositionY: _kFrameWateringY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 2 : _x14,
        framePositionX: _kFrameDownX14,
        framePositionY: _kFrameWateringY,
        framePositionYPadding: -17,
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

  /// TODO(Kevin): remove this test animations
  static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode
            ? 2
            : 5, // TODO(Kevin): change the real value
        framePositionX: _kFrameRightX9,
        framePositionY: _kFramePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode
            ? 2
            : 5, // TODO(Kevin): change the real value
        framePositionX: _kFrameLeftX9,
        framePositionY: _kFramePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode
            ? 2
            : 5, // TODO(Kevin): change the real value
        framePositionX: _kFrameUpX9,
        framePositionY: _kFramePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasModernFarm(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode
            ? 2
            : 5, // TODO(Kevin): change the real value
        framePositionX: _kFrameDownX9,
        framePositionY: _kFramePlaceSeedY,
        framePositionYPadding: -1,
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
  ); // TODO(Kevin): add farmer death animation playonce // - new/Player/death/

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
