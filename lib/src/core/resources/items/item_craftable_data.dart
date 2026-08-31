import 'package:dawnforge/src/core/resources/items/item_amount.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// An item with a RECIPE — the Dart port of `ItemCraftableData.cs`.
///
/// It answers three questions about making one: what it costs
/// ([ingredients]), where it is made ([craftedAt]) and how long one batch
/// takes ([craftTime] × [craftAmount]). It does NOT answer whether a
/// particular bag can pay — that needs a container, and a resource that reads
/// containers is a resource that cannot be tested on its own. Those live in
/// `CraftingRules`.
///
/// The pack has authored all four fields on every craftable since the import,
/// and the pipeline has been emitting them into the JSON the whole time; this
/// is the first class to read them.
///
/// **This is the link `ItemBuildableData` was promised at 0.35.0.** The spec
/// reads `ItemBuildableData : IItemActionData : ItemCraftableData : ItemData`,
/// and that note recorded both middle links as missing. One is filled here;
/// `IItemActionData`'s reach was lifted onto [ItemData] at 0.27.0 and stays
/// there, so a blueprint now extends this and inherits a recipe — which is
/// exactly what the smelter blueprint authors (5 logs, 5 copper ore, 5 coal,
/// `crafted_at: NONE`).
class ItemCraftableData extends ItemData {
  ItemCraftableData({
    required super.id,
    this.ingredients = const <ItemAmount>[],
    this.craftedAt = WorkstationType.none,
    this.craftTime = 1.0,
    this.craftAmount = 1,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.tier,
    super.groups,
    super.materialType,
    super.maxStack,
    super.spriteScale,
    super.magnetSpeed,
    super.pickupDelay,
    super.toolType,
    super.attackDamage,
    super.actionRange,
  }) {
    _validate();
  }

  ItemCraftableData.fromReader(super.reader)
      : ingredients = reader
            .objectListOr('ingredients')
            .map(ItemAmount.fromJson)
            .toList(),
        craftedAt = reader.enumOr(
          'crafted_at',
          WorkstationType.values,
          WorkstationType.none,
        ),
        craftTime = reader.doubleOr('craft_time', 1),
        craftAmount = reader.intOr('craft_amount', 1),
        super.fromReader() {
    _validate();
  }

  factory ItemCraftableData.fromJson(Map<String, Object?> json) =>
      ItemCraftableData.fromReader(JsonReader(json, 'ItemCraftableData'));

  void _validate() {
    // An empty ingredient list is a real authored state and not a hole: it
    // says this item is not made, it is found. The two numbers only have to
    // mean anything when there IS a recipe, which is why they are asserted
    // under that condition and not above it — the spec's own `validate()`
    // draws the line in the same place.
    if (ingredients.isEmpty) return;
    assert(craftTime > 0, '[$runtimeType($id)] craft_time must be > 0');
    assert(craftAmount > 0, '[$runtimeType($id)] craft_amount must be > 0');
  }

  /// What one batch costs. Empty when this item is not craftable at all.
  final List<ItemAmount> ingredients;

  /// Where it is made. [WorkstationType.none] means BY HAND — an authored
  /// answer, not an absent one.
  final WorkstationType craftedAt;

  /// Seconds one unit takes.
  final double craftTime;

  /// How many come out of one batch.
  final int craftAmount;

  /// Whether this item can be made at all.
  ///
  /// PORT DELTA: the spec also re-checks that every ingredient `is_valid()`,
  /// because there an `ItemAmount` can be constructed empty from the
  /// inspector. Here the constructor asserts both of its fields, so an
  /// ingredient that exists is a valid one and the second half of that test
  /// has nothing left to catch (*data that exists is valid data*).
  bool get isCraftable => ingredients.isNotEmpty;

  @override
  ItemCraftableData clone() => ItemCraftableData(
        id: id,
        // The entries are immutable, so the copy that matters is the LIST —
        // an instance must never share the container its recipe lives in.
        ingredients: List<ItemAmount>.of(ingredients),
        craftedAt: craftedAt,
        craftTime: craftTime,
        craftAmount: craftAmount,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        tier: tier,
        groups: List<String>.of(groups),
        materialType: materialType,
        maxStack: maxStack,
        spriteScale: spriteScale,
        magnetSpeed: magnetSpeed,
        pickupDelay: pickupDelay,
        toolType: toolType,
        attackDamage: attackDamage,
        actionRange: actionRange,
      );
}
