import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';

final class FarmerPlayerConfig {
  FarmerPlayerConfig._();

  static const double kLife = CharacterConstants.kLifeExtraLarge;

  static double kSpeed = CharacterConstants.kSpeedFast;

  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const int kToolActionEnergyCost = 2;

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;

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
      'Modern_Farm_v1.2/16x16/Characters_16x16/Farmer_1_16x16.png';
  static double farmerPlayerRightFrameX = 0;
  static double farmerPlayerUpFrameX = 6;
  static double farmerPlayerLeftFrameX = 12;
  static double farmerPlayerDownFrameX = 18;

  static double farmerPlayerIdleFrameY = 2;
  static double farmerPlayerWalkFrameY = 4; // TODO(Kevin): fix it to be 3

  static Future<SpriteAnimation> _loadAnimationFarmerPlayerByFramePosition(
    double framePositionX,
    double framePositionY,
  ) => SpriteAnimation.load(
    farmerPlayerAssetPath,
    SpriteAnimationConfigHelper.createStandardData(
      amount: 6,
      textureSize: FarmerPlayerConfig.textureSize,
      texturePosition: Vector2(
        framePositionX * FarmerPlayerConfig.textureSize.x,
        32 + (framePositionY * 32),
      ),
    ),
  );

  static final Future<SpriteAnimation> loadAnimationIdleRight =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerRightFrameX,
        farmerPlayerIdleFrameY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerLeftFrameX,
        farmerPlayerIdleFrameY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerUpFrameX,
        farmerPlayerIdleFrameY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleDown =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerDownFrameX,
        farmerPlayerIdleFrameY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerLeftFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerRightFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerUpFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerDownFrameX,
        farmerPlayerWalkFrameY,
      );

  ///
  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerLeftFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunRight =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerRightFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunUp =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerUpFrameX,
        farmerPlayerWalkFrameY,
      );
  static final Future<SpriteAnimation> _loadAnimationRunDown =
      _loadAnimationFarmerPlayerByFramePosition(
        farmerPlayerDownFrameX,
        farmerPlayerWalkFrameY,
      );

  ///
  static final Future<SpriteAnimation> _loadAnimationAttackRight =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_right_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackLeft =
      SpriteAnimation.load(
        'new/Player/attack/player_attack_left_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackUp =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_up_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationAttackDown =
      SpriteAnimation.load(
        // TODO(Kevin): NOW - create up and down verifications
        'new/Player/attack/player_attack_down_48x48_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
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

  static final Future<SpriteAnimation> _loadAnimationShovelRight =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_right_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelLeft =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_left_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelUp =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_up_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationShovelDown =
      SpriteAnimation.load(
        'new/Player/shovel/player_shovel_down_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final _animationShovelFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationShovelRight,
    loadLeft: _loadAnimationShovelLeft,
    loadUp: _loadAnimationShovelUp,
    loadDown: _loadAnimationShovelDown,
    loadRightUp: null,
    loadRightDown: null,
    loadLeftUp: null,
    loadLeftDown: null,
  );

  static final Future<SpriteAnimation> _loadAnimationWateringCanRight =
      SpriteAnimation.load(
        'new/Player/water/player_water_right_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanLeft =
      SpriteAnimation.load(
        'new/Player/water/player_water_left_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanUp =
      SpriteAnimation.load(
        'new/Player/water/player_water_up_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final Future<SpriteAnimation> _loadAnimationWateringCanDown =
      SpriteAnimation.load(
        'new/Player/water/player_water_down_48x48_2.png',
        SpriteAnimationConfigHelper.createCustomData(
          amount: 2,
          textureSize: textureSize,
          stepTime: SpriteAnimationConstants.kStepTimeSlow,
        ),
      );

  static final _animationWateringCanFactory = DDAnimationDirectionalFactory(
    loadRight: _loadAnimationWateringCanRight,
    loadLeft: _loadAnimationWateringCanLeft,
    loadUp: _loadAnimationWateringCanUp,
    loadDown: _loadAnimationWateringCanDown,
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

  static final _animationPlaceSeedFactory = DDAnimationDirectionalFactory(
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

  static final _animationHarvestBasketFactory = DDAnimationDirectionalFactory(
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
    hitbox: FarmerPlayerConfig._hitbox,
    lighting: FarmerPlayerConfig._lighting,
    getDeathMarker: (position) =>
        FarmerPlayerConfig._createDeathMarker(position),
    animationWalkDirectional: FarmerPlayerConfig._animationWalkDirectional,
    animationRunDirectional: FarmerPlayerConfig._animationRunDirectional,
    animationAttackDirectionalFactory:
        FarmerPlayerConfig._animationAttackDirectionalFactory,
    animationShovelFactory: FarmerPlayerConfig._animationShovelFactory,
    animationWateringCanFactory:
        FarmerPlayerConfig._animationWateringCanFactory,
    animationPlaceSeedFactory: FarmerPlayerConfig._animationPlaceSeedFactory,
    animationHarvestBasketFactory:
        FarmerPlayerConfig._animationHarvestBasketFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
