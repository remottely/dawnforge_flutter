import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.4(b), the crop half: a prop that has a life reads its stages and its
/// per-stage tables, and knows which stage it is at.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  Map<String, Object?> palmJson() => <String, Object?>{
        'type': 'prop_crop_data',
        'id': 't1_prop_crop_tree_palm',
        'peak_stage': 'BUDDING',
        'is_immortal': true,
        'is_waterable': false,
        'is_hand_harvestable': false,
        'has_ground_stage': false,
        'hides_actors_at_stage': 2,
        'stage_drop_configs': <String, Object?>{
          'PLANTED': <Map<String, Object?>>[
            <String, Object?>{
              'item_id': 't1_item_buildable_seed_tree_palm',
              'chance': 0.25,
              'min_amount': 1,
              'max_amount': 1,
            },
          ],
          'BUDDING': <Map<String, Object?>>[
            <String, Object?>{
              'item_id': 't1_item_buildable_seed_tree_palm',
              'chance': 0.5,
              'min_amount': 1,
              'max_amount': 1,
            },
            <String, Object?>{
              'item_id': 't1_item_logs_palm',
              'chance': 1.0,
              'min_amount': 1,
              'max_amount': 1,
            },
          ],
        },
      };

  test('the registry routes the pack type', () {
    locator<PropRegistry>().registerJson(palmJson());
    final prop = locator<PropRegistry>().getProp('t1_prop_crop_tree_palm');
    expect(prop, isA<PropCropData>());
  });

  test('reads the life and the tables, keyed by stage name', () {
    final palm = PropCropData.fromJson(palmJson());
    expect(palm.peakStage, CropStage.budding);
    expect(palm.isImmortal, isTrue);
    expect(palm.hidesActorsAtStage, CropStage.budding,
        reason: 'an int index is accepted too, as every enum here does');
    expect(palm.realStageCount, 3);
    expect(palm.stageEntries(CropStage.budding).map((e) => e.itemId),
        <String>['t1_item_buildable_seed_tree_palm', 't1_item_logs_palm']);
    expect(palm.stageEntries(CropStage.sprout), isEmpty,
        reason: 'a stage the pack wrote no table for gives nothing — it '
            'does NOT fall back to drops');
  });

  test('a fresh crop is planted, and can be put anywhere up to its peak', () {
    final palm = PropCropData.fromJson(palmJson());
    expect(palm.currentStage, CropStage.planted);
    palm.setStage(CropStage.budding);
    expect(palm.currentStage, CropStage.budding);
    expect(
      () => palm.setStage(CropStage.flowering),
      throwsA(isA<AssertionError>()),
      reason: 'past the peak is not a stage this crop has',
    );
  });

  test('a clone carries the stage and owns its tables', () {
    final palm = PropCropData.fromJson(palmJson())..setStage(CropStage.sprout);
    final copy = palm.clone();
    expect(copy.currentStage, CropStage.sprout);
    expect(
      identical(
        copy.stageDropConfigs[CropStage.budding],
        palm.stageDropConfigs[CropStage.budding],
      ),
      isFalse,
    );
    expect(copy.serialize()['current_stage'], CropStage.sprout.index);
  });

  test('a stage name the enum does not know crashes at read', () {
    final json = palmJson();
    json['stage_drop_configs'] = <String, Object?>{
      'RIPE': <Map<String, Object?>>[],
    };
    expect(() => PropCropData.fromJson(json), throwsA(isA<Error>()));
  });

  test("the spec's two constructor throws are asserts here", () {
    expect(
      () => PropCropData.fromJson(<String, Object?>{
        'type': 'prop_crop_data',
        'id': 't1_prop_crop_probe',
        'days_to_die_if_unharvested': 0,
        'is_immortal': false,
      }),
      throwsA(isA<AssertionError>()),
      reason: 'a mortal crop with no countdown dies the day it peaks',
    );
    expect(
      () => PropCropData.fromJson(<String, Object?>{
        'type': 'prop_crop_data',
        'id': 't1_prop_crop_probe',
        'is_recurrent': true,
        'peak_stage': 'FLOWERING',
        'recurrent_return_stage': 'FLOWERING',
      }),
      throwsA(isA<AssertionError>()),
      reason: 'a recurrent crop that returns AT its peak never leaves it',
    );
  });
}
