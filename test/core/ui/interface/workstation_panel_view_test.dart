import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/props/prop_workstation.dart';
import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/managers/ui_state_machine.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/ui/interface/workstation_panel_view.dart';
import 'package:dawnforge/src/core/ui/widgets/panel_button.dart';
import 'package:dawnforge/src/core/ui/widgets/recipe_slot_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(f): the bench, open. What cannot be checked by looking at it is that
/// the panel never decides anything the station owns — it asks, and draws the
/// answer — and that which view is on screen is DERIVED from the machine
/// rather than remembered.
void main() {
  const sheet = 'res://data/forge_almanac/01_biomes/t1/items/sprites/'
      't1_item_coal.png';

  setUp(() {
    registerCoreSystems();
    locator<LocalizationSystem>().loadLocale('en', <String, Object?>{
      'strings': <String, Object?>{
        'ui.workstation.select_recipe': 'Pick something to make',
        'ui.workstation.requires': 'You need:',
        'ui.workstation.ingredient_have_need': '{have} of {need} {item}',
        'ui.workstation.output_format': 'Makes {amount} {item}',
        'ui.workstation.time_seconds': 'Takes {seconds} seconds',
        'ui.workstation.quantity': 'How many:',
        'ui.workstation.max': 'All',
        'ui.workstation.start_production': 'Make it',
        'ui.workstation.cancel': 'Stop',
        'ui.workstation.producing': 'Making {item}',
        'ui.workstation.producing_progress':
            'Making {item}: {current} of {total}',
        'item.ore.name': 'Copper ore',
        'item.coal.name': 'Coal',
        'item.bar.name': 'Copper bar',
        'item.ingot.name': 'Copper ingot',
        'prop.smelter.name': 'Smelter',
      },
    });

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_ore_copper',
        'max_stack': 100,
        'spritesheet': sheet,
        'display_name_key': 'item.ore.name',
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_coal',
        'max_stack': 100,
        'spritesheet': sheet,
        'display_name_key': 'item.coal.name',
      })
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_bar_copper',
        'max_stack': 100,
        'spritesheet': sheet,
        'display_name_key': 'item.bar.name',
        'crafted_at': 'SMELTER',
        'craft_time': 2.0,
        'craft_amount': 1,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_ore_copper', 'amount': 5},
          <String, Object?>{'id': 't1_item_coal', 'amount': 1},
        ],
      })
      // A second SMELTER recipe, so the grid has more than one thing in it.
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_ingot_copper',
        'max_stack': 100,
        'spritesheet': sheet,
        'display_name_key': 'item.ingot.name',
        'crafted_at': 'SMELTER',
        'craft_time': 1.0,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_coal', 'amount': 50},
        ],
      })
      // A WORKSHOP recipe, which this bench must never offer.
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_plank',
        'spritesheet': sheet,
        'display_name_key': 'item.coal.name',
        'crafted_at': 'WORKSHOP',
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_coal', 'amount': 1},
        ],
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'display_name_key': 'item.coal.name',
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
    });
    locator<PropRegistry>().registerJson(<String, Object?>{
      'type': 'prop_workstation_data',
      'id': 't1_prop_workstation_smelter',
      'display_name_key': 'prop.smelter.name',
      'workstation_type': 'SMELTER',
      'production_speed_multiplier': 2.0,
      'grid_size': <int>[2, 1],
      'base_max_health': 10,
    });

    final grid = locator<GridManager>();
    for (var x = -4; x <= 8; x++) {
      for (var y = -4; y <= 8; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  PropWorkstation smelter() => PropFactory.create(
        't1_prop_workstation_smelter',
        locator<GridManager>().gridToWorld(const GridPos(3, 3)),
        random: Random(20260910),
      ) as PropWorkstation;

  /// A player holding [ore] ore and [coal] coal.
  InventoryComponent bagWith({required int ore, required int coal}) {
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    final items = locator<ItemRegistry>();
    if (ore > 0) {
      player.inventory.setSlot(0, items.getItem('t1_item_ore_copper'), ore);
    }
    if (coal > 0) {
      player.inventory.setSlot(1, items.getItem('t1_item_coal'), coal);
    }
    return player.inventory;
  }

  var closed = 0;

  Future<void> pump(
    WidgetTester tester,
    PropWorkstation station,
    InventoryComponent inventory,
  ) async {
    closed = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WorkstationPanelView(
          station: station.workstation,
          inventory: inventory,
          title: station.workstationData.displayName,
          onClose: () => closed++,
        ),
      ),
    );
  }

  WorkstationPanelViewState stateOf(WidgetTester tester) =>
      tester.state(find.byType(WorkstationPanelView));

  Future<void> tapLabel(WidgetTester tester, String label) async {
    await tester.tap(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(PanelButton),
      ),
    );
    await tester.pump();
  }

  bool isEnabled(WidgetTester tester, String label) => tester
      .widget<PanelButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(PanelButton),
        ),
      )
      .isEnabled;

  testWidgets('opening registers on both stacks; closing clears both',
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));

    final ui = locator<UIStateMachine>();
    expect(ui.state, UIState.menu);
    expect(ui.isHudVisible, isFalse);
    // Rule 30: the player is stopped from ACTING, the world keeps running.
    expect(locator<GameInputManager>().isGameplayEnabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(ui.state, UIState.gameplay);
    expect(locator<GameInputManager>().isGameplayEnabled, isTrue,
        reason: 'a surface that leaves owes its blocker back');
  });

  testWidgets('the world behind it is live, not a snapshot', (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));

    // Rule 30's visible half. A captured image would be a lie about a
    // simulation that never stopped.
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets("the grid offers this station's recipes and no others",
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));

    // Two SMELTER recipes; the WORKSHOP plank is not this bench's business.
    expect(find.byType(RecipeSlotView), findsNWidgets(2));
    expect(find.text('Copper bar'), findsOneWidget);
    expect(find.text('Copper ingot'), findsOneWidget);
  });

  testWidgets("the title is the station's own name, translated",
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));

    expect(find.text('Smelter'), findsOneWidget);
  });

  testWidgets('nothing chosen says so; choosing shows have against need',
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 3, coal: 10));
    expect(find.text('Pick something to make'), findsOneWidget);

    await tester.tap(find.text('Copper bar'));
    await tester.pump();

    // Three of the five ore, and the coal covered — both numbers said out
    // loud, because a colour alone is not a number a child can read.
    expect(find.text('3 of 5 Copper ore'), findsOneWidget);
    expect(find.text('10 of 1 Coal'), findsOneWidget);
    expect(find.text('Makes 1 Copper bar'), findsOneWidget);
  });

  testWidgets("the time shown is the STATION'S, multiplier and all",
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();

    // 2.0s a bar at a bench that works twice as fast.
    expect(find.text('Takes 1.0 seconds'), findsOneWidget);
  });

  testWidgets('a batch you cannot pay for refuses BEFORE the press',
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 3, coal: 10));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();

    expect(isEnabled(tester, 'Make it'), isFalse,
        reason: 'a disabled button is the refusal, said before it costs '
            'anything');
    await tapLabel(tester, 'Make it');
    expect(stateOf(tester).widget.station.isProducing, isFalse);
  });

  testWidgets('the stepper stops where the bag does', (tester) async {
    // Ten ore and ten coal pays for exactly two bars.
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();

    expect(stateOf(tester).quantity, 1);
    expect(isEnabled(tester, '-'), isFalse, reason: 'one is the floor');

    await tapLabel(tester, '+');
    expect(stateOf(tester).quantity, 2);
    expect(isEnabled(tester, '+'), isFalse, reason: 'two is what ten ore buys');

    await tapLabel(tester, '-');
    expect(stateOf(tester).quantity, 1);
    await tapLabel(tester, 'All');
    expect(stateOf(tester).quantity, 2);
  });

  testWidgets('choosing another recipe starts its count at one',
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 100));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    await tapLabel(tester, '+');
    expect(stateOf(tester).quantity, 2);

    await tester.tap(find.text('Copper ingot'));
    await tester.pump();

    expect(stateOf(tester).selectedRecipe?.id, 't1_item_ingot_copper');
    expect(stateOf(tester).quantity, 1,
        reason: 'a number left over from the last recipe is a number about '
            'something else');
  });

  testWidgets('Make it pays the bag and the panel becomes the progress view',
      (tester) async {
    final station = smelter();
    final bag = bagWith(ore: 10, coal: 10);
    await pump(tester, station, bag);
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    await tapLabel(tester, '+');
    await tapLabel(tester, 'Make it');

    expect(station.workstation.isProducing, isTrue);
    expect(bag.countOf('t1_item_ore_copper'), 0, reason: 'paid up front');
    // Which view is drawn is DERIVED from the machine, never remembered.
    expect(find.byType(RecipeSlotView), findsNothing);
    expect(find.text('Making Copper bar: 1 of 2'), findsOneWidget);
  });

  testWidgets('a batch of one says what, not which of how many',
      (tester) async {
    final station = smelter();
    await pump(tester, station, bagWith(ore: 10, coal: 10));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    await tapLabel(tester, 'Make it');

    expect(find.text('Making Copper bar'), findsOneWidget);
  });

  testWidgets("the bar follows the station's own tick", (tester) async {
    final station = smelter();
    await pump(tester, station, bagWith(ore: 10, coal: 10));
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    await tapLabel(tester, 'Make it');

    // Half a bar's worth of world time at this bench's doubled speed.
    station.workstation.update(0.5);
    await tester.pump();

    final bar = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(bar.widthFactor, closeTo(0.5, 0.001));
  });

  testWidgets('Stop gives the batch back and the grid returns',
      (tester) async {
    final station = smelter();
    final bag = bagWith(ore: 10, coal: 10);
    await pump(tester, station, bag);
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    await tapLabel(tester, 'Make it');
    expect(station.workstation.isProducing, isTrue);

    await tapLabel(tester, 'Stop');

    expect(station.workstation.isProducing, isFalse);
    expect(find.byType(RecipeSlotView), findsNWidgets(2),
        reason: "the view is the machine's answer, so it comes back by "
            'itself');
  });

  testWidgets('the routed back press closes it; an unrouted one never arrives',
      (tester) async {
    await pump(tester, smelter(), bagWith(ore: 10, coal: 10));
    final ui = locator<UIStateMachine>();

    // Rule 25: the machine routes the press to whoever owns the screen.
    expect(ui.requestCancel(), isTrue);
    expect(closed, 1);

    // A cancel aimed at somebody else is somebody else's.
    ui.cancelRequested.emit(Object());
    expect(closed, 1);
  });

  testWidgets('a picked-up ingredient redraws the panel under the player',
      (tester) async {
    final bag = bagWith(ore: 3, coal: 10);
    await pump(tester, smelter(), bag);
    await tester.tap(find.text('Copper bar'));
    await tester.pump();
    expect(isEnabled(tester, 'Make it'), isFalse);

    bag.addItem(locator<ItemRegistry>().getItem('t1_item_ore_copper'), 2);
    await tester.pump();

    expect(find.text('5 of 5 Copper ore'), findsOneWidget);
    expect(isEnabled(tester, 'Make it'), isTrue,
        reason: 'the panel holds the one subscription to the bag');
  });
}
