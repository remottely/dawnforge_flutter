import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/components/i_world_object/crop_drop_component.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// A prop with a life — the host half of `prop_crop.gd`, FP4.4's minimal
/// core. Created only by `PropFactory.create()` (rule 1), which routes here
/// when the registry hands it [PropCropData].
///
/// What the host adds over a plain [Prop] is the second loot half and the
/// one verb this slice needs, [setGrowthStage]. Growth over days, watering,
/// the death countdown, the hand harvest and the soil left behind are the
/// rest of FP4.4 and arrive with the time system.
final class PropCrop extends Prop {
  PropCrop(super.random);

  /// Typed view over the injected soul.
  PropCropData get cropData => data as PropCropData;

  late final CropDropComponent cropDrop;

  @override
  void setupComponents() {
    super.setupComponents();
    // The same roll stream as the plain half, so which entries a felled palm
    // yields is one sequence from one seed, not two streams that happen to
    // agree today.
    cropDrop = addComponent(CropDropComponent(random));
  }

  /// Puts the crop at [stage] — how a wild crop surfaces already grown.
  void setGrowthStage(CropStage stage) => cropData.setStage(stage);

  /// Both halves, plain first: the logs every stage gives, then what this
  /// stage adds.
  @override
  void dropLoot(WorldPos center) {
    super.dropLoot(center);
    cropDrop.dropItems(center);
  }
}
