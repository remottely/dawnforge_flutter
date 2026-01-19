import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class SkeletonEnemyDef {
  SkeletonEnemyDef._();

  static const double kFixedLifeBarWidth =
      CharacterConstants.kFixedLifeBarWidthMedium;
  static final Vector2 fixedLifeBarOffset =
      CharacterConstants.fixedLifeBarOffsetLarge;

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageMedium;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalMedium;

  static const double kLife = CharacterConstants.kLifeMedium;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static final Vector2 textureSize = TileConstants.tileSizeSmallburg;
  static final Vector2 componentSize = textureSize;

  static const int _attackFrameCount = 6;
  static const double _kAttackFrameRightY = 0;
  static const double _kAttackFrameLeftY =
      TileConstants.kCharacterDimensionSmallburg;
  static const double _kAttackFrameUpY =
      TileConstants.kCharacterDimensionSmallburg * 2;
  static const double _kAttackFrameDownY =
      TileConstants.kCharacterDimensionSmallburg * 3;

  static const String kIdleAssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/idle/skeleton_idle_2.png';
  static const String kWalkAssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/walk/skeleton_walk_4.png';
  static const String kAttack1AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/attack/skeleton_attack.png';

  static const int _x2 = 2;
  static const int _x4 = 4;
  static const double _kFrameRightY = 0;
  static const double _kFrameLeftY =
      TileConstants.kCharacterDimensionSmallburg * 1;
  static const double _kFrameDownY =
      TileConstants.kCharacterDimensionSmallburg * 2;
  static const double _kFrameUpY =
      TileConstants.kCharacterDimensionSmallburg * 3;

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kIdleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _kFrameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kIdleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _kFrameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kIdleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _kFrameUpY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kIdleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _kFrameDownY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kWalkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _kFrameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kWalkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _kFrameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kWalkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _kFrameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kWalkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _kFrameDownY,
      );

  static SimpleDirectionAnimation createAnimationWalkDirectional() =>
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

  static RectangleHitbox createHitbox() => HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 26,
    top: 29,
    right: 26,
    bottom: 25,
  );

  static Future<SpriteAnimation> _loadAnimationAttackRight() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kAttack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _kAttackFrameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackLeft() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kAttack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _kAttackFrameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackUp() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kAttack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _kAttackFrameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackDown() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: kAttack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _kAttackFrameDownY,
      );
  static animationAttack1DirectionalFactory() => DDAnimationDirectionalFactory(
    loadRight: _loadAnimationAttackRight(),
    loadLeft: _loadAnimationAttackLeft(),
    loadUp: _loadAnimationAttackUp(),
    loadDown: _loadAnimationAttackDown(),
  );
  static List<DDAnimationDirectionalFactory> comboAttackAnimationFactories() =>
      [animationAttack1DirectionalFactory()];
}
