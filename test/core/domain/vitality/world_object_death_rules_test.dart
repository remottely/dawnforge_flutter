import 'package:dawnforge/src/core/domain/vitality/world_object_death_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a: the two halves of every tool gate, and the pack fields they read.
void main() {
  test('the right KIND of tool, and an empty list refusing everything', () {
    const allowed = <ToolType>[ToolType.axe, ToolType.sickle];

    expect(WorldObjectDeathRules.hasAllowedTool(ToolType.axe, allowed), isTrue);
    expect(
      WorldObjectDeathRules.hasAllowedTool(ToolType.pickaxe, allowed),
      isFalse,
    );

    // An authored refusal, not a missing value. Reading an empty list as
    // "anything goes" would mean omitting the field opened every object in
    // the pack at once.
    expect(
      WorldObjectDeathRules.hasAllowedTool(ToolType.axe, const <ToolType>[]),
      isFalse,
    );

    // Nothing in hand that IS a tool matches nothing, for the same reason.
    expect(WorldObjectDeathRules.hasAllowedTool(null, allowed), isFalse);
  });

  test('good ENOUGH runs one way only', () {
    expect(WorldObjectDeathRules.meetsTierRequirement(2, 1), isTrue);
    expect(WorldObjectDeathRules.meetsTierRequirement(1, 1), isTrue,
        reason: 'equal tiers meet the bar — it is >=, not >');
    expect(WorldObjectDeathRules.meetsTierRequirement(1, 2), isFalse);
  });

  group('the pack feeds both halves', () {
    setUp(registerCoreSystems);
    tearDown(resetCoreSystems);

    test('an authored tool and an authored target answer each other', () {
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'id': 't1_item_probe_axe',
        'tool_type': 'AXE',
        'tier': 2,
      });
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'id': 't1_item_probe_plank',
        'tier': 1,
      });
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_probe_tree',
        'allowed_tools': <String>['AXE', 'SICKLE'],
        'tier': 1,
      });

      final axe = locator<ItemRegistry>().getItem('t1_item_probe_axe');
      final plank = locator<ItemRegistry>().getItem('t1_item_probe_plank');
      final tree = locator<PropRegistry>().getProp('t1_prop_probe_tree');

      // Enum names arrive as the pack writes them, folded case-insensitively.
      expect(axe.toolType, ToolType.axe);
      expect(tree.allowedTools, <ToolType>[ToolType.axe, ToolType.sickle]);

      expect(
        WorldObjectDeathRules.hasAllowedTool(axe.toolType, tree.allowedTools),
        isTrue,
      );
      expect(
        WorldObjectDeathRules.meetsTierRequirement(axe.tier, tree.tier),
        isTrue,
      );

      // A plank is not a tool. Null is the honest answer, and it fails the
      // kind gate rather than sneaking through some default.
      expect(plank.toolType, isNull);
      expect(
        WorldObjectDeathRules.hasAllowedTool(plank.toolType, tree.allowedTools),
        isFalse,
      );
    });

    test('the tool fields survive the clone every instance gets', () {
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_probe_rock',
        'allowed_tools': <String>['PICKAXE'],
        'tier': 3,
      });
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'id': 't1_item_probe_pickaxe',
        'tool_type': 'PICKAXE',
        'tier': 3,
        'attack_damage': 1.5,
      });
      // Rule 3: a host is initialized with a CLONE, so a field the clone drops
      // is a field the running game does not have — invisible in the registry.
      final cloned = locator<PropRegistry>().getProp('t1_prop_probe_rock').clone();
      expect(cloned.tier, 3);
      expect(cloned.allowedTools, <ToolType>[ToolType.pickaxe]);

      final clonedTool =
          locator<ItemRegistry>().getItem('t1_item_probe_pickaxe').clone();
      expect(clonedTool.toolType, ToolType.pickaxe);
      expect(clonedTool.attackDamage, 1.5,
          reason: 'a swing that lost its damage on the way to the world '
              'would still look correct in the registry');
    });
  });
}
