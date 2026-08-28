import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// Data of every prop (trees, rocks, furniture) — port of `PropData.cs`
/// (faithful slice: physicality + ambience; workstations, drops and placement
/// rules arrive with their systems).
class PropData extends IWorldObjectData {
  PropData({
    required super.id,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.tier,
    super.allowedTools,
    super.groups,
    super.gridWidth,
    super.gridHeight,
    super.isFlat,
    super.hasCollision,
    super.allowsActorOverlap,
    super.isProjectilePassable,
    super.baseMaxHealth,
    super.drops,
    super.inventorySize,
    super.currentHealth,
    this.hasIdleSway = false,
    this.isPushable = false,
    this.weight = 1.0,
    this.heatRadius = 0.0,
    this.respawnTime = 0.0,
    this.hidesActors = false,
  }) {
    _validate();
  }

  PropData.fromReader(super.reader)
      : hasIdleSway = reader.boolOr('has_idle_sway', declaredDefault: false),
        isPushable = reader.boolOr('is_pushable', declaredDefault: false),
        weight = reader.doubleOr('weight', 1),
        heatRadius = reader.doubleOr('heat_radius', 0),
        respawnTime = reader.doubleOr('respawn_time', 0),
        hidesActors = reader.boolOr('hides_actors', declaredDefault: false),
        super.fromReader() {
    _validate();
  }

  factory PropData.fromJson(Map<String, Object?> json) =>
      PropData.fromReader(JsonReader(json, 'PropData'));

  void _validate() {
    // 0 is legal: weightless props exist (crops).
    assert(weight >= 0, '[$runtimeType($id)] weight negative');
    assert(heatRadius >= 0, '[$runtimeType($id)] heat_radius');
    assert(respawnTime >= 0, '[$runtimeType($id)] respawn_time');
  }

  final bool hasIdleSway;
  final bool isPushable;
  final double weight;

  /// Tiles warmed around this prop (0 = no heat source).
  final double heatRadius;

  /// Seconds until a harvested prop regrows (0 = never).
  final double respawnTime;
  final bool hidesActors;

  @override
  PropData clone() => PropData(
        id: id,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        tier: tier,
        allowedTools: List<ToolType>.of(allowedTools),
        groups: List<String>.of(groups),
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        isFlat: isFlat,
        hasCollision: hasCollision,
        allowsActorOverlap: allowsActorOverlap,
        isProjectilePassable: isProjectilePassable,
        baseMaxHealth: baseMaxHealth,
        drops: List<DropEntry>.of(drops),
        inventorySize: inventorySize,
        currentHealth: currentHealth,
        hasIdleSway: hasIdleSway,
        isPushable: isPushable,
        weight: weight,
        heatRadius: heatRadius,
        respawnTime: respawnTime,
        hidesActors: hidesActors,
      );
}
