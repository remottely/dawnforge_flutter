import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
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
  static const int _kHarvestBasketStaminaCost = 5;

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
    harvestBasketStaminaCost: _kHarvestBasketStaminaCost,
  );

  static final Vector2 textureSize = TileConstants.tileSizeFarmer;

  static final Vector2 componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 20.0,
    top: 22.0,
    right: 20.0,
    bottom: 16.0,
  );

  static String farmerPlayerAssetPath =
      'tiled/Modern_Farm_v1.2/Characters/Farmer_1_16x16.png';

  static const _x6 = 6;
  static const _frameRightX6 = _x6 * 0.0;
  static const _frameUp6 = _x6 * 1.0;
  static const _frameLeftX6 = _x6 * 2.0;
  static const _frameDownX6 = _x6 * 3.0;

  static const _x9 = 9;
  static const _frameRightX9 = _x9 * 0.0;
  static const _frameUpX9 = _x9 * 1.0;
  static const _frameLeftX9 = _x9 * 2.0;
  static const _frameDownX9 = _x9 * 3.0;

  static const _x10 = 10;
  static const _frameRightX10 = _x10 * 0.0;
  static const _frameUpX10 = _x10 * 1.0;
  static const _frameLeftX10 = _x10 * 2.0;
  static const _frameDownX10 = _x10 * 3.0;

  static const _x14 = 14;
  static const _frameRightX14 = _x14 * 0.0;
  static const _frameUpX14 = _x14 * 1.0;
  static const _frameLeftX14 = _x14 * 2.0;
  static const _frameDownX14 = _x14 * 3.0;

  static const _frameIdleY = 2.0;
  static const _frameWalkY = 4.0;
  static const _frameHarvestY = 6.0;
  static const _frameDigY = 10.0;
  static const _frameWateringY = 14.0;
  static const _frameChoppingY = 18.0;
  static const _frameAttackY = _frameChoppingY;
  
  static final int skipFrameX6 = 6;

  static Future<SpriteAnimation> _loadAnimationFarmerPlayerByFramePosition(
    double framePositionYPadding,
    int amount,
    double framePositionXPadding,
    double framePositionX,
    double framePositionY,
  ) => SpriteAnimation.load(
    farmerPlayerAssetPath,
    SpriteAnimationConfigHelper.createStandardData(
      amount: amount,
      textureSize: FarmerPlayerDef.textureSize,
      texturePosition: Vector2(
        framePositionXPadding +
            (framePositionX * FarmerPlayerDef.textureSize.x),
        framePositionYPadding + 32 + (framePositionY * 32),
      ),
    ),
  );

  static final Future<SpriteAnimation> loadAnimationIdleRight =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameRightX6,
        _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameLeftX6,
        _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameUp6,
        _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleDown =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameDownX6,
        _frameIdleY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameLeftX6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameRightX6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameUp6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameDownX6,
        _frameWalkY,
      );

  ///
  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameLeftX6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunRight =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameRightX6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunUp =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x6,
        0,
        _frameUp6,
        _frameWalkY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunDown =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        6,
        0,
        _frameDownX6,
        _frameWalkY,
      );

  // ///
  // static final Future<SpriteAnimation> _loadAnimationAttackRight =
  //     SpriteAnimation.load(
  //       'new/Player/attack/player_attack_right_48x48_4.png',
  //       SpriteAnimationConfigHelper.createStandardData(
  //         amount: 4,
  //         textureSize: textureSize,
  //       ),
  //     );

  // static final Future<SpriteAnimation> _loadAnimationAttackLeft =
  //     SpriteAnimation.load(
  //       'new/Player/attack/player_attack_left_48x48_4.png',
  //       SpriteAnimationConfigHelper.createStandardData(
  //         amount: 4,
  //         textureSize: textureSize,
  //       ),
  //     );

  // static final Future<SpriteAnimation> _loadAnimationAttackUp =
  //     SpriteAnimation.load(
  //       // TODO(Kevin): NOW - create up and down verifications
  //       'new/Player/attack/player_attack_up_48x48_4.png',
  //       SpriteAnimationConfigHelper.createStandardData(
  //         amount: 4,
  //         textureSize: textureSize,
  //       ),
  //     );

  // static final Future<SpriteAnimation> _loadAnimationAttackDown =
  //     SpriteAnimation.load(
  //       // TODO(Kevin): NOW - create up and down verifications
  //       'new/Player/attack/player_attack_down_48x48_4.png',
  //       SpriteAnimationConfigHelper.createStandardData(
  //         amount: 4,
  //         textureSize: textureSize,
  //       ),
  //     );

  // static final _animationAttackDirectionalFactory =
  //     DDAnimationDirectionalFactory(
  //       loadRight: _loadAnimationAttackRight,
  //       loadLeft: _loadAnimationAttackLeft,
  //       loadUp: _loadAnimationAttackUp,
  //       loadDown: _loadAnimationAttackDown,
  //       loadRightUp: null,
  //       loadRightDown: null,
  //       loadLeftUp: null,
  //       loadLeftDown: null,
  //     );

  static final Future<SpriteAnimation> _loadAnimationChoppingRight =
      _loadAnimationFarmerPlayerByFramePosition(
        -6,
        _x10,
        -8,
        _frameRightX10,
        _frameChoppingY,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        -6,
        _x10,
        -8,
        _frameLeftX10,
        _frameChoppingY,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingUp =
      _loadAnimationFarmerPlayerByFramePosition(
        -4,
        _x10,
        -8,
        _frameUpX10,
        _frameChoppingY,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingDown =
      _loadAnimationFarmerPlayerByFramePosition(
        -8,
        _x10,
        -8,
        _frameDownX10,
        _frameChoppingY,
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
      _loadAnimationFarmerPlayerByFramePosition(
        -6,
        _x10 - skipFrameX6,
        -8,
        _frameRightX10 + skipFrameX6,
        _frameAttackY,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        -6,
        _x10 - skipFrameX6,
        -8,
        _frameLeftX10 + skipFrameX6,
        _frameAttackY,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      _loadAnimationFarmerPlayerByFramePosition(
        -4,
        _x10 - skipFrameX6,
        -8,
        _frameUpX10 + skipFrameX6,
        _frameAttackY,
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      _loadAnimationFarmerPlayerByFramePosition(
        -8,
        _x10 - skipFrameX6,
        -8,
        _frameDownX10 + skipFrameX6,
        _frameAttackY,
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
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x9,
        -8,
        _frameRightX9,
        _frameDigY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x9,
        -8,
        _frameLeftX9,
        _frameDigY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x9,
        -8,
        _frameUpX9,
        _frameDigY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      _loadAnimationFarmerPlayerByFramePosition(
        -4,
        _x9,
        -8,
        _frameDownX9,
        _frameDigY,
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

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x14,
        -8,
        _frameRightX14,
        _frameWateringY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x14,
        8,
        _frameLeftX14,
        _frameWateringY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      _loadAnimationFarmerPlayerByFramePosition(
        0,
        _x14,
        0,
        _frameUpX14,
        _frameWateringY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      _loadAnimationFarmerPlayerByFramePosition(
        -16,
        _x14,
        0,
        _frameDownX14,
        _frameWateringY,
      );

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

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationPlaceSeedLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      // TODO(Kevin): create dedicated up animation
      _loadAnimationPlaceSeedRight;

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      // TODO(Kevin): create dedicated down animation
      _loadAnimationPlaceSeedLeft;

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

  static final Future<SpriteAnimation>
  _loadAnimationHarvestBasketRight = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation>
  _loadAnimationHarvestBasketLeft = SpriteAnimation.load(
    // TODO(Kevin): CREATE ANIMATION
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static final Future<SpriteAnimation> _loadAnimationHarvestBasketUp =
      // TODO(Kevin): create dedicated up animation
      _loadAnimationHarvestBasketRight;

  static final Future<SpriteAnimation> _loadAnimationHarvestBasketDown =
      // TODO(Kevin): create dedicated down animation
      _loadAnimationHarvestBasketLeft;

  static final _animationHarvestBasketDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestBasketRight,
        loadLeft: _loadAnimationHarvestBasketLeft,
        loadUp: _loadAnimationHarvestBasketUp,
        loadDown: _loadAnimationHarvestBasketDown,
        loadRightUp: null,
        loadRightDown: null,
        loadLeftUp: null,
        loadLeftDown: null,
      );

  static final SimpleDirectionAnimation _animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: _loadAnimationIdleDown,
        runLeft: _loadAnimationWalkLeft,
        runRight: _loadAnimationWalkRight,
        runUp: _loadAnimationWalkUp,
        runDown: _loadAnimationWalkDown,
      );

  static final SimpleDirectionAnimation _animationRunDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: _loadAnimationIdleDown,
        // TODO(Kevin): NOW - create run animations
        runLeft: _loadAnimationRunLeft,
        runRight: _loadAnimationRunRight,
        runUp: _loadAnimationRunUp,
        runDown: _loadAnimationRunDown,
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
    animationHarvestBasketFactory:
        FarmerPlayerDef._animationHarvestBasketDirectionalFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
