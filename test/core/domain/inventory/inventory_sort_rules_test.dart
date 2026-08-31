import 'package:dawnforge/src/core/domain/inventory/inventory_sort_rules.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:flutter_test/flutter_test.dart';

ItemData _item(String id, {ToolType? toolType, int tier = 1}) =>
    ItemData(id: id, toolType: toolType, tier: tier);

ItemBuildableData _buildable(String id) =>
    ItemBuildableData(id: id, blueprintId: 't1_prop_workstation_smelter');

void main() {
  group('InventorySortRules', () {
    group('the category ladder', () {
      test('the seven steps keep the spec numbers, live subject or not', () {
        // Four of them have no class in this port yet. Their numbers are held
        // so no family renumbers on arrival, and so the two engines answer
        // "which drawer" with the same integer.
        expect(InventorySortRules.categoryTool, 0);
        expect(InventorySortRules.categoryArmor, 1);
        expect(InventorySortRules.categoryConsumable, 2);
        expect(InventorySortRules.categoryBuildable, 3);
        expect(InventorySortRules.categoryCosmetic, 4);
        expect(InventorySortRules.categoryProjectile, 5);
        expect(InventorySortRules.categoryMaterial, 6);
      });

      test('the three that DO have a subject each find their drawer', () {
        expect(
          InventorySortRules.categoryRank(
            _item('t1_item_tool_melee_hand', toolType: ToolType.innate),
          ),
          InventorySortRules.categoryTool,
        );
        expect(
          InventorySortRules.categoryRank(
            _buildable('t1_item_buildable_workstation_smelter'),
          ),
          InventorySortRules.categoryBuildable,
        );
        expect(
          InventorySortRules.categoryRank(_item('t1_item_logs_palm')),
          InventorySortRules.categoryMaterial,
        );
      });

      test('an unported family falls to MATERIAL, and that is honest', () {
        // The pack authors these with a `type` of their own
        // (`item_consumable_data`, `item_projectile_data`), and `ItemRegistry`
        // reads both back as plain ItemData because the classes do not exist.
        // So the apple ranks beside the ore until `ItemConsumableData` does.
        expect(
          InventorySortRules.categoryRank(
            _item('t1_item_consumable_fruit_apple'),
          ),
          InventorySortRules.categoryMaterial,
        );
        expect(
          InventorySortRules.categoryRank(
            _item('t1_item_projectile_spell_vinewhip'),
          ),
          InventorySortRules.categoryMaterial,
        );
      });

      test('tools sort above what you build, which sorts above the bulk', () {
        final tool = InventorySortRules.categoryRank(
          _item('t1_item_tool_melee_hand', toolType: ToolType.axe),
        );
        final buildable = InventorySortRules.categoryRank(
          _buildable('t1_item_buildable_ground_bridge_palm'),
        );
        final material = InventorySortRules.categoryRank(
          _item('t1_item_stone_moss'),
        );
        expect(tool, lessThan(buildable));
        expect(buildable, lessThan(material));
      });
    });

    group('the tool shelf', () {
      test("the order is the design's, not the enum declaration's", () {
        // ToolType declares shovel first (it mirrors the Godot int values).
        // The shelf leads with the axe, and the table is what decides.
        expect(InventorySortRules.toolTypeRank(ToolType.axe), 0);
        expect(InventorySortRules.toolTypeRank(ToolType.pickaxe), 1);
        expect(InventorySortRules.toolTypeRank(ToolType.shovel), 2);
        expect(InventorySortRules.toolTypeRank(ToolType.hoe), 3);
        expect(InventorySortRules.toolTypeRank(ToolType.sickle), 4);
        expect(InventorySortRules.toolTypeRank(ToolType.sledgehammer), 5);
        expect(InventorySortRules.toolTypeRank(ToolType.wateringCan), 6);
        expect(InventorySortRules.toolTypeRank(ToolType.fishingRod), 7);
        expect(InventorySortRules.toolTypeRank(ToolType.scanner), 8);
        expect(InventorySortRules.toolTypeRank(ToolType.sword), 9);
        expect(InventorySortRules.toolTypeRank(ToolType.bow), 10);
        expect(InventorySortRules.toolTypeRank(ToolType.staff), 11);
        expect(InventorySortRules.toolTypeRank(ToolType.innate), 12);
      });

      test('harvesting leads, and the weapons close the drawer', () {
        expect(
          InventorySortRules.toolTypeRank(ToolType.axe),
          lessThan(InventorySortRules.toolTypeRank(ToolType.sword)),
        );
        expect(
          InventorySortRules.toolTypeRank(ToolType.sword),
          lessThan(InventorySortRules.toolTypeRank(ToolType.bow)),
        );
        expect(
          InventorySortRules.toolTypeRank(ToolType.bow),
          lessThan(InventorySortRules.toolTypeRank(ToolType.staff)),
        );
      });

      test('EVERY ToolType has a place — this is what the throw guards', () {
        // The throw inside toolTypeRank cannot be reached while this passes,
        // and that is the point: the day someone appends a fourteenth kind,
        // this test names the omission before a release build has to.
        for (final toolType in ToolType.values) {
          expect(
            () => InventorySortRules.toolTypeRank(toolType),
            returnsNormally,
            reason: '${toolType.name} has no place in the tool order',
          );
        }
        final ranks = ToolType.values
            .map(InventorySortRules.toolTypeRank)
            .toSet();
        expect(ranks.length, ToolType.values.length,
            reason: 'two tool kinds share one shelf');
      });

      test('a tool reads its shelf; everything else is one flat shelf', () {
        expect(
          InventorySortRules.subcategoryRank(
            _item('t1_item_tool_axe', toolType: ToolType.staff),
          ),
          InventorySortRules.toolTypeRank(ToolType.staff),
        );
        expect(InventorySortRules.subcategoryRank(_item('t1_item_coal')), 0);
        expect(
          InventorySortRules.subcategoryRank(
            _buildable('t1_item_buildable_ground_grass'),
          ),
          0,
        );
      });
    });

    group('tier', () {
      test('negated, so the better thing sorts EARLIER', () {
        final t1 = InventorySortRules.tierRank(_item('t1_item_logs_palm'));
        final t2 = InventorySortRules.tierRank(
          _item('t2_item_logs_willow', tier: 2),
        );
        expect(t1, -1);
        expect(t2, -2);
        expect(t2, lessThan(t1));
      });
    });
  });
}
