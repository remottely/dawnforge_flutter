import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// Data of the two EMPTY tiles — what remains where no buildable ground
/// stands: water (the endless sea) and cliff (a hole enclosed by land).
/// Port of `GroundEmptyData.cs`.
///
/// The generator emits these for level-0 tiles; destruction leaves one
/// behind (FP4). Neither is drawn by the chunk renderer — water is the
/// world background, a cliff hole shows the background through it.
class GroundEmptyData extends GroundBuildableData {
  GroundEmptyData({
    required super.id,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.groups,
    super.gridWidth,
    super.gridHeight,
    super.isFlat,
    super.hasCollision,
    super.allowsActorOverlap,
    super.isProjectilePassable,
    super.baseMaxHealth,
    super.currentHealth,
    super.zIndexOffset,
    super.isDenseTerrain,
    super.blocksProps,
    super.allowsResourceSpawning,
    super.speedModifier,
    super.farmPropId,
    super.farmTools,
    super.floatsOnWater,
    this.isPassable = false,
    this.isWater = false,
  });

  GroundEmptyData.fromReader(super.reader)
      : isPassable = reader.boolOr('is_passable', declaredDefault: false),
        isWater = reader.boolOr('is_water', declaredDefault: false),
        super.fromReader();

  factory GroundEmptyData.fromJson(Map<String, Object?> json) =>
      GroundEmptyData.fromReader(JsonReader(json, 'GroundEmptyData'));

  /// False blocks pathfinding — water and cliff both author false.
  final bool isPassable;

  /// True: water. False: cliff (or another impassable empty).
  final bool isWater;

  @override
  GroundEmptyData clone() => GroundEmptyData(
        id: id,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        groups: List<String>.of(groups),
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        isFlat: isFlat,
        hasCollision: hasCollision,
        allowsActorOverlap: allowsActorOverlap,
        isProjectilePassable: isProjectilePassable,
        baseMaxHealth: baseMaxHealth,
        currentHealth: currentHealth,
        zIndexOffset: zIndexOffset,
        isDenseTerrain: isDenseTerrain,
        blocksProps: blocksProps,
        allowsResourceSpawning: allowsResourceSpawning,
        speedModifier: speedModifier,
        farmPropId: farmPropId,
        farmTools: List<ToolType>.of(farmTools),
        floatsOnWater: floatsOnWater,
        isPassable: isPassable,
        isWater: isWater,
      );
}
