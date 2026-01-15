import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class SkeletonEnemyDef {
  SkeletonEnemyDef._();

  static const double fixedLifeBarWidth =
      CharacterConstants.fixedLifeBarWidthMedium;
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
  static const double _attackFrameRightY = 0;
  static const double _attackFrameLeftY = TileConstants.kCharacterDimensionSmallburg;
  static const double _attackFrameUpY =
      TileConstants.kCharacterDimensionSmallburg * 2;
  static const double _attackFrameDownY =
      TileConstants.kCharacterDimensionSmallburg * 3;

  static const String idleAssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/idle/skeleton_idle_2.png';
  static const String walkAssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/walk/skeleton_walk_4.png';
  static const String attack1AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/assets/enemies/skeletons/skeleton/attack/skeleton_attack.png';

  static const int _x2 = 2;
  static const int _x4 = 4;
  static const int _x6 = 6;
  static const int _x7 = 7;
  static const int _x10 = 10;
  static const double _frameRightY = 0;
  static const double _frameLeftY = TileConstants.kCharacterDimensionSmallburg * 1;
  static const double _frameDownY = TileConstants.kCharacterDimensionSmallburg * 2;
  static const double _frameUpY = TileConstants.kCharacterDimensionSmallburg * 3;

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
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameDownY,
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
        assetPath: attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _attackFrameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackLeft() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _attackFrameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackUp() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _attackFrameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttackDown() =>
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack1AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: TileConstants.tileSizeSmallburg,
        totalFrames: _attackFrameCount,
        framePositionX: 0,
        framePositionY: _attackFrameDownY,
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
