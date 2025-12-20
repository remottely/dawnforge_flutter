import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

final class FarmerPlayerDef {
  FarmerPlayerDef._();

  static const double kLife = CharacterConstants.kLifeExtraLarge;

  static double kSpeed = CharacterConstants.kSpeedFast;

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

  static const int _kShovelStaminaCost = 5;
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
    shovelStaminaCost: _kShovelStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
  );

  static final Vector2 textureSize = TileDef.tileSizeFarmer;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 20.0,
    top: 22.0,
    right: 20.0,
    bottom: 16.0,
  );

  static String assetPath =
      'tiled/Modern_Farm_v1.2/Characters/Farmer_1_16x16.png';

  static const int _x6 = 6;
  static const double _frameRightX6 = _x6 * 0.0;
  static const double _frameUpX6 = _x6 * 1.0;
  static const double _frameLeftX6 = _x6 * 2.0;
  static const double _frameDownX6 = _x6 * 3.0;

  static const int _x9 = 9;
  static const double _frameRightX9 = _x9 * 0.0;
  static const double _frameUpX9 = _x9 * 1.0;
  static const double _frameLeftX9 = _x9 * 2.0;
  static const double _frameDownX9 = _x9 * 3.0;

  static const int _x10 = 10;
  static const double _frameRightX10 = _x10 * 0.0;
  static const double _frameUpX10 = _x10 * 1.0;
  static const double _frameLeftX10 = _x10 * 2.0;
  static const double _frameDownX10 = _x10 * 3.0;

  static const int _x14 = 14;
  static const double _frameRightX14 = _x14 * 0.0;
  static const double _frameUpX14 = _x14 * 1.0;
  static const double _frameLeftX14 = _x14 * 2.0;
  static const double _frameDownX14 = _x14 * 3.0;

  static const double _frameIdleY = 2.0;
  static const double _frameWalkY = 4.0;
  static const double _frameHarvestY = 6.0;
  static const double _framePlaceSeedY = _frameHarvestY;
  static const double _frameDigY = 10.0;
  static const double _frameWateringY = 14.0;
  static const double _frameChoppingY = 18.0;
  static const double _frameAttackY = _frameChoppingY;

  static final int _skipFirstFramesX6 = 6;

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameRightX6,
        framePositionY: _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameLeftX6,
        framePositionY: _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameUpX6,
        framePositionY: _frameIdleY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameDownX6,
        framePositionY: _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameLeftX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameRightX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameUpX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameDownX6,
        framePositionY: _frameWalkY,
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
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameLeftX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameRightX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: _frameUpX6,
        framePositionY: _frameWalkY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 6,
        framePositionX: _frameDownX6,
        framePositionY: _frameWalkY,
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
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameRightX9,
        framePositionY: _frameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameLeftX9,
        framePositionY: _frameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameUpX9,
        framePositionY: _frameHarvestY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameDownX9,
        framePositionY: _frameHarvestY,
      );

  static final _animationHarvestDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestRight,
        loadLeft: _loadAnimationHarvestLeft,
        loadUp: _loadAnimationHarvestUp,
        loadDown: _loadAnimationHarvestDown,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameRightX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameLeftX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameUpX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
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
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameRightX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameLeftX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        skipFirstFrames: _skipFirstFramesX6,
        framePositionX: _frameUpX10,
        framePositionY: _frameAttackY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
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
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final Future<SpriteAnimation> _loadAnimationDigRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameRightX9,
        framePositionY: _frameDigY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameLeftX9,
        framePositionY: _frameDigY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameUpX9,
        framePositionY: _frameDigY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: _x9,
        framePositionX: _frameDownX9,
        framePositionY: _frameDigY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final _animationDigDirectionalFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationDigRight,
    loadLeft: _loadAnimationDigLeft,
    loadUp: _loadAnimationDigUp,
    loadDown: _loadAnimationDigDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  // static final Future<SpriteAnimation> _loadAnimationWateringRight =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x14,
  //       framePositionX: _frameRightX14,
  //       framePositionY: _frameWateringY,
  //       framePositionXPadding: -8,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationWateringLeft =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x14,
  //       framePositionX: _frameLeftX14,
  //       framePositionY: _frameWateringY,
  //       framePositionXPadding: 8,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationWateringUp =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x14,
  //       framePositionX: _frameUpX14,
  //       framePositionY: _frameWateringY,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationWateringDown =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x14,
  //       framePositionX: _frameDownX14,
  //       framePositionY: _frameWateringY,
  //       framePositionYPadding: -16,
  //     );

  static final _animationWateringDirectionalFactory =
      DDAnimationDirectionalFactory(
        // TODO(Kevin): change all waterincan names to watering
        loadRight: _loadAnimationWateringRight,
        loadLeft: _loadAnimationWateringLeft,
        loadUp: _loadAnimationWateringUp,
        loadDown: _loadAnimationWateringDown,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  // static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x6,
  //       framePositionX: _frameRightX9,
  //       framePositionY: _framePlaceSeedY,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x6,
  //       framePositionX: _frameLeftX9,
  //       framePositionY: _framePlaceSeedY,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x6,
  //       framePositionX: _frameUpX9,
  //       framePositionY: _framePlaceSeedY,
  //     );

  // static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
  //     SpriteAnimationConfigHelper.loadAnimationFromSheet(
  //       assetPath: assetPath,
  //       textureSize: textureSize,
  //       totalFrames: _x6,
  //       framePositionX: _frameDownX9,
  //       framePositionY: _framePlaceSeedY,
  //     );

  static final _animationPlaceSeedDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationPlaceSeedRight,
        loadLeft: _loadAnimationPlaceSeedLeft,
        loadUp: _loadAnimationPlaceSeedUp,
        loadDown: _loadAnimationPlaceSeedDown,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final LightingConfig _lighting = LightingConfig(
    radius: TileDef.kTileDimensionLarge,
    blurBorder: TileDef.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 _cryptComponentSize = TileDef.tileSizeStandard;

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
    hitbox: FarmerPlayerDef._hitbox,
    lighting: FarmerPlayerDef._lighting,
    getDeathMarker: (position) => FarmerPlayerDef._createDeathMarker(position),
    animationWalkDirectional: FarmerPlayerDef._animationWalkDirectional,
    animationRunDirectional: FarmerPlayerDef._animationRunDirectional,
    animationAttackDirectionalFactory:
        FarmerPlayerDef._animationAttackDirectionalFactory,
    animationShovelFactory: FarmerPlayerDef._animationDigDirectionalFactory,
    animationWateringCanFactory:
        FarmerPlayerDef._animationWateringDirectionalFactory,
    animationPlaceSeedFactory:
        FarmerPlayerDef._animationPlaceSeedDirectionalFactory,
    animationHarvestFactory:
        FarmerPlayerDef._animationHarvestDirectionalFactory,
  );

  /// TODO(Kevin): remove this test animations
  static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameRightX9,
        framePositionY: _framePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameLeftX9,
        framePositionY: _framePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameUpX9,
        framePositionY: _framePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameDownX9,
        framePositionY: _framePlaceSeedY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameRightX14,
        framePositionY: _frameWateringY,
        framePositionXPadding: -8,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameLeftX14,
        framePositionY: _frameWateringY,
        framePositionXPadding: 8,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameUpX14,
        framePositionY: _frameWateringY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      SpriteAnimationConfigHelper.loadAnimationFromSheet(
        assetPath: assetPath,
        textureSize: textureSize,
        totalFrames: 2,
        framePositionX: _frameDownX14,
        framePositionY: _frameWateringY,
        framePositionYPadding: -16,
      );
}

// - new/Player/axe/
// - new/Player/pickaxe/
