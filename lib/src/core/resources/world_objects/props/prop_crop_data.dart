import 'package:dawnforge/src/core/domain/farming/crop_rules.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// A prop that has a LIFE — the Dart port of `PropCropData.cs`: the eleven
/// authored fields that say how a crop is planted, grows and is harvested,
/// the sparse per-stage drop table, and the one piece of state this slice
/// needs, which stage it is at.
///
/// This is FP4.4's minimal core, pulled forward because the FP4 gate could
/// not be reached without it: a palm's logs live in its stage table and
/// nowhere else, so until a crop knew its stage no tree in the world gave
/// wood. What is NOT here is growth itself — the day tick, watering, the
/// death countdown, the recurrent return — which arrives with the time
/// system. A wild crop surfaces at a stage and stays there.
///
/// PORT DELTA — `stage_occlusion_configs`, `destruction_confirmation` and the
/// per-stage `is_flat` / `hides_actors` overrides are render- and UI-side and
/// unported; the authored flags mean what they say at every stage until then.
/// `PropSoilData` (the spec's parent, tilled/watered state) is skipped in the
/// hierarchy: this extends [PropData] directly, and the soil half slots in
/// between when watering is ported.
class PropCropData extends PropData {
  PropCropData({
    required super.id,
    super.displayNameKey,
    super.descriptionKey,
    this.groundStage = CropStage.planted,
    this.hasGroundStage = true,
    this.isWaterable = true,
    this.peakStage = CropStage.harvestable,
    this.isImmortal = false,
    this.daysToDieIfUnharvested = 2,
    this.isHandHarvestable = true,
    this.isRecurrent = false,
    this.recurrentReturnStage = CropStage.flowering,
    this.variantsPerStage = 1,
    this.hidesActorsAtStage = CropStage.harvestable,
    this.stageDropConfigs = const <CropStage, List<DropEntry>>{},
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
    super.hasIdleSway,
    super.isPushable,
    super.weight,
    super.heatRadius,
    super.respawnTime,
    super.hidesActors,
  }) {
    _validate();
  }

  PropCropData.fromReader(super.reader)
      : groundStage = _stage(reader, 'ground_stage', CropStage.planted),
        hasGroundStage =
            reader.boolOr('has_ground_stage', declaredDefault: true),
        isWaterable = reader.boolOr('is_waterable', declaredDefault: true),
        peakStage = _stage(reader, 'peak_stage', CropStage.harvestable),
        isImmortal = reader.boolOr('is_immortal', declaredDefault: false),
        daysToDieIfUnharvested = reader.intOr('days_to_die_if_unharvested', 2),
        isHandHarvestable =
            reader.boolOr('is_hand_harvestable', declaredDefault: true),
        isRecurrent = reader.boolOr('is_recurrent', declaredDefault: false),
        recurrentReturnStage =
            _stage(reader, 'recurrent_return_stage', CropStage.flowering),
        variantsPerStage = reader.intOr('variants_per_stage', 1),
        hidesActorsAtStage =
            _stage(reader, 'hides_actors_at_stage', CropStage.harvestable),
        stageDropConfigs = _stageTables(reader),
        super.fromReader() {
    _validate();
  }

  factory PropCropData.fromJson(Map<String, Object?> json) =>
      PropCropData.fromReader(JsonReader(json, 'PropCropData'));

  static CropStage _stage(JsonReader reader, String key, CropStage fallback) =>
      reader.enumOr(key, CropStage.values, fallback);

  /// The pack keys the table by stage NAME (`BUDDING:`), and each value is a
  /// plain loot table in the same shape as `drops`. An unknown key is a typo
  /// in the pack and crashes here rather than becoming a stage nothing
  /// reaches (rule 5).
  static Map<CropStage, List<DropEntry>> _stageTables(JsonReader reader) {
    final raw = reader.mapOr('stage_drop_configs');
    final tables = <CropStage, List<DropEntry>>{};
    for (final entry in raw.entries) {
      final stage = JsonReader(<String, Object?>{'stage': entry.key}, 'PropCropData')
          .enumOr('stage', CropStage.values, CropStage.dead);
      final lines = entry.value;
      if (lines is! List) {
        throw StateError(
          '[PropCropData] stage_drop_configs.${entry.key} is not a list',
        );
      }
      tables[stage] = lines.map((line) {
        if (line is! Map<String, Object?>) {
          throw StateError(
            '[PropCropData] stage_drop_configs.${entry.key} has a non-object line',
          );
        }
        return DropEntry.fromJson(line);
      }).toList();
    }
    return tables;
  }

  void _validate() {
    // The spec's constructor throws for both of these, and both are content
    // bugs with a delayed symptom: a mortal crop with no countdown dies the
    // day it peaks, and a recurrent one that returns AT its peak never leaves
    // it.
    assert(
      daysToDieIfUnharvested > 0 || isImmortal,
      '[$runtimeType($id)] days_to_die_if_unharvested must be > 0 unless '
      'is_immortal',
    );
    assert(
      !isRecurrent || recurrentReturnStage.index < peakStage.index,
      '[$runtimeType($id)] recurrent_return_stage must be below peak_stage',
    );
    assert(
      peakStage != CropStage.dead,
      '[$runtimeType($id)] peak_stage cannot be DEAD',
    );
    assert(variantsPerStage > 0, '[$runtimeType($id)] variants_per_stage');
    assert(
      _currentStage.index <= peakStage.index,
      '[$runtimeType($id)] current_stage past peak_stage',
    );
  }

  // --- PLANTING ---
  /// The stage that leaves soil under the crop; below it the tile shows bare
  /// ground.
  final CropStage groundStage;
  final bool hasGroundStage;

  // --- GROWTH ---
  /// Needs water to grow and leaves soil when harvested; a tree does neither.
  final bool isWaterable;

  /// Where growth stops. A wild crop surfaces anywhere up to here.
  final CropStage peakStage;

  /// Never dies of neglect (a palm, a herb patch).
  final bool isImmortal;
  final int daysToDieIfUnharvested;

  // --- HARVEST ---
  final bool isHandHarvestable;
  final bool isRecurrent;
  final CropStage recurrentReturnStage;

  // --- PER-STAGE ---
  final int variantsPerStage;
  final CropStage hidesActorsAtStage;

  /// What a stage gives on top of [drops], sparse: a stage not listed gives
  /// nothing stage-specific, and does NOT fall back to [drops] — that list
  /// is rolled by the plain drop component every prop already owns, and
  /// handing it out here is how one list got rolled twice.
  final Map<CropStage, List<DropEntry>> stageDropConfigs;

  /// The stage-specific half of the loot at [stage]. Empty is the honest
  /// answer for a stage the pack did not write a table for.
  List<DropEntry> stageEntries(CropStage stage) =>
      stageDropConfigs[stage] ?? const <DropEntry>[];

  /// How many rows of the sheet one variant block spans.
  int get realStageCount =>
      CropRules.realStageCount(peakStage, isImmortal: isImmortal);

  // ---------------------------------------------------------------------------
  // RUNTIME STATE (rule 8: it lives here)
  // ---------------------------------------------------------------------------

  CropStage _currentStage = CropStage.planted;
  int _daysUnharvested = 0;

  /// Where this crop is in its life.
  CropStage get currentStage => _currentStage;

  /// Days spent at the peak without being taken. Zero until growth is ported.
  int get daysUnharvested => _daysUnharvested;

  /// Puts the crop at [stage]. Asserted within `[PLANTED, peak]`, as the
  /// spec's `set_growth_stage` does: DEAD is reached by dying, never set.
  void setStage(CropStage stage) {
    assert(
      stage.index <= peakStage.index,
      '[$runtimeType($id)] stage $stage past peak_stage $peakStage',
    );
    _currentStage = stage;
  }

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        'current_stage': _currentStage.index,
        'days_unharvested': _daysUnharvested,
      };

  @override
  PropCropData clone() => PropCropData(
        id: id,
        displayNameKey: displayNameKey,
        descriptionKey: descriptionKey,
        groundStage: groundStage,
        hasGroundStage: hasGroundStage,
        isWaterable: isWaterable,
        peakStage: peakStage,
        isImmortal: isImmortal,
        daysToDieIfUnharvested: daysToDieIfUnharvested,
        isHandHarvestable: isHandHarvestable,
        isRecurrent: isRecurrent,
        recurrentReturnStage: recurrentReturnStage,
        variantsPerStage: variantsPerStage,
        hidesActorsAtStage: hidesActorsAtStage,
        // The entries are immutable definitions; the MAP and its lists are
        // copied so an instance never shares the container its tables live in.
        stageDropConfigs: <CropStage, List<DropEntry>>{
          for (final entry in stageDropConfigs.entries)
            entry.key: List<DropEntry>.of(entry.value),
        },
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
      )
        .._currentStage = _currentStage
        .._daysUnharvested = _daysUnharvested;
}
