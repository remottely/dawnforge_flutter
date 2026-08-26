import 'package:dawnforge/src/core/resources/i_visual_object_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// Base of every placeable world object's data (Actor / Prop / Ground) — the
/// Dart port of `IWorldObjectData.cs` (faithful slice; see
/// [IVisualObjectData]'s doc for the slice discipline).
///
/// Owns the health contract: `currentHealth` is MUTABLE STATE and lives here
/// and only here (rule 8) — hosts and components read through `data`, never
/// cache. It initializes to [maxHealth], and damage/heal clamp against it.
abstract class IWorldObjectData extends IVisualObjectData {
  IWorldObjectData({
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
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.isFlat = false,
    this.hasCollision = true,
    this.allowsActorOverlap = true,
    this.isProjectilePassable = false,
    this.baseMaxHealth = EngineConstants.defaultMaxHealth,
    this.drops = const <DropEntry>[],
    this.inventorySize = 30,
    double? currentHealth,
  }) : _currentHealth = currentHealth ?? baseMaxHealth {
    _validate();
  }

  IWorldObjectData.fromReader(super.reader)
      // Authored as a [w, h] pair, like every vector in the pack.
      : gridWidth = reader.intPairOr('grid_size', (1, 1)).$1,
        gridHeight = reader.intPairOr('grid_size', (1, 1)).$2,
        isFlat = reader.boolOr('is_flat', declaredDefault: false),
        hasCollision = reader.boolOr('has_collision', declaredDefault: true),
        allowsActorOverlap =
            reader.boolOr('allows_actor_overlap', declaredDefault: true),
        isProjectilePassable =
            reader.boolOr('is_projectile_passable', declaredDefault: false),
        baseMaxHealth = reader.doubleOr(
          'base_max_health',
          EngineConstants.defaultMaxHealth,
        ),
        drops = reader.objectListOr('drops').map(DropEntry.fromJson).toList(),
        inventorySize = reader.intOr('inventory_size', 30),
        _currentHealth = 0,
        super.fromReader() {
    // Fresh content spawns at full health; a save overwrites via deserialize.
    _currentHealth = maxHealth;
    _validate();
  }

  void _validate() {
    assert(gridWidth > 0 && gridHeight > 0, '[$runtimeType($id)] grid_size');
    assert(baseMaxHealth > 0, '[$runtimeType($id)] base_max_health must be > 0');
    assert(inventorySize >= 0, '[$runtimeType($id)] inventory_size negative');
  }

  /// Footprint in tiles.
  final int gridWidth;
  final int gridHeight;
  final bool isFlat;
  final bool hasCollision;

  /// Rule 33: asked on Place (of the object placed) and Destroy (of the object
  /// destroyed) — and by no third verb.
  final bool allowsActorOverlap;
  final bool isProjectilePassable;

  final double baseMaxHealth;

  /// The loot table rolled when this object dies or is harvested — immutable
  /// definition data (`DropEntry` lines), never mutable state, so it is not
  /// part of [serialize]. Empty is a legitimate authored answer: the object
  /// yields nothing.
  final List<DropEntry> drops;

  /// Authored container capacity, in slots. The container STATE lives on
  /// `IActorData.inventory` for now; this field sizes it (and will size
  /// storage props when they arrive).
  final int inventorySize;

  double _currentHealth;
  double get currentHealth => _currentHealth;

  /// Virtual so equipment/state can override the cap later (same contract as
  /// the Godot `get_max_health()`).
  double get maxHealth => baseMaxHealth;

  bool get isDead => _currentHealth <= 0;

  void takeDamage(double amount) {
    assert(amount >= 0, '[$runtimeType($id)] negative damage: $amount');
    _currentHealth = (_currentHealth - amount).clamp(0.0, maxHealth);
  }

  void heal(double amount) {
    assert(amount >= 0, '[$runtimeType($id)] negative heal: $amount');
    _currentHealth = (_currentHealth + amount).clamp(0.0, maxHealth);
  }

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        'current_health': _currentHealth,
      };

  @override
  IWorldObjectData clone();
}
