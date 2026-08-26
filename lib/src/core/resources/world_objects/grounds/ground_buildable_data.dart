import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// Data of every buildable terrain tile — port of `GroundBuildableData.cs`
/// (faithful slice: terrain behavior + the rule-33 farming knobs; elevation
/// drops and tilemap placement arrive with the world renderer).
///
/// Rule 33: `farmTools` names the tools that TRANSFORM this ground (legal under
/// anyone's feet); destruction tools are content on the item side. Which verb a
/// tool performs is content, never a new `if` in a tool script.
class GroundBuildableData extends IWorldObjectData {
  GroundBuildableData({
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
    super.drops,
    super.currentHealth,
    this.zIndexOffset = 0,
    this.isDenseTerrain = false,
    this.blocksProps = false,
    this.allowsResourceSpawning = false,
    this.speedModifier = 1.0,
    this.farmPropId = '',
    this.farmTools = const <ToolType>[],
    this.floatsOnWater = false,
  }) {
    _validate();
  }

  GroundBuildableData.fromReader(super.reader)
      : zIndexOffset = reader.intOr('z_index_offset', 0),
        isDenseTerrain =
            reader.boolOr('is_dense_terrain', declaredDefault: false),
        blocksProps = reader.boolOr('blocks_props', declaredDefault: false),
        allowsResourceSpawning =
            reader.boolOr('allows_resource_spawning', declaredDefault: false),
        speedModifier = reader.doubleOr('speed_modifier', 1),
        farmPropId = reader.stringOr('farm_prop_id', ''),
        farmTools = reader.enumListOr('farm_tools', ToolType.values),
        floatsOnWater =
            reader.boolOr('floats_on_water', declaredDefault: false),
        super.fromReader() {
    _validate();
  }

  factory GroundBuildableData.fromJson(Map<String, Object?> json) =>
      GroundBuildableData.fromReader(JsonReader(json, 'GroundBuildableData'));

  void _validate() {
    assert(speedModifier >= 0, '[$runtimeType($id)] speed_modifier negative');
    assert(
      farmPropId.isEmpty || farmTools.isNotEmpty,
      '[$runtimeType($id)] farm_prop_id set but farm_tools empty — '
      'no tool could ever transform this ground (rule 33)',
    );
  }

  final int zIndexOffset;
  final bool isDenseTerrain;
  final bool blocksProps;
  final bool allowsResourceSpawning;

  /// Multiplies actor move speed while standing on this ground.
  final double speedModifier;

  /// The prop spawned ON TOP of this tile when a farm tool transforms it.
  final String farmPropId;

  /// The tools that TRANSFORM this ground (rule 33).
  final List<ToolType> farmTools;
  final bool floatsOnWater;

  @override
  GroundBuildableData clone() => GroundBuildableData(
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
        drops: List<DropEntry>.of(drops),
        currentHealth: currentHealth,
        zIndexOffset: zIndexOffset,
        isDenseTerrain: isDenseTerrain,
        blocksProps: blocksProps,
        allowsResourceSpawning: allowsResourceSpawning,
        speedModifier: speedModifier,
        farmPropId: farmPropId,
        farmTools: List<ToolType>.of(farmTools),
        floatsOnWater: floatsOnWater,
      );
}
