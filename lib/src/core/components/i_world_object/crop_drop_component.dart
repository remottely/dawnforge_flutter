import 'package:dawnforge/src/core/components/i_world_object/drop_component.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// The stage half of a crop's loot — the port of `crop_drop_component.gd`,
/// which is four lines for the reason `DropComponent`'s doc gives: a subclass
/// only ever decides WHICH table. The roll is inherited whole.
///
/// It sits BESIDE the plain [DropComponent] on the same host, never instead
/// of it: the pack authors a crop's loot as two halves that ADD (a fruit
/// tree's `drops` is its logs, its stage table is its fruit and its seed),
/// and `PropCrop.dropLoot` rolls both. The spec's `DropTableHelper` keeps the
/// same split, and its `L-217` is the entry that records what happened when
/// one component rolled both halves.
///
/// PORT DELTA — no `crop_data_ref`. The spec stores a second reference to the
/// crop data on the component; here the soul is read through the container
/// like every other component reads it (rule 8: one home, no copies).
final class CropDropComponent extends DropComponent {
  CropDropComponent(super.random);

  PropCropData get cropData => data as PropCropData;

  @override
  void onAttach() {
    assert(
      data is PropCropData,
      '[CropDropComponent] requires PropCropData, got ${data.runtimeType}',
    );
  }

  @override
  List<DropEntry> get activeDropEntries =>
      cropData.stageEntries(cropData.currentStage);
}
